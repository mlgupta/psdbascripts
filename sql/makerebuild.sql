-- @(#)makerebuild.sql	1.1 04/06/00 12:28:43

set heading off pagesize 0

column block_KB new_value block_KB
select value/1024 block_KB from v$parameter where name = 'db_block_size';

column coalesce fold_b
select 'alter index ' || owner || '.' ||segment_name ||
	' rebuild noparallel tablespace ' ||
	-- tablespace_name,
	decode(sign(bytes-1024000),-1,'PSINDEX','PSINDBIG') ,
	' storage( initial ' || 
	decode(sign((bytes/1024)-100000),1,100000,bytes/1024) ||
	'K next ' || next_extent/1024 || 'K',
	'maxextents unlimited pctincrease 0);',
'alter tablespace ' || tablespace_name || ' coalesce;' coalesce
from dba_segments
where owner = 'SYSADM'
and segment_type = 'INDEX'
and (
	extents >1
	OR tablespace_name not in ('PSINDEX', 'PSINDBIG')
	OR ( bytes >= 1024000
		AND tablespace_name not in ( 'PSINDBIG')
	    )
     )
order by blocks desc
/

select 'alter index ' || owner || '.' ||segment_name ||
	' rebuild noparallel tablespace ' || 'RPTMART',
	-- tablespace_name,
	-- decode(sign(bytes-1024000),-1,'PSINDEX','PSINDBIG') ,
	' storage( initial ' || 
	decode(sign((bytes/1024)-100000),1,100000,bytes/1024) ||
	'K next ' || next_extent/1024 || 'K',
	'maxextents unlimited pctincrease 0);',
'alter tablespace ' || tablespace_name || ' coalesce;' coalesce
from dba_segments
where owner = 'RPTMART'
and segment_type = 'INDEX'
and (
	extents >1
	OR tablespace_name != 'RPTMART'
     )
order by blocks desc
/
column coalesce clear
