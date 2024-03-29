% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readVars.R
\name{readVars}
\alias{readVars}
\title{Process data from the DWD CDC FTP Server}
\usage{
readVars(file, params = dwdparams, quiet = rdwdquiet(), progbar = TRUE)
}
\arguments{
\item{file}{Char (vector): name(s) of the file(s) downloaded with \code{\link[=dataDWD]{dataDWD()}},
e.g. "~/DWDdata/tageswerte_KL_02575_akt.zip"}

\item{params}{data.frame: Parameter explanations. DEFAULT: \code{\link{dwdparams}}}

\item{quiet}{Suppress message about non-abbreviated parameters?
DEFAULT: FALSE through \code{\link[=rdwdquiet]{rdwdquiet()}}}

\item{progbar}{Logical: present a progress bar with estimated remaining time?
If missing and length(file)==1, progbar is internally set to FALSE.
DEFAULT: TRUE}
}
\value{
data.frame of the desired dataset,
or a named list of data.frames if length(file) > 1.
}
\description{
Read climate variables (column meta data) from zip folders downloaded with
\code{\link[=dataDWD]{dataDWD()}}.
The metadata file \code{"Metadaten_Parameter.*txt"} in the zip folder \code{file}
is read, processed and returned as a data.frame.\cr
\code{file} can be a vector with several filenames.
}
\examples{
# see dataDWD

}
\seealso{
\code{\link[=dataDWD]{dataDWD()}}, \code{\link[=readDWD]{readDWD()}}, \code{\link{dwdparams}}, \code{\link[=newColumnNames]{newColumnNames()}}\cr
\code{\link[=readMeta]{readMeta()}} for complete  \code{Metadaten_Parameter} file.\cr
\href{https://bookdown.org/brry/rdwd/use-case-get-all-hourly-rainfall-data-20142016.html#read-the-data}{website use case}
}
\author{
Berry Boessenkool, \email{berry-b@gmx.de}, Jun 2018
}
\keyword{file}
