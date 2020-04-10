-- @(#)tablespace_bigsmall2.sql	1.1 04/06/00 12:28:47

break on tablespace_name skip 1 dup

column segment_type format a10 heading TYPE
column owner format a10
column tablespace_name format a10
column KB format 9999999

/*
	tablespaces with multiple segment types, not showing SYSTEM
 */

select s.tablespace_name, owner, segment_type, sum(bytes)/1024 KB,
	sum(decode(sign(bytes-1024000),-1,bytes,0))/1024 small_KB,
	sum(decode(sign(bytes-1024000),-1,0,bytes))/1024 large_KB
from dba_segments s, 
	( select tablespace_name, count(distinct segment_type) 
	  from dba_segments
	  where tablespace_name <> 'SYSTEM'
	  group by tablespace_name
	  having count(distinct segment_type) >1) sc
where s.tablespace_name  = sc.tablespace_name
      and s.tablespace_name <> 'SYSTEM'
group by s.tablespace_name, owner, segment_type
order by s.tablespace_name, owner, segment_type
/
clear breaks


/*
	tablespaces (except SYSTEM & PSRBS) with both large and small segments.
 */

select a.tablespace_name, a.sum_KB,
	small.sum_KB small_KB, large.sum_KB large_KB
-- 	sum(decode(sign(bytes-1024000),-1,bytes,0))/1024 small_KB,
-- 	sum(decode(sign(bytes-1024000),-1,0,bytes))/1024 large_KB
from (select tablespace_name, sum(bytes)/1024 sum_KB
	from dba_segments
	where tablespace_name not in ('SYSTEM', 'PSRBS')
	group by tablespace_name
	) a,
	(select tablespace_name, sum(bytes)/1024 sum_KB
	 from dba_segments
	 where bytes< 1024000
	 and tablespace_name not in ('SYSTEM', 'PSRBS')
	 group by tablespace_name) small,
	(select tablespace_name, sum(bytes)/1024 sum_KB
	 from dba_segments
	 where bytes>= 1024000
	 and tablespace_name not in ('SYSTEM', 'PSRBS')
	 group by tablespace_name) large
where a.tablespace_name = small.tablespace_name
and   a.tablespace_name = large.tablespace_name
-- group by a.tablespace_name
order by tablespace_name
/
-- clear breaks
