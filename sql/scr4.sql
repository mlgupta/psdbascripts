update ps_gvt_pers_nid
set national_id = lpad(to_char(to_number(emplid) + 23), 9,'0')
where substr(emplid,1,3) = '000';
