Sys.setlocale("LC_ALL", "nb-NO.UTF-8")
source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")
options(warn = 1)

lastupdated <- "2025.08.12"
if(interactive()){
  if(is_updates(lastupdated)){
    update_userfiles()
  }

  rm(lastupdated)
  rm(is_updates)

  GEO_VALID <- qualcontrol:::.validgeo
  GEO_RECODE <- qualcontrol:::.georecode
  POPULATION_TABLE <- qualcontrol:::.popinfo
}

source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")

look_for_new_versions()
