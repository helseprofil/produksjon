use_khfunctions <- function(){
  message("Loading KHfunctions\n---\n")
  message("Currentlynot available")
  # source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/R/KHsetup.R")
}

use_orgdata <- function(){
  message("Loading orgdata\n---\n")
  library(orgdata)
}

use_qualcontrol <- function(){
  message("Loading KHvalitetskontroll\n---\n")
  message("Currently not available")
}

is_updates <- function(){
  currentversion <- "2024.09.12"
  localversion <- character()
  if(file.exists("setup/internal_functions.R")){
    localversion <- sub(".*\"(.*)\".*", "\\1", grep("currentversion <-", readLines("setup/internal_functions.R"), value = T)[1])
  }
  currentversion != localversion
}

update_userfiles <- function(){

  choice <- menu(choices = c("Yes", "No"),
                 title = paste0("\nOppdaterte brukerfiler er tilgjengelige!!",
                                "\n\nOppdater (anbefalt)?"))

  if(choice == 1){
    message("\nHenter oppdateringer...")
    invisible(system("git fetch origin main"))
    invisible(system("git reset --hard origin/main"))
    invisible(system("git pull"))
  } else {
    message("\nSkipper oppdateringer, brukerfilene kan være utdaterte.")
  }
}
