# addBorders -------------------------------------------------------------------

#' @title add country and Bundesland borders to a map
#' @return invisible list with DEU and EUR
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2019
#' @seealso [`plotRadar`], [`DEU`], [`EUR`]
#' @keywords aplot
#' @importFrom utils globalVariables
#' @export
#' @examples
#' if(requireNamespace("raster", quietly=TRUE)){
#' plot(1, xlim=c(2,16), ylim=c(47,55))
#' addBorders()
#' plot(1, xlim=c(2,16), ylim=c(47,55))
#' addBorders(de="orange", eu=NA)
#' }
#' 
#' @param de      Color for Bundeslaender line ([`DEU`]). NA to suppress. DEFAULT: "grey80"
#' @param eu      Color for countries line ([`EUR`]). NA to suppress. DEFAULT: "black"
#' @param add     Logical: add to existing plot? DEFAULT: TRUE
#' @param \dots   Further arguments passed to [raster::plot()]
addBorders <- function(
 de="grey80",
 eu="black",
 add=TRUE,
 ...)
{
checkSuggestedPackage("raster", "addBorders") # stops also if sp is missing
load(system.file("extdata/DEU.rda", package="rdwd"), envir=environment())
load(system.file("extdata/EUR.rda", package="rdwd"), envir=environment())
raster::plot(DEU, add=add, border=de, ...)
raster::plot(EUR, add=TRUE, border=eu, ...)
return(invisible(list(DEU=DEU, EUR=EUR)))
}
# Suppress CRAN check note 'no visible binding for global variable':
if(getRversion() >= "2.15.1")  utils::globalVariables(c("DEU", "EUR"))


# DEU Map dataset --------------------------------------------------------------

#' Map of German states (Bundeslaender) from GADM through the `raster` package
#' @name DEU
#' @seealso [`addBorders`], [`EUR`]
#' @details Use directly with:\cr
#' `load(system.file("extdata/DEU.rda", package="rdwd"))`\cr\cr
#' Obtained with the code: \cr
#' ```
#' DEU1 <- raster::getData("GADM", country="DEU", level=1)
#' DEU <- rgeos::gSimplify(DEU1, tol=0.02, topologyPreserve=FALSE)
#' raster::plot(DEU1)
#' raster::plot(DEU)
#' save(DEU,        file="inst/extdata/DEU.rda")
#' tools::resaveRdaFiles("inst/extdata/DEU.rda")
#' ```
#' @docType data
#' @format Formal class 'SpatialPolygons' (package "sp") with 4 slots
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, May 2018
#' @keywords datasets
if(requireNamespace("sp", quietly=TRUE))
load(system.file("extdata/DEU.rda", package="rdwd"), envir=environment())
# To have it avaliable as rdwd:::DEU


# EUR Map dataset --------------------------------------------------------------

#' Map of Western European countries through the `rworldmap` package
#' @name EUR
#' @seealso[`addBorders`], [`DEU`]
#' @details Use directly with:\cr
#' `load(system.file("extdata/EUR.rda", package="rdwd"))`\cr\cr
#' Obtained with the code: \cr
#' ```
#' EUR <- rworldmap::getMap("low")
#' EUR <- raster::crop(EUR, c(-5,25, 40,60))
#' raster::plot(EUR)
#' save(EUR,        file="inst/extdata/EUR.rda", version=2)
#' tools::resaveRdaFiles("inst/extdata/EUR.rda", version=2)
#' ```
#' @docType data
#' @format SpatialPolygonsDataFrame (package "sp") with 32 rows
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2019
#' @keywords datasets
if(requireNamespace("sp", quietly=TRUE))
load(system.file("extdata/EUR.rda", package="rdwd"), envir=environment())

