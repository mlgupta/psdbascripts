-- @(#)tablespace_bigsmall.sql	1.1 04/06/00 12:28:46

REM
REM   change history:
REM tjm	02/26/98:	initial version
REM tjm 01/21/99	add column formats.

break on tablespace_name skip 1 dup

column segment_type format a10 heading TYPE
column owner format a10
column tablespace_name format a10
column KB format 9999999

select tablespace_name, owner, segment_type, sum(bytes)/1024 KB,
	sum(decode(sign(bytes-1024000),-1,bytes,0))/1024 small_KB,
	sum(decode(sign(bytes-1024000),-1,0,bytes))/1024 large_KB
from dba_segments
group by tablespace_name, owner, segment_type
order by tablespace_name, owner, segment_type
/
clear breaks
