start_produksjon <- function() {
  if (!interactive()) return()

  res <- try({
    tmp <- tempfile(fileext = ".R")
    download.file(
      "https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/setup.R",
      tmp,
      quiet = TRUE
    )
    sys.source(tmp, envir = .GlobalEnv)
    unlink(tmp)
  }, silent = TRUE)

  if("try-error" %in% class(res)){
    warning("Prosjektet har ikke startet skikkelig, kjør `start_produksjon()` i konsollen")
  }
}

if (interactive() &&
    nzchar(Sys.getenv("RSTUDIO")) &&
    requireNamespace("later", quietly = TRUE)) {

  later::later(start_produksjon, delay = 0)
}
