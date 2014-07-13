\name{read.lgrflow}
\alias{read.lgrflow}
\alias{read.lgrbatch}
\title{
Read one LGR file
}
\description{
An LGR isotope analyzer uses the same file format for all datapoints, but the file headers and footers differ depending whether it is running in "flow" mode or "batch" mode. These functions handle the format differences. In most cases you will not want to call these directly, but instead use \code{\link{readflow.day}} or \code{\link{readbatch.day}} (which use them internally).}
\usage{
read.lgrbatch(file)
read.lgrflow(file)
}
\arguments{
  \item{file}{
	Character vector giving the path to the file.}
}
\value{
Data frame with all variables from the LGR file. On my machine it has 113 columns, but this may be configuration-dependent. 'Time' is a character vector, all others are numeric.}
\author{
Chris Black}
\note{
These functions make internal calls to the text-processing shell command \code{sed}, which is available on most UNIX-alikes but probably will not work on Windows. If you have a portable fix, please get in touch.}

\seealso{
\code{\link{readflow.day}} and \code{\link{readbatch.day}}, which use these functions to read a whole directory of batch files into one dataframe.
}
\examples{
\dontrun{
## read.lgrflow is currently defined as
function(file){

    # Files are plaintext while being written, then compressed for storage.  
    if(any(grep("\\.txt\\.zip$", file))){
        method = "unzip -p"
    }else{
        method = "cat"
    }

    # File ends with one of:
    #   * Nothing if file still being written 
    #   * a PGP-encrypted settings block if encrypt is on, 
    #   * plaintext settings if encrypt is off.
    # We can use one sed command can handle all three of these cases:
    command = paste(
        method, 
        file, 
        "| sed -e '/-----BEGIN PGP MESSAGE-----/{x;q;}'",
        "-e '/#=-=-=-=-=-=-=-=-=Start/{x;q;}'")
    
    # skip=1 to remove stray pre-header timestamp
    read.csv(pipe(command), skip=1, stringsAsFactors=FALSE)
}


## read.lgrbatch is currently defined as
function (file) 
{
    command = paste("sed -n '/^.\\{65\\}/p'", file)
    read.csv(pipe(command), stringsAsFactors=FALSE)
  }
}
}
\keyword{ IO }
