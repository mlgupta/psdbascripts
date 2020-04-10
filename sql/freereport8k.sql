-- @(#)freereport8k.sql	1.1 04/06/00 12:28:42

column block_KB new_value block_KB
select value/1024 block_KB from v$parameter where name = 'db_block_size';

-- set linesize 83
set recsep off
column tablespace_name format a10 heading TABLESPACE
column count format 9990
column files format 9990
column max_KB format      9999990
column ">=40K" format    99999990
column ">=200K" format   99999990
column ">=1,000K" format 99999990
column "10,000K" format  99999990
column "100,000K" format 99999990
column "TS MB" format 99999
select sysdate from dual;
select ts.tablespace_name, count(fs.block_id) count, ts.files, max(fs.blocks)*&block_KB MAX_KB,
sum(decode(sign(fs.blocks-5),-1,0,fs.blocks))*&block_KB ">=40K",
sum(decode(sign(fs.blocks-25),-1,0,fs.blocks))*&block_KB ">=200K",
sum(decode(sign(fs.blocks-125),-1,0,fs.blocks))*&block_KB ">=1,000K",
sum(decode(sign(fs.blocks-1250),-1,0,fs.blocks))*&block_KB "10,000K",
sum(decode(sign(fs.blocks-12500),-1,0,fs.blocks))*&block_KB "100,000K",
ts.sumblocks/(1024/&block_KB) "TS MB"
/*	(select sum(df.blocks)/(1024/&block_KB) "TS MB"
	 from dba_data_files df
	 where df.tablespace_name = t.tablespace_name
	 group by df.tablespace_name
	) */
from dba_free_space fs, -- dba_tablespaces t,
	-- tablespaces_sumsize_vw ts
	( select df.tablespace_name, count(df.file_id) files, sum(df.blocks) sumblocks
	  from dba_data_files df
	  group by df.tablespace_name ) ts
where fs.tablespace_name (+) = ts.tablespace_name
group by ts.tablespace_name, ts.files, ts.sumblocks
having ( count(fs.block_id) = 0
    or count(fs.block_id) > ts.files
    )
/
set recsep wrapped
