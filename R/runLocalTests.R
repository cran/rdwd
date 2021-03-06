#' @title run local tests of rdwd
#' @description Run `rdwd` tests on local machine. Due to time-intensive
#' data downloads, these tests are not run automatically on CRAN.
#' @return Time taken to run tests in minutes
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Apr-Oct 2019
#' @seealso [localtestdir()]
#' @keywords debugging
#' @importFrom grDevices dev.off pdf
#' @importFrom graphics par title
#' @importFrom utils tail
#' @export
#' 
#' @param dir_data  Reusable data location. Preferably not under version control.
#'                  DEFAULT: [localtestdir()]
#' @param dir_exmpl Reusable example location. DEFAULT: localtestdir(folder="misc/ExampleTests")
#' @param fast      Exclude many tests? DEFAULT: FALSE
#' @param devcheck  Run `devtools::check()`? DEFAULT: !fast
#' @param radar     Test reading radar example files. DEFAULT: !fast
#' @param all_Potsdam_files Read all (ca 60) files for Potsdam? Re-downloads if
#'              files are older than 24 hours. Reduce test time a lot by setting
#'              this to FALSE. DEFAULT: !fast
#' @param index Run [checkIndex()]? DEFAULT: !fast
#' @param indexfast `fast` option passed to [checkIndex()]. DEFAULT: !fast
#' @param examples Run Examples (including donttest sections) DEFAULT: !fast
#' @param quiet Suppress progress messages? DEFAULT: FALSE through [rdwdquiet()]
#' 
runLocalTests <- function(
dir_data=localtestdir(),
dir_exmpl=localtestdir(folder="misc/ExampleTests"),
fast=FALSE,              # ca 0.1 minutes (always, even if fast=T)
devcheck=!fast,          # ca 1.0 minutes
radar=!fast,             # ca 0.3 minutes
all_Potsdam_files=!fast, # ca 1.4 minutes
index=!fast,             # ca 0.3 minutes
indexfast=fast,          # ca 1.3 minutes
examples=!fast,          # ca 2.6 minutes
quiet=rdwdquiet()
)
{
# pre-checks ----
checkSuggestedPackage("testthat", "runLocalTests")
if(!grepl("rdwd$", getwd())) stop("getwd must be in package root folder.")
begintime <- Sys.time()
messaget <- function(x) if(!quiet) message(x, " (",
          round(difftime(Sys.time(), begintime, units="s")), " secs so far)")

# clear warnings logfile:
cat("", file=paste0(dir_exmpl,"/warnings.txt"))


# readDWD.data ----

messaget("++ Testing dataDWD + readDWD.data")

testthat::test_that("dataDWD works", {
link <- selectDWD("Potsdam", res="daily", var="kl", per="recent")
file <- dataDWD(link, read=FALSE, dir=dir_data, quiet=TRUE)
testthat::expect_equal(basename(file), "daily_kl_recent_tageswerte_KL_03987_akt.zip")
links <- selectDWD(id=c(5302,5711,6295),res="daily",var="more_precip",per="h")
testthat::expect_error(dataDWD(links, dir=dir_data), "url must be a vector, not a list")
testthat::expect_warning(dataDWD("multi/mean/Temp.txt", quiet=TRUE),
               "dataDWD needs urls starting with 'ftp://'.")
f <- paste0(dwdbase, "/daily/kl/historical/tageswerte_KL_03987_18930101_20181231_hist.zip")
testthat::expect_warning(dataDWD(f, quiet=TRUE), "If files have been renamed on the DWD server")
testthat::expect_warning(dataDWD(c("multi/mean/Temp.txt", f), quiet=TRUE),
                         "urls starting with .* renamed on the DWD server")
})

testthat::test_that("readDWD.data works for regular data", {
link <- selectDWD("Potsdam", res="daily", var="kl", per="recent")
file <- dataDWD(link, read=FALSE, dir=dir_data, quiet=TRUE)
clim <- readDWD(file)
supposedcolnames <- c("STATIONS_ID", "MESS_DATUM", "QN_3", "FX", "FM", "QN_4",
                      "RSK", "RSKF", "SDK", "SHK_TAG", "NM", "VPM", "PM", "TMK",
                      "UPM", "TXK", "TNK", "TGK", "eor")
testthat::expect_equal(colnames(clim), supposedcolnames)
climf <- readDWD(file, fread=TRUE)
testthat::expect_equal(clim, climf)
#
clim_vn  <- readDWD(file, varnames=TRUE)
clim_vnf <- readDWD(file, varnames=TRUE, fread=TRUE)
testthat::expect_equivalent(clim, clim_vn)
testthat::expect_equal(clim_vn, clim_vnf)
})

testthat::test_that("readDWD.data works for 10 minute data", {
link <- selectDWD("Kiel-Holtenau", res="10_minutes", var="air_temperature", per="recent")
file <- dataDWD(link, read=FALSE, dir=dir_data)
air_temperature <- readDWD(file, varnames=TRUE)
time_diff <- as.numeric(diff(air_temperature$MESS_DATUM[1:10]))
testthat::expect_equal(time_diff, rep(10,9))
})


# readRadarFile ----

if(radar)
{
messaget("++ Testing readRadarFile")
#
if(!file.exists(dir_exmpl)) dir.create(dir_exmpl)
#
testthat::test_that("readRadarFile works", {
trr <- function(file, ext="radolan", readdwd=FALSE) # trr: test reading radar data
  {
  main <- deparse(substitute(file))
  file2 <- localtestdir(folder="misc", file=file)
  rrf <- if(readdwd) readDWD(file2, toraster=FALSE) else dwdradar::readRadarFile(file2)
  rrr <- raster::raster(rrf$dat)
  rrp <- projectRasterDWD(rrr, extent=ext)
  raster::plot(rrr, main="\nOriginal")
  raster::plot(rrp, main="\nProjected")
  addBorders()
  title(main=main, outer=TRUE, line=-1.1)
  rngr <- range(raster::cellStats(rrr, "range"))
  rngp <- range(raster::cellStats(rrp, "range"))
  return(list(file=file2, rrp=rrp, meta=rrf$meta, range_orig=rngr, range_proj=rngp))
  }
pdf(paste0(dir_exmpl,"/Radartests.pdf"), width=10, height=7)
par(mfrow=c(1,2), mar=c(2,2,3,3), mgp=c(2,0.7,0))
w1 <- trr("raa01-rw2017.002_10000-1712310850-dwd---bin_hourRadReproc", ext="rw")
w2 <- trr("raa01-rw_10000-1907311350-dwd---bin_hourRadRecentBin.gz", readdwd=TRUE)
rw <- trr("raa01-rw_10000-1907010950-dwd---bin_weatherRadolan")
sf <- trr("raa01-sf_10000-1605010450-dwd---bin_dailyRadHist")
rx <- trr("raa01-rx_10000-1605290600-dwd---bin_Braunsbach")
rx1 <- raster::raster(dwdradar::readRadarFile(rx$file)$dat)
rx2 <- projectRasterDWD(rx1, targetproj=NULL)
raster::plot(rx2, main="\nProjected without latlon")
raster::plot(rx$rrp, zlim=rx$range_orig, main="\nProjected, with custom zlim")
addBorders()
dev.off()
if(interactive()) berryFunctions::openFile(paste0(dir_exmpl,"/Radartests.pdf"))
#
# "True" values from versions of reading functions that seem to make sense.
# NOT actually checked with DWD, reality or anything!
#
rangecheck <- function(rr, orig, proj, tolerance=0.01)
  {
  name <- deparse(substitute(rr))
  rc <- function(is, should, msg)
  {
  eq <- berryFunctions::almost.equal(is, should, tolerance=tolerance, scale=1)
  if(any(!eq)) stop(msg, " not correct for: ", name, "\n",
               toString(round(is,5)), "   instead of   ", toString(should), "\n")
  }
  rc(rr$range_orig, orig, "Range (unprojected)")
  rc(rr$range_proj, proj, "Range (projected)")
  }
rangecheck(w1, c( 0.0,  6.2), c( 0.00,  5.87))
rangecheck(w2, c( 0.0, 72.6), c(-0.19, 70.98))
rangecheck(rw, c( 0.0, 30.7), c(-0.45, 30.45))
rangecheck(sf, c( 0.0, 39.2), c(-0.03, 38.20))
rangecheck(rx, c(31.5, 95.0), c(18.30, 97.17))
})
} # End radar


# findID ----

messaget("++ Testing findID + selectDWD")

testthat::test_that("findID warns as wanted", {
testthat::expect_warning(findID("this_is_not_a_city"),
               "findID: no ID could be determined from name 'this_is_not_a_city'.")
testthat::expect_warning(findID(c("Wuppertal","this_is_not_a_city") ),
               "findID: no ID could be determined from name 'this_is_not_a_city'.")
testthat::expect_warning(findID(7777),
               "findID: no ID could be determined from name '7777'.")
testthat::expect_warning(findID("01050"),
               "findID: no ID could be determined from name '01050'.")
testthat::expect_equal(findID(), "")
})



# indexFTP----

testthat::test_that("indexFTP warns and works as intended", {
base <- "https://opendata.dwd.de/weather/radar/radolan/rw/"
testthat::expect_warning(indexFTP(base, folder="", dir=tempdir(), quiet=TRUE),
                         "base should start with ftp://")
base <- "ftp://ftp-cdc.dwd.de/weather/radar/radolan/rw"
rw <- indexFTP(base, folder="", dir=tempdir(), quiet=TRUE, exclude.latest.bin=FALSE)
testthat::expect_equal(tail(rw,1), "/raa01-rw_10000-latest-dwd---bin")
})



# selectDWD ----

testthat::test_that("selectDWD works", {
link <- selectDWD("Potsdam", res="daily", var="kl", per="recent")
testthat::expect_equal(link, paste0(dwdbase,"/daily/kl/recent/tageswerte_KL_03987_akt.zip"))
testthat::expect_equal(selectDWD("Potsdam", res="daily", var="solar"),
             paste0(dwdbase,"/daily/solar/tageswerte_ST_03987_row.zip"))
})

testthat::test_that("selectDWD id input can be numeric or character", {
testthat::expect_equal(selectDWD(id="00386", res="daily", var="kl", per="historical"),
             selectDWD(id=386,     res="daily", var="kl", per="historical"))
})

testthat::test_that("selectDWD can choose Beschreibung meta files", {
testthat::expect_equal(selectDWD(id="00386", res="daily", var="kl", per="h", meta=TRUE),
  paste0(dwdbase, "/daily/kl/historical/KL_Tageswerte_Beschreibung_Stationen.txt"))

testthat::expect_equal(selectDWD(id="00386", res="daily", var="kl", per="h", meta=TRUE),
  selectDWD(res="daily", var="kl", per="h", meta=TRUE))
})


testthat::test_that("selectDWD properly vectorizes", {
testthat::expect_type(selectDWD(id="01050", res="daily", var="kl", per=c("r","h")), "list")
testthat::expect_type(selectDWD(id="01050", res="daily", var="kl", per="rh"), "character")
# all zip files in all paths matching id:
allzip_id <- selectDWD(id=c(1050, 386), res="",var="",per="")
# all zip files in a given path (if ID is empty):
allzip_folder <- selectDWD(id="", res="daily", var="kl", per="recent")
testthat::expect_equal(length(allzip_id), 2)
testthat::expect_gte(length(allzip_id[[1]]), 200)
testthat::expect_gte(length(allzip_id[[2]]), 7)
testthat::expect_gte(length(allzip_folder), 573)
})


testthat::test_that("selectDWD uses remove_dupli correctly", {
fi <- data.frame(res="aa", var="bb", per="cc", id=42, start=as.Date("1989-07-01"), 
                 end=as.Date(c("2016-12-31","2015-12-31")), ismeta=FALSE, 
                 path=c("longer", "shorter"))
testthat::expect_length(selectDWD(res="aa",var="bb",per="cc",id=42,findex=fi), 1)
testthat::expect_length(selectDWD(res="aa",var="bb",per="cc",id=42,findex=fi, remove_dupli=FALSE), 2)
testthat::expect_warning(selectDWD(res="aa",var="bb",per="cc",id=42,findex=fi), 
                         "selectDWD: duplicate file on FTP server")
})

# selectDWD warnings ----

messaget("++ Testing selectDWD warnings")

oop <- options(rdwdquiet=FALSE)

testthat::test_that("selectDWD warns as intended", {
testthat::expect_warning(selectDWD(res="",var="",per=""),
               "selectDWD: neither station ID nor valid FTP folder is given.")
testthat::expect_warning(selectDWD(7777, res="",var="",per=""),
               "selectDWD -> findID: no ID could be determined from name '7777'.")
testthat::expect_warning(selectDWD(7777, res="",var="",per=""),
               "selectDWD: neither station ID nor valid FTP folder is given.")
testthat::expect_warning(selectDWD(id=7777, res="",var="",per=""),
               "selectDWD: in file index 'fileIndex', there are 0 files with ID 7777")
testthat::expect_warning(selectDWD(id="", res="dummy", var="dummy", per=""),
               "according to file index 'fileIndex', the following path doesn't exist: /dummy/dummy/")
testthat::expect_warning(selectDWD(id="", res="dummy", var="dummy", per=""),
               "according to file index 'fileIndex', there is no file in '/dummy/dummy/' with ID NA.")
testthat::expect_warning(selectDWD(res="dummy", var="", per=""),
               "selectDWD: neither station ID nor valid FTP folder is given.")
testthat::expect_warning(selectDWD(res="daily", var="", per="r"),
               "selectDWD: neither station ID nor valid FTP folder is given.")
testthat::expect_warning(selectDWD(res="daily", var="kl", per=""),
               "according to file index 'fileIndex', there is no file in '/daily/kl/' with ID NA.")
testthat::expect_warning(selectDWD(id="01050", res=c("daily","monthly"), var="kl", per=""), # needs 'per'
               "according to file index 'fileIndex', there is no file in \n - '/daily/kl/' with ID 1050")
testthat::expect_warning(selectDWD(id="00386", res="",var="",per="", meta=TRUE),
               "meta is ignored if id is given, but path is not given.")
testthat::expect_warning(selectDWD("Potsdam", res="multi_annual", var="mean_81-10", per=""),
               "selectDWD: multi_annual data is not organized by station ID")
testthat::expect_warning(selectDWD(res="multi_annual", var="mean_81-10", per="r"),
               "selectDWD: multi_annual data is not organized in period folders")

testthat::expect_error(selectDWD(id="Potsdam", res="daily", var="solar"),
             "selectDWD: id may not contain letters: Potsdam")
testthat::expect_error(selectDWD(id="", current=TRUE, res="",var="",per=""),
             "selectDWD: current=TRUE, but no valid paths available.")
})

options(oop)
rm(oop)


# checkIndex ----

if(index) checkIndex(findex=fileIndex, mindex=metaIndex, gindex=geoIndex, fast=indexfast,
          logfile=paste0(dir_exmpl,"/warnings.txt"), warn=FALSE)


# Index up to date? ----

messaget("++ Testing index up to date?")

# simply try all files for Potsdam (for 1_minute and 10_minutes only 1 each)
if(all_Potsdam_files)
testthat::test_that("index is up to date - all files can be downloaded and read", {
links <- selectDWD("Potsdam","","","") # does not include multi_annual data!
toexclude <- grep("1_minute", links)
toexclude <- toexclude[-(length(toexclude)-3)]
toexclude <- c(toexclude, grep("10_minutes", links)[-1])
files <- dataDWD(links[-toexclude], dir=dir_data, force=NA, overwrite=TRUE, read=FALSE)
contents <- readDWD(files)
})


messaget("assuming updateIndexes() has been run.")
testthat::test_that("historical files have been updated by DWD", {
# data("fileIndex")
lastyear <- as.numeric(format(Sys.Date(), "%Y"))-1 # the last completed year
outdated <- fileIndex$end==as.Date(paste0(lastyear-1, "-12-31")) & # ends 1 year before lastyear
            fileIndex$per=="historical" &
            fileIndex$res!="1_minute"
outdated[is.na(outdated)] <- FALSE
sum(outdated)
#View(fileIndex[outdated,])
if(any(outdated)){
rvp <- unique(fileIndex[outdated,1:3])
alloutdated <- sapply(1:nrow(rvp), function(r)
 {
 fi <- fileIndex$res==rvp[r, "res"] &
  fileIndex$var==rvp[r, "var"] &
  fileIndex$per==rvp[r, "per"]
 all(fi[outdated])
 })
rvp <- apply(rvp, 1, paste, collapse="/")
rvp <- unname(rvp)
if(any(alloutdated)) stop("The DWD has not yet updated any historical files in ",
                          "the following ", sum(alloutdated), " folders:\n",
                          toString(rvp[alloutdated]))
}})



# devtools::check ----

if(devcheck) 
  {
  checkSuggestedPackage("devtools", "runLocalTests with devcheck=TRUE")
  messaget("++ Running devtools::check. This will take a minute.")
  dd <- devtools::check(quiet=quiet)
  print(dd)
  }

  
# Testing examples ----
if(examples)
  {
  checkSuggestedPackage("roxygen2", "runLocalTests with examples=TRUE")
  messaget("++ Testing examples")
  if(!devcheck) roxygen2::roxygenise()
  oo <- options(rdwdquiet=TRUE)
  berryFunctions::testExamples(logfolder=dir_exmpl, telldocument=FALSE) # version >= 1.18.18
  options(oo)

# remove false positives in warnings.txt
logfile <- paste0(dir_exmpl,"/warnings.txt")
log <- readLines(logfile)
log <- paste0(log, collapse="\n")
rem <- "Metadaten_Fehl[[:alpha:]]{5}_05856_[[:digit:]]{8}_[[:digit:]]{8}.txt:'data.frame':	"
log <- gsub(rem, "Metadaten_Fehl--_05856_--.txt:'data.frame':	", log)
rem <- "\nList of 8
 $ Metadaten_Fehl--_05856_--.txt:'data.frame':	12 obs. of  9 variables:
 $ Metadaten_Fehl--_05856_--.txt:'data.frame':	9 obs. of  9 variables:
 $ Metadaten_Fehlwerte_Gesamt_05856.txt           :'data.frame':	2 obs. of  9 variables:
 $ Metadaten_Geographie_05856.txt                 :'data.frame':	3 obs. of  7 variables:
 $ Metadaten_Geraete_Windgeschwindigkeit_05856.txt:'data.frame':	3 obs. of  12 variables:
 $ Metadaten_Geraete_Windrichtung_05856.txt       :'data.frame':	3 obs. of  12 variables:
 $ Metadaten_Parameter_ff_stunde_05856.txt        :'data.frame':	8 obs. of  13 variables:
 $ Metadaten_Stationsname_05856.txt               :'data.frame':	1 obs. of  4 variables:"
log <- sub(rem, "", log, fixed=TRUE)
rem <- "Warning in fileType(\"random_stuff.odt\") :
  fileType failed for the following file: 'random_stuff.odt'\n"
log <- sub(rem, "", log, fixed=TRUE)
rem <- "\nrdwd station id 2849 with 3 files.
Name: Langenburg-Baechlingen, State: Baden-Wuerttemberg
Additionally, there are 3 non-public files. Display all with  metaInfo(2849,FALSE)
To request those datasets, please contact cdc.daten@dwd.de or klima.vertrieb@dwd.de
      res         var        per hasfile       from         to     lat   long ele
1  annual more_precip historical    TRUE 1991-01-01 2007-12-31 49.2445 9.8499 300
2   daily more_precip historical    TRUE 1990-10-01 2008-06-30 49.2445 9.8499 300
3 monthly more_precip historical    TRUE 1990-10-01 2008-06-30 49.2445 9.8499 300"
log <- sub(rem, "", log, fixed=TRUE)
rem <- "\nNote in is.error: Error in plotRadar(ncp1, layer = 1:4, project = FALSE) : 
  3 layers selected that do not exist.\n"
log <- sub(rem, "", log, fixed=TRUE)
rem <- "\nFormal class 'RasterBrick' [package \"raster\"] with 12 slots
  ..@ file    :Formal class '.RasterFile' [package \"raster\"] with 13 slots
  ..@ data    :Formal class '.MultipleRasterData' [package \"raster\"] with 14 slots
  ..@ legend  :Formal class '.RasterLegend' [package \"raster\"] with 5 slots
  ..@ title   : chr \"mean relative humidity at 2 m height\"
  ..@ extent  :Formal class 'Extent' [package \"raster\"] with 4 slots
  ..@ rotated : logi FALSE
  ..@ rotation:Formal class '.Rotation' [package \"raster\"] with 2 slots
  ..@ ncols   : int 720
  ..@ nrows   : int 938
  ..@ crs     :Formal class 'CRS' [package \"sp\"] with 1 slot
  ..@ history : list()
  ..@ z       :List of 1
 num [1:720, 1:938, 1:30] NA NA NA NA NA NA NA NA NA NA ..."
log <- sub(rem, "", log, fixed=TRUE)
rem <- "---------------\nC:/Dropbox/Rpack/rdwd/man/.{10,50}\n\n\n"
log <- gsub(rem, "", log)
rem <- "---------------\nC:/Dropbox/Rpack/rdwd/man/updateRdwd.Rd -- .{19}"
log <- sub(rem, "", log)

cat(log, file=logfile)

} # end if(examples)


# Output ----
runtime <- round(difftime(Sys.time(), begintime, units="min"),1)
if(!quiet) message("++ Testing finished!  Total run time: ", runtime, " minutes")
return(invisible(runtime))
}
