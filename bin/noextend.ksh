#!/bin/ksh

# @(#)noextend.ksh	1.4 10/10/00 11:37:37

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
# Set mailto to as many people as need to receive the email separated by space
export mailtopager=`cat ~/.mailtopager`
# Set mailon to 1 to send mail and 0 to turn off mail
export mailon=1

main () {
	startup
	export mailfile=/tmp/`basename $0`m_$$.log
	export SID_LIST="$@"
	for ORACLE_SID in $SID_LIST
	do
	if ! ps -fu oracle |grep ora_pmon_${ORACLE_SID} |grep -v grep>/dev/null
	then 
		echo "ORACLE_SID $ORACLE_SID not available" >>$logfile 2>&1
	else
		sqlfile=/tmp/sqlfile.log
		echo >|$sqlfile
		ORAENV_ASK=NO; export ORAENV_ASK
		whence oraenv >> /dev/null 2>> /dev/null || PATH=$PATH:/opt/bin
		. oraenv
		sqlplus -s / @extend >>$sqlfile 2>&1
	   tail +7 $sqlfile >>$mailfile 2>&1
	fi
	done
	if [ -s $mailfile ]
	then
	   mailx -s "WARNING: Can't extend segment on $(hostname)" $mailtopager \
			<$mailfile >>$logfile 2>&1
	   testerr $?
#	   rm $mailfile >>$logfile 2>&1
	   testerr $?
	fi
}
main "$@"
export mailon=0
endup 0
