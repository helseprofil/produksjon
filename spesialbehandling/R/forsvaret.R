# Koder for å lage filene:
# aggreger_forsvaret_gk(path_raw = "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/forsvaret_2021_grunnkrets.csv", aar = 2021)
# aggreger_forsvaret_gk(path_raw = "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/forsvaret_2022_grunnkrets.csv", aar = 2022)
# aggreger_forsvaret_gk(path_raw = "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/2026-03-12 leveranse FHI for 2006 kull_2023.xlsx", aar = 2023)
# aggreger_forsvaret_gk(path_raw = "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/forsvaret_2024_grunnkrets.csv", aar = 2024)
# aggreger_forsvaret_gk(path_raw = "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/FHI leveranse 2026_2025.xlsx", aar = 2025)
# aggreger_forsvaret_eldre()

# Til utvikling, path til råfiler
# 2021 path_raw <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/forsvaret_2021_grunnkrets.csv"
# 2022 path_raw <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/forsvaret_2022_grunnkrets.csv"
# 2023 path_raw <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/2026-03-12 leveranse FHI for 2006 kull_2023.xlsx"
# 2024 path_raw <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/forsvaret_2024_grunnkrets.csv"
# 2025 path_raw <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/PRE_RAADATA/ORG_RAADATA/FHI leveranse 2026_2025.xlsx"

aggreger_forsvaret_gk <- function(path_raw, aargang){

  type <- tools::file_ext(path_raw)
  if(type == "csv"){
    file <- data.table::fread(path_raw)
  } else if (type == "xlsx"){
    file <- data.table::setDT(readxl::read_xlsx(path_raw))
  }

  kjonn <- intersect(names(file), c("Kjønn"))
  alder <- intersect(names(file), c("Alder", "ALDER"))
  hoyde <- intersect(names(file), c("Høyde"))
  vekt <- intersect(names(file), c("Vekt"))
  svomming <- intersect(names(file), c("Kan svømme 200m"))
  trening <- intersect(names(file), c("Treningshyppighet"))
  kommune <- intersect(names(file), c("Kommune nummer", "Kommunenr", "Kommune nummmer"))
  gk <- intersect(names(file), c("Grunnkrets", "GK"))

  varcheck <- sapply(c(kjonn, alder, hoyde, vekt, svomming, trening, kommune, gk), length)
  if(any(varcheck != 1)){
    varcheck
    stop("Nødvendig kolonne ikke korrekt identifisert")
  }

  # Kolonnenavn og fjerne rader med spørsmål
  data.table::setnames(file,
                       old = c(kjonn, alder, hoyde, vekt, svomming, trening, gk, kommune),
                       new = c("KJONN", "ALDER", "HOYDE", "VEKT", "SVOMMING", "TRENING", "GK", "KOMM"), skip_absent = TRUE)
  file <- file[ALDER == 17 & SVOMMING != "12. Kan du svømme 200 meter?" & TRENING != "7. Hvor ofte trener du?"]

  # GEO
  add_geo(dt = file)
  # AAR
  file[, AAR := aargang]
  # KJONN
  file[KJONN %in% c("M", "Mann"), KJONN := 1]
  file[KJONN %in% c("K", "Kvinne"), KJONN := 2]
  # BMIcat
  add_bmicat(dt = file)

  # SVOMMING
  file[, SVOMMING := data.table::fcase(SVOMMING %in% c("Ja"), "ja", default = "nei")]
  # TRENING
  file[, TRENING := data.table::fcase(TRENING %in% c("Sjeldnere enn 1 gang i uka"), "ja", default = "nei")]

  # SLUTTFILTER
  dims <- c("GEO", "AAR", "KJONN", "ALDER")
  file <- file[, .SD, .SDcols = c(dims, "SVOMMING", "TRENING", "BMIcat")]
  data.table::set(file, j = "ANTALL", value = 1L)

  aggreger_forsvaret_svomming(dt = file, aar = aargang, dims = dims)
  aggreger_forsvaret_trening(dt = file, aar = aargang, dims = dims)
  aggreger_forsvaret_overvekt(dt = file, aar = aargang, dims = dims)
}

