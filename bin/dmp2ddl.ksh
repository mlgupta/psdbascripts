#!/bin/ksh

# @(#)dmp2ddl.ksh	1.1 04/06/00 11:30:22

set -xv
set +o noclobber
# ksh script to automate makeing mktable and mkindex scripts from a dmp file.

AWKFILE=$ORACLE_BASE/local/bin/fixKtblspace.awk
whence gunzip >/dev/null 2>&1 \
|| alias gunzip=/usr/bin/gunzip
FROMTOUSER=sysadm
TABLELIST=""
FORCEFLAG=false
while getopts "fu:t:" opt
do
	case "$opt" in
		f)	FORCEFLAG=true
			;;
		u)
			FROMTOUSER="$OPTARG"
			;;
		t)
			TABLELIST=tables=\("$OPTARG"\)
			;;
	esac
done

shift OPTIND-1

for DMPFILE in "$@"
do
	if [[ -r $DMPFILE ]] && [[ ${DMPFILE} == *.gz ]]
	then 
		gunzip $DMPFILE && DMPFILE=${DMPFILE%%.gz}
	elif  [[ -r ${DMPFILE}.gz ]]
	then  gunzip $DMPFILE
	fi

	FILEBASE=${DMPFILE%.exp|.dmp}
	### if test:
	### if FORCEFLAG=true, then sc to imp command.	sc = shortcircuit.
	### if can't read the indexfile, sc to imp cmd.
	### if can read dmpfile AND indexfile is older than dmpfile.
	### test if indexfile exists ### tjm 08/1299: also check if newer.
	if	$FORCEFLAG ||  \
		! [[ -r ${FILEBASE}.indexfile ]] || \
		{ [[ -r ${DMPFILE} ]] && \
		[[ ${FILEBASE}.indexfile -ot ${DMPFILE} ]] }
	then 
		imp / file=${DMPFILE} fromuser=\($FROMTOUSER\) \
			touser=\($FROMTOUSER\) ${TABLELIST} \
			indexfile= ${FILEBASE}.indexfile
	else
	:
	fi
	######## mktable.sql sript ###################################
	echo "spool ${FILEBASE}.mktable.&instance..out" > ${FILEBASE}.mktable.sql
	echo "whenever sqlerror exit sql.sqlcode" >> ${FILEBASE}.mktable.sql
	sed -n '/^REM  \.\.\..*rows$/d;/^REM/s/^REM  //p' \
		${FILEBASE}.indexfile |
		nawk -f ${AWKFILE} >> ${FILEBASE}.mktable.sql

	#### now the mkindex sql script ##############################
	echo "spool ${FILEBASE}.mkindex.&instance..out" > ${FILEBASE}.mkindex.sql
	echo "whenever sqlerror exit sql.sqlcode" >> ${FILEBASE}.mkindex.sql
	egrep -v '^(REM |CONNECT )' ${FILEBASE}.indexfile |
		nawk -f ${AWKFILE} >> ${FILEBASE}.mkindex.sql
	### now make droptable and trunctable scripts.  tjm 03/03/99
	echo "spool ${FILEBASE}.droptable.&instance..out" > ${FILEBASE}.droptable.sql
	awk '/^ CREATE TABLE /{print "drop table",$3 ";"}' \
		${FILEBASE}.mktable.sql >> ${FILEBASE}.droptable.sql
	echo "@coalesce" >> ${FILEBASE}.droptable.sql
	#### now the trunctable sql script.
	echo "spool ${FILEBASE}.trunctable.&instance..out" > ${FILEBASE}.trunctable.sql
	awk '/^ CREATE TABLE /{print "truncate table",$3, "reuse storage;"}' \
		${FILEBASE}.mktable.sql >> ${FILEBASE}.trunctable.sql
	####
	echo "spool ${FILEBASE}.analtable.&instance..out" > ${FILEBASE}.analtable.sql
	awk '/^ CREATE TABLE /{print "analyze table",$3, "estimate statistics sample 30 percent;"}' \
		${FILEBASE}.mktable.sql >> ${FILEBASE}.analtable.sql
done
