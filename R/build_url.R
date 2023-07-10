
# Build url address for a given request
#
# Build the url to download climatic data from ftp://palantir.boku.ac.at/Public/ClimateData/
#
# @param climatic_var Character. Climatic variable to be downloaded. One of 'Tmax',
# 'Tmin' or 'Prcp'.
# @param year Numeric. Year to download climatic information
#
# @return text string with the url
#
# @author Veronica Cruz-Alonso, Francisco Rodríguez-Sánchez, Sophia Ratcliffe

build_url <- function(climatic_var_single,
                      year,
                      version = 4) {

  ## Check arguments
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Prcp"))
    stop("climatic_var_single must be one of 'Tmax', 'Tmin' or 'Prcp'")

  if (version == 3) {
    if (year < 1950 | year > 2020)
      stop("Year (period) must be between 1950 and 2020")
  }
  if (version == 4) {
    if (year < 1950 | year > 2022)
      stop("Year (period) must be between 1950 and 2022")
  }

  ## Adjust climvar to file names in FTP server
  climvar <- switch(climatic_var_single,
                    "Tmax" = "tmax",
                    "Tmin" = "tmin",
                    "Prcp" = "prec")

  ## Build url
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/v",
               version,
               "_cogeo/AllDataRasters/",
               climvar,
               "/Downscaled",
               climatic_var_single,
               year,
               "_cogeo.tif",
               sep = "")

  invisible(url)

}


