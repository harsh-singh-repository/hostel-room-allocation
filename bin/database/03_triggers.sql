-- =====================================================================
--  Hostel Room Allocation System
--  03_triggers.sql  -  integrity rules, occupancy counter and audit log
--  Run as user HOSTEL after 02_package.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Before a bed is allotted: room must be active, not full, and the
--    block gender must match the student's gender.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_alloc_validate
BEFORE INSERT ON allocations
FOR EACH ROW
DECLARE
  v_capacity  rooms.capacity%TYPE;
  v_occupied  rooms.occupied%TYPE;
  v_status    rooms.status%TYPE;
  v_bgender   hostel_blocks.gender%TYPE;
  v_sgender   users.gender%TYPE;
BEGIN
  SELECT r.capacity, r.occupied, r.status, b.gender
    INTO v_capacity, v_occupied, v_status, v_bgender
    FROM rooms r
    JOIN hostel_blocks b ON b.block_id = r.block_id
   WHERE r.room_id = :NEW.room_id;

  SELECT gender INTO v_sgender FROM users WHERE user_id = :NEW.student_id;

  IF v_status <> 'ACTIVE' THEN
    RAISE_APPLICATION_ERROR(-20011, 'Room is under maintenance and cannot be allotted.');
  END IF;

  IF v_occupied >= v_capacity THEN
    RAISE_APPLICATION_ERROR(-20010, 'Room is already full.');
  END IF;

  IF v_bgender <> v_sgender THEN
    RAISE_APPLICATION_ERROR(-20004, 'Block gender does not match the student.');
  END IF;

  :NEW.status     := 'ACTIVE';
  :NEW.alloc_date := NVL(:NEW.alloc_date, SYSDATE);
END;
/

-- ---------------------------------------------------------------------
-- 2. Keep ROOMS.occupied in sync and write every change to the audit log.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_alloc_occupancy
AFTER INSERT OR UPDATE OF status ON allocations
FOR EACH ROW
BEGIN
  IF INSERTING AND :NEW.status = 'ACTIVE' THEN
    UPDATE rooms SET occupied = occupied + 1 WHERE room_id = :NEW.room_id;

    INSERT INTO allocation_log (alloc_id, student_id, room_id, action, details)
    VALUES (:NEW.alloc_id, :NEW.student_id, :NEW.room_id, 'ALLOTTED',
            'Bed allotted from application #' || :NEW.app_id);

  ELSIF UPDATING AND :OLD.status = 'ACTIVE' AND :NEW.status = 'VACATED' THEN
    UPDATE rooms SET occupied = occupied - 1 WHERE room_id = :OLD.room_id;

    INSERT INTO allocation_log (alloc_id, student_id, room_id, action, details)
    VALUES (:OLD.alloc_id, :OLD.student_id, :OLD.room_id, 'VACATED',
            'Bed released on ' || TO_CHAR(SYSDATE, 'DD-Mon-YYYY'));
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- 3. An occupied room cannot be sent for maintenance.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_room_status
BEFORE UPDATE OF status ON rooms
FOR EACH ROW
BEGIN
  IF :NEW.status = 'MAINTENANCE' AND :NEW.occupied > 0 THEN
    RAISE_APPLICATION_ERROR(-20013,
      'Room ' || :NEW.room_no || ' has ' || :NEW.occupied ||
      ' resident(s). Vacate them before marking it for maintenance.');
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- 4. Stamp the decision date whenever an application is decided.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_app_decided
BEFORE UPDATE OF status ON applications
FOR EACH ROW
BEGIN
  IF :NEW.status <> :OLD.status
     AND :NEW.status IN ('ALLOTTED', 'REJECTED', 'CANCELLED', 'WAITLISTED') THEN
    :NEW.decided_on := SYSDATE;
  END IF;
END;
/

-- ---------------------------------------------------------------------
-- 5. Log every fee payment in the audit trail.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_fee_log
AFTER INSERT ON fee_payments
FOR EACH ROW
DECLARE
  v_student allocations.student_id%TYPE;
  v_room    allocations.room_id%TYPE;
BEGIN
  SELECT student_id, room_id INTO v_student, v_room
    FROM allocations WHERE alloc_id = :NEW.alloc_id;

  INSERT INTO allocation_log (alloc_id, student_id, room_id, action, details)
  VALUES (:NEW.alloc_id, v_student, v_room, 'FEE_PAID',
          'Rs. ' || :NEW.amount || ' via ' || :NEW.pay_mode || ' (' || :NEW.txn_ref || ')');
END;
/

SHOW ERRORS;

-- Recompile the package in case it was created before the triggers
ALTER PACKAGE hostel_pkg COMPILE;
