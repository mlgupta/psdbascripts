-- @(#)db_securitycheck.sql	1.1 04/06/00 12:28:40

column privilege clear
clear breaks
column grantee format a15

-- column granted role format a20
select grantee, granted_role from dba_role_privs where granted_role = 'DBA'
order by grantee
/

select grantee, privilege from dba_sys_privs
where privilege = 'UNLIMITED TABLESPACE' or privilege like '%ALL%'
order by grantee, privilege
/

column default_tablespace   format a14 heading DEFAULT_TBSP
column temporary_tablespace format a14 heading TEMPORARY_TBSP
select username, default_tablespace, temporary_tablespace
from dba_users
where default_tablespace =   'SYSTEM'
or    temporary_tablespace = 'SYSTEM'
order by username
/

/*
Now check for users with default or atemporary SYSTEM AND unlimited_tablespace
 */

column username format a15
column privilege format a20
select dba_u.username, dba_sp.privilege,
	dba_u.default_tablespace, dba_u.temporary_tablespace
from dba_users dba_u, dba_sys_privs dba_sp
where dba_sp.privilege = 'UNLIMITED TABLESPACE'
and   dba_sp.grantee = dba_u.username
and   (dba_u.default_tablespace =   'SYSTEM'
or    dba_u.temporary_tablespace = 'SYSTEM'
)
order by dba_u.username
/

/*
	Now check for users who have extra privileges on SYSADM tables.
	*/

break on grantee skip 1 dup
column privilege format a10
column owner format a10
select grantee, privilege, owner,  table_name 
from dba_tab_privs
where owner = 'SYSADM'
and privilege != 'SELECT'
and grantee not in ('PS_SELECT', 'PS_UPDATE', 'PS_SEL', 'PS_DML', 'PS_UPD')
order by grantee, privilege, table_name
/
column privilege clear

/**** 
 now check for TS Quotas.
 */
column username format a20
select username, tablespace_name, bytes/1024 USED_K, max_bytes/1024 MAX_K
from dba_ts_quotas
where username not in ('SYS', 'SYSADM', 'SYSTEM')
order by username, tablespace_name
/
clear breaks
