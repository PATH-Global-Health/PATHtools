#' Areal rainfall data
#'
#' @param dates A character vector containing the start and end date in "YYYY-MM-DD" format.
#' @param shapefile A sf object containing the areal aggregation polygons.
#' @param output_raster TRUE/FALSE Should output be cropped rasters? Default is FALSE.
#' @param fun A character string containing the aggregation function, default is "sum".
#' @param long TRUE/FALSE Should the output be in "long" format? Default is FALSE.
#' @param verbose TRUE/FALSE Print progress messages?
#' @param pop_weight TRUE/FALSE Should vaulues be weighted based on WorldPop population estimates? Default is FALSE
#'
#' @importFrom dplyr bind_cols contains mutate
#' @importFrom exactextractr exact_extract
#' @importFrom sf st_drop_geometry
#' @importFrom stringr str_remove
#' @importFrom terra rast subst vect crop resample
#' @importFrom tibble as_tibble
#' @importFrom tidyr pivot_longer
#' @importFrom pins board_url pin_read
#'
#' @return A tibble containing extracted values along with any columns from 'shapefile'. If output_raster is TRUE then a SpatRaster object is returned.
#' @export
#'
daily_rainfall <- function(dates, shapefile, output_raster = FALSE, fun = "mean", long = FALSE, verbose = TRUE, pop_weight = FALSE) {
  # Adapted from 'chirps' package
  # https://github.com/ropensci/chirps/blob/master/R/internal_functions.R

  # Convert sf shapefile to SpatVector (faster for terra::crop and extract)
  v <- terra::vect(shapefile)

  # Keep options for future customization
  resolution <- 0.05
  coverage <- "global"
  interval <- "daily"
  format <- "cogs"

  # Create file paths to download based on date sequence
  seqdate <- seq.Date(as.Date(dates[1]), as.Date(dates[2]), by = "day")
  years <- format(seqdate, format = "%Y")
  dates <- gsub("-", "\\.", seqdate)
  fnames <- file.path(years, paste0("chirps-v2.0.", dates, ".cog"))

  resolution <- gsub("p0.", "p", paste0("p", resolution))
  u <- file.path(
    "https://data.chc.ucsb.edu/products/CHIRPS-2.0",
    paste0(coverage, "_", interval),
    format,
    resolution,
    fnames
  )
  u1 <- file.path("/vsicurl", u)

  # Download and crop rasters
  message("Downloading files...")
  r <- terra::rast(u1)

  message("Cropping...")
  r <- terra::crop(r, v, mask = T)

  # Set -9999 to NA
  r <- terra::subst(r, -9999, NA)

  # Rename raster layers
  names(r) <- paste("chirps", seqdate, sep = "_")

  # Return either rasters or areal summaries
  if (output_raster == TRUE) {
    return(r)
  } else {
    # Extract areal values
    message("Extracting areal summaries...")
    # vv <- terra::extract(r, v, fun = fun)[,-1]
    if(pop_weight == TRUE) {
      message("Weighting by population...")
      # Load pop raster from pinned dataset
      b <- pins::board_url("https://PATH-Global-Health.github.io/PATHtools/pins-board/")
      pr <- pins::pin_read(b, "global-pop")
      pr <- terra::resample(terra::crop(terra::rast(pr), v, mask = T), r)

      vv <- exactextractr::exact_extract(r, shapefile,
                                         fun = paste("weighted", fun, sep = "_"),
                                         weights = pr, default_weight = 0, progress = F)

    } else {
      vv <- exactextractr::exact_extract(r, shapefile, fun = fun, progress = F)
      }

    names(vv) <- paste("chirps", seqdate, sep = "_")

    # Join and export
    out <- tibble::as_tibble(dplyr::bind_cols(sf::st_drop_geometry(shapefile), vv))

    # Convert to long
    if (long == TRUE) {
      out <- tidyr::pivot_longer(
        out,
        dplyr::contains("chirps"),
        names_to = "date",
        values_to = "rainfall"
      )
      out <- dplyr::mutate(out, date = as.Date(stringr::str_remove(date, "chirps_")))
    }
    return(out)
  }
}
