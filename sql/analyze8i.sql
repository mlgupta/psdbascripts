-- @(#)analyze8i.sql	1.4 06/12/01 09:02:45

set pagesize 0

select 'Started on :' || to_char(sysdate,'Day, Month DD, YYYY HH:MI')
from dual;

exec dbms_stats.gather_database_stats(cascade=>TRUE);

select 'Finished on :' || to_char(sysdate,'Day, Month DD, YYYY HH:MI')
from dual;
