#!/bin/ksh 
#*****************************************************************************
#*                                                                           *
#* USDOL SCCS Control Information :                                          *
#* %W% %G% %U% %P%
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*                **      **   *********   ********     *********   **       *
#*               **      **   *********   **********   *********   **        *
#*              **      **   **          **      **   **     **   **         *
#*             **      **   **          **      **   **     **   **          *
#*            **      **   *********   **      **   **     **   **           *
#*           **      **   *********   **      **   **     **   **            *
#*          **      **          **   **      **   **     **   **             *
#*         **      **          **   **      **   **     **   **              *
#*        **********   *********   **********   *********   **********       *
#*        ********    *********   *********    *********   **********        *
#*                                                                           *
#***************************************************************************** 
#* This Script Refreshes BRIO database from the production database.         *
#*                                                                           *
#*  Usage :                                                                  *
#*        $ refresh_brio.ksh                                                 *
#*****************************************************************************
#*                         MODIFICATION LOG                                  *
#*                         ----------------                                  *
#*                                                                           *
#* Date     INI  CR #       Description                                      *
#* ----     ---  ----       -----------                                      *
#* 11/18/99 mlg             - Initial creation                               *
#***************************************************************************** 
USAGE="Usage : $0 " 

export mailon=0
export ORACLE_SID=hrms2 
export PATH=$PATH:/apps/oracle/product/8.0.5/bin:/usr/local/bin:/opt/bin
export ORACLE_BASE=/apps/oracle
export ORACLE_HOME=$ORACLE_BASE/product/8.0.5
#export ORAENV_ASK=NO 
#. oraenv

USERID="system/kundun"
USERID1="sysadm/xrpt2jee"
SCRIPT_BASE_DIR=/apps/oracle/local

DATE=`date +\%y%\m%\d.%R`
WORK_DIR=/u09/oradata/hrms2/export
FILE_NAME=${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}

DAY=`date +%a`

case ${DAY} in
    Sun)
        TABLE_LIST="(sysadm.ps_accomplishments, sysadm.ps_dl_employees, sysadm.ps_dl_history, sysadm.ps_employee_review, sysadm.ps_gvt_awd_data, sysadm.ps_gvt_geoloc_tbl, sysadm.ps_gvt_job, sysadm.ps_gvt_noac_tbl, sysadm.ps_gvt_pers_data, sysadm.ps_benef_plan_tbl, sysadm.ps_location_tbl, sysadm.ps_position_data, sysadm.ps_revw_rating_tbl, sysadm.ps_dept_tbl, sysadm.ps_gvt_employment, sysadm.ps_dl_payroll_data)"
        ;;
      *)
        TABLE_LIST="(sysadm.ps_accomplishments, sysadm.ps_dl_employees, sysadm.ps_employee_review, sysadm.ps_gvt_awd_data, sysadm.ps_gvt_job, sysadm.ps_gvt_pers_data, sysadm.ps_benef_plan_tbl, sysadm.ps_dept_tbl, sysadm.ps_gvt_employment, sysadm.ps_position_data)"
        ;;
esac

exp ${USERID}@${ORACLE_SID} buffer=16000000 file=${FILE_NAME}.exp log=${FILE_NAME}.log tables=${TABLE_LIST}

export ORACLE_SID=XRPT

$SCRIPT_BASE_DIR/bin/dmp2ddl.ksh ${FILE_NAME}.exp
$SCRIPT_BASE_DIR/bin/runsql.ksh "XRPT" ${FILE_NAME}.droptable.sql
$SCRIPT_BASE_DIR/bin/runsql.ksh -s "XRPT" $SCRIPT_BASE_DIR/sql/coalesce.sql
$SCRIPT_BASE_DIR/bin/runsql.ksh -s "XRPT" $SCRIPT_BASE_DIR/sql/rbs_shrink.sql
$SCRIPT_BASE_DIR/bin/runsql.ksh "XRPT" ${FILE_NAME}.mktable.sql

imp / file=${FILE_NAME}.exp fromuser=sysadm touser=sysadm ignore=y grants=n indexes=n buffer=16000000 log=${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}.log

$SCRIPT_BASE_DIR/bin/runsql.ksh "XRPT" ${FILE_NAME}.mkindex.sql

sqlplus ${USERID1} <<-EOF
start $SCRIPT_BASE_DIR/sql/syngrant_brio.sql
exit
EOF
