read_campbelldat = function(path){
	f = file(path, open="r")
	on.exit(close(f))
	
	# line 1: File encoding, program name, datalogger make, etc
	meta = read.csv(f, header=FALSE, nrows=1, stringsAsFactors=FALSE)

	# line 2: variable names -- will be read as header of colinfo
	# line 3: units for each column
	# line 4: aggregation level (one sample, average, sum, etc)
	colinfo = read.csv(f, header=TRUE, nrows=2, stringsAsFactors=FALSE)
	
	# lines 5-end: data
	body = read.csv(f, header=FALSE, stringsAsFactors=FALSE)

	# reattach headers, store other metadata as attributes
	stopifnot(ncol(body) == ncol(colinfo))
	names(body) = names(colinfo)
	attr(body, "loggerInfo") = unlist(meta, use.names=FALSE)
	attr(body, "columnUnits") = unlist(colinfo[1,])
	attr(body, "columnAggregationLevel") = unlist(colinfo[2,])

	if("TIMESTAMP" %in% names(body)){
		body$timestamp = as.POSIXct(body$TIMESTAMP)
	}

	return(body)
}