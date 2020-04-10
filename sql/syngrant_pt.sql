-- %W% %G% %U%

REM This script needs to be run as Peoplesoft Sysadm user
REM this is needed for the PL/SQL display procedure.
set serverout on size 1000000 
set echo off 
set verify off

DECLARE
-- example of a cursor to get the information you need.
CURSOR  objectlist_c is
	select a.view_name
		from all_views a
		where a.owner = 'VERSATA';
	cid	INTEGER;
	BEGIN
	/* open the new cursor and return cursor ID. */
	cid  := DBMS_SQL.OPEN_CURSOR;
	-- now get all the rows, and do ddl for each row.
	FOR objectlist_rec in objectlist_c  LOOP
		BEGIN
		dbms_output.put_line('grant select ' ||
					'on ' ||
					objectlist_rec.view_name ||
					' to versata');
		DBMS_SQL.PARSE(cid, 'grant select ' ||
					'on ' ||
					objectlist_rec.view_name ||
					' to versata',
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END LOOP;

	DBMS_SQL.CLOSE_CURSOR(cid);
	END;
/

