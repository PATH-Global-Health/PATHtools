# PATHtools

<!-- badges: start -->

<!-- badges: end -->

The goal of `PATHtools` is to provide a common set of miscellanous R functions and assets that could be used by any R-based analytical work. This will allow us to share common resources, which will prevent duplicate code and version-control issues.

This is a **public repository**, which means that there will never be private or protected data and/or code contained within this package.

## Installation

The `PATHtools` package is hosted on Github and constantly under development. You can install the package like so:

``` r
install.packages("devtools")
devtools::install_github("PATH-Global-Health/PATHtools")
```

## Examples

```{r}
library(PATHtools)

# Shapefiles --------------------
# Check for available shapefiles
available_shapefile(country = "Senegal")
available_shapefile(admin_level = 2)

# Load shapefile
shp <- load_shapefile(country = "Nigeria", admin_level = 1)
plot(shp)

# Save GeoJSON file locally
load_shapefile(country = "Nigeria", admin_level = 1, download = TRUE)
```

## Contributing

### Requesting features

You can suggest new ideas or requests for features by [opening an issue on Github](https://github.com/PATH-Global-Health/PATHtools/issues). Please provide as much description and examples as possible, and link to external sources (if possible). We will use Issue to discuss developing new features, and document progress.

### Providing new functions

Before starting a new contribution, please check the existing issues and open a new issue if needed. You can add new code to the package by creating a new fork and submitting a pull request (PR). Please reference the issue your PR is addressing, and run `devtools::check()` before submission.
