-- @(#)space_summ.sql	1.1 04/06/00 12:28:45

rem
rem space_summary.sql
rem  parameter 1:  database link name
rem  parameter 2:  check date
rem  parameter 3:  ratio of Oracle block size to os block size
rem
rem  to call this report from within sqlplus:
rem  @space_summary link_name check_date block_ratio
rem
rem  Example:
rem  @space_summary CASE 07-AUG-94 4
rem
rem  Should be called weekly for each database.
rem  
set pagesize 60 linesize 132 verify off feedback off newpage 0
column ts heading 'Tablespace' format A18
column file_nm heading 'File nm' format A40
column blocks heading 'Orablocks'
column percentfree format 999.99
column diskblocks format 99999999
column cfb format 9999999 heading 'NumFrExts'
column mfb format 9999999 heading 'MaxFrExt'
column sfb format 9999999 heading 'SumFrBl'
column dfrb format 9999999 heading 'DiskFrBl'
column sum_file_blocks heading 'DiskBlocks'
column maxfrpct heading 'MaxFrPct' format 9999999

break on ts
ttitle center 'Oracle Tablespaces in ' &&1 skip center -      
'Check Date = ' &&2 skip 2 center    
spool &&1._space_summary.lst  

select 
	ts, 			/*tablespace name*/
	file_nm, 		/*file name*/
	blocks, 			/*Oracle blocks in the file*/
	blocks*&&3 diskblocks	/*operating system blocks in the file*/
from files
where check_date = '&&2'
and db_nm = upper('&&1')    
order by ts, file_nm
/

ttitle center 'Oracle Free Space Statistics for ' &&1 skip center -
 '(Extent Sizes in Oracle blocks)' skip center -
  'Check Date = ' &&2 skip 2

select 
	spaces.ts,			/*tablespace name*/
	spaces.count_free_blocks cfb,	/*number of free extents*/
	spaces.max_free_blocks mfb,	/*lgst free extent, in Orablocks*/
	spaces.sum_free_blocks sfb,	/*sum of free space*/
	round(100*sum_free_blocks/sum_file_blocks,2) 
		percentfree, 		/*percent free in ts*/
	round(100*max_free_blocks/sum_free_blocks,2) 
		maxfrpct,		/*ratio of largest extent to sum*/
	spaces.sum_free_blocks*&&3 dfrb, /*disk blocks free*/
	sum_file_blocks*&&3 sum_file_blocks   /*disk blocks allocated*/
from spaces, files_ts_view ftv
where spaces.db_nm = ftv.db_nm
and spaces.ts = ftv.ts
and spaces.check_date = ftv.check_date
and spaces.db_nm = upper('&&1')
and spaces.check_date = '&&2'
/
spool off
undefine 1
undefine 2
undefine 3

