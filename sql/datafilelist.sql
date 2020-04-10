-- @(#)datafilelist.sql	1.1 04/06/00 12:28:39

column file_name format a45

/* 
	Now get the log information
 */
column MB format 9999.99
column member like file_name
break on tablespace_name skip 1 on report

compute sum of MB on group#
compute sum of MB on report
break on group# skip 1 on report
select vl.group#, vlf.member, vl.bytes/(1024*1024) MB
from v$log vl, v$logfile vlf
where vl.group# = vlf.group#
order by group#, member
/

break on tablespace_name skip 1 on report
column tablespace_name format a10
compute sum of MB on tablespace_name
compute sum of MB on report
select tablespace_name, file_name, bytes/(1024*1024) MB from dba_data_files
order by tablespace_name, file_name
/
