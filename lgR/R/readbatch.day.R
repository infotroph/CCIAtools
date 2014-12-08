readbatch.day <-
function(
		date, 
		path="/Volumes/lgrdata/", 
		strip.se=TRUE,
		exclude.last=FALSE # use when there's a currently-active file hanging around
		){	
	
	prevdigits = getOption("digits.secs")
	on.exit(options(digits.secs=prevdigits))
	options(digits.secs=3)

	path = paste(path, date, "/batch/", sep="")
	filenames = list.files(path)
	if(exclude.last){filenames = filenames[-length(filenames)]}
	df = lapply(
		paste(path,filenames, sep=""), 
		function(x){print(x); read.lgrbatch(x)})
	df = do.call("rbind", df)
	
	df$time = as.POSIXct(df$Time, format="%m/%d/%y %H:%M:%OS")
	df$filename = factor(df$filename)
	
	if(strip.se){ # Remove std. errors; all zero if logged at 1 Hz
		return(df[,-grep("_se$", names(df))]) }	
		
	return(df)
}
