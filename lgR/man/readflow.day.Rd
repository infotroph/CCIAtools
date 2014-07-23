\name{readflow.day}
\alias{readflow.day}
\alias{readbatch.day}
\title{
Read a day's worth of LGR data files
}
\description{
Given a date string and a path to a directory full of LGR data with one subfolder per day, these functions read all files of the requested type (continuous flow or batch injection) and return them as a single dataframe.
}
\usage{
readflow.day(date, path = "/Volumes/lgrdata/", strip.se = TRUE)
readbatch.day(date, path = "/Volumes/lgrdata/", strip.se = TRUE, exclude.last = FALSE)
}
\arguments{
    \item{date}{ Character vector in the date format used by your instrument. Mine is DDMMMYYYY, e.g. "31Jun2014".}

    \item{path}{ Path to the data directory, NOT including the date string. Defaults to "/Volumes/lgrdata/", which is the path for the CCIA's automatic SMB share when mounted locally on an OS X system.}
    
    \item{strip.se}{ Logical: Remove standard error columns for each variable? See Details.}
    
    \item{exclude.last}{ Logical: If TRUE, will skip the last file in the directory. Useful if you're reading data while the machine is in the middle of a batch measurement.}
}
\details{
When the analyzer is running at its highest rate (1 Hz for the CCIA-36EP), all standard error estimates (data columns with ending in \code{_se}) will be zero, because each datapoint is a single unaveraged observation. \code{strip.se=TRUE} removes these columns, *without* checking whether they contain any nonzeroes; if `any(df$N_Fits_Avg.d != 1)`, then you probably don't want to strip SEs. 
}
\value{
Data frame with 60 (if \code{strip.se==TRUE}) or 115 (if \code{strip.se==FALSE}) columns: All variables from the LGR file (see \code{?\link{read.lgrbatch}} and \code{\link{read.lgrflow}} for details), plus:
\item{time}{POSIXct version of character vector "Time"}
\item{filename}{factor containing the last five digits of the filename, e.g. "f0001" for a flow file, "b0001" for a batch file.}
}

\author{
Chris Black}
\note{
In addition to storing multiple files from each injection, the CCIA also produces daily zip archives; future versions of these function may or may not allow reading from those without prior decompression.
}

\seealso{
\code{\link{read.lgrflow}} and \code{\link{read.lgrbatch}} for the underlying workhorse functions. 
}
\examples{
\dontrun{
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
}

\keyword{ IO }
