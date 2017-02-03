# rdwd
`rdwd` is an [R](https://www.r-project.org/) package to select, download and read climate data from the 
German Weather Service (Deutscher Wetterdienst, DWD).
They provide over 25 thousand datasets with weather observations online at 
<ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate>.

Usage of the package will usually look something like the following:

```R

# download and install the rdwd package (only needed once):
install.packages("rdwd")

# load the package into library (needed in every R session):
library(rdwd)

# view package documentation:
?rdwd

# select a dataset (e.g. last year's daily climate data from Potsdam City):
link <- selectDWD("Potsdam", res="daily", var="kl", per="recent")

# Actually download that dataset, returning the local storage file name:
file <- dataDWD(link, read=FALSE)

# Read the file from the zip folder:
clim <- readDWD(file)

# Inspect the data.frame:
str(clim)
```

You can also select datasets with the [interactive map](https://cran.r-project.org/package=rdwd/vignettes/mapDWD.html).
Further instructions and examples are available in the [package vignette](https://cran.r-project.org/package=rdwd/vignettes/rdwd.html).

```R
vignette("mapDWD") # interactive map, likely faster than CRAN link above
vignette("rdwd")   # package instructions and examples
```

A real-life usage example of the package can be found at
https://github.com/brry/prectemp/blob/master/Code_analysis.R

