-- @(#)syngrantproc.sql	1.1 04/06/00 12:28:46

REM this is needed for the PL/SQL display procedure.
set serveroutput on size 1000000

CREATE or REPLACE PROCEDURE SYSADM.SYNGRANT (tabname in varchar2 DEFAULT NULL)
	IS
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
	IF tabname IS NULL THEN
	-- now get all the rows, and do ddl for each row.
	FOR objectlist_rec in objectlist_c  LOOP
		BEGIN
		dbms_output.put_line('create public synonym ' ||
					objectlist_rec.object_name ||
					' for ' || objectlist_rec.username ||
					'.' || objectlist_rec.object_name);
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
		dbms_output.put_line('grant select ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_select');
		DBMS_SQL.PARSE(cid, 'grant select ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_select',
					dbms_sql.v7);
		dbms_output.put_line('grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_update');
		DBMS_SQL.PARSE(cid, 'grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to ps_update',
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END lOOP;
	ELSE
		BEGIN
		dbms_output.put_line('create public synonym ' ||
					upper(tabname) || 
					' for ' || 
					'SYSADM.' || upper(tabname) );
		DBMS_SQL.PARSE(cid, 'create public synonym ' ||
					upper(tabname) || 
					' for ' || 
					'SYSADM.' || upper(tabname),
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
		BEGIN
		dbms_output.put_line('grant select ' ||
					'on ' ||
					'SYSADM.' || upper(tabname) ||
					' to ps_select');
		DBMS_SQL.PARSE(cid, 'grant select ' ||
					'on ' ||
					'SYSADM.' || upper(tabname) ||
					' to ps_select',
					dbms_sql.v7);
		dbms_output.put_line('grant select, insert, update, delete ' ||
					'on ' ||
					'SYSADM.' || upper(tabname) ||
					' to ps_update');
		DBMS_SQL.PARSE(cid, 'grant select, insert, update, delete ' ||
					'on ' ||
					'SYSADM.' || upper(tabname) ||
					' to ps_update',
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;

		END;
	END IF;
	DBMS_SQL.CLOSE_CURSOR(cid);
	DBMS_SQL.CLOSE_CURSOR(cid2);
END SYNGRANT;
/

grant execute on SYSADM.SYNGRANT to ps_update, ps_select;
