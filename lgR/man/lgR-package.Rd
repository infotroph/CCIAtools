\name{lgR-package}
\alias{lgR-package}
\alias{lgR}
\docType{package}
\title{Data handling for LGR isotope analyzers}
\description{
These functions were written to manipulate dat from an LGR model CCIA-36EP carbon dioxide isotope analyzer. They're intended to be compatible with any LGR analyzer, but I haven't tested them with data from any other machine.
}

\details{
\tabular{ll}{
Package: \tab lgR\cr
Type: \tab Package\cr
Version: \tab 0.2.1-prealpha\cr
Date: \tab 2014-07-06\cr
License: \tab Unlimited\cr
}
The general workflow: 

1. Read in your data. If a single continuous flow file: `read.lgrflow("path/to/file.zip")`. If a whole day's worth of batch files: `readbatch.day("01Jan2014")`, and so on.

2. Filter out unwanted times. \code{markInterval} can help, other tools not written yet.

3. Align timestamps with any external files (temperature logger, flow controller values, inlet manifold settings, etc). Not written yet.

3. Check instrument stability and extract summary statistics from the stable times. I have some of these functions under testing but not yet in this package.

}
\author{
Chris Black

Maintainer: Chris Black <chris@bodger.org>
}
\references{\href{http://lgrinc.com}{Los Gatos Research website}}

\keyword{ package }

\examples{
\dontrun{
# read in all batch files from today
jul6.injections = readbatch.day("06Jul2014", path="~/LGRarchive/")

# Plot pressure and temperature through the day
plot.new()
par(mfrow=c(1,3))
plot(GasP_torr ~ time, jul6.injections)
plot(GasT_C ~ time, jul6.injections)

# Find the last 60 seconds of each injection, 
# ignore the ~30 seconds before that.
end_secs = tapply(
	X=jul6.injections$time, 
	INDICES=jul6.injections$filename, 
	FUN=max))
stable_obs = markInterval(
	times=jul6.injections$time, 
	breaks=end_secs, 
	lag=1, 
	lagunits="mins")

# Compute mean and std. error of [CO2], d13C, d18O 
# from the stable portion of each injection  
jul6.avgs = aggregate(
	cbind(X.CO2._ppm, d13C, d18O) ~ filename, 
	data=jul6.injections,
	subset=stable_obs,
	FUN=function(x)cbind(mean(x), sd(x)/length(x)))
jul6.avgs = do.call("cbind", jul6.avgs) # flatten mean/se to their own columns.
colnames(jul6.avgs) = c(
	`[CO2]`, `[CO2]_se`, 
	`d13C`, `d13C_se`, 
	`d18O`, `d18O_se`)
}
}
