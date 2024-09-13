use_khfunctions <- function(){
  message("Loading KHfunctions\n---\n")
  message("Currently not available")
  # source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/R/KHsetup.R")
}

is_updates <- function(){
  currentversion <- "2024.09.12" # Update this whenever updating user files
  localversion <- character()
  if(file.exists("setup/internal_functions.R")){
    localversion <- sub(".*\"(.*)\".*", "\\1", grep("currentversion <-", readLines("setup/internal_functions.R"), value = T)[1])
  }
  currentversion != localversion
}

update_userfiles <- function(){

  choice <- utils::menu(choices = c("Yes", "No"),
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
