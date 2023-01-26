# Creating PATH Color Palette for Package

# PATH Color Palette
path_pals <- list(
  path_style = c(
    "#F65050",
    "#5050CD",
    "#008C9B",
    "#1EAF5F",
    "#A8001E",
    "#37379B",
    "#005A87",
    "#056E23",
    "#FBB9B9",
    "#FFE178",
    "#99D1D7",
    "#A5DFBF",
    "#464F60",
    "#E8EAEB",
    "#F4EDE7",
    "#000000"
  ),
  tableau_style = c("goldenrod2", "darkorange3", "dodgerblue3")
)


#' Generating PATH color palettes based on user inputs
#'
#' @param name name of specific path palette, default is path_style, secondary option for tableau_style
#' @param n number of colors, if left undefined it will default to the length of the palette
#' @param type continuous or discrete
#'
#' @importFrom grDevices colorRampPalette
#'
#' @export
#'
path_palette <- function(name = "path_style", n, type = c("discrete", "continuous")) {
  palette <- path_pals[[name]]
  if (missing(n)) {
    n <- length(palette)
  }

  type <- match.arg(type)
  out <- switch(
    type,
    continuous = grDevices::colorRampPalette(palette)(n),
    discrete = colorRampPalette(palette)(n)
  )
  structure(out, name = name, class = "palette")
}

#' PATH color palette functions for ggplot
#'
#' @description
#' Various functions for apply PATH color palettes to ggplot graphics. There are
#' specific functions for setting the "fill" and "color" aesthetics, and
#' suffixes for continuous (`_c`) and discrete (`_d`) variables. For example,
#' `scale_color_path_d` would apply the PATH color palette to a discrete
#' variable in the "color" aesthetic.
#'
#' @param name name of palette
#'
#' @importFrom ggplot2 scale_color_manual scale_fill_manual scale_colour_gradientn
#'
#' @export
#'
scale_color_path_d <- function(name = "path_style") {
  ggplot2::scale_color_manual(values = path_palette(
    name,
    type = "discrete"
  ))
}

#' @rdname scale_color_path_d
scale_fill_path_d <- function(name = "path_style") {
  ggplot2::scale_fill_manual(values = path_palette(
    name,
    type = "discrete"
  ))
}

#' @rdname scale_color_path_d
scale_color_path_c <- function(name = "path_style") {
  ggplot2::scale_colour_gradientn(colors = path_palette(
    name = name,
    type = "continuous"
  ))
}

#' @rdname scale_color_path_d
scale_fill_path_c <- function(name = "path_style") {
  ggplot2::scale_fill_gradientn(colors = path_palette(
    name = name,
    type = "continuous"
  ))
}
