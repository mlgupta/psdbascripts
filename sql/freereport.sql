-- @(#)freereport.sql	1.1 04/06/00 12:28:41

column block_KB new_value block_KB
column sqlfile  new_value sqlfile
select value/1024 block_KB,
	decode(value,2048,'freereport2k',8192,'freereport8k') sqlfile
 from v$parameter where name = 'db_block_size';

@ &sqlfile
