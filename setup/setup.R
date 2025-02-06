Sys.setlocale("LC_ALL", "nb-NO.UTF-8")
source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")

lastupdated <- "2025.01.30b"
if(is_updates(lastupdated)){
  update_userfiles()
}

rm(lastupdated)
rm(is_updates)

DIMENSIONS_ALL <- qualcontrol:::.validdims
DIMENSIONS_STANDARD <- qualcontrol:::.standarddimensions
VALUES_STANDARD <- qualcontrol:::.standardvalues
GEO_VALID <- qualcontrol:::.validgeo
GEO_RECODE <- qualcontrol:::.georecode
POPULATION_TABLE <- qualcontrol:::.popinfo

source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")
