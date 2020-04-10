-- @(#)pslock.sql	1.1 04/06/00 12:28:43

select 'grant select on sysadm.pslock to ' || oprid || ';' from psoprdefn
/
