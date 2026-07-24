#' Get the latest year available on the server
#'
#' Returns the most recent year available on the server. The result is stored
#' in an internal cache to avoid repeated queries once the value has been returned.
#'
#' @param refresh Logical. Optional. If TRUE, forces a new query, ignoring any cached value.
#' Default is FALSE.
#'
#' @return An integer indicating the latest year available on the server.
#'
#' @keywords internal
#' @noRd
#'
#' @author Sofía Miguel


.cache <- new.env(parent = emptyenv()) # create hidden environment

get_latest_year <- function(refresh = FALSE) {


  # Check if the variable exists in the hidden env
  if (!refresh && exists("latest_year", envir = .cache,  inherits = FALSE)) {
    return(.cache$latest_year)
  }

  base_url <- "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/YearlyDataRasters/prcp/"


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

