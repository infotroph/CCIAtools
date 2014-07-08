\name{get.lgrflow}
\alias{get.lgrflow}
\title{
Read LGR flow file, add filename and POSIXct timestamps
}
\description{
This is a thin wrapper that calls \code{\link{read.lgrflow}} on the given file, then adds POSIXct timestamps and a filename column to return a dataframe suitably formatted for easy merging with other files, using e.g. \code{\link{rbind}}.
}
\usage{
get.lgrflow(file)
}
\arguments{
  \item{file}{
Character vector, or something coerceable to it, giving the path to the desired file. 
}
}
\details{
the `file` argument is passed directly to \code{\link{read.lgrflow}} -- anything that works there should also work here.}
\value{
Data frame with the same components as \code{read.lgrflow(file)}, plus:
\item{time }{POSIXct version of the 'Time' column}
\item{file }{basename of the read file. Currently returned as a string, but possibly ought to be a factor instead.}
}
\author{
Chris Black <chris@bodger.org>
}
\seealso{
\code{\link{read.lgrflow}}, 
\code{\link{readflow.day}}
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (file) 
{
    prevdigits <- getOption("digits.secs")
    on.exit(options(digits.secs = prevdigits))
    options(digits.secs = 3)
    f = read.lgrflow(file)
    f$time = as.POSIXct(f$Time, format = "\%m/\%d/\%y \%H:\%M:\%OS")
    f$filename = basename(file)

    return(f)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~manip }
