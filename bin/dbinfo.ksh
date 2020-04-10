#!/bin/ksh

# @(#)dbinfo.ksh	1.1 04/06/00 11:30:21

# This script will print out the db info needed for disaster recovery.
# 1.  Run the sql script that logs information to a logfile.
# 2.  mail the above information to user at other machine.

# Include the standard functions
. $ORACLE_BASE/local/bin/stdfunc.ksh
if [ ! -d /var/runlog ]
then
	mkdir /var/runlog 2>/dev/null
fi
export logfile=/var/runlog/`basename $0`_$$.log

# Set mailon to 1 to send mail and 0 to turn off mail
export mailon=1

main () {
	startup
	SID_LIST="$@"
	echo $SID_LIST >>$logfile 2>&1
	export ORACLE_SID

	whence -v runsql.ksh >/dev/null || \
	PATH=$PATH:$ORACLE_BASE/local/bin >>$logfile 2>&1
	testerr $?

	echo $SID_LIST >>$logfile 2>&1
	for ORACLE_SID in $SID_LIST 
	do
		### get & display the db file information
		export mailon=0 # Turn off mail during runsql
		export outputon=1 # Turn on output to screen
		runsql.ksh $ORACLE_SID dbfileinfo.sql >>$logfile 2>&1
		export mailon=1 # Turn mail back on after runsql
		### show the control file trace info.
		curtracefile=$(find $ORACLE_BASE/admin/$ORACLE_SID/udump/*.trc \
		-exec grep -l "^CREATE CONTROLFILE REUSE DATABASE" {} \; \
		| head -1)
		cat $curtracefile >>$logfile 2>&1
		testerr $?
	done 
	testerr $?
	endup 0
}

main $@

