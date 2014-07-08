\name{readbatch.day}
\alias{readbatch.day}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
readbatch.day(date, path = "/Volumes/lgrdata/", strip.se = TRUE, exclude.last = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{date}{
%%     ~~Describe \code{date} here~~
}
  \item{path}{
%%     ~~Describe \code{path} here~~
}
  \item{strip.se}{
%%     ~~Describe \code{strip.se} here~~
}
  \item{exclude.last}{
%%     ~~Describe \code{exclude.last} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (date, path = "/Volumes/lgrdata/", strip.se = TRUE, 
    exclude.last = FALSE) 
{
    prevdigits = getOption("digits.secs")
    on.exit(options(digits.secs = prevdigits))
    options(digits.secs = 3)
    readwrap = function(filename) {
        df = read.lgrbatch(filename)
        len = nchar(filename)
        df$filename = substr(filename, len - 8, len - 4)
        return(df)
    }
    path = paste(path, date, "/batch/", sep = "")
    filenames = list.files(path)
    if (exclude.last) {
        filenames = filenames[-length(filenames)]
    }
    df = lapply(paste(path, filenames, sep = ""), readwrap)
    df = do.call("rbind", df)
    df$time = as.POSIXct(df$Time, format = "\%m/\%d/\%y \%H:\%M:\%OS")
    df$filename = factor(df$filename)
    if (strip.se) {
        return(df[, -grep("_se$", names(df))])
    }
    return(df)
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
