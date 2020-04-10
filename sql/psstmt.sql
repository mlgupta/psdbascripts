-- @(#)psstmt.sql	1.1 04/06/00 15:19:16
--
set linesize 80
set pagesize 10000
set recsep off
set verify off
column unix_proc_id     format 999999           heading OS_PID 
column unix_user        format a10              heading OS_USER
column ora_user         format a8
column oprid            format a10              heading OPRID(?)
column name             format a20
column work_phone       format a15
column first_load_time  format a16              heading LOAD_TIME
column loads            format 990              heading LOADS
column users_opening    format 990              heading USR_OPN
column users_executing  format 990              heading USR_EXC
column executions       format 99,990           heading EXECS
column sorts            format 990              heading SORTS
column disk_reads       format 99,999,990       heading D_READS
column buffer_gets      format 99,999,990       heading B_GETS
column sql_text         format a80              heading SQL_TEXT word_wrapped
accept spid_parm        prompt 'Enter Unix Process ID (wildcards ok): '
accept sql_text_parm    prompt 'Display SQL Text (Y/N):               '
break on unix_proc_id skip 1
-- lists the non-consultant users
select p.spid unix_proc_id,
       substr(p.username,1,10) unix_user,
       decode(s.osuser,'SYSADM','',s.osuser) oprid,
       substr(q.first_load_time,1,16) first_load_time,
       q.loads,
       q.users_opening,
       q.users_executing,
       q.executions,
       q.sorts,
       q.disk_reads,
       q.buffer_gets,
       decode(upper('&&sql_text_parm'),'Y',q.sql_text,'') sql_text
 from  sys.v_$session s,
       sys.v_$process p,
       sys.v_$sqlarea q
 where p.addr = s.paddr
 and   p.spid like '&&spid_parm'
 and   s.sql_address = q.address
order by 1 desc;
