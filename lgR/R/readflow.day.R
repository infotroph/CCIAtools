readflow.day <-
function(
		date, 
		path="/Volumes/lgrdata/",
		strip.se=TRUE
		){
	
	prevdigits = getOption("digits.secs")
	on.exit(options(digits.secs=prevdigits))
	options(digits.secs=3)

	# Get all filenames in the directory, then throw out any 
	# that don't look like data
	dirstr = paste(path, date, "/flow/", sep="")
	filenames = list.files(dirstr)
	datafiles = grep("\\.txt(\\.zip)?$", filenames)
	filenames = filenames[datafiles]

	df = lapply(
		paste(dirstr,filenames, sep=""), 
		function(x){print(x); read.lgrflow(x)})
	df = do.call("rbind", df)
	
	df$time = as.POSIXct(df$Time, format="%m/%d/%y %H:%M:%OS")
	
	if(strip.se){ # Remove std. errors; all zero if logged at 1 Hz
		return(df[,-grep("_se$", names(df))]) }	
		
	return(df)
}
