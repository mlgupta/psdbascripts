#!/bin/ksh

# @(#)runsql.ksh	1.2 04/11/00 12:24:17

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

# Check to see if mail is already set, if not turn it on
export mailon=${mailon:-1}

# Check to see if output is already set, if not turn it off
export outputon=${outputon:-0}

main () {
	startup
	SILENT="echo on verify on"
	SQLPLUS_CMD=sqlplus

	while getopts "s" opt
	do
		case "$opt" in
			s)	SILENT="echo off verify off"
				;;
		esac
	done

	shift `expr $OPTIND - 1`

	SID_LIST="$1"
	export ORACLE_SID
	shift
	SCRIPT_NAME="$@"	### all other command line args
	echo "Executing script ${SCRIPT_NAME} on $(hostname)." >>$logfile

	PATH=$PATH:/usr/local/bin
	export SQLPATH=$ORACLE_BASE/local/sql

	for ORACLE_SID in $SID_LIST
	do
	if ! ps -fu oracle |grep ora_pmon_${ORACLE_SID} |grep -v grep>/dev/null
	then 
		echo "ORACLE_SID $ORACLE_SID not available" >>$logfile 2>&1
	else
		ORAENV_ASK=NO; export ORAENV_ASK
		whence oraenv >> /dev/null 2>> /dev/null || PATH=$PATH:/opt/bin
		. oraenv

		$SQLPLUS_CMD / <<- END_SCRIPT >>$logfile 2>&1
			set time on timing on $SILENT
			set tab off
			WHENEVER OSERROR EXIT 111
			start  ${SCRIPT_NAME}
			exit
		END_SCRIPT

		export exit_rc=$?
		if [ exit_rc -ne 0 ]
		then
			echo "${SCRIPT_NAME} failed for $ORACLE_SID" >>$logfile 2>&1
			export error_cnt=`expr ${error_cnt:-0} + 1`
		fi
	fi
	done
	testerr $?
}

main "$@"
if [ $outputon = 1 ]
then
	cat $logfile
fi
endup ${error_cnt:-0}
