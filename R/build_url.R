

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
                      version = "last",
                      temp_res = "day") {
  ## Check arguments
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Tavg", "Prcp"))
    stop("climatic_var_single must be one of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'")

  if (year < 1950 | year > 2024)
    stop("Year (period) must be between 1950 and 2024") ## SMR: Creo que se puede eliminar estoporque ya esta en get_X_climate_single
                                                        ## aunque si se eliminara, deberia de ser tambien en test_build_url

  ## Build url
  if (version  == "last") {
    ## Adjust climvar to file names in FTP server
    climvar <- switch(
      climatic_var_single,
      "Tmax" = "tmax",
      "Tmin" = "tmin",
      "Tavg" = "tavg",
      "Prcp" = "prcp" ## SMR: dado que la abreviatura para v4 y v_last es distinta, prec y prcp, hacemos el switch dentro de cada if
    )

    if (temp_res == "day") {
      url <- paste(
        "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/DailyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        "_cogeo.tif",
        sep = ""
      )

      #invisible(url)

    } else if (temp_res == "month") {

      aggr <- ifelse(climvar == "prcp", "MonthlySum", "MonthlyAvg")

      url <- paste(
        "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/MonthlyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        aggr,
        "_cogeo.tif",
        sep = ""
      )

    #  invisible(url)

    }  else if (temp_res == "year") {
      aggr <- ifelse(climvar == "prcp", "YearlySum", "YearlyAvg")

      url <- paste(
        "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/YearlyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        aggr,
        "_cogeo.tif",
        sep = ""
      )

    #  invisible(url)
    }
  } else if (version  == "4") {
    ## Adjust climvar to file names in FTP server
    climvar <- switch(
      climatic_var_single,
      "Tmax" = "tmax",
      "Tmin" = "tmin",
      "Tavg" = "tavg",
      "Prcp" = "prec"
    )
    if (temp_res == "day") {
      url <- paste(
        "ftp://palantir.boku.ac.at/Public/ClimateData/v",
        version,
        "_cogeo/AllDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        "_cogeo.tif",
        sep = ""
      )

    #  invisible(url)

    } else {
      stop("Version 4 is only avaliable for daily data")

      }
  }

 invisible(url)
}
