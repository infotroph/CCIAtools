read.lgrflow <-
function(file){

	# Files are plaintext while being written, then compressed for storage.  
	if(any(grep("\\.txt\\.zip$", file))){
		method = "unzip -p"
	}else{
		method = "cat"
	}

	# File ends with one of:
	#	* Nothing if file still being written 
	#	* a PGP-encrypted settings block if encrypt is on, 
	#	* plaintext settings if encrypt is off.
	# We can use one sed command can handle all three of these cases:
	command = paste(
		method, 
		file, 
		"| sed -e '/-----BEGIN PGP MESSAGE-----/{x;q;}'",
		"-e '/#=-=-=-=-=-=-=-=-=Start/{x;q;}'")
	
	# skip=1 to remove stray pre-header timestamp
	read.csv(pipe(command), skip=1)
}
