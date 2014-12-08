read.lgrbatch <-
function(file){
	# LGR batch files begin with short summary lines 
	# and end with a PGP-encrypted settings block. 
	# These lines are much shorter than data lines, so filter out 
	# by removing any line containing less than 65 characters.
	command = paste("sed -n '/^.\\{65\\}/p'", file)
	df = read.csv(pipe(command), stringsAsFactors=FALSE)
	df$filename = basename(file)
	return(df)
}
