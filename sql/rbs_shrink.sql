-- @(#)rbs_shrink.sql	1.1 04/06/00 12:28:44

set serveroutput on size 1000000

DECLARE
-- example of a cursor to get the information you need.
CURSOR  segment_name_c is
	select segment_name, status from sys.dba_rollback_segs
		-- where status='ONLINE'
		order by segment_name;
	cid	INTEGER;
	BEGIN
	/* open the new cursor and return cursor ID. */
	cid := DBMS_SQL.OPEN_CURSOR;
	-- now get all the rows, and do ddl for each row.
	FOR segment_name_rec in segment_name_c  LOOP
		IF segment_name_rec.status <> 'ONLINE'
		THEN
		DBMS_SQL.PARSE(cid, 'ALTER rollback segment ' ||
					segment_name_rec.segment_name ||
					' ONLINE',
					dbms_sql.v7);
		END IF;
		dbms_output.put_line('alter rollback segment ' ||
					segment_name_rec.segment_name ||
					' shrink');
		DBMS_SQL.PARSE(cid, 'ALTER rollback segment ' ||
					segment_name_rec.segment_name ||
					' SHRINK',
					dbms_sql.v7);
		IF segment_name_rec.status <> 'ONLINE'
		THEN
		DBMS_SQL.PARSE(cid, 'ALTER rollback segment ' ||
					segment_name_rec.segment_name ||
					' OFFLINE',
					dbms_sql.v7);
		END IF;
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(cid);
	END;
/

