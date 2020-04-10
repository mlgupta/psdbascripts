-- @(#)syngrant_brio.sql	1.37 05/06/02 13:27:15

REM this is needed for the PL/SQL display procedure.
set serverout on size 1000000 
set echo off 
set verify off

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
					' to brio_select');
		DBMS_SQL.PARSE(cid, 'grant select ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to brio_select',
					dbms_sql.v7);
		dbms_output.put_line('grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to brio_update');
		DBMS_SQL.PARSE(cid, 'grant select, insert, update, delete ' ||
					'on ' ||
					objectlist_rec.object_name ||
					' to brio_update',
					dbms_sql.v7);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END LOOP;

   BEGIN
	    DBMS_SQL.PARSE(cid, 'grant select on access_sep_rate_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_113_turn_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_113a_detail_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_113g_detail_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_awards_appraisals_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_comp_projctn_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_dept_hier_descr to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_current_employees_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_fte_projctn_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_history_dep_info_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_history_poi_info_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_history_sub_info_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_history_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_staffing_history_sbq to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_staffing_history_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_staffing_history_vw2 to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on br_security_wa_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_training_cost_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_training_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on curr_posn_data_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_appraisal_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_brio_accsep_oct01_poi_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_brio_accsep_oct01_sub_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_brio_accsep_poi_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_brio_accsep_sub_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_curr_pos_data to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_current_wl_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_employee_phone_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_fy99_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_fy9399_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_pt_in_time_oct95_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_pt_in_time_oct96_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_pt_in_time_oct97_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_pt_in_time_oct98_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_pt_in_time_oct01_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on dl_separations_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on emp_locator to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on emp_locator_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_benef_plan_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_dept_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_gvt_geoloc_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_gvt_noac_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_jobcode_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_location_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_position_data to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on ps_revw_rating_tbl to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on qsi_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on sub_agency_ceil to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on terminations_dt_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on xlattable to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_tsp_data_vw to brio_end_user', dbms_sql.v7);
	    DBMS_SQL.PARSE(cid, 'grant select on brio_workflow_vw to brio_end_user', dbms_sql.v7);
	EXCEPTION
	    WHEN OTHERS THEN
		 DBMS_OUTPUT.PUT_LINE (SQLERRM);
	END;

	DBMS_SQL.CLOSE_CURSOR(cid);
	DBMS_SQL.CLOSE_CURSOR(cid2);
	END;
/

