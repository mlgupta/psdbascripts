update ps_personal_data
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    last_name_srch = 'LAST'||emplid,
    first_name_srch = 'FIRST'||emplid
where substr(emplid,1,3) = '000';
