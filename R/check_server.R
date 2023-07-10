#' Check climate data server
#'
#' Check that the online climate data server is available and working correctly.
#'
#' @param climatic_var Optional. One of "Prcp", "Tmin", or "Tmax".
#' @param year Optional. Year between 1950 and 2022.
#' @param verbose Logical. Print diagnostic messages, or just return TRUE/FALSE?
#'
#' @return TRUE if the server seems available, FALSE otherwise.
#'
#' @details This function checks access to the latest version of the climatic
#' dataset (version 4).
#'
#' @export
#'
#' @examplesIf interactive()
#' check_server()

check_server <- function(climatic_var = NULL,
                         year = NULL,
                         verbose = TRUE) {

  if (is.null(climatic_var)) {
    climatic_var <- sample(c("Prcp", "Tmin", "Tmax"), size = 1)
  }

  if (is.null(year)) {
    year <- sample(1950:2022, size = 1)
  }

  cog.url <- build_url(climatic_var_single = climatic_var,
                       version = 4,
                       year = year)

  # Can we see the raster file?
  url.ok <- RCurl::url.exists(cog.url)

  if (!isTRUE(url.ok)) {
    server.ok <- FALSE
    if (verbose) {
      message(paste(
        "Cannot connect to the server.",
        "Please, make sure that you have internet connection.",
        "Some network connections (e.g. eduroam, some VPN) often give problems. Please try from a different network.",
        "If problems persist, please send an email to christoph.pucher@boku.ac.at with the output of running check_server()",
        sep = "\n"
      ))
    }

  } else {
    # Server is reachable, but can we download a single data point?
    coords <- data.frame(lon = -5, lat = 37)
    data.ok <- try(
      R.utils::withTimeout({
        suppressMessages(
          get_daily_climate_single(coords, climatic_var, paste0(year, "-01-01"),
                                   check_conn = FALSE))
      },
      timeout = 30,   # allow 30 seconds to download this single data point
      onTimeout = "silent"),  # if time out, return NULL
      silent = TRUE)

    if (inherits(data.ok, "data.frame")) {
      server.ok <- TRUE
      if (verbose) {
        message("The server seems to be running correctly.")
      }
    } else {
      server.ok <- FALSE
      if (verbose) {
        if (is.null(data.ok)) {
          message(paste(
            "The server has been reached, but data transfer seems too slow.",
            "The server may be too busy, or your internet connection too slow.",
            "Please try again in a few hours, or from a different network.",
            "If problems persist, please send an email to christoph.pucher@boku.ac.at with the output of running check_server()",
            sep = "\n"
          ))

        } else {
          message(data.ok)
          message(paste(
            "The server has been reached, but data downloading is failing.",
            "Some network connections (e.g. eduroam, some VPN) often give problems. Please try from a different network.",
            "If problems persist, please send an email to christoph.pucher@boku.ac.at with the output of running check_server()",
            sep = "\n"
          ))

        }

      }
    }

  }

  return(server.ok)
}
