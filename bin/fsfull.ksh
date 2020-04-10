#!/bin/ksh

# @(#)fsfull.ksh	1.2 01/07/02 12:58:28

# Include the standard functions
. ~oracle/.profile >/dev/null 2>&1
. ~oracle/.kshrc >/dev/null 2>&1

. $ORACLE_BASE/local/bin/stdfunc.ksh

export logfile=/var/runlog/`basename $0`_$$.log
export mailfile=/var/runlog/`basename $0`m_$$.log
# Set mailto to as many people as need to receive the email separated by space
export mailtopager=`cat ~oracle/.mailtopager`
# Set mailon to 1 to send mail and 0 to turn off mail
export mailon=1
# Set the trigger percent full for email
if [ $# -eq 1 ] 
then
	export pct_full=$1
else
	export pct_full=95
fi

main () {
startup
server=`uname -a|cut -d" " -f2`
echo "Running out of space on server $server." >>$logfile 2>&1
echo >>$logfile 2>&1
count=0
oldpro=0
export badjobs=0
for fsline in `df -k|nawk '{ printf( "%s%%%s\n", $6, $5) }'` 
do
	size=`echo $fsline|cut -d"%" -f2` >>$logfile 2>&1
        if [ $size -ge $pct_full ] 2>/dev/null
	then
		if [ `echo $fsline|cut -d"%" -f1|grep -v cdrom` ] 2>/dev/null
		then
			echo "File system `echo $fsline|cut -d"%" -f1` is `echo $fsline|cut -d"%" -f2`% full." >>$logfile 2>&1
			testerr $?
			echo "File system `echo $fsline|cut -d"%" -f1` is `echo $fsline|cut -d"%" -f2`% full." >>$mailfile 2>/dev/null
			testerr $?
			badjobs=1
		fi
	fi
done
if [ $badjobs -gt 0 ]
then
	mailx -s "WARNING: File system on $server" $mailtopager <$mailfile \
		>>$logfile 2>&1
	testerr $?
	rm $mailfile >>$logfile 2>&1
	testerr $?
fi
}
# Main program body.
main
# Turn off the mailing of the logfile since message is already mailed.
export mailon=0 
endup
