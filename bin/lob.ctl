LOAD DATA
INFILE 'logfiles.dat'
REPLACE
INTO TABLE sa.sa_logfile
fields terminated by ','
(dba_filename char(50),
 file_date date "DD-Mon-HH24:MI",
 text LOBFILE (dba_filename) TERMINATED BY EOF
) 

