aggreger_forsvaret <- function(path_raw, aargang, gk = TRUE){

  type <- tools::file_ext(path_raw)
  if(type == "csv"){
    file <- data.table::fread(path_raw)
  } else if (type == "xlsx"){
    file <- data.table::setDT(readxl::read_xlsx(path_raw))
  }

  if(isFALSE(gk)) file[, GK := 9999]

  kjonn <- intersect(names(file), c("Kjønn"))
  alder <- intersect(names(file), c("Alder", "ALDER"))
  hoyde <- intersect(names(file), c("Høyde", "kjønn"))
  vekt <- intersect(names(file), c("Vekt", "kjønn"))
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
  file[, names(.SD) := lapply(.SD, as.character), .SDcols = c("GK", "KOMM")]
  file[is.na(GK), GK := "9999"]
  file[nchar(GK) == 3, GK := paste0("0", GK)]
  file[is.na(KOMM), GK := "9999"]
  file[nchar(KOMM) == 3, KOMM := paste0("0", KOMM)]
  file[, GEO := paste0(KOMM, GK)]
  # AAR
  file[, AAR := aargang]
  # KJONN
  file[KJONN %in% c("M", "Mann"), KJONN := 1]
  file[KJONN %in% c("K", "Kvinne"), KJONN := 2]
  # BMIcat
  file[, names(.SD) := lapply(.SD, as.numeric), .SDcols = c("VEKT", "HOYDE")]
  file[, BMI := as.numeric(VEKT) / ((as.numeric(HOYDE)/100)^2)]
  # REF BMI-kategorier, bruker cutoff for 17.5 år
  # https://www.helsedirektoratet.no/retningslinjer/helsestasjons-og-skolehelsetjenesten/_/attachment/inline/a6ab0dc1-274e-48c7-afac-a9fd8ead469a:5806c06e9e09748618d08dd16532cbcc4617fb34/IS-1736-isoKMI-%20tabell-over-og-undervekt.pdf
  file[, BMIcat := NA_character_]
  file[, BMIcat := data.table::fcase(((KJONN == 1 & BMI >= 29.71) | (KJONN == 2 & BMI >= 29.85)), "fedme",
                                     ((KJONN == 1 & BMI >= 24.73) | (KJONN == 2 & BMI >= 24.85)), "overvekt",
                                     ((KJONN == 1 & BMI <= 18.28) | (KJONN == 2 & BMI <= 18.38)), "undervekt",
                                     default = "normalvekt")]
  # SVOMMING
  file[, SVOMMING := data.table::fcase(SVOMMING %in% c("Ja"), 1L, default = 0L)]
  # TRENING
  file[, TRENING := data.table::fcase(TRENING %in% c("Sjeldnere enn 1 gang i uka"), 0L, default = 1L)]

  # SLUTTFILTER
  dims <- c("GEO", "AAR", "KJONN", "ALDER")
  file <- file[, .SD, .SDcols = c(dims, "SVOMMING", "TRENING", "BMIcat")]
  data.table::set(file, j = "ANTALL", value = 1L)

  aggreger_forsvaret_svomming(dt = file, aar = aargang, dims = dims)
  aggreger_forsvaret_trening(dt = file, aar = aargang, dims = dims)
  aggreger_forsvaret_overvekt(dt = file, aar = aargang, dims = dims)
}




aggreger_forsvaret_svomming <- function(dt, aar, dims){
  dt <- dt[, .SD, .SDcols = c(dims, "SVOMMING", "ANTALL")]
  cols <- c(dims, "SVOMMING")
  rect <- do.call(data.table::CJ, c(dt[, ..cols], unique = TRUE))
  out <- collapse::join(rect, dt, on = cols, multiple = T, verbose = 0, overid = 2)
  out[is.na(ANTALL), ANTALL := 0L]
  out <- out[, .(ANTALL = sum(ANTALL)), by = cols]
  out[, NEVNER := sum(ANTALL), by = dims]

  dir_out <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/RAADATA/AGGREGERT/SVOMMING"
  file_out <- file.path(dir_out, paste0("FORSVARET_SVOMMING_", aar, ".csv"))
  data.table::fwrite(dt, file_out, sep = ";")
}

aggreger_forsvaret_trening <- function(dt, aar, dims){
  dt <- dt[, .SD, .SDcols = c(dims, "TRENING", "ANTALL")]
  cols <- c(dims, "TRENING")
  rect <- do.call(data.table::CJ, c(dt[, ..cols], unique = TRUE))
  out <- collapse::join(rect, dt, on = cols, multiple = T, verbose = 0, overid = 2)
  out[is.na(ANTALL), ANTALL := 0L]
  out <- out[, .(ANTALL = sum(ANTALL)), by = cols]
  out[, NEVNER := sum(ANTALL), by = dims]

  dir_out <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/RAADATA/AGGREGERT/TRENING"
  file_out <- file.path(dir_out, paste0("FORSVARET_TRENING_", aar, ".csv"))
  data.table::fwrite(dt, file_out, sep = ";")
}

aggreger_forsvaret_overvekt <- function(dt, aar, dims){
  dt <- dt[, .SD, .SDcols = c(dims, "BMIcat", "ANTALL")]
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

  dir_out <- "O:/Prosjekt/FHP/PRODUKSJON/ORGDATA/FORSVARET/RAADATA/AGGREGERT/OVERVEKT"
  file_out <- file.path(dir_out, paste0("FORSVARET_OVERVEKT_", aar, ".csv"))
  data.table::fwrite(dt, file_out, sep = ";")
}
