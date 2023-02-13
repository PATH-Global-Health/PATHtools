library("usethis")
library("here")
library("pins")
library(terra)

# Create pins board in pgkdown site
board <- board_folder(here("pkgdown/assets/pins-board"), versioned = FALSE)
# board <- board_url("https://path-global-health.github.io/PATHtools/pins-board/")

# Making Cloud Optimizied GeoTIFF
# gdalUtilities::gdal_translate(src_dataset = in.tif,
#                               dst_dataset = out.tif,
#                               co = matrix(c("TILED=YES",
#                                             "COPY_SRC_OVERVIEWS=YES",
#                                             "COMPRESS=DEFLATE"),
#                                           ncol = 1))


# WorldPop 2021 Global Raster (COG version) -------------
# r <- rast("C:/Users/jmillar/Box/Africa Data and Analytics for community case Management/ccm-africa/data/raster/WorldPop/ppp_2020_1km_Aggregated_optim.tif")
r <- raster::raster(paste0("C:/Users/", Sys.info()[7], "/Box/Africa Data and Analytics for community case Management/ccm-africa/data/raster/WorldPop/ppp_2020_1km_Aggregated_optim.tif"))

# write to package data
# use_data(r, overwrite = TRUE)

# Write pin to board
board |> pin_write(r, name = "global-pop", title = "WorldPop global raster", description = "2021 WorldPop global population raster (appx. 1 sq. km. resolution)")
board |> write_board_manifest()

# MAP surfaces ----------------------
# Walking friction
r <- raster::raster(paste0("C:/Users/", Sys.info()[7], "/Box/Spatial Repository/MAP Travel Time Estimation/processed/202001_Global_Walking_Only_Friction_Surface_2019.tif"))

board |> pin_write(
  r,
  name = "walking-friction",
  title = "Malaria Atlas Project - Walking friction surface",
  description = "2019 estimated global walking friction raster (~ 1 km. res. ) from Weiss et al. 2020")
board |> write_board_manifest()

# Motorized friction
r <- raster::raster(paste0("C:/Users/", Sys.info()[7], "/Box/Spatial Repository/MAP Travel Time Estimation/processed/202001_Global_Motorized_Friction_Surface_2019.tif"))

board |> pin_write(
  r,
  name = "motor-friction",
  title = "Malaria Atlas Project - Motorized friction surface",
  description = "2019 estimated global motorized friction raster (~ 1 km. res. ) from Weiss et al. 2020")
board |> write_board_manifest()

# Malaria incidence
r <- raster::raster(paste0("C:/Users/", Sys.info()[7], "/Box/Spatial Repository/MAP Global Malaria Incidence/processed/202206_Global_Pf_Incidence_Rate_2020.tif"))

board |> pin_write(
  r,
  name = "map-incidence-2020",
  title = "Malaria Atlas Project - Global malaria incidence",
  description = "2020 estimated malaria cases per person raster (~ 5 km res)")
board |> write_board_manifest()


# From tutorial --------------------------
# # create data
#
#
# mtcars_metric <- mtcars
# mtcars_metric$lper100km <- 235.215 / mtcars$mpg
#
# # write to package data
# use_data(mtcars_metric, overwrite = TRUE)
#
# # create, write to board
# board <- board_folder(here("pkgdown/assets/pins-board"), versioned = FALSE)
# board |> pin_write(mtcars_metric, type = "json")
# board |> write_board_manifest()
