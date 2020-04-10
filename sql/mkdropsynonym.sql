set timing off
set feedback off
set pagesize 0

spool dropsynonym.sql
select 'SPOOL dropsynonym.log' from dual;
select 'DROP '||DECODE(owner,'PUBLIC','PUBLIC ')||'SYNONYM '||SYNONYM_NAME||';'
FROM DBA_SYNONYMS where owner= 'SYSADM';
select 'SPOOL off' from dual;
spool off

