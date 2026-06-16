try(Sys.setlocale("LC_ALL", "nb-NO.UTF-8"), silent = T)

safe_source <- function(url) {
  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  tryCatch(
    {
     download.file(url, tmp, quiet = TRUE)
     sys.source(tmp, envir = .GlobalEnv)
     TRUE
    },
    error = function(e) {
      message("Kunne ikke laste: ", url)
      FALSE
    }
  )
}

safe_source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")
options(warn = 1)

lastupdated <- "2026.06.16"
if(interactive()){

  upd <- tryCatch(
    is_updates(lastupdated),
    error = function(e) FALSE
  )

  if (isTRUE(upd)) {

    if (Sys.which("git") == "") {
      message("Git er ikke tilgjengelig – kan ikke oppdatere brukerfiler")
      return(invisible(FALSE))
    }
    update_userfiles()
  }
}

rm(lastupdated)
rm(is_updates)
rm(upd)

if (requireNamespace("qualcontrol", quietly = TRUE)) {
  assign("GEO_VALID", qualcontrol:::.validgeo, envir = .GlobalEnv)
  assign("GEO_RECODE", qualcontrol:::.georecode, envir = .GlobalEnv)
  assign("POPULATION_TABLE", qualcontrol:::.popinfo, envir = .GlobalEnv)
}

safe_source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")

# "OPPVARMING" AV FILMAPPER
# Midlertidig fiks av lese- og skriveproblematikk
d <- arrow::open_dataset("O:/Prosjekt/FHP/PRODUKSJON/PRODUKTER/FILGRUPPER/NYESTE/BEF_GKny_alder_aar_geo")
d <- dplyr::filter(d, alder %in% c("18_29") & AARl == 2026 & lks == 0) |> dplyr::collect()
rm(d)

try(look_for_new_versions(), silent = T)
