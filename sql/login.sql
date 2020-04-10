-- @(#)login.sql	1.1 04/06/00 12:28:42

set serverout on
column instance new_value instance
select name instance from v$database;
set sqlprompt "&&instance SQL> "
column owner format a10
column tablespace_name format a10 heading TABLESPACE
column segment_name format a30
set time on timing on feedback 1 trimout on trimspool on serverout on
-- set arraysize 100
column segment_name format a30
column tablespace_name format a10
