-- =====================================================================
--  Hostel Room Allocation System
--  00_create_user.sql  -  creates the application schema (run ONCE)
--
--  Run this as SYSTEM, connected to the pluggable database XEPDB1
--  (SQL Developer: Hostname=localhost, Port=1521, Service name=XEPDB1).
-- =====================================================================

CREATE USER hostel IDENTIFIED BY hostel123
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE SEQUENCE,
      CREATE PROCEDURE,
      CREATE TRIGGER
   TO hostel;

-- Now create a new SQL Developer connection:
--   Username: hostel   Password: hostel123   Service name: XEPDB1
-- and run 01_schema.sql, 02_package.sql, 03_triggers.sql, 04_seed_data.sql
