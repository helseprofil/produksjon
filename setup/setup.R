Sys.setlocale("LC_ALL", "nb-NO.UTF-8")
source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/internal_functions.R")

if(is_updates()){
  update_userfiles()
}

source("https://raw.githubusercontent.com/helseprofil/produksjon/main/setup/welcome.R")
