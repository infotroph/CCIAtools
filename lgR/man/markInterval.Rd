\name{markInterval}
\alias{markInterval}
\title{
Find timestamps less than n units before this one
}
\description{
Identify those observations in a (possibly variable-frequency) set of \code{times} that occured less than \code{lag} timesteps before each event in \code{breaks}.
}
\usage{
markInterval(times, breaks, lag, lagunits="secs")
}
\arguments{
	\item{times}{
POSIXt vector of timestamps from which to identify stable periods.
	}
	\item{breaks}{
POSIXt vector of times at which stable periods ended.
	}
	\item{lag}{ 
Numeric: How much time should be selected before each break?
	}
	\item{lagunits}{
Character string recognized by \code{\link[base]{difftime}}, probably one of c("auto", "secs", "mins", "hours", "days", "weeks").
	}
}
\details{
\code{markInterval} is useful if you have time-stamped data from a system where observations become unstable for some time after a change in conditions. Given timestamps from the breakpoints at the \emph{end} of each stable period, e.g. the times when a setting changed, or just the times you said "Hey, I see conditions have been stable for 30 seconds!", you want to identify all data collected within some fixed time before each breakpoint. The fixed time need not correspond to a fixed number of observations -- \code{markInterval} will work correctly even if observation timestamps are irregularly spaced. 

The interval-finding method relies on \code{times} being sorted in nondecreasing order; if they are unsorted, \code{markInterval} will attempt to sort them internally for calculation and then return the results in the same order you provided them.

\code{markInterval} should be most useful in datasets with many observations per stable period, so that the exact number of observations falling within any particular period is not critical. If you're in the opposite situation, where the number of observations per period is more important than the exact time interval they came in, count rows instead of using \code{markInterval}.
}
\value{
logical vector the same length and in the same order as \code{times}.
}
\note{
If time math seems off-by one in some places, check for display-rounding errors first --
is options(digits.secs) set high enough to show the full timestamp?
}
\note{
This function \emph{does NOT} test for stability in any way! It is up to the user to determine the correct lag length and check that the selected timestamps are actually stable enough for their application.
}

\author{
Chris Black <chris@bodger.org>
}
\seealso{
\code{\link[base]{findInterval}} to group observations between two timestamps, 
\code{\link[base]{cut}} to convert timestamps (or anything else numeric) into factors at custom intervals, 
\code{\link[base]{difftime}} for values accepted in `lagunits` and details on timestamp math. 
}
\examples{
# regularly spaced timestamps
x = as.POSIXct(paste0("2014-12-10 08:27:", 1:20))
y = x[c(5, 10, 15)]
data.frame(time=x, isStable=markInterval(x, y, 3))
# Note we could have gotten the same result with:
apply(sapply(y, function(z)x>(z-3) & x<=z), 1, any)

# more complex: times recorded at *roughly* equal intervals
set.seed(10000) # for reproducible example
xx = as.POSIXct(paste0("2014-12-", 11:30, "10:00:00")) + as.difftime(rnorm(20),units="mins")
yy = xx[c(6, 11, 15)]
data.frame(time=xx, isStable=markInterval(xx, yy, 3, "days"))
# Notice that picking "three days before yy[1]" resulted in four lines picked.
# This is as intended -- the observation on 2014-12-13 makes the inclusion cutoff by one minute.

\dontrun{
# markInterval will complain if lag is longer than interval between any two breakpoints
diff(yy)
# Time differences in days
# [1] 5.001250 3.999458
markInterval(xx, yy, 4, "days")
# Error in markInterval(xx, yy, 4, "days") : 
#  some intervals between breaks are shorter than requested lag
}
# If you really need to compute stability from breaks with overlapping lag:
ss1 = markInterval(xx, yy[-2], 4, "days")
ss2 = markInterval(xx, yy[-3], 4, "days")
sscomb = data.frame(time=xx, isStable=(ss1|ss2))
}
\keyword{ manip }
\keyword{ chron }
