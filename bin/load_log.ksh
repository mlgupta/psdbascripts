#!/bin/ksh
. /usr/local/bin/.functions

export SERVER=$(hostname)
# Create list of filenames
echo "Changing to runlog directory..."
cd /var/runlog
echo "Creating logfile name list.."
ls -ltr *.log|awk '{print $9 "," $7 "-" $6 "-"$8}'>/var/runlog/logfiles.dat
echo "Loading Data into Demo6 database..."
sqlldr sa/kundun@demo6 $ORACLE_BASE/local/bin/lob.ctl
echo "Setting error flag..."
sqlplus -s sa/kundun@demo6 <<EOF
update sa.sa_logfile
set server = upper('$SERVER');
exec sa.sa_error_flag
exit
EOF
