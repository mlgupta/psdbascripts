-- @(#)check_next.sql	1.1 04/06/00 12:28:39

column segment_name format a30
column type format a5
column KB     format   99999
column next_K format   99999
column usable_K format 9999999
column tablespace_name format a10
clear breaks
break on tablespace_name DUP
compute sum of KB on tablespace_name
select sysdate from dual;
-- now check for segments near max_extents
-- first find out the block size, and determine max_extents from that.
column block_KB new_value block_KB
column sys_max_extents  new_value sys_max_extents
select value/1024 block_KB,
	decode(value, 2048,121, 4096, 249, 8192, 505 ) sys_max_extents
 from v$parameter where name = 'db_block_size';
select s.segment_name, s.segment_type type, s.bytes/1024 KB,
	s.next_extent/1024 next_K, s.tablespace_name,
	sum(decode(sign(fs.bytes - s.next_extent),
		  0, fs.bytes,
		  1, fs.bytes - MOD(fs.bytes, s.next_extent),
		  0
		   )
	    ) /1024  usable_K
from dba_segments s, dba_free_space fs
where s.owner in ('SYSADM', 'SYS', 'PS', 'SYSTEM', 'RPTMART', 'BRIO')
-- and s.tablespace_name = 'PTAPP'
and s.tablespace_name = fs.tablespace_name
group by s.segment_name, s.segment_type, s.bytes,
	s.next_extent, s.tablespace_name
having next_extent  * 5 > sum(decode(sign(fs.bytes - s.next_extent),
				  0, fs.bytes,
				  1, fs.bytes - MOD(fs.bytes, s.next_extent),
				  0
				   )  
			    )
order by tablespace_name asc, KB desc, segment_name asc, type asc
/

-- now check for segments near max_extents
column extents format 999 heading EXT
column max_extents format 999 heading MAX
select s.segment_name, s.segment_type type, s.bytes/1024 KB,
	s.next_extent/1024 next_K, s.tablespace_name,
	s.extents , s.max_extents
from dba_segments s
where s.owner in ('SYSADM', 'SYS', 'PS', 'SYSTEM', 'RPTMART', 'BRIO')
-- and s.tablespace_name = 'PTAPP'
   and max_extents < 2147483645   -- not "maxextents unlimited"
   and s.segment_type not in ('CACHE', 'TEMPORARY')
   and ( extents >= (&sys_max_extents - 5)
	 or extents >= (max_extents - 5)
	 )
order by tablespace_name asc, extents desc, KB desc, segment_name asc, type asc
/
clear computes
