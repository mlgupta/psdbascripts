#!/bin/ksh 

# @(#)refresh_brio_drpt.ksh	1.5 05/14/02 11:30:01
#set -x

# This script should contain seperate lists of tables to be refreshed.
# There should be no overlap since all of the daily tables will be included in any
# weekly or specific day refreshes.

. ~oracle/.profile >/dev/null 2>&1
. ~oracle/.kshrc >/dev/null 2>&1

# For debuging purposes only should be commented out
#export DEBUG=true

testerror () {
  runstat="$1"
  if [ $runstat -ne 0 ]
  then
    mailon=1
    endup $runstat
  fi
}

export mailon=0
export ORACLE_SID=$1
USERID="system/kundun"

case $(hostname) in
    pssvr03) WORK_DIR=/u01/oradata/$1/exp
             export mailto="${mailto} willett-mary@dol.gov hines-william-m@dol.gov montalto-giuseppe@dol.gov "
             ;;
    pssvr01) WORK_DIR=/u01/oradata/$1/exp
             export mailto="${mailto} hines-william-m@dol.gov montalto-giuseppe@dol.gov "
             ;;
esac

# Include the standard functions
if [ -s $ORACLE_BASE/local/bin/stdfunc.ksh ]
then
   . $ORACLE_BASE/local/bin/stdfunc.ksh 2>/dev/null
fi

SCRIPT_BASE_DIR=$ORACLE_BASE/local
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/opt/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
DATE=`date +\%y%\m%\d.%R`
FILE_NAME=${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}
DOM=`date +%e`
DAY=`date +%a`
export logfile=/var/runlog/`basename $0`_$$.log

startup
case ${DAY} in
    Sat)
        TABLE_LIST=",sysadm.ps_actn_reason_tbl,sysadm.ps_dl_history,sysadm.ps_emergency_cntct,sysadm.ps_gvt_geoloc_tbl,sysadm.ps_gvt_noac_tbl,sysadm.ps_gvt_pers_phone,sysadm.ps_gvt_tsp_inv_dta,sysadm.ps_location_tbl,sysadm.ps_revw_rating_tbl,sysadm.ps_rtrmnt_plan,sysadm.ps_savings_plan,sysadm.xlattable"
        ;;
esac

case $DOM in
    13)
       TABLE_LIST="$TABLE_LIST,sysadm.ps_dl_113g_detail,sysadm.ps_dl_sf113a_rptg,sysadm.ps_dl_sf113a_turn"
       ;;
esac

TABLE_LIST="(sysadm.ps_accomplishments,sysadm.ps_benef_plan_tbl,sysadm.ps_dept_tbl,sysadm.ps_dl_employees,sysadm.ps_dl_pbm_cmp_brio,sysadm.ps_dl_pbm_fte_brio,sysadm.ps_dl_posn_budget,sysadm.ps_dl_training,sysadm.ps_dl_trng_acct_cd,sysadm.ps_dl_trng_cost,sysadm.ps_employee_review,sysadm.ps_employment,sysadm.ps_gvt_awd_data,sysadm.ps_gvt_ee_data_wl,sysadm.ps_gvt_employment,sysadm.ps_gvt_job,sysadm.ps_gvt_joberns,sysadm.ps_gvt_occupation,sysadm.ps_gvt_pers_data,sysadm.ps_job,sysadm.ps_jobcode_tbl,sysadm.ps_personal_data,sysadm.ps_position_data,sysadm.ps_rolexlatopr,sysadm.psoprdefn,sysadm.pstreenode,sysadm.ps_gvt_ee_data_trk,sysadm.psworklist$TABLE_LIST)"


exp ${USERID}@${ORACLE_SID} buffer=16000000 file=${FILE_NAME}.exp log=${FILE_NAME}.log tables=${TABLE_LIST}

testerror $?

case $(hostname) in
    pssvr03) export ORACLE_SID=hrpt2
             USERID1="sysadm/xxxx"
             export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
             export PATH=$ORACLE_HOME/bin:$PATH
             ;;
    pssvr01) export ORACLE_SID=drpt
             USERID1="sysadm/drioste1"
             export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
             export PATH=$ORACLE_HOME/bin:$PATH
             ;;
esac

$SCRIPT_BASE_DIR/bin/dmp2ddl.ksh ${FILE_NAME}.exp
testerror $?

$DEBUG $SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} ${FILE_NAME}.droptable.sql
$DEBUG $SCRIPT_BASE_DIR/bin/runsql.ksh -s ${ORACLE_SID} $SCRIPT_BASE_DIR/sql/coalesce.sql
$DEBUG $SCRIPT_BASE_DIR/bin/runsql.ksh -s ${ORACLE_SID} $SCRIPT_BASE_DIR/sql/rbs_shrink.sql
$DEBUG $SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} ${FILE_NAME}.mktable.sql
$DEBUG testerror $?

$DEBUG imp ${USERID}@${ORACLE_SID} file=${FILE_NAME}.exp fromuser=sysadm touser=sysadm ignore=y grants=n indexes=n buffer=16000000 log=${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}.log

$DEBUG grep "Import terminated successfully without warnings" ${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}.log

DEBUG runstat=$?

if [ $runstat -ne 0 ]
then
    testerror 1
fi

$DEBUG $SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} ${FILE_NAME}.mkindex.sql
testerror $?

$DEBUG $SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} analyze8i.sql
testerror $?

$DEBUG sqlplus ${USERID1}@${ORACLE_SID} <<-EOF
start $SCRIPT_BASE_DIR/sql/syngrant_brio.sql
exit
EOF

# Added by JVB 12/13/01 to reduce wasted space
$DEBUG gzip ${FILE_NAME}.exp

$DEBUG export mailon=1
endup 0
