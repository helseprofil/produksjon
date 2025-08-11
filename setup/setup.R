Sys.setlocale("LC_ALL", "nb-NO.UTF-8")
source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")

lastupdated <- "2025.08.11"
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

updates <- look_for_new_versions()

source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")
if(!is.null(updates)) warning(updates)
