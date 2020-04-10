-- @(#)cleanprcs.sql	1.1 02/02/01 11:28:16

delete from sysadm.psprcsrqst where rundttm < sysdate - 7;
commit;
