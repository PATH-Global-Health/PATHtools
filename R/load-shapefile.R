#' Functions for loading and downloading shapefiles from
#' https://github.com/PATH-Global-Health/geometries
#'
#' Load and download shapefile
#' @param country Name of country
#' @param admin_level Numeric value either 0, 1, or 2.
#' @param quiet sf parameter to choose if shapefile info is printed
#' @param download TRUE/FALSE should the GeoJSON be downloaded?
#' @param destfile Path to output directory
#'
#' @return A sf-object
#' @export
#'
#' @importFrom sf st_read
#' @importFrom glue glue
#' @importFrom httr GET content
#' @importFrom stringi stri_subset stri_extract_first_regex
#' @importFrom stringr str_remove_all
#' @importFrom utils download.file
#'

load_shapefile <- function(country, admin_level = c(0,1,2), quiet = T,
                           download = F, destfile = ".") {
  # Convert admin to numeric
  admin_level <- as.numeric(admin_level)

  # Get url components
  rawgh <- "https://raw.githubusercontent.com/"
  repo <- "PATH-Global-Health/geometries/main/"
  adm <- glue::glue("adm{admin_level}")
  address <- glue::glue("{rawgh}{repo}{adm}/{country}/{adm}.json")

  # Check if file exist
  req <- httr::GET("https://api.github.com/repos/PATH-Global-Health/geometries/git/trees/main?recursive=1")
  filelist <- unlist(lapply(httr::content(req)$tree, "[", "path"), use.names = F)

  available <- filelist |>
    stringi::stri_subset(regex = glue::glue("^{adm}.*.json$")) |>
    stringr::str_remove_all(glue::glue("{adm}")) |>
    stringr::str_remove_all(glue::glue("/")) |>
    stringr::str_remove_all(glue::glue(".json"))

  if(!country %in% available) stop(glue::glue("{country} not availible for Admin {admin_level}, use available_shapefile(admin_level = {admin_level}) to see available countries."))

  # Load GeoJSON as sf object
  out <- sf::st_read(address, quiet = quiet)

  # Download if requested
  if(download) download.file(address, destfile)

  return(out)
}

#' Check if shapefile is available
#'
#' @param country Name of country
#' @param admin_level Numeric value either 0, 1, or 2.
#'
#' @return Printed message in console
#' @export
#'
#' @importFrom glue glue
#' @importFrom httr GET content
#' @importFrom stringi stri_subset stri_extract_first_regex
#' @importFrom stringr str_remove_all
#'
available_shapefile <- function(country = NA, admin_level = NA) {

  # Neither option supplied
  if(is.na(country) & is.na(admin_level)) stop("Please supply country or Admin level.")

  # Wrong admin_level suppled
  admin_level <- as.numeric(admin_level)
  adm <- glue::glue("adm{admin_level}")

  if(!is.na(admin_level) & length(admin_level) > 0){
    if(!admin_level %in% 0:2) stop("Admin level must be 0, 1, or 2")
  }

  # Multiple inputs
  if(length(admin_level) > 1 | length(country) > 1) stop("Only use one input.")

  # Get repo files
  req <- httr::GET("https://api.github.com/repos/PATH-Global-Health/geometries/git/trees/main?recursive=1")
  filelist <- unlist(lapply(httr::content(req)$tree, "[", "path"), use.names = F)

  # Country supplied
  if(!is.na(country) & is.na(admin_level)) {
    available <- filelist |>
      stringi::stri_subset(regex = glue::glue("{country}.*.json$")) |>
      stringi::stri_extract_first_regex(pattern = "\\d") |>
      as.numeric()

    message(glue::glue("Available admin levels for {country}: "),
            paste(available, collapse=" "))
  }

  # Admin level supplied
  if(is.na(country) & !is.na(admin_level)) {
    available <- filelist |>
      stringi::stri_subset(regex = glue::glue("^{adm}.*.json$")) |>
      stringr::str_remove_all(glue::glue("{adm}")) |>
      stringr::str_remove_all(glue::glue("/")) |>
      stringr::str_remove_all(glue::glue(".json"))

    message(glue::glue("Available countries for Admin {admin_level}:"))
    message(paste(available, collapse = "\n"))
  }

  # Both supplied
  if(!is.na(country) & !is.na(admin_level)) {
    available <- filelist |>
      stringi::stri_subset(regex = glue::glue("^{adm}.*{country}.*.json$"))

    m <- glue::glue("Admin {admin_level} {country} avaliable? ")
    if(length(available) == 1) message(m, "Yes!") else message(m, "No")
  }
}
