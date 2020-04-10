update ps_gvt_pers_data
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    last_name_srch = 'LAST'||emplid,
    first_name_srch = 'FIRST'||emplid
where substr(emplid,1,3) = '000';

update ps_personal_data
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    last_name_srch = 'LAST'||emplid,
    first_name_srch = 'FIRST'||emplid
where substr(emplid,1,3) = '000';


update ps_gvt_pers_nid
set national_id = lpad(to_char(to_number(emplid) + 23), 9,'0')
where substr(emplid,1,3) = '000';

update ps_pers_nid
set national_id = lpad(to_char(to_number(emplid) + 23), 9,'0')
where substr(emplid,1,3) = '000';
