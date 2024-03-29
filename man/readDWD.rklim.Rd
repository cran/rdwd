% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/readDWD.R
\name{readDWD.rklim}
\alias{readDWD.rklim}
\title{read dwd gridded radklim binary data}
\usage{
readDWD.rklim(
  file,
  exdir = NULL,
  unpacked = NULL,
  selection = NULL,
  toraster = TRUE,
  quiet = rdwdquiet(),
  progbar = !quiet,
  ...
)
}
\arguments{
\item{file}{Name of file on harddrive, like e.g.
DWDdata/5_minutes_radolan_reproc_2017_002_bin_2020_YW2017.002_202006.tar}

\item{exdir}{Directory to unzip into. If existing, only the needed files
will be unpacked with \code{\link[=untar]{untar()}}. Note that exdir
size will be around 17 GB for 5-minute files.
If \code{unpacked=FALSE}, exdir can contain other files
that will be ignored for the actual reading.
DEFAULT: basename(file) at tempdir}

\item{unpacked}{Manually indicate whether .tar.gz files within .tar file
have already been unpacked before.
DEFAULT: NULL: checks if 'yw.*--bin' file(s) are present}

\item{selection}{Optionally read only a subset of the ~ 12 x 24 x 30/31 = 8640 files.
Called as \code{f[selection]}. DEFAULT: NULL (ignored)}

\item{toraster}{Logical: convert to \link[terra:rast]{terra::rast}? see \link{readDWD.binary}
DEFAULT: TRUE}

\item{quiet}{Suppress progress messages?
DEFAULT: FALSE through \code{\link[=rdwdquiet]{rdwdquiet()}}}

\item{progbar}{Show progress bars?
DEFAULT: !quiet, i.e. TRUE}

\item{\dots}{Further arguments passed to \code{\link[dwdradar:readRadarFile]{dwdradar::readRadarFile()}},
i.e. \code{na} and \code{clutter}}
}
\value{
list depending on argument \code{toraster}, see there for details
}
\description{
read gridded radklim binary data.
Intended to be called via \code{\link[=readDWD]{readDWD()}}.\cr
Note: needs dwdradar >= 0.2.6 (2021-08-08)
}
\examples{
\dontrun{ # Excluded from CRAN checks, but run in localtests
yw_link <- "/5_minutes/radolan/reproc/2017_002/bin/2022/YW2017.002_202203.tar"
# 202006 has untar error on Mac, 2023-04, maybe due to incomplete download
yw_file <- dataDWD(url=yw_link, base=gridbase, joinbf=TRUE, read=FALSE) # 207 MB
x <- readDWD(yw_file, selection=3641:3644)
# 00:30 for tar files, 01:40 for unpacking. 
# If you need a preselection argument, let me know.
terra::plot(x$dat)
plotRadar(x$dat[[1]], extent="rw") # better extent below

f <- system.file("tests//raa01-yw2017.002_10000-2006131525-dwd---bin", package="dwdradar")
# https://stackoverflow.com/a/72207233/1587132 on how to install with tests folder
if(!file.exists(f)){
# Clone from https://github.com/brry/dwdradar:
f <- locdir(file="binary_testfile")
download.file(paste0("https://github.com/brry/dwdradar/raw/master/tests/",
                     "raa01-yw2017.002_10000-2006131525-dwd---bin"), f, mode="wb")
}
x <- dwdradar::readRadarFile(f)
x$dat <- terra::rast(x$dat)
terra::plot(x$dat)
plotRadar(x$dat, extent=c(-360, 380, -4730 ,-3690))

radloc <- read.table(header=T, sep=",", text="
ND, NM, NS  ,   ED, EM, ES
53, 33, 50.4,   06, 44, 53.9
51, 07, 26.5,   13, 45, 48.5
51, 24, 18.5,   06, 57, 49.8
47, 52, 21.3,   08, 00, 24.6
54, 10, 23.2,   12, 06, 25.3
52, 28, 40.3,   13, 23, 13.0
54, 00, 15.8,   10, 02, 48.7
51, 07, 28.7,   13, 46, 07.1
49, 32, 26.4,   12, 24, 10.0
53, 20, 19.4,   07, 01, 25.5
51, 24, 20.2,   06, 58, 01.6
47, 52, 25.0,   08, 00, 13.0
51, 20, 06.0,   08, 51, 09.0
51, 18, 40.3,   08, 48, 07.2
50, 03, 06.0,   08, 34, 05.0
50, 01, 20.8,   08, 33, 30.7
53, 37, 16.5,   09, 59, 47.6
52, 27, 47.0,   09, 41, 53.9
52, 27, 36.2,   09, 41, 40.2
48, 10, 28.9,   12, 06, 06.3
48, 02, 31.7,   10, 13, 09.2
48, 20, 10.9,   11, 36, 42.1
50, 30, 00.4,   11, 08, 06.2
50, 06, 34.7,   06, 32, 53.9
49, 59, 05.1,   08, 42, 46.6
52, 38, 55.2,   13, 51, 29.6
54, 10, 32.4,   12, 03, 29.1
48, 35, 07.0,   09, 46, 58.0
52, 09, 36.3,   11, 10, 33.9")
radloc$x <- radloc$ED + radloc$EM/60 + radloc$ES/3600
radloc$y <- radloc$ND + radloc$NM/60 + radloc$NS/3600
for(i in 1:29) berryFunctions::circle(radloc$x[i], radloc$y[i], 0.9)
}
}
\seealso{
\code{\link[=readDWD.binary]{readDWD.binary()}}, radar locations from \url{https://www.dwd.de/DE/leistungen/radarklimatologie/radklim_kompositformat_1_0.pdf?__blob=publicationFile&v=1}
}
\author{
Berry Boessenkool, \email{berry-b@gmx.de}, Aug 2021.
}
