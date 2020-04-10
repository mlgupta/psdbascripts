-- @(#)mkdropall.sql	1.1 04/06/00 12:28:43

--
-- sql script to drop all tables owned by VERSATA.
-- 
set heading off echo off pagesize 0
select 'set echo on' from dual;
--
select 'drop table ' || owner || '.' || table_name || ';'
from sys.dba_tables
where owner = 'VERSATA'
order by table_name;
--
select 'drop view ' || owner || '.' || view_name || ';'
from sys.dba_views
where owner = 'VERSATA'
order by view_name;
--
set echo on
