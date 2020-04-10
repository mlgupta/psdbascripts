-- @(#)analyze.sql	1.1 04/06/00 12:28:38

set pagesize 0

select 'Started on :' || to_char(sysdate,'Day, Month DD, YYYY HH:MI')
from dual;

exec dbms_utility.analyze_schema('SYSADM','COMPUTE');

select 'Finished on :' || to_char(sysdate,'Day, Month DD, YYYY HH:MI')
from dual;
