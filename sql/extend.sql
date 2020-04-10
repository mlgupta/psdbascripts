-- %W% %G% %U%

set pagesize 0
set feedback off
set linesize 300
set timing off
set verify off
column nxt for 999,990 head Next
column tablespace_name for a12
column segment_type for a5
column instance new_value instance
set termout off
select name instance from v$database;
set termout on
select '&instance'||': '||initcap(a.segment_type)||' '||a.segment_name||' in tablespace '||
b.tablespace_name ||' could not be extended by '||
to_char(round(b.next_extent*(1+(b.pct_increase/100))/1024/1024,0))||'M.' 
from dba_segments a,dba_tables b
where a.segment_name = b.table_name
and a.segment_type = 'TABLE'
and b.next_extent*(1+(b.pct_increase/100)) > (select max(bytes) from
dba_free_space where tablespace_name = b.tablespace_name)
union
select '&instance'||': '||initcap(a.segment_type)||' '||a.segment_name||' in tablespace '||
b.tablespace_name ||' could not be extended by '||
to_char(round(b.next_extent*(1+(b.pct_increase/100))/1024/1024,0))||'M.' 
from dba_segments a,dba_indexes b
where a.segment_name = b.index_name
and a.segment_type = 'INDEX'
and b.next_extent*(1+(b.pct_increase/100)) > (select max(bytes) from
dba_free_space where tablespace_name = b.tablespace_name)
order by 1;
exit
