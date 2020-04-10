#!/bin/ksh

# @(#)template.ksh	1.1 04/06/00 11:30:23

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

main () {
# Place the main body of the script here
# Leave the endup 0 at the end to exit the script cleanly.
  startup
#  echo "Hello World!" >>$logfile 2>&1
  cat /tmp/xxxx >>$logfile 2>&1
  testerr $?
  endup 0
}

main
