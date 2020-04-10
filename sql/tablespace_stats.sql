-- @(#)tablespace_stats.sql	1.1 04/06/00 12:28:48

column block_KB new_value block_KB
select value/1024 block_KB from v$parameter where name = 'db_block_size';


break on report
compute sum of total_k on report
compute sum of used_k on report
compute sum of free_k on report
column total_k format 999,999,999
column used_k  format  99,999,999
column free_k like used_k
select tss.tablespace_name, tss.sumblocks * &block_KB Total_K, nvl(seg.sumblocks,0) * &block_KB used_K, free.sumblocks * &block_KB free_K
from	-- tablespaces_sumsize_vw tss,
	( select tablespace_name, sum(blocks) sumblocks
	  from dba_data_files
	  group by tablespace_name ) tss,
--	tablespaces_freesize_vw free,
	( select tablespace_name, sum(blocks) sumblocks
	  from dba_free_space
	  group by tablespace_name ) free,
--	tablespaces_usedsize_vw seg
	( select tablespace_name, sum(blocks) sumblocks
	  from dba_segments
	  group by tablespace_name ) seg
where tss.tablespace_name = free.tablespace_name
and   tss.tablespace_name = seg.tablespace_name(+)
-- and   tss.tablespace_name = 'AMAPP'
order by tss.tablespace_name
/
