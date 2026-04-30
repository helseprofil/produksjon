try(Sys.setlocale("LC_ALL", "nb-NO.UTF-8"), silent = T)


safe_source <- function(url) {
  tryCatch(
    source(url),
    error = function(e) {
      message("Kunne ikke laste: ", url)
      invisible(FALSE)
    }
  )
}

safe_source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")
options(warn = 1)

lastupdated <- "2026.04.30"
if(interactive()){

  upd <- tryCatch(
    is_updates(lastupdated),
    error = function(e) FALSE
  )

  if (isTRUE(upd)) {
    update_userfiles()
  }
}

rm(lastupdated)
rm(is_updates)
rm(upd)

if (requireNamespace("qualcontrol", quietly = TRUE)) {
  GEO_VALID <- qualcontrol:::.validgeo
  GEO_RECODE <- qualcontrol:::.georecode
  POPULATION_TABLE <- qualcontrol:::.popinfo
}

safe_source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")

try(look_for_new_versions(), silent = T)
