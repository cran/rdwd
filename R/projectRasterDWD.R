#' @title project DWD raster data
#' @description Set projection and extent for DWD raster data. Optionally (and
#'   per default) also reprojects to latlon data.\cr\cr
#'   **WARNING:** reprojection to latlon changes values slightly. For the
#'   tested RX product, this change is significant, see:
#'   <https://github.com/brry/rdwd/blob/master/misc/ExampleTests/Radartests.pdf>\cr
#'    In terra::plot, **use range=zlim with the original range** if needed.
#' @details The internal defaults are extracted from the Kompositformatbeschreibung at
#'   <https://www.dwd.de/DE/leistungen/radolan/radolan.html>, as provided
#'   2019-04 by Antonia Hengst.\cr The nc extent was obtained by projecting
#'   Germanys bbox to EPSG 3034 (specified in the DWD documentation). Using that
#'   as a starting point, I then refined the extent to a visual match, see
#'   [developmentNotes.R](https://github.com/brry/rdwd/blob/master/misc/developmentNotes.R)\cr\cr
#' @return terra raster object with projection and extent, invisible
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, May 2019, June 2023
#' @seealso [plotRadar()]\cr
#' `terra::`[`crs`][terra::crs] / [`ext`][terra::ext] / [`project`][terra::project]\cr
#' `readDWD.`[`binary`][readDWD.binary] / [`raster`][readDWD.raster] /
#' [`asc`][readDWD.asc] / [`radar`][readDWD.radar] / [`nc`][readDWD.nc]\cr
#' [website raster chapter](https://bookdown.org/brry/rdwd/raster-data.html)
#' @keywords aplot
#' @export
#' @importFrom berryFunctions tstop
#' @examples
#' # To be used after readDWD.binary etc
#' @param r      terra raster object
#' @param proj   Current projection to be given to `r`. Can be\cr 
#'               - a [terra::crs()] input,\cr 
#'               - NULL to not set proj+extent (but still consider `targetproj`),\cr 
#'               - or a special charstring for internal defaults, namely:
#'               "radolan" (readDWD.binary + .asc + .radar), "seasonal" (.raster) or "nc"  (.nc).\cr 
#'               DEFAULT: "radolan"
#' @param extent Current [terra::ext()] extent to be given to `r`.
#'               Ignored if `proj=NULL`. Can be NULL to be ignored, an extent object, 
#'               a vector with 4 numbers, or "radolan" / "rw" / "seasonal" / "nc" with internal defaults.
#'               DEFAULT: "radolan"
#' @param adjust05 Logical: Adjust extent by 0.5m to match edges? DEFAULT: FALSE
#' @param targetproj `r` is reprojected to this [terra::crs()]. 
#'               Use NULL to not reproject (i.e. only set proj and extent).
#'               DEFAULT: "ll" with internal default for lat-lon.
#' @param threads Use multiple CPU threads for [terra::project()]? 
#'               DEFAULT: TRUE (opposite from terra::project)
#' @param quiet  Logical: suppress progress messages? DEFAULT: FALSE through [rdwdquiet()]
#' 
projectRasterDWD <- function(
r,
proj="radolan",
extent="radolan",
adjust05=FALSE,
targetproj="ll",
threads=TRUE,
quiet=rdwdquiet()
)
{
# input check
if(is.null(r)) tstop("r is NULL. Make sure you select the terra raster part properly.")
if(identical(names(r),c("dat","meta"))) tstop("projectRasterDWD needs the 'dat' element as input.")
# package check
checkSuggestedPackage("terra", "rdwd::projectRasterDWD")
starttime <- Sys.time()

# current projection ----
if(!is.null(proj))
{
if(!quiet) message("Setting terra raster crs to ", proj, " ...")
# Default projection and extent:
# Projection as per Kompositbeschreibung 1.5
# https://opendata.dwd.de/climate_environment/CDC/grids_germany/seasonal/air_temperature_max/BESCHREIBUNG_gridsgermany_seasonal_air_temperature_max_de.pdf
# https://spatialreference.org/ref/epsg/31467/
p_radolan <- "+proj=stere +lat_0=90 +lat_ts=90 +lon_0=10 +k=0.93301270189
              +x_0=0 +y_0=0 +a=6370040 +b=6370040 +to_meter=1000 +no_defs"
p_seasonal <- "EPSG:31467"
p_nc <- "EPSG:3034"
#
if(is.character(proj))
  proj <- switch(proj, radolan=p_radolan, seasonal=p_seasonal, nc=p_nc, proj)
# if(!inherits(proj, "crs")) proj <- sf::st_crs(proj)$wkt
# Using st_crs to avoid proj4 warning for seasonal: 
# [crs<-] Only the WGS84, NAD83 and NAD27 datums can be used with a PROJ.4 string.
# Use WKT2, authority:code, or +towgs84= instead 
# actually project:
terra::crs(r) <- proj
} # end if not null proj

# current extent ----
if(!is.null(extent))
{
# Extent as per Kompositbeschreibung 1.4 / seasonal DESCRIPTION pdf:
e_radolan <- c(-523.4622,376.5378,-4658.645,-3758.645)
e_rw <-      c(-443.4622,456.5378,-4758.645,-3658.645) # 1.2, Abb 3
# e_radolan <- c(-673.4656656,726.5343344,-5008.642536,-3508.642536) # ME
e_seasonal <- c(3280414.71163347, 3934414.71163347, 5237500.62890625, 6103500.62890625)
e_nc <- c(3667000, 4389000, 2242000, 3181000)
if(is.character(extent))
  extent <- switch(extent, radolan=e_radolan, rw=e_rw, seasonal=e_seasonal, nc=e_nc)
if(is.numeric(extent) && adjust05) extent <- extent - 0.5
if(!quiet) message("Setting terra raster extent to ", toString(sapply(extent, I)), " ...")
terra::ext(r) <- extent
} # end if not null extent

# reproject ----
# lat-lon projection:
if(!is.null(targetproj))
 {
 if(!quiet) message("Reprojecting terra raster to ",targetproj," ...")
 if(is.character(targetproj)) if(targetproj=="ll")
     targetproj <- "+proj=longlat +datum=WGS84 +no_defs" # sf::st_crs()$wkt
 r <- terra::project(r, targetproj, threads=threads)
 }
dt <- difftime(Sys.time(),starttime)
if(!quiet) message("projectRasterDWD took ", round(dt,1), " ", attr(dt, "units"))
# invisible output:
return(invisible(r))
}
