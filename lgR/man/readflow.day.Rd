\name{readflow.day}
\alias{readflow.day}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
%%  ~~function to do ... ~~
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
readflow.day(date, path = "/Volumes/lgrdata/", strip.se = TRUE)
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
function (date, path = "/Volumes/lgrdata/", strip.se = TRUE) 
{
    prevdigits = getOption("digits.secs")
    on.exit(options(digits.secs = prevdigits))
    options(digits.secs = 3)
    readwrap = function(filename) {
        print(filename)
        df = read.lgrflow(filename)
        len = nchar(filename)
        if (nrow(df) > 0) {
            df$filename = substr(filename, len - 12, len - 8)
        }
        return(df)
    }
    dirstr = paste(path, date, "/flow/", sep = "")
    filenames = list.files(dirstr)
    datafiles = grep("\\.txt(\\.zip)?$", filenames)
    filenames = filenames[datafiles]
    df = lapply(paste(dirstr, filenames, sep = ""), readwrap)
    df = do.call("rbind", df)
    df$time = as.POSIXct(df$Time, format = "\%m/\%d/\%y \%H:\%M:\%OS")
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
