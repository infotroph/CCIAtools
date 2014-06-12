is.lgrdata = function(obj){
	return(is.data.frame(obj) && colnames(obj)[1:2] == c("Time", "X.ht12._ppm"))
}

lgr.dfs=ls()[sapply(mget(ls(), .GlobalEnv), is.lgrdata)]