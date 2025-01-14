% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rainfall.R
\name{daily_rainfall}
\alias{daily_rainfall}
\title{Areal rainfall data}
\usage{
daily_rainfall(
  dates,
  shapefile,
  output_raster = FALSE,
  fun = "mean",
  long = FALSE,
  verbose = TRUE,
  pop_weight = FALSE
)
}
\arguments{
\item{dates}{A character vector containing the start and end date in "YYYY-MM-DD" format.}

\item{shapefile}{A sf object containing the areal aggregation polygons.}

\item{output_raster}{TRUE/FALSE Should output be cropped rasters? Default is FALSE.}

\item{fun}{A character string containing the aggregation function, default is "sum".}

\item{long}{TRUE/FALSE Should the output be in "long" format? Default is FALSE.}

\item{verbose}{TRUE/FALSE Print progress messages?}

\item{pop_weight}{TRUE/FALSE Should vaulues be weighted based on WorldPop population estimates? Default is FALSE}
}
\value{
A tibble containing extracted values along with any columns from 'shapefile'. If output_raster is TRUE then a SpatRaster object is returned.
}
\description{
Areal rainfall data
}
