#' @title Update rdwd development version
#' @description Update rdwd to the latest development version on github, if necessary.
#'         If the version number or date is larger on github,
#'         [remotes::install_github()] will be called.
#' @return data.frame with version information
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Nov 2019
#' @seealso [remotes::install_github()]
#' @keywords file
#' @importFrom utils packageDescription download.file compareVersion
#' @export
#' @examples
#' # updateRdwd()
#' 
#' @param pack     Name of (already installed) package. DEFAULT: "rdwd"
#' @param user     Github username. repo will then be user/pack. DEFAULT: "brry"
#' @param vignette build_vignettes in [remotes::install_github()]?
#'                 DEFAULT: NA (changed to TRUE if rmarkdown and knitr are available)
#' @param quiet    Suppress version messages and `remotes::install` output?
#'                 DEFAULT: FALSE through [rdwdquiet()]
#' @param \dots    Further arguments passed to [remotes::install_github()]
#' 
updateRdwd <- function(
pack="rdwd",
user="brry",
vignette=NA,
quiet=rdwdquiet(),
...
)
{
# installed date/version:
Vinst <- suppressWarnings(utils::packageDescription(pack)[c("Date","Version")])
repo <- paste0(user,"/",pack)
# date/version in source code
url <- paste0("https://raw.githubusercontent.com/",repo,"/master/DESCRIPTION")
tf <- tempfile("DESCRIPTION")
download.file(url, tf, quiet=TRUE)
Vsrc <- read.dcf(file=tf, fields=c("Date","Version"))
Vsrc <- split(unname(Vsrc),colnames(Vsrc)) # transform matrix to list
output <- data.frame(Version=c(Vinst$Version, Vsrc$Version),
                        Date=c(Vinst$Date,    Vsrc$Date))
rownames(output) <- paste0(pack,"_",c("Locally_installed", "Github_latest"))
if(anyNA(output$Date)) stop("Date field is missing, cannot be compared.")
# install if outdated:
doinst <-  compareVersion(Vsrc$Version, Vinst$Version)==1   |   Vsrc$Date > Vinst$Date
if(!doinst)
{
if(!quiet) message(pack, " is up to date, compared to github.com/",repo,
         ". Version ", Vinst$Version, " (", Vinst$Date,")")
return(invisible(output))
}
if(!quiet) message(pack, " local version ", Vinst$Version, " (", Vinst$Date,
        ") is outdated.\nInstalling development version ",
        Vsrc$Version, " (", Vsrc$Date,") from github.com/",repo)
checkSuggestedPackage("remotes", "updateRdwd")
if(!quiet) message("First unloading ",pack," so it can be installed by remotes::install_github.")
try(detach(paste0("package:",pack), character.only=TRUE, unload=TRUE), silent=TRUE)
# actually install, with vignettes (unlike remotes default)
if(is.na(vignette)) vignette <- requireNamespace("knitr", quietly=TRUE) && requireNamespace("rmarkdown", quietly=TRUE)
remotes::install_github(repo=repo, build_vignettes=vignette, quiet=quiet, ...)
if(!quiet) message("Please re-load ",pack," now.  library(",pack,")  should do.")
return(invisible(output))
}
