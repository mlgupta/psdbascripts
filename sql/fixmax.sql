-- @(#)fixmax.sql	1.1 04/06/00 12:28:41

-- determine recomended max_extents dynamically.
column old_max_extents new_value old_max_extents
column new_max_extents new_value new_max_extents
select decode(value, 2048,100, 4096, 220, 8192, 400, 200) old_max_extents,
	decode(value, 2048,'unlimited', 4096, 'unlimited', 8192, 500, 'unlimited') new_max_extents
from v$parameter where name = 'db_block_size';

set heading off pagesize 0 verify off timing off feedback off echo off
spool /tmp/runfixmax.&INSTANCE..sql

select 'alter ' || segment_type || ' ' || owner || '.' || segment_name ||
	' storage (pctincrease 0 maxextents &new_max_extents);'
from dba_segments where max_extents < &old_max_extents
and owner in ('SYSADM', 'PS', 'RPTMART', 'BRIO')
and segment_type in ('TABLE', 'INDEX', 'CLUSTER')
order by owner, segment_name, segment_type
/

spool off
!mv /tmp/runfixmax.&INSTANCE..out /tmp/runfixmax.&INSTANCE..out.$$
spool /tmp/runfixmax.&INSTANCE..out
set echo on
@ /tmp/runfixmax.&INSTANCE..sql
spool off

set heading on pagesize 15 verify off timing on feedback 1
