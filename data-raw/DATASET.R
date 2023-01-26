library("usethis")
library("here")
library("pins")
library(terra)

# Create pins board in pgkdown site
board <- board_folder(here("pkgdown/assets/pins-board"), versioned = FALSE)


# WorldPop 2021 Global Raster (COG version) -------------
r <- rast("C:/Users/jmillar/Box/Africa Data and Analytics for community case Management/ccm-africa/data/raster/WorldPop/ppp_2020_1km_Aggregated_optim.tif")

# write to package data
# use_data(r, overwrite = TRUE)

# Write pin to board
board |> pin_write(r, name = "global-pop", title = "WorldPop global raster", description = "2021 WorldPop global population raster (appx. 1 sq. km. resolution)")
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
