rem ======= 
rem Purpose
rem ======= 
 
rem This script allows the user to enter the tablespace name and creates a list of  
rem tables in exp format.  Additional choices allow the export of overextended  
rem tables or tables over a certain size.  
 
 
rem ============ 
rem Requirements
rem ============ 
 
rem This scripts must be executed as a script from SQL*Plus.   
 
rem 
rem list.sql  
rem Give list of tables depending on parameters  
  
 set termout on linesize 75 pagesize 0 verify off feedback off  
 clear buffer  
 clear columns  
 
 prompt  
 prompt This script will create list.out, which can be used 
 prompt to give export tables parameter file  
 prompt  
  
 accept Segment_Name Prompt 'Enter Seg Name               : '  
 accept owner        Prompt 'Enter Seg Owner              : '  
 accept tsname       prompt 'Enter TableSpace Name        : '  
 accept min_extents  Prompt 'Enter Minimum num of exts    : '  
 accept min_size     Prompt 'Enter Minimum seg size(M)    : '  
  
 prompt  
 
 accept expchoice    Prompt 'Is this list for exports?   : '  
  
 col srt                        noprint  
 
 SPOOL list.out  
  
-- start bit  
select 0 srt, decode(upper('&expchoice'),'Y','tables=(','')  
from   dual  
union  
-- data bit without end segment  
select 1 srt, segment_name||decode(upper('&expchoice'),'Y',',','')  
from   dba_segments  
where segment_type    = 'TABLE'  
and    segment_name    like upper('&&Segment_Name%')  
and    owner           like upper('&&owner%')  
and    tablespace_name like upper('&&tsname%')  
and    extents         >= (&&min_extents + 0)  
and    bytes      >= (&&min_size + 0) * (1024*1024)  
minus  
-- remove last one (with ',' after the name)  
select 1 srt, max(segment_name)||decode(upper('&expchoice'),'Y',',','')  
from   dba_segments  
where  segment_type    = 'TABLE'  
and    segment_name    like upper('&&Segment_Name%')  
and    owner           like upper('&&owner%')  
and    tablespace_name like upper('&&tsname%')  
and    extents         >= (&&min_extents + 0)  
and    bytes           >= (&&min_size + 0) * (1024*1024)  
union  
-- data bit with end segment  
select 3 srt, max(segment_name)||decode(upper('&expchoice'),'Y',')','')  
from   dba_segments  
where  segment_type    = 'TABLE'  
and    segment_name    like upper('&&Segment_Name%')  
and    owner           like upper('&&owner%')  
and    tablespace_name like upper('&&tsname%')  
and    extents         >= (&&min_extents + 0)  
and    bytes           >= (&&min_size + 0) * (1024*1024)  
order by 1,2  
/  
  
spool off  
  
set heading on  
 
---------cut---------------cut--------cut--------cut-------- 
 
s script allows the user to enter the tablespace name and creates a list of  
tables in exp format.  Additional choices allow the export of overextended  
tables or tables over a certain size.  
 
 
============= 
Requirements: 
============= 
 
This scripts must be executed as a script from SQL*Plus.   
 
======= 
Script: 
======= 
 
---------cut---------------cut--------cut--------cut-------- 
 
rem 
rem list.sql  
rem Give list of tables depending on parameters  
  
 set termout on linesize 75 pagesize 0 verify off feedback off  
 clear buffer  
 clear columns  
 
 prompt  
 prompt This script will create list.out, which can be used 
 prompt to give export tables parameter file  
 prompt  
  
 accept Segment_Name Prompt 'Enter Seg Name               : '  
 accept owner        Prompt 'Enter Seg Owner              : '  
 accept tsname       prompt 'Enter TableSpace Name        : '  
 accept min_extents  Prompt 'Enter Minimum num of exts    : '  
 accept min_size     Prompt 'Enter Minimum seg size(M)    : '  
  
 prompt  
 
 accept expchoice    Prompt 'Is this list for exports?   : '  
  
 col srt                        noprint  
 
 SPOOL list.out  
  
-- start bit  
select 0 srt, decode(upper('&expchoice'),'Y','tables=(','')  
from   dual  
union  
-- data bit without end segment  
select 1 srt, segment_name||decode(upper('&expchoice'),'Y',',','')  
from   dba_segments  
where segment_type    = 'TABLE'  
and    segment_name    like upper('&&Segment_Name%')  
and    owner           like upper('&&owner%')  
and    tablespace_name like upper('&&tsname%')  
and    extents         >= (&&min_extents + 0)  
and    bytes      >= (&&min_size + 0) * (1024*1024)  
minus  
-- remove last one (with ',' after the name)  
select 1 srt, max(segment_name)||decode(upper('&expchoice'),'Y',',','')  
from   dba_segments  
where  segment_type    = 'TABLE'  
and    segment_name    like upper('&&Segment_Name%')  
and    owner           like upper('&&owner%')  
and    tablespace_name like upper('&&tsname%')  
and    extents         >= (&&min_extents + 0)  
and    bytes           >= (&&min_size + 0) * (1024*1024)  
union  
-- data bit with end segment  
select 3 srt, max(segment_name)||decode(upper('&expchoice'),'Y',')','')  
from   dba_segments  
where  segment_type    = 'TABLE'  
and    segment_name    like upper('&&Segment_Name%')  
and    owner           like upper('&&owner%')  
and    tablespace_name like upper('&&tsname%')  
and    extents         >= (&&min_extents + 0)  
and    bytes           >= (&&min_size + 0) * (1024*1024)  
order by 1,2  
/  
  
spool off  
  
set heading on  
