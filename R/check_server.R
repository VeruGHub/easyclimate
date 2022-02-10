#' Check climate data server
#'
#' Check that the online climate data server is available and working correctly.
#'
#' @return TRUE if the server seems available, FALSE otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' check_server()
#' }
check_server <- function() {

  cog.url <- build_url(climatic_var_single = "Prcp", year = 2010)

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
