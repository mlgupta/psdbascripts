-- @(#)badnext.sql	1.1 04/06/00 12:28:38

column block_KB new_value block_KB
select value/1024 block_KB from v$parameter where name = 'db_block_size';

REM badnext.sql
REM this report is to list all SYSADM segments where NEXT is not a "page" size.
REM ------------------
REM first we list all segments where NEXT is not a standard size.
REM then we list the segments where the NEXT size does not match the seg size.
REM

column segment_name format a30
column segment_type format a5 heading TYPE
column tablespace_name format a10
set verify off echo off

select segment_name, segment_type, tablespace_name, blocks*&block_KB KB,
	next_extent/1024 next_kb, pct_increase
from dba_segments
where owner in ('SYSADM', 'PS', 'RPTMART', 'BRIO')
and ( 
	next_extent/1024 not in (8, 40, 200, 1000, 10000, 100000)
 OR
	pct_increase >0
    )
order by segment_name asc, segment_type desc
/

select segment_name, segment_type, tablespace_name, blocks*&block_KB KB, next_extent/1024 next_kb
from dba_segments
where owner in ('SYSADM',  'RPTMART', 'BRIO')
AND (
	(
	blocks*&block_KB <40
	and next_extent <> 8*1024
	)
	OR
	(
	(blocks* &block_KB) between 40 and 199
	and next_extent <> 40*1024
	)
	OR
	(
	(blocks* &block_KB) between 200 and 999
	and next_extent <> 200*1024
	)
	OR
	(
	-- (blocks * &block_KB) >= 1000
	(blocks * &block_KB) between 1000 and 9999
	and next_extent <> 1000*1024
	)
	OR
	(
	(blocks * &block_KB) >= 10000
	-- (blocks * &block_KB) between 10000 and 99999
	and next_extent <> 10000*1024
	)
	-- OR
	-- (
	-- blocks * &block_KB >= 100000
	-- and next_extent <> 100000*1024
	-- )
)
order by segment_name asc, segment_type desc
/
