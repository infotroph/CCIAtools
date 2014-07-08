get.lgrflow <-
function(file){
	prevdigits <- getOption("digits.secs")
	on.exit(options(digits.secs=prevdigits))
	options(digits.secs=3)
	
	f = read.lgrflow(file)
	f$time = as.POSIXct(f$Time, format="%m/%d/%y %H:%M:%OS")
	f$filename = basename(file)

	return(f)
}
