\name{read.lgrbatch}
\alias{read.lgrbatch}
\title{
Read an LGR batch (injection) file
}
\description{
An LGR analyzer running in "batch" mode creates one file for each injection, and the format differs slightly from the standard continuous-flow file. This function reads one such batch file; in most cases you'll want to use \code{\link{readbatch.day}} (which uses \code{read.lgrbatch} internally) to read multiple injections at once instead of calling this directly.}
\usage{
read.lgrbatch(file, strip.se = TRUE)
}
\arguments{
  \item{file}{
	Character vector giving the path to the file.
}
  \item{strip.se}{
	NOT IMPLEMENTED YET. Logical: Remove standard error columns for each variable? See Details. 
}
}
\details{
If the analyzer is running at its highest rate (1 Hz for the CCIA-36EP), all standard error estimates (data columns with ending in \code{_se}) will be zero, because each datapoint is a single unaveraged observation. \code{strip.se=TRUE} will eventually remove these, but currently has no effect. }
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
function (file, strip.se = TRUE) 
{
    command = paste("sed -n '/^.\\{65\\}/p'", file)
    read.csv(pipe(command))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
