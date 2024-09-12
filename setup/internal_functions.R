use_khfunctions <- function(){
  message("Loading KHfunctions\n---\n")
  source("https://raw.githubusercontent.com/helseprofil/khfunctions/master/R/KHsetup.R")
}

use_orgdata <- function(){
  message("Loading orgdata\n---\n")
  library(orgdata)
}

use_qualcontrol <- function(){
  message("Loading KHvalitetskontroll\n---\n")
  message("Currently not available")
}
