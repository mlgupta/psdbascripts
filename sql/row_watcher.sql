-- @(#)row_watcher.sql	1.7 01/14/01 03:27:51

column db_nm format A8
column tablespace_name format A18
column table_owner format a14
column table_name format a18
column avg_row_len format 9999 head "Avg Row Len|Bytes"
column week4 format 99990.9 heading "4Wk|Ago"
column week3 format 99990.9 heading "3Wks|Ago"
column week2 format 99990.9 heading "2Wks|Ago"
column week1 format 99990.9 heading "1Wks|Ago"
column today format 99990.9
column diff format 999990 head "% Inc"

set pagesize 60 linesize 132
break on db_nm skip 2 on table_owner skip 1 on report 
ttitle center 'Tables whose row count has increased by 5%' skip 2

select 
	num_rows.db_nm,
	num_rows.table_owner,
	num_rows.tablespace_name,
	num_rows.table_name,
	max(decode(num_rows.check_date, trunc(sysdate-28),
		round(num_rows/1000,1),0)) week4,
	max(decode(num_rows.check_date, trunc(sysdate-21),
		round(num_rows/1000,1),0)) week3,
	max(decode(num_rows.check_date, trunc(sysdate-14),
		round(num_rows/1000,1),0)) week2,
	max(decode(num_rows.check_date, trunc(sysdate-7),
		round(num_rows/1000,1),0)) week1,
	max(decode(num_rows.check_date, trunc(sysdate),
		round(num_rows/1000,1),0)) today,
	(max(decode(num_rows.check_date, trunc(sysdate),
		num_rows,0)) -
	max(decode(num_rows.check_date, trunc(sysdate-28),
		num_rows,0))) /
	max(decode(num_rows.check_date, trunc(sysdate),
		num_rows,0)) * 100 diff
from num_rows
where exists 	/*did this segment show up today during the inserts?*/
	(select 'x' from num_rows x
	where x.db_nm = num_rows.db_nm
	and x.tablespace_name = num_rows.tablespace_name
	and x.table_owner = num_rows.table_owner
	and x.table_name = num_rows.table_name
	and x.check_date = trunc(sysdate))
and num_rows >= 1000
group by 
	num_rows.db_nm, 
	num_rows.table_owner, 
	num_rows.tablespace_name,
	num_rows.table_name
having
	max(decode(num_rows.check_date, trunc(sysdate),
		num_rows/1000,0)) > 0
and
	((max(decode(num_rows.check_date, trunc(sysdate),
		num_rows,0)) -
	max(decode(num_rows.check_date, trunc(sysdate-28),
		num_rows,0))) /
	max(decode(num_rows.check_date, trunc(sysdate),
		num_rows,0)) * 100 ) >= 5
order by 
	((max(decode(num_rows.check_date, trunc(sysdate),
		num_rows,0)) -
	max(decode(num_rows.check_date, trunc(sysdate-28),
		num_rows,0))) /
	max(decode(num_rows.check_date, trunc(sysdate),
		num_rows,0)) * 100 ) desc,
	num_rows.db_nm desc
/
