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
Data frame with all variables from the LGR file (113 columns on my machine, but this may be configuration-dependent) plus a new column containing the filename from wihch it was read. 'Time' and 'filename' are character vectors, all others are numeric.}
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
    df = read.csv(pipe(command), skip=1, stringsAsFactors=FALSE)
    df$filename = basename(file)
    return(df)
}


## read.lgrbatch is currently defined as
function(file){
    # LGR batch files begin with short summary lines 
    # and end with a PGP-encrypted settings block. 
    # These lines are much shorter than data lines, so filter out 
    # by removing any line containing less than 65 characters.
    command = paste("sed -n '/^.\\{65\\}/p'", file)
    df = read.csv(pipe(command), stringsAsFactors=FALSE)
    df$filename = basename(file)
    return(df)
}
}
}
\keyword{ IO }
