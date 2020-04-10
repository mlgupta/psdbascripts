-- @(#)fixnext.sql	1.1 04/06/00 12:28:41

set heading off pagesize 0  verify off timing off feedback off echo off
spool /tmp/runfixnext.&INSTANCE..sql

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter index ____ storage ( next 8k)' where bytes < 40K

select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
	' storage (next ' || '8k pctincrease 0);'
from dba_segments
where owner in ('SYSADM', 'RPTMART', 'BRIO')
and   segment_type in ('TABLE', 'INDEX')
and   bytes < 40*1024 
and   (next_extent <> 8*1024
	OR
	pct_increase >0
	)
order by segment_name asc, segment_type desc
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter index ___ storage (next 40K)' where bytes between 40k and 199k

select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
	 ' storage (next ' || '40k pctincrease 0);'
from dba_segments
where owner in ('SYSADM',  'RPTMART', 'BRIO')
and   segment_type in ('TABLE', 'INDEX')
and   bytes between 40*1024 and 199*1024
and   (next_extent <> 40*1024
	OR
	pct_increase >0
	)
order by segment_name asc, segment_type desc
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter index _____ storage (next 200K)' where bytes between 200K and 1000K

select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
	' storage (next ' || '200k pctincrease 0);'
from dba_segments
where owner in ('SYSADM', 'RPTMART', 'BRIO')
and    segment_type in ('TABLE', 'INDEX')
and    bytes between 200*1024 and 999*1024
and   (next_extent <> 200*1024
	OR
	pct_increase >0
	)
order by segment_name asc, segment_type desc
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter index _____ storage (next 1000K)' where KB between 1000K and 10000K

select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
	 ' storage (next ' || '1000k pctincrease 0);'
from dba_segments
where owner in ('SYSADM', 'RPTMART', 'BRIO')
and   segment_type in ('TABLE', 'INDEX')
and   bytes between 1000*1024 and 9999*1024
-- and   bytes >= 1000*1024 
and   ( next_extent <> 1000*1024
	OR
	pct_increase >0
	)
order by segment_name asc, segment_type desc
/

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter index _____ storage (next 10000K)' where KB >= 10000K
-- 
select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
	' storage (next ' || '10000k pctincrease 0);'
from dba_segments
where owner in ('SYSADM', 'RPTMART', 'BRIO')
and   segment_type in ('TABLE', 'INDEX')
-- and not (tablespace_name like '%LARGE'
-- 	 or tablespace_name = 'BIGINDX')
and   bytes >= 10000*1024
and   ( next_extent <> 10000*1024
	OR
	pct_increase >0
	)
order by segment_name asc, segment_type desc
/
-- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
REM 'alter index _____ storage (next 100000K)' 
REM (%LARGE and BIGINDX tablespaces only.

-- /*
-- select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
-- 	' storage (next ' || '100000k pctincrease 0);'
-- from dba_segments
-- where owner in ('SYSADM', 'RPTMART', 'BRIO')
-- and   segment_type in ('TABLE', 'INDEX')
-- and (   tablespace_name = 'BIGINDX'
-- 	or tablespace_name like '%LARGE')
-- and   ( next_extent <> 100000*1024
-- 	OR
-- 	pct_increase >0
-- 	)
-- order by segment_name asc, segment_type desc
-- /
--  */
spool off

REM INSTANCE is set by "login.sql".  do "@login" after switching instance.
!mv /tmp/runfixnext.&INSTANCE..out /tmp/runfixnext.&INSTANCE..out.$$
spool /tmp/runfixnext.&INSTANCE..out
set echo on
@ /tmp/runfixnext.&INSTANCE..sql
spool off

set heading on pagesize 15  verify off timing on feedback 1 echo off
