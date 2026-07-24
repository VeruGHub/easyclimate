
#' Get available climatic data versions and years available.
#'
#' Returns a data.frame describing the available climatic data versions and
#' their temporal coverage (initial and latest available years).
#'
#' @return A data.frame containing the available climate data versions and
#' their corresponding initial and latest available years.
#'
#' @export
#'
#' @references
#' For details on the latest version of the climatic data, see:
#' Pucher, Christoph (2026). Description of Downscaled European Climate Data. figshare.
#' Online resource. https://doi.org/10.6084/m9.figshare.33078053.v1
#'
#' For details on version 4, see:
#' Pucher C. 2023. Description and Evaluation of Downscaled Daily Climate Data Version 4.
#' https://doi.org/10.6084/m9.figshare.22962671.v1
#' ftp://palantir.boku.ac.at/Public/ClimateData/
#'
#' Adam Moreno, Hubert Hasenauer. 2016. Spatial downscaling of European climate data.
#' International Journal of Climatology 36: 1444–1458.
#'
#' @author Sofia Miguel


get_periods <- function() {

  ## Load last year of data
  latest_year <- get_latest_year()

  periods <- data.frame("version" = c("4", "latest"),
                        "From" = c(1950, 1950),
                        "To" = c( 2022, latest_year ))

  return(periods)
}
