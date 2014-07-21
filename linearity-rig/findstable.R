# Goal: Identify the rows of a time series where I should expect concentration to be steady
#	(i.e. setpoint has not changed recently). 
# N.B. Not yet testing whether concentration IS steady -- that's the next step downstream.
# Wrinkles: setpoints are logged at a lower frequency than concentrations, and logging intervals 
# 	for both are just irregular enough to be troublesome.

# Generate sample data:
# running log of gas concentrations, recorded approximately every second
concdata = data.frame( 
	time = as.POSIXct((1:50) + rnorm(25, mean= 0, sd=0.1), origin="2014-07-07"),
	conc = rep(seq(10,50,10),each=10)+rnorm(50))
# running log of setpoints, recorded approximately every 1.5 seconds
# For this example, setpoint change is sent every 10 seconds
# and concentration stabilizes within 3 seconds.
setdata = data.frame(
	time = as.POSIXct(seq(1,50, by=1.5) + rnorm(33, mean= 1.5, sd=0.1), origin="2014-07-07"),
	setpoint = c(rep(10,6), rep(20,7), rep(30,6), rep(40,7), rep(50,7)))

setstable = function(start, end, time){
  # Which values in `time` are between `start` and `end`?
  # start, end, time should all be comparable types, but need not be POSIXt objects.
  # returns a logical vector same length as `time`.
	(time >= start) & (time <= end)
}

# Find times when setpoint changed
setdata_changepoints = cumsum(rle(setdata$setpoint)$lengths)
setdata_changetimes = setdata$time[setdata_changepoints]


# Build a logical matrix with one column for each steady interval.
# BEWARE: This matrix is nrow(concdata) by length(setdata_changetimes). 
#	You probably don't want to do this on a large dataset.
concdata_stable = mapply(
	FUN=setstable, 
	start=setdata_changetimes-7, # 10-7 = 3 sec stabilization time
	end=setdata_changetimes, 
	MoreArgs=list(time=concdata$time))

concdata$stable = apply(concdata_stable, 1, any)

# Visual check: Did we mark the right points?
# If misaligned, check for timestamp problems (especially timezones)
plot(conc ~ time, concdata, col=stable+1)



# ...Actually, I want to bring the setpoints over too. 
# Maybe ought to be a separate function, but dumping here for the moment
# Approach: merge on timestamps

# round timestamps to nearest second
library(xts)
setdata$time_rnd = align.time(setdata$time,1)
concdata$time_rnd = align.time(concdata$time,1)

# now merge dataframes on the rounded times, drop unaligned time (column 1 in both dfs)
concdata_w_set = merge(concdata[,-1], setdata[,-1], all=TRUE) 
# Since setpoint is logged less often than concentration, some lines will be NA.
# Fill these from the previously recorded setpoint.
# (Setpoints are logged immediately on change, so last recorded value is never stale.)
# If conc logging started before setpoint logging, some NAs may remain at beginning of df;
# must fix these by hand, R can't deduce what the setpoint was before logging started!
concdata_w_set$setpoint = na.locf(concdata_w_set$setpoint, na.rm=FALSE)

# Now that all concentration times have setpoints, 
# remove setpoints logged at times with no concentration data.
# !! BUGBUG: Assumes all NAs were introduced by merge. 
#	In this example that's true because stable was initialized to FALSE a few lines ago.
#	when using real data, check this.
concdata_w_set = concdata_w_set[!is.na(concdata_w_set$stable),]
row.names(concdata_w_set)=NULL # reset numbers to 1:nrow(concdata)
