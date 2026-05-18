
#' Get available data versions and temporal coverages
#'
#' Returns a data frame describing the available data versions and their
#' corresponding temporal coverage (initial and latest available years).
#'
#' @param none
#' @return A data.frame with the available versions and their initial and
#' latest year of data available.
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


get_periods <- function() {

  ## Load last year of data
  latest_year <- get_latest_year()

  periods <- data.frame("Version" = c("4", "latest"),
                        "Initial year available" = c(1950, 1950),
                        "Latest year available" = c( 2022, latest_year ))

  return(periods)
}
