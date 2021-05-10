
#' URL
#'
#' @description create an url to download climatic data from ftp://palantir.boku.ac.at/Public/ClimateData/
#'
#' @param year year to download climatic information
#' @param climatic_var climatic variable to be downloaded (Prcp, Tmax, Tmin)
#'
#' @return text string with the url
#' @export
#'
#' @examples
#' @author Veronica Cruz-Alonso, Sophia Ratcliffe

url <- function (climatic_var,
                 year) {

  paste("/vsicurl/ftp://palantir.boku.ac.at/Public/ClimateData/v2_cogeo/AllDataRasters/",
        ifelse(climatic_var == "Tmax", "tmax",
               ifelse(climatic_var == "Tmin", "tmin",
                      "prcp")),
        "/Downscaled",
        climatic_var,
        year,
        "_cogeo.tif",
        sep = "")

  }




