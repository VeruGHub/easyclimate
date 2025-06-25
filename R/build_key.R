
# Build key address for a given request
#
# Build the key to download climatic data
#
# @param climatic_var Character. Climatic variable to be downloaded. One of 'Tmax',
# 'Tmin' or 'Prcp'.
# @param year Numeric. Year to download climatic information
# @param temp_res Character. One of "day" , "month" or "year"
#
# @return text string with the url
#
# @author Veronica Cruz-Alonso, Francisco Rodríguez-Sánchez, Sophia Ratcliffe

build_key <- function(climatic_var_single,
                      year,
                      temp_res = "day") {

  ## Check arguments
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Tavg", "Prcp"))
    stop("climatic_var_single must be one of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'")

  if (!temp_res %in% c("day", "month", "year"))
    stop("temp_res must be one of 'day', 'month', or 'year'")

  ## Adjust climvar to file names in FTP server
  climvar <- switch(climatic_var_single,
                    "Tmax" = "tmax",
                    "Tmin" = "tmin",
                    "Tavg" = "tavg",
                    "Prcp" = "prcp")

  ## Build key

  if (temp_res == "day") {

    key <- paste("v31_cogeo/DailyDataRasters/",
               climvar,
               "/Downscaled",
               climatic_var_single,
               year,
               "_cogeo.tif",
               sep = "")

    invisible(key)

  } else {

    if (temp_res == "month") {

      aggr <- ifelse(climvar == "prcp", "MonthlySum", "MonthlyAvg")

  key <- paste("v31_cogeo/MonthlyDataRasters/",
               climvar,
               "/Downscaled",
               climatic_var_single,
               year,
               aggr,
               "_cogeo.tif",
               sep = "")

  invisible(key)

    }} else {

      if (temp_res == "year") {

        aggr <- ifelse(climvar == "prcp", "YearlySum", "YearlyAvg")

        key <- paste("v31_cogeo/YearlyDataRasters/",
                     climvar,
                     "/Downscaled",
                     climatic_var_single,
                     year,
                     aggr,
                     "_cogeo.tif",
                     sep = "")

        invisible(key)

      }
    }
}


