% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readDWD.R
\name{readDWD.asc}
\alias{readDWD.asc}
\title{read dwd gridded radolan asc data}
\usage{
readDWD.asc(file, exdir = NULL, dividebyten = TRUE, selection = NULL,
  progbar = TRUE, ...)
}
\arguments{
\item{file}{Name of file on harddrive, like e.g. 
DWDdata/grids_germany/hourly/radolan/historical/asc/
2018_RW-201809.tar.
Must have been downloaded with \code{mode="wb"}!}

\item{exdir}{Directory to unzip into. Unpacked files existing therein
will not be untarred again, saving up to 15 secs per file.
DEFAULT: NULL (subfolder of \code{\link{tempdir}()})}

\item{dividebyten}{Divide numerical values by 10? 
If dividebyten=FALSE and exdir left at NULL (tempdir), save 
the result on disc with \code{raster::\link[raster]{writeRaster}}.
Accessing out-of-memory raster objects won't work if 
exdir is removed! -> Error in .local(.Object, ...)
DEFAULT: TRUE}

\item{selection}{Optionally read only a subset of the ~24*31=744 files.
Called as \code{f[selection]}. DEFAULT: NULL (ignored)}

\item{progbar}{Show messages and progress bars? \code{\link{readDWD}} will
keep progbar=TRUE for asc files, even if length(file)==1.
DEFAULT: TRUE}

\item{\dots}{Further arguments passed to \code{raster::\link[raster]{raster}}}
}
\value{
data.frame
}
\description{
read grid-interpolated radolan asc data. 
Intended to be called via \code{\link{readDWD}}.\cr
See \url{ftp://ftp-cdc.dwd.de/pub/CDC/grids_germany/hourly/radolan/README.txt}
All layers (following \code{selection} if given) in all .tar.gz files are 
combined into a raster stack with \code{raster::\link[raster]{stack}}.\cr
To project the data, use \code{\link{projectRasterDWD}}
}
\examples{
\dontrun{ # Excluded from CRAN checks, but run in localtests

# File selection and download:
datadir <- localtestdir()
# 2019-05-18, hourly radolan files not yet copied to new ftp, hence:
gridbase <- "ftp://ftp-cdc.dwd.de/pub/CDC/grids_germany" 
radbase <- paste0(gridbase,"/hourly/radolan/historical/asc/")
radfile <- "2018/RW-201809.tar" # 25 MB to download
file <- dataDWD(radfile, base=radbase, joinbf=TRUE, dir=datadir,
                dfargs=list(mode="wb"), read=FALSE) # download with mode=wb!!!
                
#asc <- readDWD(file) # 4 GB in mem. ~ 20 secs unzip, 30 secs read, 10 min divide
asc <- readDWD(file, selection=1:20, dividebyten=TRUE)
asc <- projectRasterDWD(asc)

raster::plot(asc[[1]], main=names(asc)[1])
data(DEU)
raster::plot(DEU, add=TRUE)

rng <- range(raster::cellStats(asc, "range"))
nframes <- 3 # raster::nlayers(asc) for all (time intensive!)
viddir <- paste0(tempdir(),"/RadolanVideo")
dir.create(viddir)
png(paste0(viddir,"/Radolan_\%03d.png"), width=7, height=5, units="in", res=300)
dummy <- pbsapply(1:nframes, function(i) 
         raster::plot(asc[[i]], main=names(asc)[i], zlim=rng)) # 3 secs per layer
dev.off()
berryFunctions::openFile(paste0(viddir,"/Radolan_001.png"))

# Time series of a given point in space:
plot(as.vector(asc[800,800,]), type="l", xlab="Time [hours]")

# if dividebyten=FALSE, raster stores things out of memory in the exdir.
# by default, this is in tempdir, hence you would need to save asc manually:
# raster::writeRaster(asc, paste0(datadir,"/RW2018-09"), overwrite=TRUE) 
}
}
\seealso{
\code{\link{readDWD}}
}
\author{
Berry Boessenkool, \email{berry-b@gmx.de}, April 2019
}