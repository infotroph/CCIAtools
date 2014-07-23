readflow.day <-
function(
		date, 
		path="/Volumes/lgrdata/",
		strip.se=TRUE
		){
	
	prevdigits = getOption("digits.secs")
	on.exit(options(digits.secs=prevdigits))
	options(digits.secs=3)

	readwrap=function(filename){
		# adds "f0001" portion of filename to the dataframe
		print(filename)
		df=read.lgrflow(filename)
		len=nchar(filename)
		if(nrow(df) > 0){ # TODO: Is this the best place to check for empty files?
			df$filename = substr(filename, len-12,len-8)
		}
		return(df)
	}

	# Get all filenames in the directory, then throw out any 
	# that don't look like data
	dirstr = paste(path, date, "/flow/", sep="")
	filenames = list.files(dirstr)
	datafiles = grep("\\.txt(\\.zip)?$", filenames)
	filenames = filenames[datafiles]

	df = lapply(paste(dirstr,filenames, sep=""), readwrap)
	df = do.call("rbind", df)
	
	df$time = as.POSIXct(df$Time, format="%m/%d/%y %H:%M:%OS")
	
	if(strip.se){ # Remove std. errors; all zero if logged at 1 Hz
		return(df[,-grep("_se$", names(df))]) }	
		
	return(df)
}
