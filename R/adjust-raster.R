#' Adjust population raster to match values from shapefile
#'
#' @param input_raster A SpatRaster (or RasterLayer) objects that will be adjusted such that the areal sums match the target column in ref_shp.
#' @param ref_shp A sf polygon object.
#' @param col_name A character string the identifies which column in ref_shp will be used to scale input_raster (this column must have numerical values and should not contain NAs).
#' @param output_class Either "terra" (default) or "raster".
#'
#' @importFrom terra rast rasterize
#' @importFrom exactextractr exact_extract
#' @importFrom raster raster
#'
#' @return a SpatRaster (or RasterLayer if output_class == "raster") object
#' @export
#'
adjust_pop_by_shp <- function(input_raster, ref_shp, col_name, output_class = "terra") {

  # Format input objects
  if("SpatRaster" %in% class(input_raster)) {r = input_raster} else {r <- terra::rast(input_raster)}
  s <- ref_shp[,col_name]
  names(s)[1] = "target"

  # Check extents?

  # Extract current values to shapefile
  s$org <- exactextractr::exact_extract(r, s, "sum", progress = F)

  # Calculate ratio
  s$ratio = s$target / s$org

  # Rasterize ratio
  ratio_rast <- terra::rasterize(s, r, "ratio")

  # Adjust input raster
  out <- r * ratio_rast
  # names(out) = col_name

  # Re-classify output
  if(output_class == "raster") {out = raster::raster(out)}

  # Export
  return(out)
}
