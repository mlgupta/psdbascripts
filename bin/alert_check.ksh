#!/bin/ksh

# @(#)alert_check.ksh	1.3 08/29/00 10:53:10

. ~oracle/.profile >/dev/null 2>&1
. ~oracle/.kshrc >/dev/null 2>&1

# Include the standard functions
if [ -s $ORACLE_BASE/local/bin/stdfunc.ksh ]
then
	. $ORACLE_BASE/local/bin/stdfunc.ksh 2>/dev/null
fi
# Start the log file in the runlog directory
if [  ! -d /var/runlog ]
then
	mkdir /var/runlog 2>/dev/null 
fi
export logfile=/var/runlog/`basename $0`_$$.log
# Set mailon to 1 to send mail and 0 to turn off mail
export mailon=1

main () {
	startup
	START_TIME=$(date +%a%b%d%Y.%T)
	for ORACLE_SID in "$@"
	do
		bdump_dir=$ORACLE_BASE/admin/$ORACLE_SID/bdump
		GZIP=$(whence gzip) || GZIP=/usr/bin/gzip >>$logfile 2>&1

	ALERT_LOGFILE=alert_$ORACLE_SID.log

	cd $bdump_dir>>$logfile 2>&1
	mv $ALERT_LOGFILE ${ALERT_LOGFILE}.${START_TIME}>>$logfile 2>&1
	echo "alert logfile started at $(date)." >> $ALERT_LOGFILE
	echo "old alert.log file copied to ${ALERT_LOGFILE}.${START_TIME}." \
		>> $ALERT_LOGFILE
	chmod o-w ${ALERT_LOGFILE}*	#### make all files unwritable for "others".
					#### note: "user" and "group" unchanged.

	### now print out the old alert.log file.
   cat $ALERT_LOGFILE.${START_TIME}|grep "ORA-" >>$logfile 2>&1
   if [ $? -eq 0 ]
   then
     echo >>$logfile 2>&1
     echo ">>>>> Errors encountered...See above. <<<<<">>$logfile 2>&1
     export error_cnt=`expr ${error_cnt:-0} + 1`
   else
     echo "No errors encountered. ">>$logfile 2>&1
   fi

	(( $# > 0 )) && echo "########################################" >>$logfile 2>&1
	$GZIP -v $ALERT_LOGFILE.${START_TIME}>>$logfile 2>&1
	(( $# > 0 )) && echo "########################################" >>$logfile 2>&1

  done
  testerr $?
  endup ${error_cnt:-0}
}
main $@
