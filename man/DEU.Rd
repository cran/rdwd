% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addBorders.R
\docType{data}
\name{DEU}
\alias{DEU}
\title{Map of German states (Bundeslaender) from GADM through the \code{raster} package}
\format{
Formal class 'SpatialPolygons' (package "sp") with 4 slots
}
\description{
Map of German states (Bundeslaender) from GADM through the \code{raster} package
}
\details{
Use directly with:\cr
\code{load(system.file("extdata/DEU.rda", package="rdwd"))}\cr\cr
Obtained with the code: \cr\preformatted{DEU1 <- raster::getData("GADM", country="DEU", level=1)
DEU <- rgeos::gSimplify(DEU1, tol=0.02, topologyPreserve=FALSE)
raster::plot(DEU1)
raster::plot(DEU)
save(DEU,        file="inst/extdata/DEU.rda")
tools::resaveRdaFiles("inst/extdata/DEU.rda")
}
}
\seealso{
\code{\link{addBorders}}, \code{\link{EUR}}
}
\author{
Berry Boessenkool, \email{berry-b@gmx.de}, May 2018
}
\keyword{datasets}
