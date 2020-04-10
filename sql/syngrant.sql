-- @(#)syngrant.sql	1.1 04/06/00 12:28:45

set serveroutput on size 1000000

DECLARE
-- example of a cursor to get the information you need.
CURSOR  objectlist_c is
	select u.username, o.object_name, o.object_type
		from user_objects o, user_users u
		where o.object_type in ('TABLE', 'VIEW', 'CLUSTER')
		-- AND o.object_name like 'PSA%'
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
/*
		dbms_output.put_line('create public synonym ' ||
					objectlist_rec.object_name ||
					' for ' || objectlist_rec.username ||
					'.' || objectlist_rec.object_name);
*/
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
/*
		dbms_output.put_line('grant select ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_sel');
*/
		DBMS_SQL.PARSE(cid, 'grant select ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_sel',
					dbms_sql.v7);
/*
		dbms_output.put_line('grant select, update ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_upd');
*/
		DBMS_SQL.PARSE(cid, 'grant select, update ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_upd',
					dbms_sql.v7);
/*
		dbms_output.put_line('grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_dml');
*/
		DBMS_SQL.PARSE(cid, 'grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_dml',
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
