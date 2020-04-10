create or replace view ts_frag as
select tablespace_name, sum(bytes) tot, count(*) cnt, max(bytes) big
from dba_free_space
group by tablespace_name;
create public synonym ts_frag for ts_frag;
grant select on ts_frag to public;

