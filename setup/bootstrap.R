safe_source <- function(url) {
  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  tryCatch({
    utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
    sys.source(tmp, envir = .GlobalEnv)
    TRUE
  }, error = function(e) {
    message("Kunne ikke laste fra: ", url)
    FALSE
  })
}

ok <- safe_source(
  "https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/setup.R"
)

if(!ok) {
  message("Bruker lokal fallback (offline-modus)")
  if (file.exists("setup/setup.R")) {
    source("setup/setup.R", local = .GlobalEnv)
  } else {
    stop("Fant ikke lokal setup/setup.R i offline-modus")
  }
}

if(ok){
  message("\nProduksjonprosjektet startet og klar til bruk")
}
