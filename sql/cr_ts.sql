set pagesize 0
set feedback off
set timing off
set linesize 1000
set trimout on
spool run_crts.sql
select 'CREATE TABLESPACE '||TABLESPACE_NAME||' DATAFILE '||
''''||file_name||''' SIZE '||BYTES/1024/1024||' M '||
'DEFAULT STORAGE (INITIAL 8K NEXT 8K  MAXEXTENTS 500 PCTINCREASE 0);'
FROM DBA_DATA_FILES
ORDER BY TABLESPACE_NAME
/
spool off
/
