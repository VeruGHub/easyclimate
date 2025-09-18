
# Build url address for a given request
#
# Build the url to download climatic data from ftp://palantir.boku.ac.at/Public/ClimateData/
#
# @param climatic_var Character. Climatic variable to be downloaded. One of 'Tmax',
# 'Tmin', 'Tavg' or 'Prcp'.
# @param year Numeric. Year to download climatic information
# @param version Numeric. Version of the climate data.
# @param temp_res Character. One of "day" , "month" or "year"
#
# @return text string with the url
#
# @author Veronica Cruz-Alonso, Francisco Rodríguez-Sánchez, Sophia Ratcliffe

build_url <- function(climatic_var_single,
                      year,
                      version = 4,
                      temp_res = "day") {

  ## Check arguments
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Tavg", "Prcp"))
    stop("climatic_var_single must be one of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'")

  if (version == "3") {
    if (year < 1950 | year > 2020)
      stop("Year (period) must be between 1950 and 2020")
  }
  if (version == "4") {
    if (year < 1950 | year > 2024)
      stop("Year (period) must be between 1950 and 2024")
  }

  ## Adjust climvar to file names in FTP server
  climvar <- switch(climatic_var_single,
                    "Tmax" = "tmax",
                    "Tmin" = "tmin",
                    "Tavg" = "tavg",
                    "Prcp" = "prec")

  ## Build url

  if (temp_res == "day") {

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

  } else {

    if (temp_res == "month") {

      aggr <- ifelse(climvar == "prec", "MonthlySum", "MonthlyAvg")

  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/v31/cogeo/MonthlyDataRasters/",
               climvar,
               "/Downscaled",
               climatic_var_single,
               year,
               aggr,
               "_cogeo.tif",
               sep = "")

  invisible(url)

    }}

}

