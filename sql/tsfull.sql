-- @(#)tsfull.sql	1.2 10/30/01 14:39:18

set pagesize 0
set linesize 300
set feedback off
set echo off
set timing off
set head off
set verify off
set tab off
select c.name||' tablespace '||a.tablespace_name||' is '||
		round((b.bytes/a.bytes)*100,0)||'% full.' 
	from sys.sm$ts_avail a, sys.sm$ts_used b, v$database c
	where a.tablespace_name = b.tablespace_name (+)
		and round((b.bytes/a.bytes)*100,0) >= &1
      and a.tablespace_name != 'PSTEMP'
	order by nvl((b.bytes/a.bytes)*100,0) desc;
exit
