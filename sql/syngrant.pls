CREATE OR REPLACE PROCEDURE syngrantl AS
  v_fh utl_file.file_type;
  v_buffer VARCHAR2(240);
  v_fname  VARCHAR2(60);
  v_fpath CONSTANT VARCHAR2(60) := '/var/runlog';
  unix_pid VARCHAR2(12);
  PROGNAME CONSTANT VARCHAR2(20) := 'syngrant.pls';
-- example of a cursor to get the information you need.
  CURSOR  objectlist_c is
    SELECT u.username, o.object_name, o.object_type
		FROM user_objects o, user_users u
	  WHERE o.object_type in ('TABLE', 'VIEW', 'CLUSTER')
	  ORDER by o.object_name;
  cid	 INTEGER;
  cid2 INTEGER;
BEGIN
-- Get the UNIX process id for the log file
  SELECT b.spid
    INTO unix_pid
    FROM sys.v_$session a, sys.v_$process b
   WHERE a.paddr = b.addr
     AND a.audsid = userenv('SESSIONID');
  v_fname := progname||'_'||unix_pid||'.log';
  v_fh := utl_file.fopen(v_fpath,v_fname,'w');
  v_buffer := 'Program '||progname||' started on '||
              to_char(sysdate,'FMDy Month DD, YYYY HH:MI:SS')||'.';
  utl_file.put_line(v_fh,v_buffer);
  v_buffer := 'Running on UNIX process '||unix_pid||'.';
  utl_file.put_line(v_fh,v_buffer);
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
-- End the program and close the logfile
	v_buffer := 'Program '||progname||' finished on '||
              to_char(sysdate,'FMDy Month DD, YYYY HH:MI:SS')||'.';
	utl_file.put_line(v_fh,v_buffer);
	utl_file.fclose(v_fh);
END;
/
