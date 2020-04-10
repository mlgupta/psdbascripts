-- @(#)row_archive.sql	1.1 06/13/00 15:40:20
-- Num Rows Archive program.  Remove all data except monthy totals
delete from num_rows
where trunc(check_date) < trunc(sysdate-28)
and trunc(check_date) not in
	(select max(check_date) from num_rows
		where to_char(check_date,'MM') 
		in ('01','02','03','04','05','06','07','08',
			'09','10','11','12')
	 group by to_char(check_date,'MM')
	)
/
exit
