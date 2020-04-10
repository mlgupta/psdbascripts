#!/bin/ksh

# @(#)chklogs.ksh	1.1 04/06/00 11:30:21

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
# Set mailto to as many people as need to receive the email separated by space
# Set mailon to 1 to send mail and 0 to turn off mail
export mailon=0

main () {
	# Count logs; list logs sorted by name; grep logs for success and failure
	echo 'Number of logs files = \c' >>$logfile 2>&1
	ls *.log | wc -l >>$logfile 2>&1
	ls -l *.log | sort -k 9 >>$logfile 2>&1
	echo 'Number of successful backups = \c' >>$logfile 2>&1
	grep "terminated successfully"  *.log >>$logfile 2>&1 | wc -l >>$logfile 2>&1
	for log in *.log
	do
		grep "terminated successfully" $log >/dev/null 2>&1 && gzip $log >>$logfile 2>&1
	done 

	echo >>$logfile 2>&1
	echo 'Number of failed backups = \c' >>$logfile 2>&1
	cat *.log 2>/dev/null | grep unsuccessful  | wc -l >>$logfile 2>&1
	grep unsuccessful *.log	/dev/null >>$logfile 2>&1

	# Send all output to the standard output
	cat $logfile

	endup 0
}

main
