markInterval = function(times, breaks, lag, lagunits="secs"){
	if(is.unsorted(times)){
		sorting=TRUE
		t_ix = order(times)
		times = times[t_ix]
	}else{
		sorting = FALSE
	}

	d = diff(breaks)
	units(d) = lagunits
	if(any(d <= lag)){
		stop("some intervals between breaks are shorter than requested lag")
	}
	
	starts = as.difftime(lag, units=lagunits)
	breaks = sort(c(breaks, breaks - starts))

	res = as.logical(apply(outer(times, breaks, ">"), 1, sum) %% 2)
	if(sorting){
		return(res[order(t_ix)])
	}
	return(res)
}