aggreger_forsvaret_eldre <- function(){
  data <- list()
  data[["1"]] <- data.table::setDT(readxl::read_xls("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2016/2015-08-11 Sesjonsdata_2014.xls"))  # (overvekt)
  data[["2"]] <- data.table::setDT(readxl::read_xlsx("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2015/hoyde_vekt.xlsx")) # (overvekt)
  data[["3"]] <- data.table::setDT(readxl::read_xlsx("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2017/2016-06-30 Sesjonsdata.xlsx")) # (overvekt)
  data[["4"]] <- data.table::setDT(readxl::read_xls("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2018/2017-04-27 Sesjonsdata.xls")) # (overvekt)
  data[["5"]] <- data.table::setDT(readxl::read_xlsx("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2019/2018-04-13 Sesjonsdata 2017.xlsx")) # (overvekt)
  data[["6"]] <- data.table::setDT(readxl::read_xlsx("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2020/EE2017 til EE2018.xlsx")) # 2645 ((overvekt, trening, svømming))
  data[["7"]] <- data.table::setDT(readxl::read_xlsx("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2021/EE2019.xlsx")) # 2812 (overvekt, trening, svømming)
  data[["8"]] <- data.table::setDT(readxl::read_xlsx("O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/ORG/2022/EE2020.xlsx")) # 3386 (overvekt, trening, svømming)

  data[["7"]][, AAR := "2019"]
  data[["8"]][, AAR := "2020"]
  for(d in 1:5){
    data[[d]][, let(SVOMMING = NA_character_, TRENING = NA_character_)]
  }
  data[[5]][, let(Svarår = NULL, AAR = "2017")]

  for(i in seq_along(data)){
    kjonn <- intersect(names(data[[i]]), c("Kjønn"))
    alder <- intersect(names(data[[i]]), c("Alder ved svardato", "Alder"))
    hoyde <- intersect(names(data[[i]]), c("Høyde"))
    vekt <- intersect(names(data[[i]]), c("Vekt"))
    svomming <- intersect(names(data[[i]]), c("Svømmeferdighet", "SVOMMING"))
    trening <- intersect(names(data[[i]]), c("Hyppighet av trening", "TRENING"))
    kommune <- intersect(names(data[[i]]), c("Bostedskommunenr", "Bostedskommune", "Kommune"))
    aar <- intersect(names(data[[i]]), c("Svarår", "Besvart år", "TESK_KODE", "AAR"))

    data.table::setnames(data[[i]],
                         old = c(aar, kjonn, alder, hoyde, vekt, svomming, trening, kommune),
                         new = c("AAR", "KJONN", "ALDER", "HOYDE", "VEKT", "SVOMMING", "TRENING", "KOMM"), skip_absent = TRUE)
    data[[i]] <- data[[i]][ALDER == 17]
    if(any(grepl("^EE", data[[i]]$AAR))) data[[i]][grepl("^EE", AAR), AAR := sub("EE(\\d{4})", "\\1", AAR)]

    # GEO
    data[[i]][, GK := NA_character_]
    add_geo(dt = data[[i]])
    # KJONN
    data[[i]][KJONN %in% c("M", "Mann"), KJONN := 1]
    data[[i]][KJONN %in% c("K", "Kvinne"), KJONN := 2]
    # BMIcat
    add_bmicat(dt = data[[i]])

    # SVOMMING
    data[[i]][!is.na(SVOMMING), SVOMMING := data.table::fcase(SVOMMING %in% c("Ja", "Kan svømme 200m"), "ja", default = "nei")]
    # TRENING
    data[[i]][!is.na(TRENING), TRENING := data.table::fcase(TRENING %in% c("Sjeldnere enn 1 gang i uka"), "ja", default = "nei")]

    # SLUTTFILTER
    dims <- c("GEO", "AAR", "KJONN", "ALDER")
    data[[i]] <- data[[i]][, .SD, .SDcols = c(dims, "SVOMMING", "TRENING", "BMIcat")]
    data.table::set(data[[i]], j = "ANTALL", value = 1L)
  }

  dt <- data.table::rbindlist(data, use.names = T, fill = T)

  dims <- c("GEO", "AAR", "KJONN", "ALDER")
  aggreger_forsvaret_svomming(dt = dt, aar = "2017_til_2020", dims = dims)
  aggreger_forsvaret_trening(dt = dt, aar = "2017_til_2020", dims = dims)
  aggreger_forsvaret_overvekt(dt = dt, aar = "2010_til_2020", dims = dims)
}

add_geo <- function(dt){
  dt[, names(.SD) := lapply(.SD, as.character), .SDcols = c("GK", "KOMM")]
  dt[is.na(GK), GK := "9999"]
  dt[nchar(GK) == 3, GK := paste0("0", GK)]
  dt[is.na(KOMM), GK := "9999"]
  dt[nchar(KOMM) == 3, KOMM := paste0("0", KOMM)]
  dt[, GEO := paste0(KOMM, GK)]
  dt[, let(KOMM = NULL, GK = NULL)]
}

