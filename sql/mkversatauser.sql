create user versata identified by versatahdev
default tablespace TMAPP
temporary tablespace PSTEMP
quota unlimited on TMAPP;
grant connect, resource, ps_sel to versata;
grant unlimited tablespace to versata;
