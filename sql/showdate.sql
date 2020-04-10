-- @(#)showdate.sql	1.1 04/06/00 12:28:44

select to_char(sysdate, 'MM_DD_YYYY HH24:MI:SS') SYSTEM_DATE
from dual
/

