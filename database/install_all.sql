-- =====================================================================
--  Runs all scripts in order (SQL*Plus / SQLcl / SQL Developer F5).
--  Connect as HOSTEL first, then:   @install_all.sql
--  (00_create_user.sql must already have been run as SYSTEM.)
-- =====================================================================
@@01_schema.sql
@@02_package.sql
@@03_triggers.sql
@@04_seed_data.sql
