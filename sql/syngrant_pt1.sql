-- %W% %G% %U%

REM This script needs to be run as Versata user

set serveroutput on size 1000000

DECLARE
-- example of a cursor to get the information you need.
CURSOR  objectlist_c is
	select u.username, o.object_name, o.object_type
		from user_objects o, user_users u
		where o.object_type = 'TABLE'
		order by o.object_name;
	cid	INTEGER;
	cid2	INTEGER;
	BEGIN
	/* open the new cursor and return cursor ID. */
	cid  := DBMS_SQL.OPEN_CURSOR;
	cid2 := DBMS_SQL.OPEN_CURSOR;
	-- now get all the rows, and do ddl for each row.
	FOR objectlist_rec in objectlist_c  LOOP
		BEGIN
		DBMS_SQL.PARSE(cid, 'create public synonym ' ||
					objectlist_rec.object_name ||
					' for ' || objectlist_rec.username ||
					'.' || objectlist_rec.object_name,
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
		BEGIN
		DBMS_SQL.PARSE(cid, 'grant select ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to pt_sel',
					dbms_sql.v7);
		DBMS_SQL.PARSE(cid, 'grant select, update ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to pt_upd',
					dbms_sql.v7);
		DBMS_SQL.PARSE(cid, 'grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to pt_dml',
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(cid);
	DBMS_SQL.CLOSE_CURSOR(cid2);
	END;
/
