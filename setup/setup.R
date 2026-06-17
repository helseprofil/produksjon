try(Sys.setlocale("LC_ALL", "nb-NO.UTF-8"), silent = T)

if (!exists("safe_source", mode = "function")) {
  safe_source <- function(url) {
    tmp <- tempfile(fileext = ".R")
    on.exit(unlink(tmp), add = TRUE)

    tryCatch({
      utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
      sys.source(tmp, envir = .GlobalEnv)
      TRUE
    }, error = function(e) {
      message("Kunne ikke laste: ", url)
      FALSE
    })
  }
}

safe_source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")
options(warn = 1)
options(scipen = 999)

if(interactive()){

  local_version <- tryCatch({
    if (!file.exists("setup/version.txt")) return(NA_character_)
    readLines("setup/version.txt", warn = FALSE)[1L]
  }, error = function(e) NA_character_)


  upd <- tryCatch(
    is_updates(local_version),
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

if (exists("upd")) rm(upd)

# "OPPVARMING" AV FILMAPPER
# Midlertidig fiks av lese- og skriveproblematikk
if (interactive()) {
  try(varm_opp_mappesystem(), silent = TRUE)
}

safe_source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")

try(look_for_new_versions(), silent = T)
