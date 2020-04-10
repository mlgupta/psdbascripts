#!/bin/ksh 
# @(#)refresh_113.ksh	1.1 04/11/02 11:04:43

# This script will refresh the subset of 113 tables for brio and can be run if these
# tables need to be refreshed outside of the normal schedule

. ~oracle/.profile >/dev/null 2>&1
. ~oracle/.kshrc >/dev/null 2>&1

testerror () {
  runstat="$1"
  if [ $runstat -ne 0 ]
  then
    mailon=1
    endup $runstat
  fi
}

export mailon=0
export ORACLE_SID=hrms2 
USERID="system/kundun"

case $(hostname) in
    pssvr03) WORK_DIR=/u01/oradata/hrms2/exp
             ;;
esac

# Include the standard functions
if [ -s $ORACLE_BASE/local/bin/stdfunc.ksh ]
then
   . $ORACLE_BASE/local/bin/stdfunc.ksh 2>/dev/null
fi

export mailto="${mailto}"

SCRIPT_BASE_DIR=$ORACLE_BASE/local
export PATH=$ORACLE_HOME/bin:/usr/local/bin:/opt/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
DATE=`date +\%y%\m%\d.%R`
FILE_NAME=${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}
DOM=`date +%e`
DAY=`date +%a`
export logfile=/var/runlog/`basename $0`_$$.log

startup

TABLE_LIST="(sysadm.ps_dl_113g_detail,sysadm.ps_dl_sf113a_rptg,sysadm.ps_dl_sf113a_turn)"

exp ${USERID}@${ORACLE_SID} buffer=16000000 file=${FILE_NAME}.exp log=${FILE_NAME}.log tables=${TABLE_LIST}

testerror $?

case $(hostname) in
    pssvr03) export ORACLE_SID=hrpt2
             USERID1="sysadm/hrpt3aud"
             export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
             export PATH=$ORACLE_HOME/bin:$PATH
             ;;
esac

$SCRIPT_BASE_DIR/bin/dmp2ddl.ksh ${FILE_NAME}.exp
testerror $?

$SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} ${FILE_NAME}.droptable.sql
$SCRIPT_BASE_DIR/bin/runsql.ksh -s ${ORACLE_SID} $SCRIPT_BASE_DIR/sql/coalesce.sql
$SCRIPT_BASE_DIR/bin/runsql.ksh -s ${ORACLE_SID} $SCRIPT_BASE_DIR/sql/rbs_shrink.sql
$SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} ${FILE_NAME}.mktable.sql
testerror $?

imp ${USERID}@${ORACLE_SID} file=${FILE_NAME}.exp fromuser=sysadm touser=sysadm ignore=y grants=n indexes=n buffer=16000000 log=${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}.log

grep "Import terminated successfully without warnings" ${WORK_DIR}/${ORACLE_SID}_BRIO_${DATE}.log

runstat=$?

if [ $runstat -ne 0 ]
then
    testerror 1
fi

$SCRIPT_BASE_DIR/bin/runsql.ksh ${ORACLE_SID} ${FILE_NAME}.mkindex.sql
testerror $?

sqlplus ${USERID1}@${ORACLE_SID} <<-EOF
start $SCRIPT_BASE_DIR/sql/syngrant_brio.sql
exit
EOF

# Added by JVB 12/13/01 to reduce wasted space
gzip ${FILE_NAME}.exp

export mailon=1
endup 0
