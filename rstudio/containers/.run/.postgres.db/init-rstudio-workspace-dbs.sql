-- create a new role, a new user with thay role assigned, and two databases
-- 
--   https://www.postgresql.org/docs/current/sql-createrole.html
--   https://www.digitalocean.com/community/tutorials/how-to-use-roles-and-manage-grant-permissions-in-postgresql-on-a-vps-2
-- 

-- 
-- CREATE ROLE
-- Create a role with a password that is valid until the end of 2034. After one second has ticked in 2035, the password is no longer valid.

CREATE ROLE rstudio_role WITH LOGIN ENCRYPTED PASSWORD '6ern@rd!' VALID UNTIL '2035-01-01';


-- user [bernard] has role [rstudio_role]
-- CREATE USER bernard rstudio_role WITH ENCRYPTED PASSWORD 'tryphon';
CREATE USER bernard rstudio_role

CREATE DATABASE rstudio_example_wk_db1;
GRANT ALL PRIVILEGES ON DATABASE rstudio_example_wk_db1 TO bernard;

CREATE DATABASE rstudio_example_wk_db2;
GRANT ALL PRIVILEGES ON DATABASE rstudio_example_wk_db2 TO bernard;


use rstudio_example_wk_db21;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rstudiouser;

use rstudio_example_wk_db2;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rstudiouser;