add_bmicat <- function(dt){
  # REF BMI-kategorier, bruker cutoff for 17.5 år
  # https://www.helsedirektoratet.no/retningslinjer/helsestasjons-og-skolehelsetjenesten/_/attachment/inline/a6ab0dc1-274e-48c7-afac-a9fd8ead469a:5806c06e9e09748618d08dd16532cbcc4617fb34/IS-1736-isoKMI-%20tabell-over-og-undervekt.pdf

  # Setter HØYDE/VEKT = missing dersom HØYDE < 140 eller > 215 og VEKT < 40 eller > 150, dette er mest trolig feilregistrert
  dt[, names(.SD) := lapply(.SD, as.numeric), .SDcols = c("VEKT", "HOYDE")]
  dt[(HOYDE < 140 | HOYDE > 215) | (VEKT < 40 | VEKT > 150), let(HOYDE = NA_real_, VEKT = NA_real_)]

  dt[, BMI := VEKT / ((HOYDE/100)^2)]
  dt[, BMIcat := NA_character_]
  dt[, BMIcat := data.table::fcase(((KJONN == 1 & BMI >= 29.71) | (KJONN == 2 & BMI >= 29.85)), "fedme",
                                     ((KJONN == 1 & BMI >= 24.73) | (KJONN == 2 & BMI >= 24.85)), "overvekt",
                                     ((KJONN == 1 & BMI <= 18.28) | (KJONN == 2 & BMI <= 18.38)), "undervekt",
                                     is.na(BMI), NA_character_,
                                     default = "normalvekt")]
}

aggreger_forsvaret_svomming <- function(dt, aar, dims){
  dt <- dt[, .SD, .SDcols = c(dims, "SVOMMING", "ANTALL")][!is.na(SVOMMING)]
  cols <- c(dims, "SVOMMING")
  rect <- do.call(data.table::CJ, c(dt[, ..cols], unique = TRUE))
  out <- collapse::join(rect, dt, on = cols, multiple = T, verbose = 0, overid = 2)
  out[is.na(ANTALL), ANTALL := 0L]
  out <- out[, .(ANTALL = sum(ANTALL)), by = cols]
  out[, NEVNER := sum(ANTALL), by = dims]

  dir_out <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/RAADATA/SVOMMING"
  file_out <- file.path(dir_out, paste0("FORSVARET_SVOMMING_", aar, ".csv"))
  data.table::fwrite(out, file_out, sep = ";")
}

aggreger_forsvaret_trening <- function(dt, aar, dims){
  dt <- dt[, .SD, .SDcols = c(dims, "TRENING", "ANTALL")][!is.na(TRENING)]
  cols <- c(dims, "TRENING")
  rect <- do.call(data.table::CJ, c(dt[, ..cols], unique = TRUE))
  out <- collapse::join(rect, dt, on = cols, multiple = T, verbose = 0, overid = 2)
  out[is.na(ANTALL), ANTALL := 0L]
  out <- out[, .(ANTALL = sum(ANTALL)), by = cols]
  out[, NEVNER := sum(ANTALL), by = dims]

  dir_out <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/RAADATA/TRENING"
  file_out <- file.path(dir_out, paste0("FORSVARET_TRENING_", aar, ".csv"))
  data.table::fwrite(out, file_out, sep = ";")
}

aggreger_forsvaret_overvekt <- function(dt, aar, dims){
  dt <- dt[, .SD, .SDcols = c(dims, "BMIcat", "ANTALL")][!is.na(BMIcat)]
  cols <- c(dims, "BMIcat")
  rect <- do.call(data.table::CJ, c(dt[, ..cols], unique = TRUE))
  out <- collapse::join(rect, dt, on = cols, multiple = T, verbose = 0, overid = 2)
  out[is.na(ANTALL), ANTALL := 0L]
  out <- out[, .(ANTALL = sum(ANTALL)), by = cols]
  out[, NEVNER := sum(ANTALL), by = dims]

  overvektfedme <- data.table::copy(out[BMIcat %in% c("overvekt", "fedme")])[, .(ANTALL = sum(ANTALL)), by = c(dims, "NEVNER")]
  overvektfedme[, BMIcat := "overvektogfedme"]
  ikkeovervekt <- data.table::copy(out[BMIcat %in% c("undervekt", "normalvekt")])[, .(ANTALL = sum(ANTALL)), by = c(dims, "NEVNER")]
  ikkeovervekt[, BMIcat := "ikkeovervekt"]
  out <- data.table::rbindlist(list(out, overvektfedme, ikkeovervekt), use.names = T)

  dir_out <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/RAADATA/OVERVEKT"
  file_out <- file.path(dir_out, paste0("FORSVARET_OVERVEKT_", aar, ".csv"))
  data.table::fwrite(out, file_out, sep = ";")
}





