
# Check the most recent year for which data are available on the server.
#
# This function is called within any of the get_<daily/monthly/annual>_climate_single()
# functions, and runs only the first time it is executed, creating a hidden variable
# `latest_year`.
#
# @return integer the most recent year for which data are available on the server
#
# @author Sofía Miguel


.cache <- new.env(parent = emptyenv()) # create hidden environment

get_latest_year <- function(refresh = FALSE) {

  # Check if the variable exists in the hidden env
  if (!refresh && exists("latest_year", envir = .cache)) {
    return(.cache$latest_year)
  }

  base_url <- "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/YearlyDataRasters/prcp/"
              # this is the link we need to use when we update the package:
              # "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/YearlyDataRasters/prcp/"

  latest_year <- purrr::detect(2040:1985, function(year) {

    url_year <- sprintf(
      "%sDownscaledPrcp%dYearlySum_cogeo.tif",
      base_url, year
    )

    httr::status_code(httr::HEAD(url_year)) == 200
  })

  # guardar en cache
  .cache$latest_year <- latest_year

  return(latest_year)
}

## Using for() instead of purrr::detect():
# get_latest_year_base <- function(refresh = FALSE) {
#
#   if (!refresh && exists("latest_year", envir = .cache)) {
#     return(.cache$latest_year)
#   }
#
#   base_url <- "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/YearlyDataRasters/prcp/"
#   # "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/YearlyDataRasters/prcp/"
#
#   latest_year <- NA
#
#   for (year in 2035:2020) {
#     url_year <- sprintf(
#       "%sDownscaledPrcp%dYearlySum_cogeo.tif",
#       base_url, year
#     )
#
#     if (httr::status_code(httr::HEAD(url_year)) == 200) {
#       latest_year <- year
#       break
#     }
#   }
#   .cache$latest_year <- latest_year
#
#   return(latest_year)
# }




