#' @title use_khfunctions
#' @description
#' Loads all functions from khfunctions from the specified branch
use_khfunctions <- function(branch = "arkiv-pre-package"){
  if(branch == "master"){
    cat('OBS: Master branch er ikke lenger tilgjengelig, da denne er under ombygging til en R-pakke.\nSkifter til siste versjon før ombygging (branch = "arkiv-pre-package").')
    branch <- "arkiv-pre-package"
  }
  source(paste0("https://raw.githubusercontent.com/helseprofil/khfunctions/", branch, "/R/KHsetup.R"))
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
update_packages <- function(cran = TRUE, internal = TRUE){
  source("https://raw.githubusercontent.com/helseprofil/backend/main/misc/R/install.R")
  if(cran) ProfileSystems(all = F, packages = T)
  if(internal) ProfileSystems(all = F, norgeo = T, orgdata = T, khfunctons = T, qualcontrol = T)
  rm(ProfileSystems, DevelopSystems, check_R_version, envir = .GlobalEnv)
}

update_kh_packages_if_new_version <- function(){
  message("Ser etter nye versjoner av norgeo, orgdata, khfunctions og qualcontrol...")
  installedpackages <- names(utils::installed.packages()[, "Package"])

  for(package in c("norgeo", "orgdata", "khfunctions", "qualcontrol")){
    branch <- ifelse(package %in% c("norgeo", "khfunctions"), "master", "main")
    newversion <- FALSE
    gitdesc <- file.path("https://raw.githubusercontent.com/helseprofil", package, branch, "DESCRIPTION")
    is_online <- orgdata:::is_online(gitdesc)

    if(is_online){
      if(package %in% installedpackages){
        localversion <- utils::packageDescription(package)[["Version"]]
        gitversion <- data.table::fread(gitdesc, nrows = 4, fill = TRUE)[grepl("Version", V1), V2]
        newversion <- numeric_version(gitversion) > numeric_version(localversion)
      } else {
        message("Pakken ", package, " ikke installert. Installerer nå")
        remotes::install_github(paste0("helseprofil/", package, "@", branch))
      }
    }

    if(newversion){
      update <- utils::menu(title = paste0("Ny versjon av ", package, " tilgjengelig, vil du oppdatere nå?"),
                            choices = c("Ja", "Nei"))
      if(update){
        message("Oppdaterer ", package, " fra versjon ", localversion," ---> ", gitversion,
                "\nFølg instruksjonene i konsoll")
        remotes::install_github(paste0("helseprofil/", package, "@", branch))
      }
    }
  }
}
