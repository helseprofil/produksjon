start_produksjon <- function() {

  bootstrap_local <- "setup/bootstrap.R"
  bootstrap_url <- "https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/bootstrap.R"

  if (file.exists(bootstrap_local)) {
    source(bootstrap_local, local = .GlobalEnv)
    return(invisible(TRUE))
  }

  stop(
    "Fant ikke setup/bootstrap.R.\n\n",
    "Kjør dette manuelt i konsollen:\n\n",
    "source('", bootstrap_url, "')\n\n",
    "Deretter kan du kjøre start_produksjon() igjen."
  )
}
