-- @(#)freereport2k.sql	1.1 04/06/00 12:28:41

column block_KB new_value block_KB
select value/1024 block_KB from v$parameter where name = 'db_block_size';

-- set linesize 83
set recsep off
column tablespace_name format a10 heading TABLESPACE
column count format 9990
column max_KB format      9999990
column ">=10K" format    99999990
column ">=100K" format   99999990
column ">=1,000K" format 99999990
column "10,000K" format  99999990
column "100,000K" format 99999990
column "TS MB" format 99999
select sysdate from dual;
select ts.tablespace_name, count(fs.block_id) count, max(fs.blocks)*&block_KB MAX_KB,
sum(decode(sign(fs.blocks-5),-1,0,fs.blocks))*&block_KB ">=10K",
sum(decode(sign(fs.blocks-50),-1,0,fs.blocks))*&block_KB ">=100K",
sum(decode(sign(fs.blocks-500),-1,0,fs.blocks))*&block_KB ">=1,000K",
sum(decode(sign(fs.blocks-5000),-1,0,fs.blocks))*&block_KB "10,000K",
sum(decode(sign(fs.blocks-50000),-1,0,fs.blocks))*&block_KB "100,000K",
ts.sumblocks/(1024/&block_KB) "TS MB"
/*	(select sum(df.blocks)/(1024/&block_KB) "TS MB"
	 from dba_data_files df
	 where df.tablespace_name = t.tablespace_name
	 group by df.tablespace_name
	) */
from dba_free_space fs, -- dba_tablespaces t,
	-- tablespaces_sumsize_vw ts
	( select tablespace_name, sum(blocks) sumblocks
	  from dba_data_files
	  group by tablespace_name ) ts
where fs.tablespace_name (+) = ts.tablespace_name
group by ts.tablespace_name, ts.sumblocks
/
set recsep wrapped
