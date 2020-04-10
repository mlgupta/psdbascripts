update ps_cbr_empl_manual
set paycheck_name = 'LAST'||emplid||','||'FIRST'||emplid;

update ps_employment
set paycheck_name = 'LAST'||emplid||','||'FIRST'||emplid;

update ps_gvt_curr_emplmt
set paycheck_name = 'LAST'||emplid||','||'FIRST'||emplid;

update ps_gvt_employment
set paycheck_name = 'LAST'||emplid||','||'FIRST'||emplid;

update ps_pay_check
set paycheck_name = 'LAST'||emplid||','||'FIRST'||emplid;
