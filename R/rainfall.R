#' Areal rainfall data
#'
#' @param dates A character vector containing the start and end date in "YYYY-MM-DD" format.
#' @param shapefile A sf object containing the areal aggregation polygons
#' @param fun A character string containing the aggregation function, default is "sum".
#' @param long TRUE/FALSE Should the output be in "long" format? Default is FALSE.
#' @param verbose TRUE/FALSE Print progres messages?
#'
#' @importFrom dplyr bind_cols contains mutate
#' @importFrom exactextractr exact_extract
#' @importFrom sf st_drop_geometry
#' @importFrom stringr str_remove
#' @importFrom terra rast subst
#' @importFrom tibble as_tibble
#' @importFrom tidyr pivot_longer
#'
#' @return A tibble containing extracted values along with any columns from 'shapefile'.
#' @export
#'
#'
daily_rainfall <- function(dates, shapefile, fun = "sum", long = F, verbose = T) {

  # Adapted from 'chirps' package
  # https://github.com/ropensci/chirps/blob/master/R/internal_functions.R

  # Convert sf shapefile to SpatVector (faster for terra::crop and extract)
  # v <- vect(shapefile)

  # Keep options for future customization
  resolution = 0.05
  coverage = "global"
  interval = "daily"
  format = "cogs"

  # Create file paths to download based on date sequence
  seqdate <- seq.Date(as.Date(dates[1]), as.Date(dates[2]), by = "day")
  years <- format(seqdate, format = "%Y")
  dates <- gsub("-","\\.",seqdate)
  fnames <- file.path(years, paste0("chirps-v2.0.", dates, ".cog"))

  resolution <- gsub("p0.", "p", paste0("p", resolution))
  u <- file.path("https://data.chc.ucsb.edu/products/CHIRPS-2.0",
                 paste0(coverage, "_", interval), format, resolution, fnames)
  u1 <- file.path("/vsicurl", u)

  # Download and crop rasters
  message("Downloading files...")
  r <- terra::rast(u1)

  # Set -9999 to NA
  r <- terra::subst(r, -9999, NA)

  # message("Cropping...")
  # r <- terra::crop(r, v, mask = T)

  # Rename raster layers
  names(r) <- paste("chirps", seqdate, sep = "_")

  # Extract areal values
  message("Extracting areal summaries...")
  # vv <- terra::extract(r, v, fun = fun)[,-1]

  vv <- exactextractr::exact_extract(r, shapefile, fun = fun, progress = F)
  names(vv) <- paste("chirps", seqdate, sep = "_")

  # Join and export
  out <- tibble::as_tibble(dplyr::bind_cols(sf::st_drop_geometry(shapefile), vv))

  # Convert to long
  if(long == TRUE) {
    out <- tidyr::pivot_longer(out, dplyr::contains("chirps"),
                          names_to = "date",
                          values_to = "rainfall")
    out <- dplyr::mutate(out, date = as.Date(stringr::str_remove(date, "chirps_")))
  }

  return(out)
}
