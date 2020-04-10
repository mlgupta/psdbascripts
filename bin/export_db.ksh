#! /bin/ksh
 
# @(#)export_db.ksh	1.13 02/28/02 09:34:42

# 	$1 = Oracle SID's 
#	$2 = Number of days to keep the files
 
. ~oracle/.profile >/dev/null 2>&1
. ~oracle/.kshrc >/dev/null 2>&1
 
# Include the standard functions
if [ -s $ORACLE_BASE/local/bin/stdfunc.ksh ]
then
	. $ORACLE_BASE/local/bin/stdfunc.ksh 2>/dev/null
fi
# Start the log file in the runlog directory
if [ ! -d /var/runlog ]
then
	mkdir /var/runlog 2>/dev/null 
fi
export logfile=/var/runlog/`basename $0`_$$.log
# Set mailon to 1 to send mail and 0 to turn off mail
export mailon=1
 
# Function: getsids() - returns the SID's of the running ORACLE instances.
#                       You can pass a program name as a parameter.
# Usage:    getsids [program] 
# Example:  getsids shutdwn  - Shuts down all running ORACLE instances.
getsids () {
ORATAB=/var/opt/oracle/oratab		# location of the oratab file

if [ -r $ORATAB ]; then
	grep -v "^#" $ORATAB |grep -v "\*"| grep "^.*:.*:.*" | while read LINE
	do
		ORASID=`echo $LINE | awk -F: '{print $1}' -`
		ORAHOME=`echo $LINE | awk -F: '{print $2}' -`
		UPFLAG=`echo $LINE | awk -F: '{print $3}' -`
		if [ $UPFLAG = "Y" ]
		  then
		      echo "$ORASID" \\c
		fi
	done
	unset ORASID
	unset ORAHOME
	unset LINE
   unset PROGRAM
fi
unset ORATAB
}

main () {
	startup
   if [ $# -eq 0 ] 
   then
		SID_LIST=`getsids`
	   integer NUM_DAYS=3
   else 
	  SID_LIST="$1"
	  integer NUM_DAYS=$2
   fi
	DATE=`date +\%y%\m%\d.%R`
 
	PATH=$PATH:/usr/local/bin:/opt/bin
 
	# the number of days (find cmd) to keep old dmp files.
	# now set above. NUM_DAYS=$2
 
	DATE=$(date +%y\%m\%d.%R)
 
	for ORACLE_SID in $SID_LIST
	do 
		LOGFILE=${ORACLE_SID}_exp${DATE}.log
 
		case $(hostname) in
			pssvr01) LOGDIR=$ORACLE_BASE/local/export_log
				EXP_PATH=/u01/oradata/$ORACLE_SID/exp
				whence gzip 1>/dev/null 2>&1 \
					|| alias gzip=/usr/sbin/gzip
				;;
			pssvr02) LOGDIR=$ORACLE_BASE/local/export_log
				EXP_PATH=/u09/oradata/$ORACLE_SID/export
				whence gzip 1>/dev/null 2>&1 \
					|| alias gzip=/usr/bin/gzip
				;;
			pssvr03) LOGDIR=$ORACLE_BASE/local/export_log
				EXP_PATH=/u01/oradata/$ORACLE_SID/exp
				whence gzip 1>/dev/null 2>&1 \
					|| alias gzip=/usr/sbin/gzip
				;;
			pssvr04) LOGDIR=$ORACLE_BASE/local/export_log
				EXP_PATH=/u01/oradata/$ORACLE_SID/exp
				whence gzip 1>/dev/null 2>&1 \
					|| alias gzip=/usr/sbin/gzip
				;;
			pssvr06) LOGDIR=$ORACLE_BASE/local/export_log
				EXP_PATH=/u01/oradata/$ORACLE_SID/exp
				whence gzip 1>/dev/null 2>&1 \
					|| alias gzip=/usr/sbin/gzip
				;;
			pssvr11) LOGDIR=$ORACLE_BASE/local/export_log
				EXP_PATH=/u01/oradata/$ORACLE_SID/exp
				whence gzip 1>/dev/null 2>&1 \
					|| alias gzip=/usr/sbin/gzip
				;;
		esac
 
		# see if directory exists; create if it does not exist.
		[[ -d $EXP_PATH ]] || mkdir -p $EXP_PATH
		EXP_OPTS="consistent=y full=y buffer=32000000 log=$LOGDIR/$LOGFILE"
		ORAENV_ASK=NO; export ORAENV_ASK
		whence oraenv >> /dev/null 2>> /dev/null || PATH=$PATH:/opt/bin
		. oraenv
 
		EXP_FILE=$EXP_PATH/$ORACLE_SID$DATE.exp
 
		echo "-------------------------" >>$logfile 2>&1
		echo "Database export for ${ORACLE_SID} started on `date`" >>$logfile 2>&1
		echo "-------------------------" >>$logfile 2>&1
		if ps -fu oracle |grep -v grep |grep ora_pmon_${ORACLE_SID} >/dev/null 2>&1
		then

			# Backup control file

			svrmgrl <<- EOFexp >>$logfile 2>&1
				connect internal
				alter database backup controlfile to trace;
				disconnect
				exit
			EOFexp
			testerr $?

			find $EXP_PATH -name '*.gz' -atime +${NUM_DAYS} |xargs -n1 rm  >/dev/null
			find $EXP_PATH -name '*.gz' -mtime +${NUM_DAYS} |xargs -n1 rm  >/dev/null

			# make export to named pipe. 
			mkfifo $EXP_FILE.pipe
			/usr/bin/rm -f $EXP_FILE.gz >>$logfile 2>&1
			cat $EXP_FILE.pipe |gzip -c > $EXP_FILE.gz & 

			# put all exp options on command line.	
			exp / ${EXP_OPTS} file=$EXP_FILE.pipe >/dev/null 2>&1
			/usr/bin/rm $EXP_FILE.pipe >>$logfile 2>&1
			grep "Export terminated successfully without warnings" $LOGDIR/$LOGFILE >>$logfile 2>&1
			runstat=$?
		   if [ $runstat -ne 0 ]
			then
				echo ">>>> EXPORT FAILED! <<<<" >>$logfile 2>&1
				tail -10 $LOGDIR/$LOGFILE >>$logfile 2>&1
				export error_cnt=`expr ${error_cnt:-0} + 1`
			fi
		   echo "-------------------------" >>$logfile 2>&1
   		echo "Database export for ${ORACLE_SID} complete on `date`" >>$logfile 2>&1
   		echo "-------------------------" >>$logfile 2>&1
   		echo >>$logfile 2>&1
		else
			echo "ORACLE_SID $ORACLE_SID not available" >>$logfile 2>&1
			export error_cnt=`expr ${error_cnt:-0} + 1`
		fi
	done
	endup ${error_cnt:-0}
}
main "$@"
#getsids
