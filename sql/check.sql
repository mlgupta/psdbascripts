-- @(#)check.sql	1.2 09/26/00 17:26:27

col owner for a8 head "Owner"
col segment_name for a22 head "Table/Index Name"
col segment_type for a7 head Type
col extents for 990 head "Exts"
col exts for a10 head "Max Exts"
col nxt for 999,990 head "Next"
col remain for a10 head "Remain"
col pct_increase for a3 head "% Inc"
set pagesize 66
set linesize 300
set feedback off
set timing off
set head off
set verify off
set tab off
break on owner on report
select 'Objects that are over 10 Extents ordered by least remaining' from dual;
set head on
select a.owner, a.segment_name , a.segment_type, a.extents, decode(b.max_extents,2147483645,'Unlimited',b.max_extents) exts,
decode(b.max_extents,2147483645,'Unlimited',b.max_extents-a.extents) remain
from dba_segments a, dba_tables b
where a.segment_name = b.table_name
and a.segment_type = 'TABLE' and a.extents > 10
union
select a.owner, a.segment_name , a.segment_type, a.extents, decode(b.max_extents,2147483645,'Unlimited',b.max_extents) exts,
decode(b.max_extents,2147483645,'Unlimited',b.max_extents-a.extents) remain
from dba_segments a, dba_indexes b
where a.segment_name = b.index_name
and a.segment_type = 'INDEX' 
and a.extents > 10
order by 1, 6 
/
set head off
select 'Free Space Remaining Orderd by Least Remaining' from dual; 
set head on
col tablespace_name for A12 head 'Tablespace'
col tota for 999,999 head 'Total|Meg'
col used for 999,999 head 'Meg|Used'
col pct for 999 head '%|Used'
col tot for 999,999 head 'Meg|Free'
col big for 999,999 head 'Largest|Free'
col cnt for 999 head 'Segments'
col pct_increase for 990 head "% Inc"
SELECT A.TABLESPACE_NAME, round(A.BYTES/1024/1024,0) tota,
nvl(round(B.BYTES/1024/1024,0),0) used, 
nvl((b.bytes/a.bytes)*100,0) pct,round(c.tot/1024/1024,0) tot, 
round(C.BIG/1024/1024,0) big, c.cnt, d.pct_increase
FROM SYS.SM$TS_AVAIL a, SYS.SM$TS_USED B, TS_FRAG C, DBA_TABLESPACES D
WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME (+)
AND A.TABLESPACE_NAME = C.TABLESPACE_NAME
AND A.TABLESPACE_NAME = D.TABLESPACE_NAME
order by nvl((b.bytes/a.bytes)*100,0) desc
/
set head off
select 'Segments with over 3 Meg Next Extents' from dual;
set head on
select a.owner, a.segment_name, a.segment_type, b.tablespace_name,
b.pct_increase, 
round(b.next_extent*(1+(b.pct_increase/100))/1024/1024,0) nxt
from dba_segments a,dba_tables b
where a.segment_name = b.table_name
and a.segment_type = 'TABLE'
and b.next_extent*(1+(b.pct_increase/100)) > 3000000 
union
select a.owner, a.segment_name, a.segment_type, b.tablespace_name,
b.pct_increase, 
round(b.next_extent*(1+(b.pct_increase/100))/1024/1024,0) nxt
from dba_segments a,dba_indexes b
where a.segment_name = b.index_name
and a.segment_type = 'INDEX'
and b.next_extent*(1+(b.pct_increase/100)) > 3000000 
order by 1, 6 desc
/
set head off
select 'Objects Larger that 10M'
from dual;
col tablespace_name for a12 head Tablespace
col bytes for 9,990 head Size
col init for 9,990 head Init
col nxt for 9,990 head Next
set head on
select owner, segment_name, segment_type, tablespace_name, round(bytes/1024/1024,0) bytes, round(initial_extent/1024/1024,0) init,
 round(next_extent/1024/1024,0) nxt, extents
from dba_segments
where bytes > 10000000
and segment_type != 'ROLLBACK'
order by owner, bytes desc;

exit

