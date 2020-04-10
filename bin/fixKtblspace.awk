# @(#)fixKtblspace.awk	1.1 04/06/00 11:30:22

BEGIN {
	FS="^\n\t"
	# RS=";"
	blockK=8
	myFS="[ ,	)]"
	outputline = ""
	inputline  = ""
	bigtblspace["\"BIGIMAGE\""] = "PSIMABIG"
	bigtblspace["\"BIGINDEX\""] = "PSINDBIG"
	bigtblspace["\"BIGPTTBL\""] = "PTLARGE"
	bigtblspace["\"BNAPP\""] = "BNLARGE"
	smalltblspace["\"BNLARGE\""] = "BNAPP"
	bigtblspace["\"HRAPP\""] = "HRLARGE"
	smalltblspace["\"HRLARGE\""] = "HRAPP"
	bigtblspace["\"HTAPP\""] = "HTLARGE"
	smalltblspace["\"HTLARGE\""] = "HTAPP"
	smalltblspace["\"PALARGE\""] = "PAAPP"
	bigtblspace["\"PAAPP\""] = "PALARGE"
	smalltblspace["\"PILARGE\""] = "PIAPP"
	bigtblspace["\"PSIMAGE\""] = "PSIMABIG"
	bigtblspace["\"PSINDEX\""] = "PSINDBIG"
	smalltblspace["\"PSTEMP\""] = "USERS"
	bigtblspace["\"PSTEMP\""] = "USERS"
	bigtblspace["\"PTAPP\""] = "PTLARGE"
	bigtblspace["\"PTPRC\""] = "PTLARGE"
	bigtblspace["\"PTTBL\""] = "PTLARGE"
	bigtblspace["\"PYAPP\""] = "PYLARGE"
	smalltblspace["\"PYLARGE\""] = "PYAPP"
	smalltblspace["\"STLARGE\""] = "STAPP"
	smalltblspace["\"TLALL\""] = "TLAPP"
	smalltblspace["\"TLLARGE\""] = "TLAPP"

	### print out for testing
	### for (ts in smalltblspace) print ts, smalltblspace[ts]
	### for (ts in bigtblspace) print ts, bigtblspace[ts]
	
}

function roundup ( insize, blocksize) {
	if ( (remK=(insize % blocksize)) > 0)
	{
	   insize = insize + blocksize - remK
	 }
	 return insize
}

function initKB( initbytes) {
	initK=initbytes/1024
	if ( initK <= 48) initK = roundup(initK, 8)
	else if (initK <= 240) initK = roundup(initK,40)
	else if (initK <= 1200) initK = roundup(initK,200)
	else if (initK <= 11000) initK = roundup(initK,1000)
	else if (initK <= 100000) initK = roundup(initK,10000)
	else initK = 100000
	return initK
}

function nextKB( initK ) {
	if ( initK < 40 ) nextK = 8
	else if (initK < 200) nextK = 40
	else if (initK < 1000) nextK = 200
	else if (initK < 10000) nextK = 1000
	else if (initK < 100000) nextK = 10000
	else nextK = 100000
	return nextK
}

function fixtblspace( initK, tblspace ) {
	### if ( initK >= 1000 ) tblspace = "BIGINDEX"
	if ( ( initK >= 1000 ) &&  ( tblspace in bigtblspace ) )
			tblspace = bigtblspace[tblspace]
	if ( ( initK < 1000 ) && ( tblspace in smalltblspace ) )
			tblspace = smalltblspace[tblspace]
	return tblspace
}

### below copied from timestamp.ksh
function fmtprint(line, maxlength) {
	### this function is to print out the line, breaking at spaces.
	### loop until the end of the line:
	### if there is a :whitespace: (blank or tab) in the line,
	###    then get the substr to that point and print it.
	###         reset the line, and do it again.
	###    else, find the first blank in the line, and split there.
	### continue until line length < maxlength: then just print the line.
	while (length(line)>maxlength && (FSpos=match(line, myFS))>0) {
		### need to split it.
			### myFS is in line.
			### print FSpos
			if (FSpos >= maxlength) {
			   print substr(line,1,FSpos)
			   line = substr(line,FSpos+1)
			   }
			else {
				### here the blank is before the maxlength.
				match(substr(line,1,maxlength),".*" myFS)
				### print RSTART, RLENGTH
				print substr(line, RSTART, RLENGTH)
				line = substr(line, RSTART + RLENGTH)
				# print line
			}
	}
	print line
}

{ gsub("\n\t"," ",$0)		### change all whitespace to blanks.
	inputline=inputline $0 " "
	}
$NF ~  /;$/ {
  n_f = split( inputline, fields, " ")	### split into multi fields.
  for (i=1;i<=n_f;i++){
	## print fields[i]
	outputline=outputline " " fields[i]
	### printf "%s ",fields[i]
	 if ( ( fields[i] == "(INITIAL" ) || ( fields[i] == "STORAGE(INITIAL") )
		{ initK=initKB(fields[++i])
		  ### printf "%dK ", initK
		  outputline=outputline " " initK "K"
	}
	if (fields[i] == "NEXT" )
		{ 
		i++
		 nextK = nextKB(initK)
		 ### printf "%dK ", nextK
		 outputline=outputline " " nextK "K"
	}
	if (fields[i] == "TABLESPACE" )
		{ 
		i++
		 ### printf "%dK ", nextK
		 outputline=outputline " " fixtblspace(initK, fields[i])
	}
  }
  # outputline = outputline " ;"
  fmtprint(outputline,80)
  printf "\n"	#### blank line to separate
  outputline = ""
  inputline  = ""
}
