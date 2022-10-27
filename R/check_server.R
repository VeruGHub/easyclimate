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

  server.ok <- RCurl::url.exists(cog.url)

  if (isTRUE(server.ok)) {
    message("The server seems to be running correctly.")
  } else {
    message("Problems with the database server.\n
            Please, make sure that you are connected to the Internet and try later.\n
            If problems persist, please, contact christoph.pucher@boku.ac.at")
  }

  return(server.ok)
}
