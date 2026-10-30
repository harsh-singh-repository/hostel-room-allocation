-- =====================================================================
--  Hostel Room Allocation System
--  02_package.sql  -  HOSTEL_PKG: all business logic lives here
--  Run as user HOSTEL after 01_schema.sql.
--
--  Custom error codes raised with RAISE_APPLICATION_ERROR
--  (the Java layer shows the message text to the user):
--    -20001  no vacant bed for the requested change
--    -20002  student already has an active room
--    -20003  student already has an open application
--    -20004  block / student gender mismatch
--    -20005  invalid login
--    -20006  email already registered
--    -20007  application not in an allocatable state
--    -20008  no active allocation
--    -20009  invalid payment amount
--    -20010  room is full                      (trigger)
--    -20011  room is under maintenance         (trigger)
--    -20012  request already pending
--    -20013  occupied room cannot go to maintenance (trigger)
--    -20014  roll number already registered
--    -20015  only students can apply
--    -20016  block not found
--    -20017  new room type missing for change request
--    -20018  request already processed
--    -20019  duplicate room number
--    -20020  weak password
-- =====================================================================

CREATE OR REPLACE PACKAGE hostel_pkg AS

  -- ---------- functions ----------
  FUNCTION hash_pwd (p_plain IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION calc_fee (p_room_type IN VARCHAR2) RETURN NUMBER;   -- fee per semester
  FUNCTION fee_due  (p_alloc_id IN NUMBER) RETURN NUMBER;

  -- ---------- authentication ----------
  PROCEDURE login (p_email    IN  VARCHAR2,
                   p_password IN  VARCHAR2,
                   o_user_id  OUT NUMBER,
                   o_role     OUT VARCHAR2,
                   o_name     OUT VARCHAR2);

  PROCEDURE register_student (p_name     IN  VARCHAR2,
                              p_email    IN  VARCHAR2,
                              p_password IN  VARCHAR2,
                              p_gender   IN  CHAR,
                              p_phone    IN  VARCHAR2,
                              p_roll     IN  VARCHAR2,
                              p_course   IN  VARCHAR2,
                              p_year     IN  NUMBER,
                              o_user_id  OUT NUMBER);

  -- ---------- applications & allocation ----------
  PROCEDURE apply_room (p_student_id IN  NUMBER,
                        p_block_id   IN  NUMBER,
                        p_type       IN  VARCHAR2,
                        o_app_id     OUT NUMBER);

  PROCEDURE cancel_application (p_app_id IN NUMBER, p_student_id IN NUMBER);

  PROCEDURE allocate_room (p_app_id  IN  NUMBER,
                           o_room_id OUT NUMBER,
                           o_status  OUT VARCHAR2);

  PROCEDURE auto_allocate_all (o_allotted   OUT NUMBER,
                               o_waitlisted OUT NUMBER);

  PROCEDURE reject_application (p_app_id IN NUMBER, p_remarks IN VARCHAR2);

  -- ---------- fees ----------
  PROCEDURE pay_fee (p_alloc_id IN  NUMBER,
                     p_amount   IN  NUMBER,
                     p_mode     IN  VARCHAR2,
                     o_pay_id   OUT NUMBER,
                     o_txn_ref  OUT VARCHAR2);

  -- ---------- vacate / change requests ----------
  PROCEDURE vacate_room (p_student_id IN NUMBER, o_next_app OUT NUMBER);

  PROCEDURE raise_request (p_student_id IN  NUMBER,
                           p_type       IN  VARCHAR2,
                           p_new_type   IN  VARCHAR2,
                           p_reason     IN  VARCHAR2,
                           o_req_id     OUT NUMBER);

  PROCEDURE process_request (p_req_id  IN NUMBER,
                             p_approve IN CHAR,
                             p_note    IN VARCHAR2);

  -- ---------- room management ----------
  PROCEDURE add_room (p_block_id IN  NUMBER,
                      p_room_no  IN  VARCHAR2,
                      p_floor    IN  NUMBER,
                      p_type     IN  VARCHAR2,
                      o_room_id  OUT NUMBER);

END hostel_pkg;
/

CREATE OR REPLACE PACKAGE BODY hostel_pkg AS

  c_fee_single CONSTANT NUMBER := 45000;
  c_fee_double CONSTANT NUMBER := 35000;
  c_fee_triple CONSTANT NUMBER := 28000;
  c_pepper     CONSTANT VARCHAR2(10) := 'HRAS#';

  -- =================================================================
  --  FUNCTIONS
  -- =================================================================
  FUNCTION hash_pwd (p_plain IN VARCHAR2) RETURN VARCHAR2 IS
    v_hash VARCHAR2(64);
  BEGIN
    -- STANDARD_HASH is SQL-only, so we call it through DUAL
    SELECT LOWER(RAWTOHEX(STANDARD_HASH(c_pepper || p_plain, 'SHA256')))
      INTO v_hash
      FROM dual;
    RETURN v_hash;
  END hash_pwd;

  FUNCTION calc_fee (p_room_type IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN CASE UPPER(p_room_type)
             WHEN 'SINGLE' THEN c_fee_single
             WHEN 'DOUBLE' THEN c_fee_double
             WHEN 'TRIPLE' THEN c_fee_triple
             ELSE 0
           END;
  END calc_fee;

  FUNCTION fee_due (p_alloc_id IN NUMBER) RETURN NUMBER IS
    v_type rooms.room_type%TYPE;
    v_paid NUMBER;
  BEGIN
    SELECT r.room_type
      INTO v_type
      FROM allocations a
      JOIN rooms r ON r.room_id = a.room_id
     WHERE a.alloc_id = p_alloc_id;

    SELECT NVL(SUM(amount), 0)
      INTO v_paid
      FROM fee_payments
     WHERE alloc_id = p_alloc_id;

    RETURN GREATEST(calc_fee(v_type) - v_paid, 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
  END fee_due;

  -- =================================================================
  --  PRIVATE HELPERS (no COMMIT - the caller controls the transaction)
  -- =================================================================

  -- Core allocation logic. Finds a free bed and creates an allocation,
  -- otherwise marks the application WAITLISTED.
  PROCEDURE do_allocate (p_app_id  IN  NUMBER,
                         o_room_id OUT NUMBER,
                         o_status  OUT VARCHAR2) IS
    v_app     applications%ROWTYPE;
    v_gender  users.gender%TYPE;
    v_active  NUMBER;
    v_room_no rooms.room_no%TYPE;
    v_block   hostel_blocks.block_name%TYPE;

    -- Same-gender block, requested room type, free bed, preferred block first,
    -- then partially-filled rooms first (keeps empty rooms free).
    CURSOR c_free_room (cp_gender CHAR, cp_type VARCHAR2, cp_block NUMBER) IS
      SELECT r.room_id, r.room_no, b.block_name
        FROM rooms r
        JOIN hostel_blocks b ON b.block_id = r.block_id
       WHERE b.gender    = cp_gender
         AND r.room_type = cp_type
         AND r.status    = 'ACTIVE'
         AND r.occupied  < r.capacity
       ORDER BY CASE WHEN r.block_id = cp_block THEN 0 ELSE 1 END,
                r.occupied DESC,
                r.room_id
         FOR UPDATE OF r.occupied SKIP LOCKED;
  BEGIN
    o_room_id := NULL;

    BEGIN
      SELECT * INTO v_app FROM applications WHERE app_id = p_app_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'Application #' || p_app_id || ' was not found.');
    END;

    IF v_app.status NOT IN ('PENDING', 'WAITLISTED') THEN
      RAISE_APPLICATION_ERROR(-20007,
        'Application #' || p_app_id || ' is already ' || LOWER(v_app.status) || '.');
    END IF;

    SELECT COUNT(*) INTO v_active
      FROM allocations
     WHERE student_id = v_app.student_id AND status = 'ACTIVE';
    IF v_active > 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'This student already has a room allotted.');
    END IF;

    SELECT gender INTO v_gender FROM users WHERE user_id = v_app.student_id;

    OPEN c_free_room(v_gender, v_app.preferred_type, v_app.preferred_block);
    FETCH c_free_room INTO o_room_id, v_room_no, v_block;
    IF c_free_room%NOTFOUND THEN
      o_room_id := NULL;
    END IF;
    CLOSE c_free_room;

    IF o_room_id IS NOT NULL THEN
      -- triggers on ALLOCATIONS update ROOMS.occupied and write the audit log
      INSERT INTO allocations (student_id, room_id, app_id)
      VALUES (v_app.student_id, o_room_id, v_app.app_id);

      UPDATE applications
         SET status  = 'ALLOTTED',
             remarks = 'Allotted room ' || v_room_no || ', ' || v_block
       WHERE app_id = p_app_id;
      o_status := 'ALLOTTED';
    ELSE
      UPDATE applications
         SET status  = 'WAITLISTED',
             remarks = 'No vacant ' || LOWER(v_app.preferred_type) || ' bed right now'
       WHERE app_id = p_app_id;
      o_status := 'WAITLISTED';
    END IF;
  END do_allocate;

  -- Frees the student's bed and hands it to the next waitlisted student
  -- of the same gender who wants the same room type.
  PROCEDURE do_vacate (p_student_id IN NUMBER, o_next_app OUT NUMBER) IS
    v_alloc_id  allocations.alloc_id%TYPE;
    v_type      rooms.room_type%TYPE;
    v_gender    hostel_blocks.gender%TYPE;
    v_room      NUMBER;
    v_status    VARCHAR2(12);
  BEGIN
    o_next_app := NULL;

    BEGIN
      SELECT a.alloc_id, r.room_type, b.gender
        INTO v_alloc_id, v_type, v_gender
        FROM allocations a
        JOIN rooms r         ON r.room_id  = a.room_id
        JOIN hostel_blocks b ON b.block_id = r.block_id
       WHERE a.student_id = p_student_id
         AND a.status     = 'ACTIVE'
         FOR UPDATE OF a.status;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, 'No active room allocation found for this student.');
    END;

    UPDATE allocations
       SET status = 'VACATED', vacate_date = SYSDATE
     WHERE alloc_id = v_alloc_id;          -- trigger decrements ROOMS.occupied

    FOR w IN (SELECT a.app_id
                FROM applications a
                JOIN users u ON u.user_id = a.student_id
               WHERE a.status         = 'WAITLISTED'
                 AND a.preferred_type = v_type
                 AND u.gender         = v_gender
               ORDER BY u.year_of_study DESC NULLS LAST, a.applied_on, a.app_id) LOOP
      do_allocate(w.app_id, v_room, v_status);
      IF v_status = 'ALLOTTED' THEN
        o_next_app := w.app_id;
      END IF;
      EXIT;   -- only the first person in the queue
    END LOOP;
  END do_vacate;

  -- =================================================================
  --  AUTHENTICATION
  -- =================================================================
  PROCEDURE login (p_email    IN  VARCHAR2,
                   p_password IN  VARCHAR2,
                   o_user_id  OUT NUMBER,
                   o_role     OUT VARCHAR2,
                   o_name     OUT VARCHAR2) IS
    v_hash VARCHAR2(64) := hash_pwd(p_password);
  BEGIN
    SELECT user_id, role, full_name
      INTO o_user_id, o_role, o_name
      FROM users
     WHERE email = LOWER(TRIM(p_email))
       AND password_hash = v_hash;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20005, 'Invalid email or password.');
  END login;

  PROCEDURE register_student (p_name     IN  VARCHAR2,
                              p_email    IN  VARCHAR2,
                              p_password IN  VARCHAR2,
                              p_gender   IN  CHAR,
                              p_phone    IN  VARCHAR2,
                              p_roll     IN  VARCHAR2,
                              p_course   IN  VARCHAR2,
                              p_year     IN  NUMBER,
                              o_user_id  OUT NUMBER) IS
    v_hash VARCHAR2(64);
    v_msg  VARCHAR2(4000);
  BEGIN
    IF p_password IS NULL OR LENGTH(p_password) < 6 THEN
      RAISE_APPLICATION_ERROR(-20020, 'Password must be at least 6 characters.');
    END IF;

    v_hash := hash_pwd(p_password);

    INSERT INTO users (full_name, email, password_hash, role, gender,
                       phone, roll_no, course, year_of_study)
    VALUES (TRIM(p_name), LOWER(TRIM(p_email)), v_hash, 'STUDENT', p_gender,
            p_phone, UPPER(TRIM(p_roll)), p_course, p_year)
    RETURNING user_id INTO o_user_id;

    COMMIT;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      v_msg := SQLERRM;
      ROLLBACK;
      IF INSTR(v_msg, 'UQ_USERS_ROLL') > 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'This roll number is already registered.');
      ELSE
        RAISE_APPLICATION_ERROR(-20006, 'This email is already registered.');
      END IF;
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END register_student;

  -- =================================================================
  --  APPLICATIONS & ALLOCATION
  -- =================================================================
  PROCEDURE apply_room (p_student_id IN  NUMBER,
                        p_block_id   IN  NUMBER,
                        p_type       IN  VARCHAR2,
                        o_app_id     OUT NUMBER) IS
    v_cnt     NUMBER;
    v_gender  users.gender%TYPE;
    v_role    users.role%TYPE;
    v_bgender hostel_blocks.gender%TYPE;
  BEGIN
    SELECT gender, role INTO v_gender, v_role FROM users WHERE user_id = p_student_id;
    IF v_role <> 'STUDENT' THEN
      RAISE_APPLICATION_ERROR(-20015, 'Only students can apply for a room.');
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM allocations WHERE student_id = p_student_id AND status = 'ACTIVE';
    IF v_cnt > 0 THEN
      RAISE_APPLICATION_ERROR(-20002, 'You already have a room allotted.');
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM applications
     WHERE student_id = p_student_id AND status IN ('PENDING', 'WAITLISTED');
    IF v_cnt > 0 THEN
      RAISE_APPLICATION_ERROR(-20003, 'You already have an open application.');
    END IF;

    IF p_block_id IS NOT NULL THEN
      BEGIN
        SELECT gender INTO v_bgender FROM hostel_blocks WHERE block_id = p_block_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20016, 'Selected block does not exist.');
      END;
      IF v_bgender <> v_gender THEN
        RAISE_APPLICATION_ERROR(-20004, 'The selected block is not available for your gender.');
      END IF;
    END IF;

    INSERT INTO applications (student_id, preferred_block, preferred_type)
    VALUES (p_student_id, p_block_id, UPPER(p_type))
    RETURNING app_id INTO o_app_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END apply_room;

  PROCEDURE cancel_application (p_app_id IN NUMBER, p_student_id IN NUMBER) IS
  BEGIN
    UPDATE applications
       SET status = 'CANCELLED', remarks = 'Cancelled by student'
     WHERE app_id = p_app_id
       AND student_id = p_student_id
       AND status IN ('PENDING', 'WAITLISTED');

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20007, 'This application can no longer be cancelled.');
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END cancel_application;

  PROCEDURE allocate_room (p_app_id  IN  NUMBER,
                           o_room_id OUT NUMBER,
                           o_status  OUT VARCHAR2) IS
  BEGIN
    do_allocate(p_app_id, o_room_id, o_status);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END allocate_room;

  -- Processes every PENDING / WAITLISTED application.
  -- Priority: senior students first, then first-come-first-served.
  PROCEDURE auto_allocate_all (o_allotted   OUT NUMBER,
                               o_waitlisted OUT NUMBER) IS
    v_room   NUMBER;
    v_status VARCHAR2(12);
  BEGIN
    o_allotted   := 0;
    o_waitlisted := 0;

    FOR rec IN (SELECT a.app_id
                  FROM applications a
                  JOIN users u ON u.user_id = a.student_id
                 WHERE a.status IN ('PENDING', 'WAITLISTED')
                 ORDER BY u.year_of_study DESC NULLS LAST, a.applied_on, a.app_id) LOOP
      SAVEPOINT before_app;
      BEGIN
        do_allocate(rec.app_id, v_room, v_status);
        IF v_status = 'ALLOTTED' THEN
          o_allotted := o_allotted + 1;
        ELSE
          o_waitlisted := o_waitlisted + 1;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO before_app;   -- skip this one, keep the rest
      END;
    END LOOP;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END auto_allocate_all;

  PROCEDURE reject_application (p_app_id IN NUMBER, p_remarks IN VARCHAR2) IS
  BEGIN
    UPDATE applications
       SET status  = 'REJECTED',
           remarks = NVL(p_remarks, 'Rejected by warden')
     WHERE app_id = p_app_id
       AND status IN ('PENDING', 'WAITLISTED');

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20007, 'Only pending or waitlisted applications can be rejected.');
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END reject_application;

  -- =================================================================
  --  FEES
  -- =================================================================
  PROCEDURE pay_fee (p_alloc_id IN  NUMBER,
                     p_amount   IN  NUMBER,
                     p_mode     IN  VARCHAR2,
                     o_pay_id   OUT NUMBER,
                     o_txn_ref  OUT VARCHAR2) IS
    v_status allocations.status%TYPE;
    v_due    NUMBER;
  BEGIN
    BEGIN
      SELECT status INTO v_status FROM allocations WHERE alloc_id = p_alloc_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20008, 'Allocation not found.');
    END;

    IF v_status <> 'ACTIVE' THEN
      RAISE_APPLICATION_ERROR(-20008, 'Fees can only be paid for an active allocation.');
    END IF;

    v_due := fee_due(p_alloc_id);

    IF p_amount IS NULL OR p_amount <= 0 THEN
      RAISE_APPLICATION_ERROR(-20009, 'Amount must be greater than zero.');
    ELSIF v_due = 0 THEN
      RAISE_APPLICATION_ERROR(-20009, 'Your hostel fee is already fully paid.');
    ELSIF p_amount > v_due THEN
      RAISE_APPLICATION_ERROR(-20009, 'Amount exceeds the pending fee of Rs. ' || v_due || '.');
    END IF;

    o_txn_ref := 'HRAS' || TO_CHAR(SYSTIMESTAMP, 'YYMMDDHH24MISSFF2')
                        || LPAD(MOD(p_alloc_id, 1000), 3, '0');

    INSERT INTO fee_payments (alloc_id, amount, pay_mode, txn_ref)
    VALUES (p_alloc_id, p_amount, UPPER(p_mode), o_txn_ref)
    RETURNING pay_id INTO o_pay_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END pay_fee;

  -- =================================================================
  --  VACATE / CHANGE REQUESTS
  -- =================================================================
  PROCEDURE vacate_room (p_student_id IN NUMBER, o_next_app OUT NUMBER) IS
  BEGIN
    do_vacate(p_student_id, o_next_app);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END vacate_room;

  PROCEDURE raise_request (p_student_id IN  NUMBER,
                           p_type       IN  VARCHAR2,
                           p_new_type   IN  VARCHAR2,
                           p_reason     IN  VARCHAR2,
                           o_req_id     OUT NUMBER) IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
      FROM allocations WHERE student_id = p_student_id AND status = 'ACTIVE';
    IF v_cnt = 0 THEN
      RAISE_APPLICATION_ERROR(-20008, 'You need an allotted room before raising a request.');
    END IF;

    SELECT COUNT(*) INTO v_cnt
      FROM room_requests WHERE student_id = p_student_id AND status = 'PENDING';
    IF v_cnt > 0 THEN
      RAISE_APPLICATION_ERROR(-20012, 'You already have a pending request.');
    END IF;

    IF UPPER(p_type) = 'CHANGE' AND p_new_type IS NULL THEN
      RAISE_APPLICATION_ERROR(-20017, 'Choose the room type you want to move to.');
    END IF;

    INSERT INTO room_requests (student_id, req_type, new_type, reason)
    VALUES (p_student_id, UPPER(p_type),
            CASE WHEN UPPER(p_type) = 'CHANGE' THEN UPPER(p_new_type) END,
            p_reason)
    RETURNING req_id INTO o_req_id;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END raise_request;

  PROCEDURE process_request (p_req_id  IN NUMBER,
                             p_approve IN CHAR,
                             p_note    IN VARCHAR2) IS
    v_req    room_requests%ROWTYPE;
    v_next   NUMBER;
    v_block  NUMBER;
    v_app    NUMBER;
    v_room   NUMBER;
    v_status VARCHAR2(12);
  BEGIN
    BEGIN
      SELECT * INTO v_req FROM room_requests WHERE req_id = p_req_id FOR UPDATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20018, 'Request not found.');
    END;

    IF v_req.status <> 'PENDING' THEN
      RAISE_APPLICATION_ERROR(-20018, 'This request has already been processed.');
    END IF;

    IF p_approve = 'Y' THEN
      IF v_req.req_type = 'VACATE' THEN
        do_vacate(v_req.student_id, v_next);
      ELSE
        -- Room change = vacate current bed + new application + allocate.
        -- If no bed of the new type is free, everything is rolled back.
        SELECT r.block_id INTO v_block
          FROM allocations a JOIN rooms r ON r.room_id = a.room_id
         WHERE a.student_id = v_req.student_id AND a.status = 'ACTIVE';

        do_vacate(v_req.student_id, v_next);

        INSERT INTO applications (student_id, preferred_block, preferred_type, remarks)
        VALUES (v_req.student_id, v_block, v_req.new_type,
                'Room change (request #' || p_req_id || ')')
        RETURNING app_id INTO v_app;

        do_allocate(v_app, v_room, v_status);
        IF v_status <> 'ALLOTTED' THEN
          RAISE_APPLICATION_ERROR(-20001,
            'No vacant ' || LOWER(v_req.new_type) || ' bed right now. The request is still pending.');
        END IF;
      END IF;

      UPDATE room_requests
         SET status = 'APPROVED', admin_note = p_note, resolved_at = SYSDATE
       WHERE req_id = p_req_id;
    ELSE
      UPDATE room_requests
         SET status = 'REJECTED', admin_note = p_note, resolved_at = SYSDATE
       WHERE req_id = p_req_id;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END process_request;

  -- =================================================================
  --  ROOM MANAGEMENT
  -- =================================================================
  PROCEDURE add_room (p_block_id IN  NUMBER,
                      p_room_no  IN  VARCHAR2,
                      p_floor    IN  NUMBER,
                      p_type     IN  VARCHAR2,
                      o_room_id  OUT NUMBER) IS
    v_cap NUMBER := CASE UPPER(p_type)
                      WHEN 'SINGLE' THEN 1
                      WHEN 'DOUBLE' THEN 2
                      WHEN 'TRIPLE' THEN 3
                    END;
  BEGIN
    INSERT INTO rooms (block_id, room_no, floor_no, room_type, capacity)
    VALUES (p_block_id, UPPER(TRIM(p_room_no)), NVL(p_floor, 0), UPPER(p_type), v_cap)
    RETURNING room_id INTO o_room_id;
    COMMIT;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20019, 'Room ' || p_room_no || ' already exists in this block.');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END add_room;

END hostel_pkg;
/

SHOW ERRORS PACKAGE hostel_pkg;
SHOW ERRORS PACKAGE BODY hostel_pkg;
