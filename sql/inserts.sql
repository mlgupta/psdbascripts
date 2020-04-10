-- @(#)inserts.sql	1.2 07/18/00 13:54:28

set verify off
set echo off
@ins_all hrms2
@ext_watcher
@space_watcher
@row_watcher
@row_archive
exit

