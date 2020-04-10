-- @(#)dbfileinfo.sql	1.1 04/06/00 12:28:40

COLUMN   member ON FORMAT   a45
COLUMN   MB ON FORMAT   9999.99
COLUMN   file_name ON FORMAT   a45 word_wrap
column data_files like file_name

break on report
compute sum of MB on report

set echo on
/*
 DATA FILES
 */

select file_name DATA_FILES, bytes/(1024*1024) MB from dba_data_files
order by file_name
/

/* 
	Now get the online redo log information
 */

select vl.group#, vlf.member, vl.bytes/(1024*1024) MB
from v$log vl, v$logfile vlf
where vl.group# = vlf.group#
order by group#, member
/

/*
 LOG ARCHIVE DEST
 */

column name format a30
column value format a44 word_wrap
select name, value from v$parameter where name like 'log_archive%'
/

/*
 CONTROL FILES
 */

column name format a20
select name, value file_name
from v$parameter
where name = 'control_files'
/

/* show the $ORACLE_BASE
 */
!echo $ORACLE_BASE

/* finally take a backup controlfile to trace.
 */
alter database backup controlfile to trace
/
