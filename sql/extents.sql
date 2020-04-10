-- @(#)extents.sql	1.1 04/06/00 12:28:40

break on segment_type skip 1 dup
compute count of segment_type on segment_type
column block_KB new_value block_KB
select value/1024 block_KB from v$parameter where name = 'db_block_size';

column owner           format a9
column extents         format 999 heading EXT
column segment_type    format a5 heading TYPE
column segment_name    format a30
column tablespace_name format a10 heading TABLESPACE
column next_K          format 999999
column KB              format 9999999

select sysdate from dual;
select segment_name, segment_type, extents, blocks* &block_KB KB,
next_extent/1024 next_K, tablespace_name
from dba_segments
where extents > 4
and owner in ('SYSADM', 'PS', 'RPTMART', 'BRIO')
order by segment_type desc, extents desc, segment_name asc
/
