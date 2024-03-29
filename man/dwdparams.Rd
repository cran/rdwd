% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readVars.R
\docType{data}
\name{dwdparams}
\alias{dwdparams}
\title{DWD parameter explanations}
\format{
An object of class \code{data.frame} with 176 rows and 2 columns.
}
\usage{
dwdparams
}
\description{
Short German parameter explanations for the DWD abbreviations
on the CDC FTP server.\cr
These are manually created by me and might need to be expanded if the DWD adds
more abbreviations.\cr
\code{\link[=readVars]{readVars()}} maps them to the variable abbreviations in the
\code{"Metadaten_Parameter.*txt"} file in any given zip folder
and will warn about missing entries.
}
\examples{
head(dwdparams)

}
\seealso{
\code{\link[=readVars]{readVars()}}, \code{\link[=readDWD]{readDWD()}}
}
\author{
Berry Boessenkool, \email{berry-b@gmx.de}, Jun 2018
}
\keyword{datasets}
