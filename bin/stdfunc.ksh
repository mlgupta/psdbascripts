# @(#)stdfunc.ksh	1.3 04/03/01 14:48:26

# This function starts the logfile and notifies of mail status
# Usage: startup

export mailto=`cat ~oracle/.mailto`

startup () {
	export today=`date +m%d`
	echo "Starting $0 on "`date` >|$logfile 2>&1
	if [ $mailon -eq 1 ]
	then
		echo "Mail enabled.  Mail will be sent to `echo $mailto`." >>$logfile 2>&1
	else
		echo "Mail disabled." >>$logfile 2>&1
	fi
}

# This function exits the script and creates an email based on the run status
# that is passed to endup.  A zero value exits with success.  A non-zero
# value exits with a failure.  The results of the script are emailed to the
# user defined by mailto.
# Usage: endup <run status>

endup () {
	if [ "$1" -eq 0 ]
	then
		echo "Script completed successfully." >>$logfile 2>&1
		echo "Completed $0 on "`date` >>$logfile 2>&1
		if [ $mailon -eq 1 ]
		then
			mailx -s "Results of ${SCRIPT_NAME:-$0} on $(hostname)" $mailto \
			<$logfile 2>/dev/null
		fi
	else
		if [ ${error_cnt:-0} -ne 0 ]
		then
			echo "There were $error_cnt errors in the script." >>$logfile 2>&1
		else
			echo "Errors in script." >>$logfile 2>&1
		fi
		echo "Completed $0 on "`date` >>$logfile 2>&1
# Removed 4/3/01 by jvb to correctly report errors from brio_refresh.ksh
#		if [ $mailon -eq 1 ]
#		then
			mailx -s "Failure of ${SCRIPT_NAME:-$0} on $(hostname)" $mailto \
			< $logfile 2>/dev/null
#		fi
	fi
	exit $1
}

# This function should be called after any command that may result in an error
# It will call the endup routine if an error has occured
# Usage: testerr <run status>

testerr () {
  runstat="$1"
  if [ $runstat -ne 0 ]
  then
    endup $runstat
  fi
}
