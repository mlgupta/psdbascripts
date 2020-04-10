-- @(#)segsize.sql	1.1 04/06/00 12:28:44

column block_KB new_value block_KB
column segment_name format a30
select value/1024 block_KB from v$parameter where name = 'db_block_size';

set verify off
column owner format a6
column tablespace_name format a10   heading TABLESPACE
column extents         format 999   heading EXT
column max_extents     format 999   heading MAX
column degree          format A6
column KB	       format 99999999
column next_KB	       format 99999999
select s.owner, t.table_name, s.tablespace_name, t.degree, s.extents, 
	s.max_extents, s.blocks* &block_KB KB, s.next_extent /1024 next_KB,
	t.empty_blocks* &block_KB EMPTY_KB, t.num_rows, t.chain_cnt, t.avg_row_len
from dba_tables t, dba_segments s
where t.table_name = upper ('&&tabname')
and  s.segment_name = upper ('&&tabname')
and s.segment_type = 'TABLE'
/
select s.owner, s.segment_name, s.tablespace_name, s.extents, s.max_extents,
	s.blocks* &block_KB KB, s.next_extent / 1024 next_kb
from dba_segments s, dba_indexes i
where i.table_name = upper ('&&tabname')
and  s.segment_name = i.index_name
and s.segment_type = 'INDEX'
and s.owner = i.owner
/
set verify on
