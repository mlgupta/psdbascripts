-- @(#)tabfreespace.sql	1.1 04/06/00 12:28:46

undef tabname 
undef type

declare
	OP1 number;
	OP2 number;
	OP3 number;
	OP4 number;
	OP5 number;
	OP6 number;
	OP7 number;
	newfree number;
begin
dbms_space.unused_space('SYSADM',upper('&&tabname'), upper('&&type'),
			 OP1, OP2, OP3, OP4, OP5, OP6, OP7);
dbms_output.put_line('OBJECT_NAME           = upper(&tabname)');
dbms_output.put_line('--------------------------------');
dbms_output.put_line('TOTAL_K        = '||OP2/1024);
dbms_output.put_line('USED_K         = '||(OP2 - OP4)/1024);
dbms_output.put_line('UNUSED_K       = '||OP4/1024);

end;
/
