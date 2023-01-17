#' Check climate data server
#'
#' Check that the online climate data server is available and working correctly.
#'
#' @param climatic_var Optional. One of "Prcp", "Tmin", or "Tmax".
#' @param year Optional. Year between 1950 and 2020.
#'
#' @return TRUE if the server seems available, FALSE otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' check_server()
#' }
check_server <- function(climatic_var = NULL, year = NULL) {

  if (is.null(climatic_var)) {
    climatic_var <- sample(c("Prcp", "Tmin", "Tmax"), size = 1)
  }

  if (is.null(year)) {
    year <- sample(1950:2020, size = 1)
  }

  cog.url <- build_url(climatic_var_single = climatic_var,
                       year = year)

  # Can we see the raster file?
  url.ok <- RCurl::url.exists(cog.url)

  if (!isTRUE(url.ok)) {
    message("Cannot connect to the server.\nPlease, make sure that you have internet connection.\nSome network connections (e.g. eduroam, some VPN) often give problems. Please try from a different network.\nIf problems persist, please contact christoph.pucher@boku.ac.at")
  } else {
    # Server is reachable
    # Can we download a single data point?
    coords <- data.frame(lon = -5, lat = 37)
    data.ok <- try(suppressMessages(
      get_daily_climate(coords, climatic_var, paste0(year, "-01-01"))),
      silent = TRUE)

    if (inherits(data.ok, "data.frame")) {
      message("The server seems to be running correctly.")
      server.ok <- TRUE
    } else {
      cat(data.ok)
      message("The server has been reached, but data downloading is failing.\nSome network connections (e.g. eduroam, some VPN) often give problems. Please try from a different network.\nIf problems persist, please contact christoph.pucher@boku.ac.at")

      server.ok <- FALSE
    }

  }

  return(server.ok)
}
