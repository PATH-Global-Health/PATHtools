#' Define urban-only pixels.
#'
#' @param population_raster An input raster containing people per pixel. Default inputs assume input resolution to be approximately 1 sq. km. resolution.
#' @param rururb_cutoff Minimum population per pixel to be eligible for urban classification.
#' @param min_urbsize Minimum total population of clustered pixels to the classified as urban.
#' @param directions See terra::patches, default is 8.
#' @param mask TRUE/FALSE, Should the returned raster have masked values (1 = Urban, 0 = Rural). Default is FALSE.
#' @param verbose TRUE/FALSE Print messages?
#'
#' @importFrom terra rast patches extract as.polygons mask values
#' @importFrom scales percent
#'
#' @return A SpatRaster object.
#' @export
#'
define_urban <- function(population_raster, rururb_cutoff = 300, min_urbsize = 2000, directions = 8, mask = FALSE, verbose = FALSE) {
  # A terra-based implementation of https://github.com/SwissTPH/CHWplacement/blob/main/R/defineUrbanRaster.R

  # Convert to terra object
  if(!"SpatRaster" %in% class(population_raster)){
    if(verbose){message("Converting to terra objects.")}
    population_raster <- terra::rast(population_raster)
  }

  names(population_raster) = "pop"
  # create a new raster indicating pixels above the cutoff
  popurb = population_raster
  popurb[popurb <= rururb_cutoff] = as.integer(0)
  popurb[popurb > rururb_cutoff]  = as.integer(1)

  # identify contiguous clusters of pixels above the cutoff
  # pop.urb.cl=raster::clump(popurb, directions=8)
  # pop.urb.cl.shp=raster::disaggregate(raster::rasterToPolygons(pop.urb.cl,dissolve=TRUE,fun=function(x){x>=1}))
  if(verbose){message("Creating urban clusters.")}
  pop_urb_cl <- terra::patches(popurb, directions = directions, zeroAsNA = T, allowGaps = F)
  pop_urb_cl_shp <- terra::as.polygons(pop_urb_cl)

  # retrieve the population in each cluster and select if above min_urbsize
  # pop.sp <- raster::extract(population_raster, pop.urb.cl.shp, fun=sum, na.rm=TRUE, sp=TRUE)
  # urb.raster=raster::mask(population_raster, pop.sp[pop.sp$pop>min_urbsize,])
  pop_sp <- terra::extract(population_raster, pop_urb_cl_shp, fun = "sum", na.rm = TRUE)
  urb_raster <- terra::mask(population_raster, pop_urb_cl_shp[which(pop_sp$pop >= min_urbsize),])
  urb_raster[urb_raster <= rururb_cutoff] = NA

  if(verbose) {
    # Print message
    urb_pct <- sum(terra::values(urb_raster), na.rm = T) / sum(terra::values(population_raster), na.rm = T)
    message("Proportion of the population in urban areas is ", scales::percent(urb_pct, 0.1))}

  # Apply mask
  if(mask == TRUE){
    if(verbose){message("Returning masked values (1 = 'Urban', 0 = 'Rural'.")}
    urb_mask <- urb_raster
    urb_mask[!is.na(population_raster)] = as.integer(0)
    urb_mask[!is.na(urb_raster)] = as.integer(1)
    urb_raster <- urb_mask
  }

  return(urb_raster)
}
