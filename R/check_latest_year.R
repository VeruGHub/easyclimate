
#' Get the most latest year for which we have data on the server
#'
#' Retrieves the most recent year available on the server. The output is saved
#' in an internal cache to avoid repeated queries once the value has been retrieved.
#'
#' @param refresh Logical. If TRUE, forces a new query, ignoring any value saved
#' in the cache. Default is FALSE.
#'
#' @return An integer indicating the latest available year.
#'
#' @references
#' Pucher C. 2023. Description and Evaluation of Downscaled Daily Climate Data Version 4.
#' https://doi.org/10.6084/m9.figshare.22962671.v1
#'
#' Werner Rammer, Christoph Pucher, Mathias Neumann. 2018.
#' Description, Evaluation and Validation of Downscaled Daily Climate Data Version 2.
#' ftp://palantir.boku.ac.at/Public/ClimateData/
#'
#' Adam Moreno, Hubert Hasenauer. 2016. Spatial downscaling of European climate data.
#' International Journal of Climatology 36: 1444–1458.
#'
#' @author Sofia Miguel


.cache <- new.env(parent = emptyenv()) # create hidden environment

get_latest_year <- function(refresh = FALSE) {


  # Check if the variable exists in the hidden env
  if (!refresh && exists("latest_year", envir = .cache,  inherits = FALSE)) {
    return(.cache$latest_year)
  }

  base_url <- "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/YearlyDataRasters/prcp/"
  # this is the link we need to use when we update the package:
  # "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/YearlyDataRasters/prcp/"


  for (year in 2030:2020) {
    url_year <- sprintf(
      "%sDownscaledPrcp%dYearlySum_cogeo.tif",
      base_url, year
    )
    if (RCurl::url.exists(url_year)) {
      .cache$latest_year <- year
      return(year)
    }
  }

  stop("No valid year found. Please, run the check_server function for further details.")
}

