-- @(#)whohasrole.sql	1.1 04/06/00 12:28:48

set serveroutput on size 1000000

set echo off
set verify off

accept rolename char a15 prompt 'Enter name of role (ex. ps_upd): '
column grantee format a15
column granted_role format a15
column default_role format a15
select grantee, granted_role, default_role
from dba_role_privs
where granted_role = upper('&rolename')
order by grantee

undefine rolename
column grantee clear
column granted_role clear
column default_role clear

set echo on
set verify on
/
