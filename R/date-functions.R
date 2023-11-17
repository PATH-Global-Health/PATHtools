#' Convert Ethiopian date to Gregorian date
#'
#' @param cmc An Ethiopian formatted date in Century-Month Code system.
#'
#' @return A date in Gregorian format
#' @export
#'
ethiopian_to_greg <- function(cmc){

  # Minorly adapted from:
  # https://github.com/hesohn/DHSmortality/blob/master/R/ethiopian_to_greg.R
  # Credit to https://github.com/hesohn

  ey = trunc((cmc - 1) / 12) + 1900
  em = cmc - (ey - 1900) * 12
  ed = 1

  joffset = 1723856
  n = 30*(em - 1) + ed - 1 # ed - 1 if actually 0
  jd = joffset + 365 + 365 * (ey - 1) + trunc(ey / 4) + n

  z = jd + 0.5
  w = trunc((z - 1867216.25) / 36524.25)
  x = trunc(w / 4)
  a = z + 1 + w - x
  b = a + 1524
  j = trunc((b - 122.1) / 365.25)
  d = trunc(365.25 * j)
  e = trunc((b - d) / 30.6001)
  f = trunc(30.6001 * e)
  day = b - d - f

  month = e - 1

  month.low  <-(month <= 12) * (e - 1)
  month.high <-(month > 12) * (e - 13)
  month = month.low + month.high

  year.low  <- (month <  3) * (j - 4715)
  year.high <- (month >= 3) * (j - 4716)
  year = year.low + year.high

  outcmc = 12 * (year - 1900) + month
  return(outcmc)
}


#' Convert data into Century-Month Code system
#'
#' @param date A date value
#'
#' @return A date in Century-Month Code format
#' @export
#'
month_to_cmc<- function(date) {
  year  = lubridate::year(date)
  month = lubridate::month(date)
  cmc   = (year  - 1900) * 12 + month
  return(cmc)
}


#' Convert Century-Month Code date to standard format
#'
#' @param cmc A Century-Month Code formated date
#'
#' @return A date in standard format
#' @export
#'
cmc_to_month <- function(cmc) {

  proc_cmc <- data.frame(year =  floor(cmc / 12) + 1900) %>%
    dplyr::mutate( month = cmc - (year - 1900) * 12) %>%
    dplyr::mutate(ym_text = dplyr::case_when(
      month == 0 ~ paste0(year - 1,"-", 12),
      TRUE ~ paste0(year,"-", month)))

  return(lubridate::ym(proc_cmc$ym_text))
}
