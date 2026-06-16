is_updates <- function(lastupdated){
  if(!file.exists("setup/setup.R")) return(TRUE)

  localversion <- sub(".*\"(.*)\".*", "\\1", grep("lastupdated <-", readLines("setup/setup.R"), value = T))
  !identical(lastupdated, localversion)
}

update_userfiles <- function(){
  choice <- 0
  if(interactive()){
    choice <- utils::menu(choices = c("Yes", "No"),
                          title = paste0("\nOppdaterte brukerfiler er tilgjengelige!!",
                                         "\n\nOppdater (anbefalt)?"))
  }

  if(choice == 1){
    message("\nHenter oppdateringer...")
    invisible(system("git fetch origin main"))
    invisible(system("git reset --hard origin/main"))
    invisible(system("git pull"))
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


#' @title look_for_new_versions
#' @description
#' Looks for new versions of norgeo, orgdata, khfunctions, and qualcontrol. If any updates are found, the user get the choice to update or continue.
#' If the user choose to update, instructions regarding what to update is printed.
#' If the user continues, or if there's no updates available, the welcome message is printed.
look_for_new_versions <- function(){
  message("Ser etter nye versjoner av norgeo, orgdata, khfunctions og qualcontrol...\n")
  installedpackages <- names(utils::installed.packages()[, "Package"])
  outmessage <- character()

  for(package in c("norgeo", "orgdata", "khfunctions", "qualcontrol")){
    branch <- ifelse(package %in% c("norgeo", "khfunctions"), "master", "main")
    is_installed <- package %in% installedpackages
    if(is_installed){
      gitdesc <- file.path("https://raw.githubusercontent.com/helseprofil", package, branch, "DESCRIPTION")
      is_newversion <- FALSE
      if(orgdata:::is_online(gitdesc)){
        localversion <- utils::packageDescription(package)[["Version"]]
        gitversion <- data.table::fread(gitdesc, nrows = 4, fill = TRUE)[grepl("Version", V1), V2]
        is_newversion <- numeric_version(gitversion) > numeric_version(localversion)
      }
    }

    installcode <- paste0("remotes::install_github('helseprofil/", package, "@", branch, "')")
    packagemessage <- character()
    if(!is_installed){
      packagemessage <- paste0("\n* ", package, " er ikke installert",
                               "\n** installer med: ", installcode)
    } else if(is_newversion){
      packagemessage <- paste0("\n* ", package, " finnes i ny versjon (", localversion, " --> ", gitversion, ")",
                               "\n** oppdater med: ", installcode)
    }

    outmessage <- paste0(outmessage, packagemessage)
  }

  updatemessage <- paste0("\n\nOBS!! OPPDATERINGER TILGJENGELIG!\n- Kjør kodene under (kanskje du må lukke prosjektet først).\n- Restart Produksjon etter oppdateringene\n ", outmessage)
  if(length(outmessage) > 0) message(updatemessage)
  invisible(NULL)
}

varm_opp_mappesystem <- function(){
  cat("\nVarmer opp mappesystem ved å lese befolkningsfil (bare noen rader)")
  d <- arrow::open_dataset("O:/Prosjekt/FHP/PRODUKSJON/PRODUKTER/FILGRUPPER/NYESTE/BEF_GKny_alder_aar_geo")
  d <- dplyr::filter(d, alder %in% c("18_29") & AARl == 2026 & lks == 0) |> dplyr::collect()
  return(d[1:10])
}
