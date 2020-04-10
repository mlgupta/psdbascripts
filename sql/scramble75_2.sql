update ps_pers_data_effdt
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    last_name_srch = 'LAST'||emplid,
    first_name_srch = 'FIRST'||emplid,
    last_name = 'LAST'||emplid,
    first_name = 'FIRST'||emplid,
    middle_name = 'MID'||emplid
where substr(emplid,1,3) = '000';


update ps_dependent_benef
set name = 'LAST'||emplid||','||'FIRST'||emplid
where substr(emplid,1,3) = '000';


update ps_disciplin_step
set name = 'LAST'||emplid||','||'FIRST'||emplid
where substr(emplid,1,3) = '000';

update ps_dl_appraisals
set name = 'LAST'||emplid||','||'FIRST'||emplid
where substr(emplid,1,3) = '000';


update ps_employees
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    national_id = lpad(to_char(to_number(emplid) + 23), 9,'0')
where substr(emplid,1,3) = '000';


update ps_dl_employees
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    national_id = lpad(to_char(to_number(emplid) + 23), 9,'0')
where substr(emplid,1,3) = '000';

update ps_dl_payroll_data
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    ssn = lpad(to_char(to_number(emplid) + 23), 9,'0')
where substr(emplid,1,3) = '000';

update ps_dl_payroll_data
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    ssn = '999999999' 
where length(emplid) <> 8;

update ps_dl_posn_budget
set name = 'LAST'||emplid||','||'FIRST'||emplid,
    oprid = substr(emplid,1,8)
where rtrim(emplid,' ') is not null;
