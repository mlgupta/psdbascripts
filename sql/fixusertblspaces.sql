-- %W% %G% %U%

REM to set the INSTANCE variable (if needed).
@login

set heading off pagesize 0  verify off timing off feedback off echo off
spool /tmp/runfixusertblspace.&INSTANCE..sql

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter user ______ temporary tablespace PSTEMP default tablespace USERS
REM	quota unlimited on PSTEMP quota 100K on users quota unlimited on PSTEMP;

REM	'default tablespace USERS' || 
REM	' quota 100k on users' || ';'

select 'alter user ' || username || ' temporary tablespace PSTEMP ',
	'default tablespace USERS ;' 
from dba_users
where username not in ('SYS', 'SYSTEM', 'SYSADM', 'RPTMART', 'BRIO', 'BRPRTL', 'VERSATA', 'QDBA', 'DBSNMP')
and (
	temporary_tablespace <> 'PSTEMP'
	OR default_tablespace <> 'USERS'
)
order by username
/


REM INSTANCE is set by "login.sql".  do "@login" after switching instance.
!mv /tmp/runfixusertblspace.&INSTANCE..out /tmp/runfixusertblspace.&INSTANCE..out.$$
spool /tmp/runfixusertblspace.&INSTANCE..out
spool /tmp/runfixnext.&INSTANCE..out
set echo on
@ /tmp/runfixusertblspace.&INSTANCE..sql
spool off

set heading on pagesize 15  verify off timing on feedback 1 echo off
