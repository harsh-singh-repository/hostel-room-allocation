-- =====================================================================
--  Hostel Room Allocation System
--  04_seed_data.sql  -  demo data (admin, blocks, rooms, students, ...)
--  Run as user HOSTEL after 03_triggers.sql.
--
--  Logins created:
--    Admin   : admin@hostel.edu     / admin123
--    Students: rahul@student.edu    / student123   (and the others below)
-- =====================================================================
SET SERVEROUTPUT ON;

DECLARE
  TYPE t_blocks IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  v_blocks   t_blocks;
  v_room_id  NUMBER;
  v_uid      NUMBER;
  v_app      NUMBER;
  v_allot    NUMBER;
  v_wait     NUMBER;
  v_alloc    NUMBER;
  v_pay      NUMBER;
  v_txn      VARCHAR2(40);
  v_req      NUMBER;
  v_type     VARCHAR2(10);

  -- helper: student id by email
  FUNCTION sid (p_email VARCHAR2) RETURN NUMBER IS
    v NUMBER;
  BEGIN
    SELECT user_id INTO v FROM users WHERE email = p_email;
    RETURN v;
  END;
BEGIN
  -- ------------------------------ admin -------------------------------
  INSERT INTO users (full_name, email, password_hash, role, gender, phone)
  VALUES ('Chief Warden', 'admin@hostel.edu', hostel_pkg.hash_pwd('admin123'),
          'ADMIN', 'M', '9876500000');

  -- ------------------------------ blocks ------------------------------
  INSERT INTO hostel_blocks (block_name, gender, warden_name, description)
  VALUES ('Aryabhata Block', 'M', 'Mr. R. K. Sharma', 'Boys hostel near the main gate')
  RETURNING block_id INTO v_blocks(1);

  INSERT INTO hostel_blocks (block_name, gender, warden_name, description)
  VALUES ('Bhaskara Block', 'M', 'Mr. S. Gill', 'Boys hostel beside the sports ground')
  RETURNING block_id INTO v_blocks(2);

  INSERT INTO hostel_blocks (block_name, gender, warden_name, description)
  VALUES ('Gargi Block', 'F', 'Mrs. P. Kaur', 'Girls hostel near the library')
  RETURNING block_id INTO v_blocks(3);

  INSERT INTO hostel_blocks (block_name, gender, warden_name, description)
  VALUES ('Kalpana Block', 'F', 'Dr. A. Mehra', 'Girls hostel with study lounge')
  RETURNING block_id INTO v_blocks(4);

  COMMIT;

  -- ------------------------------ rooms -------------------------------
  -- Each block: 2 floors x 5 rooms -> room 1 single, 2-3 double, 4-5 triple
  FOR b IN 1 .. 4 LOOP
    FOR f IN 1 .. 2 LOOP
      FOR r IN 1 .. 5 LOOP
        v_type := CASE WHEN r = 1 THEN 'SINGLE'
                       WHEN r IN (2, 3) THEN 'DOUBLE'
                       ELSE 'TRIPLE' END;
        hostel_pkg.add_room(v_blocks(b), TO_CHAR(f * 100 + r), f, v_type, v_room_id);
      END LOOP;
    END LOOP;
  END LOOP;

  -- one room under maintenance
  UPDATE rooms SET status = 'MAINTENANCE'
   WHERE block_id = v_blocks(2) AND room_no = '205';
  COMMIT;

  -- ----------------------------- students -----------------------------
  hostel_pkg.register_student('Rahul Sharma',   'rahul@student.edu',   'student123', 'M', '9876511111', 'CSE22001', 'B.Tech CSE', 4, v_uid);
  hostel_pkg.register_student('Priya Verma',    'priya@student.edu',   'student123', 'F', '9876522222', 'ECE23014', 'B.Tech ECE', 3, v_uid);
  hostel_pkg.register_student('Aman Gill',      'aman@student.edu',    'student123', 'M', '9876533333', 'ME24007',  'B.Tech ME',  2, v_uid);
  hostel_pkg.register_student('Simran Kaur',    'simran@student.edu',  'student123', 'F', '9876544444', 'BCA25021', 'BCA',        1, v_uid);
  hostel_pkg.register_student('Arjun Mehta',    'arjun@student.edu',   'student123', 'M', '9876555555', 'CSE25033', 'B.Tech CSE', 1, v_uid);
  hostel_pkg.register_student('Neha Singh',     'neha@student.edu',    'student123', 'F', '9876566666', 'MBA25002', 'MBA',        2, v_uid);
  hostel_pkg.register_student('Karan Malhotra', 'karan@student.edu',   'student123', 'M', '9876577777', 'CIV23011', 'B.Tech Civil', 3, v_uid);
  hostel_pkg.register_student('Ananya Gupta',   'ananya@student.edu',  'student123', 'F', '9876588888', 'CSE22045', 'B.Tech CSE', 4, v_uid);

  -- --------------------------- applications ---------------------------
  hostel_pkg.apply_room(sid('rahul@student.edu'),  v_blocks(1), 'SINGLE', v_app);
  hostel_pkg.apply_room(sid('priya@student.edu'),  v_blocks(3), 'DOUBLE', v_app);
  hostel_pkg.apply_room(sid('aman@student.edu'),   v_blocks(1), 'DOUBLE', v_app);
  hostel_pkg.apply_room(sid('simran@student.edu'), v_blocks(3), 'TRIPLE', v_app);
  hostel_pkg.apply_room(sid('arjun@student.edu'),  v_blocks(2), 'TRIPLE', v_app);
  hostel_pkg.apply_room(sid('neha@student.edu'),   v_blocks(4), 'DOUBLE', v_app);

  -- allocate the six applications above using the PL/SQL engine
  hostel_pkg.auto_allocate_all(v_allot, v_wait);
  DBMS_OUTPUT.PUT_LINE('Auto allocation: ' || v_allot || ' allotted, ' || v_wait || ' waitlisted');

  -- these two stay PENDING so the admin has something to process
  hostel_pkg.apply_room(sid('karan@student.edu'),  v_blocks(2), 'DOUBLE', v_app);
  hostel_pkg.apply_room(sid('ananya@student.edu'), v_blocks(4), 'SINGLE', v_app);

  -- ------------------------------- fees -------------------------------
  SELECT alloc_id INTO v_alloc FROM allocations
   WHERE student_id = sid('rahul@student.edu') AND status = 'ACTIVE';
  hostel_pkg.pay_fee(v_alloc, 45000, 'UPI', v_pay, v_txn);          -- fully paid

  SELECT alloc_id INTO v_alloc FROM allocations
   WHERE student_id = sid('priya@student.edu') AND status = 'ACTIVE';
  hostel_pkg.pay_fee(v_alloc, 20000, 'NETBANKING', v_pay, v_txn);   -- partly paid

  -- ----------------------------- requests -----------------------------
  hostel_pkg.raise_request(sid('aman@student.edu'), 'CHANGE', 'SINGLE',
                           'Final project work needs a quiet room.', v_req);

  DBMS_OUTPUT.PUT_LINE('Seed data loaded successfully.');
END;
/

-- quick check
SELECT block_name, total_rooms, total_beds, occupied_beds FROM v_block_occupancy ORDER BY block_name;
