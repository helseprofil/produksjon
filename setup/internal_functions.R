#' @title use_khfunctions
#' @description
#' Loads all functions from khfunctions, production-test branch which is not
#' depending on renv.
use_khfunctions <- function(){
  source("https://raw.githubusercontent.com/helseprofil/khfunctions/production-test/R/KHsetup.R")
}

is_updates <- function(lastupdated){
  localversion <- character()
  if(file.exists("setup/setup.R")){
    localversion <- sub(".*\"(.*)\".*", "\\1", grep("lastupdated <-", readLines("setup/setup.R"), value = T))
  }
  lastupdated != localversion
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

#' @title update_packages
#' @description Updates packages from cran and GitHub
update_packages <- function(){
  source("https://raw.githubusercontent.com/helseprofil/misc/main/ProfileSystems.R")
  ProfileSystems(all = F, packages = T, norgeo = T, orgdata = T, qualcontrol = T)
  rm(ProfileSystems, DevelopSystems, check_R_version, envir = .GlobalEnv)
}
