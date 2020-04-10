-- @(#)coalesce.sql	1.1 04/06/00 12:28:39

set serveroutput on size 1000000

DECLARE
CURSOR  tablespacelist_c is
	select tablespace_name from sys.dba_tablespaces
		order by tablespace_name;
	cid	INTEGER;
	BEGIN
	/* open the new cursor and return cursor ID. */
	cid := DBMS_SQL.OPEN_CURSOR;
	FOR tablespace_name_rec in tablespacelist_c  LOOP
		dbms_output.put_line('coalesce tablespace ' ||
					tablespace_name_rec.tablespace_name);
		DBMS_SQL.PARSE(cid, 'ALTER TABLESPACE ' ||
					tablespace_name_rec.tablespace_name ||
					' COALESCE',
					dbms_sql.v7);
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(cid);
	END;
/

