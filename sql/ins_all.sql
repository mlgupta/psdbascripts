-- @(#)ins_all.sql	1.1 04/06/00 12:28:42

insert into files
	(db_nm, 
	ts, 
	check_date, 
	file_nm, 
	blocks)
select
	upper('&&1'), 	/*insert database link name as instance name*/
	tablespace_name, 	/*tablespace name*/
	trunc(sysdate), 	/*date query is being performed*/
	file_name, 		/*full name of database file*/
	blocks		/*number of database blocks in file*/
from sys.dba_data_files@&&1
/
commit;
rem
insert into spaces
	(db_nm, 
	check_date, 
	ts, 
	count_free_blocks, 
	sum_free_blocks, 
	max_free_blocks)
select
	upper('&&1'), 	/*insert database link name as instance name*/
	trunc(sysdate), 	/*date query is being performed*/
	tablespace_name, 	/*tablespace name*/
	count(blocks),	/*num. of free space entries in the tablespace*/
	sum(blocks), 	/*total free space in the tablespace*/
	max(blocks)		/*largest free extent in the tablespace*/
from sys.dba_free_space@&&1
group by tablespace_name
/
commit;
rem
insert into extents
	(db_nm, 
	ts, 
	seg_owner, 
	seg_name, 
	seg_type, 
	extents, 
	bytes, 
	check_date)
select
	upper('&&1'),	/*insert database link name as instance name*/
	tablespace_name, 	/*tablespace name*/
	owner, 		/*owner of the segment*/
	segment_name, 	/*name of the segment*/
	segment_type,	/*type of segment (ex. TABLE, INDEX)*/ 
	extents, 		/*number of extents in the segment*/
	bytes, 		/*number of bytes in the segment*/
	trunc(sysdate)	/*date the query is being performed*/
from sys.dba_segments@&&1
where extents>9		/*only record badly extended segments*/
or segment_type = 'ROLLBACK'	/*or rollback segments*/
/
commit;
insert into num_rows
select upper('&&1'),
   a.owner,
	a.table_name,
	a.tablespace_name,
	a.num_rows,
	a.avg_row_len,
	trunc(sysdate)
from sys.dba_tables@&&1 a, sys.dba_objects@&&1 b
where a.table_name = b.object_name
  and a.owner = b.owner
  and b.object_type = 'TABLE'
/

rem
undefine 1

