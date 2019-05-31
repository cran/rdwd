#' @title check indexes
#' @description check indexes. Mainly for internal usage in \code{\link{createIndex}}.
#'              Not exported, so call it as rdwd:::checkIndex() if you want to
#'              run tests yourself. Further test suggestions are welcome!
#' @return Charstring with issues (if any) to be printed with \code{cat()}.
#' @importFrom berryFunctions sortDF truncMessage round0
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, May 2019
#' @seealso \code{\link{createIndex}}
#' @examples 
#' data(fileIndex) ; data(metaIndex) ; data(geoIndex)
#' # ci <- checkIndex(findex=fileIndex, mindex=metaIndex, gindex=geoIndex)
#' # cat(ci)
#' @param findex    \code{\link{fileIndex}}. DEFAULT: NULL
#' @param mindex    \code{\link{metaIndex}}. DEFAULT: NULL
#' @param gindex    \code{\link{geoIndex}}.  DEFAULT: NULL
#' @param excludefp Exclude false positives from geoIndex coordinate check results?
#'                  DEFAULT: TRUE
#' @param fast      Exclude the 3-minute location per ID check? DEFAULT: FALSE
checkIndex <- function(findex=NULL, mindex=NULL, gindex=NULL, excludefp=TRUE, fast=FALSE)
{
# helper function:
alldupli <- function(x) duplicated(x) | duplicated(x, fromLast=TRUE)
# Output text:
out <- ""

# findex ----

if(!is.null(findex)){
message("Checking fileIndex...")
# check for duplicate files (DWD errors):
duplifile <- findex[!grepl("minute",findex$res),] # 1min + 10min excluded
duplifile <- duplifile[alldupli(duplifile[,1:4]),]
duplifile <- duplifile[!is.na(duplifile$id),] # exclude meta + multia files
duplifile <- duplifile[duplifile$res!="subdaily" & duplifile$var!="standard_format",]

if(nrow(duplifile)>0)
  {
  rvp <- paste(duplifile$res,duplifile$var,duplifile$per, sep="/")
  per_folder <- lapply(unique(rvp), function(p) 
    {i <- unique(duplifile$id[rvp==p])
    paste0("- ", round0(length(i), pre=4, flag=" "), " at ", p, "; ", 
           truncMessage(i, ntrunc=10, prefix=""))
    })
  per_folder <- paste(unlist(per_folder), collapse="\n")
  out <- c(out, "IDs with duplicate files:", per_folder)
  }
}


# mindex ----

if(!is.null(mindex)){
message("Checking metaIndex...")
# helper function:
newout <- function(out,ids,colcomp,column,textvar,unit="") 
 {
 new <- sapply(ids, function(i) 
 {tt <- sort(table(mindex[colcomp==i,column]), decreasing=TRUE)
 unname(paste0("- ", textvar,"=",i, ": ", paste0(tt,"x",names(tt),unit, collapse=", ")))
 })
 c(out, new)
 }

id_uni <- unique(mindex$Stations_id)
# ID elevation inconsistencies:
eletol <- 2.1 # m tolerance
id_ele <- pbapply::pbsapply(id_uni, function(i) 
                 any(abs(diff(mindex[mindex$Stations_id==i,"Stationshoehe"]))>eletol))
if(any(id_ele))
  {
  out <- c(out,paste0("Elevation differences >",eletol,"m:"))
  out <- newout(out, id_uni[id_ele], mindex$Stations_id, "Stationshoehe", "ID", "m")
  }

# several locations for one station ID:
if(!fast){
loctol <- 0.040 # km
id_loc <- pbapply::pbsapply(id_uni, function(i) 
    maxlldist("geoBreite","geoLaenge", mindex[mindex$Stations_id==i,], each=FALSE)>loctol)
mindex$coord <- paste(mindex$geoBreite, mindex$geoLaenge, sep="_")
if(any(id_loc))
  {
  out <- c(out, paste0("Location differences >",loctol*1000,"m:"))
  out <- newout(out, id_uni[id_loc], mindex$Stations_id, "coord", "ID") 
  }
}

# Different names per ID:
id_name <- pbapply::pbsapply(id_uni, function(i) 
                  length(unique(mindex[mindex$Stations_id==i,"Stationsname"]))>1)
if(any(id_name))
  {
  out <- c(out, "Different names per id:")
  out <- newout(out, id_uni[id_name], mindex$Stations_id, "Stationsname", "ID")
  }

# Different IDs per name:
name_uni <- unique(mindex$Stationsname)
name_id <- pbapply::pbsapply(name_uni, function(n) 
                  length(unique(mindex[mindex$Stationsname==n,"Stations_id"]))>1)
if(excludefp) name_id[name_uni=="Suderburg"] <- FALSE
if(any(name_id))
  {
  out <- c(out, "More than one id per name:")
  out <- newout(out, name_uni[name_id], mindex$Stationsname,"Stations_id", "Name")
  }
}


# gindex ----

if(!is.null(gindex)){
message("Checking geoIndex...")
columns <- !colnames(gindex) %in% c("display","col")
# Duplicate coordinates checks:
# Exclude known false positives like "Dasburg" vs "Dasburg (WWV RLP)"
fpid <- c(14306,921, 13967,13918, 14317,3024, 2158,7434, 785,787, 15526, 5248,5249, 396,397)
# sortDF(gindex[gindex$id %in% fpid, columns], "name")
gindex_id <- gindex
if(excludefp) gindex_id <- gindex[!gindex$id %in% fpid,]
coord <- paste(gindex_id$lon, gindex_id$lat, sep="_")
# several stations at the same locations:
if(anyDuplicated(coord))
  {
  out <- c(out, "Coordinates used for more than one station:")
  new <- sapply(coord[duplicated(coord)], function(c){
    g <- gindex_id[coord==c, ]
    t <- toString(paste0(g$nfiles+g$nonpublic, "x ID=", g$id, " (", g$name, ")"))
    paste0("- ", c, ": ", t)
    })
  out <- c(out, new)
  }
}

# output stuff:
if(any(out!="")) warning("There are issues in the indexes, view them with cat.")
out <- c(out, as.character(Sys.time()))
out <- paste(out, collapse="\n")
return(invisible(out))
} # end checkIndex