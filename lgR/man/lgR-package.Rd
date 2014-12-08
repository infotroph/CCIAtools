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
Version: \tab 0.2.0-prealpha\cr
Date: \tab 2014-07-06\cr
License: \tab Unlimited\cr
}
The general workflow: 

1. Read in your data. If a single continuous flow file: `read.lgrflow("path/to/file.zip")`. If a whole day's worth of batch files: `readbatch.day("01Jan2014")`, and so on.

2. Filter out unwanted times. Not written yet.

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

# Strip the first 30 seconds of each injection, 
# average remaining 60 seconds, 
# report mean/SE of [CO2], d13C, and d18O.
# N.B. Demo only. There are like 10000 better ways to 
# do this without turning numbers into strings.
meanse=function(x){
	x = x[-c(1:30)]
	paste(
		signif(mean(x),2), 
		signif(sd(x)/sqrt(length(x)),2),
		sep=" ± ")
	}
with(jul6.injections, cbind(
	`[CO2]` = tapply(X.CO2._ppm, filename, meanse),
	`d13C` = tapply(d13C, filename, meanse),
	`d18O` = tapply(d18O, filename, meanse)))
}
}
