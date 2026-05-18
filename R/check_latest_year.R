
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

  if (!refresh && exists("latest_year", envir = .cache)) {
    return(.cache$latest_year)
  }

  base_url <- "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/YearlyDataRasters/prcp/"
  # this is the link we need to use when we update the package:
  # "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/YearlyDataRasters/prcp/"

  latest_year <- NA

  for (year in 2040:2020) {
    url_year <- sprintf(
      "%sDownscaledPrcp%dYearlySum_cogeo.tif",
      base_url, year
    )
    if (RCurl::url.exists(url_year)) {
      latest_year <- year
      break
    }
  }
  .cache$latest_year <- latest_year

  return(latest_year)
}


