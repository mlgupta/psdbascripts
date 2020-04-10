-- @(#)ext_watcher.sql	1.1 04/06/00 12:28:40

column db_nm format A8 head "Database"
column ts format A12 head "Tablespace"
column seg_owner format a14 head "Seg Owner"
column seg_name format a20 head "Seg Name"
column seg_type format a9 head "Seg Type"
column megs format 99999 head Megs
column week4 format 9999 heading "1Wk|Ago"
column week3 format 9999 heading "2Wks|Ago"
column week2 format 9999 heading "3Wks|Ago"
column week1 format 9999 heading "4Wks|Ago"
column today format 9999 head "Today"
column change format 9999 head "Change"

set pagesize 60 linesize 132
break on db_nm skip 2 on seg_owner skip 1 on ts on report
ttitle center 'Segments whose extent count is over 10' skip 2

select 
	extents.db_nm,
	extents.seg_owner,
	extents.ts ts,
	extents.seg_name,
	extents.seg_type,
	max(decode(extents.check_date, trunc(sysdate),
		bytes/1024/1024,0)) megs, 
	max(decode(extents.check_date, trunc(sysdate-28),
		extents,0)) week1,
	max(decode(extents.check_date, trunc(sysdate-21),
		extents,0)) week2,
	max(decode(extents.check_date, trunc(sysdate-14),
		extents,0)) week3,
	max(decode(extents.check_date, trunc(sysdate-7),
		extents,0)) week4,
	max(decode(extents.check_date, trunc(sysdate),
		extents,0)) today,
	max(decode(extents.check_date, trunc(sysdate),
		extents,0)) -
	max(decode(extents.check_date, trunc(sysdate-28),
		extents,0)) change
from extents
where exists 	/*did this segment show up today during the inserts?*/
	(select 'x' from extents x
	where x.db_nm = extents.db_nm
	and x.ts = extents.ts
	and x.seg_owner = extents.seg_owner
	and x.seg_name = extents.seg_name
	and x.seg_type = extents.seg_type
	and x.check_date = trunc(sysdate))
	and extents.seg_type != 'ROLLBACK'
group by 
	extents.db_nm, 
	extents.seg_owner, 
	extents.ts,
	extents.seg_name, 
	extents.seg_type
order by extents.db_nm, extents.seg_owner, decode(
	max(decode(extents.check_date,trunc(sysdate), 
		extents,0)) -
	max(decode(extents.check_date, trunc(sysdate-28),
		extents,0)),0,-9999,
	max(decode(extents.check_date,trunc(sysdate), 
		extents,0)) -
	max(decode(extents.check_date, trunc(sysdate-28),
		extents,0))) desc,
	max(decode(extents.check_date,trunc(sysdate), 
		extents,0)) desc
/
