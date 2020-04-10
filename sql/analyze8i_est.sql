-- @(#)analyze8i_est.sql	1.2 04/26/02 14:31:21

set pagesize 0

select 'Started on :' || to_char(sysdate,'Day, Month DD, YYYY HH:MI')
from dual;

exec dbms_stats.gather_schema_stats('SYSADM',estimate_percent=>20,cascade=>TRUE);
exec dbms_stats.gather_schema_stats('VERSATA',estimate_percent=>20,cascade=>TRUE);

select 'Finished on :' || to_char(sysdate,'Day, Month DD, YYYY HH:MI')
from dual;
