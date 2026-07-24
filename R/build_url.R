#' Build the URL for a given request
#'
#' Build the URL to download climate data from
#' ftp://palantir.boku.ac.at/Public/ClimateData/
#'
#' @param climatic_var_single Character. Climatic variable to download.
#' One of "Tmax","Tmin", "Tavg", or "Prcp".
#' @param year Numeric. Year for which climatic data will be downloaded.
#' @param version Character. Climate data version. Either "last" (default) or
#' "4" (version 4).
#' @param temp_res Character. One of "day" , "month" or "year".
#'
#' @return Character string with the URL.
#'
#' @author Veronica Cruz-Alonso, Francisco Rodríguez-Sánchez, Sophia Ratcliffe, Sofía Miguel

build_url <- function(climatic_var_single,
                      year,
                      version = "last",
                      temp_res = "day") {
  ## Check arguments
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Tavg", "Prcp"))
    stop("climatic_var_single must be one of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'")

  ## Load last year of data
  latest_year <- get_latest_year()

  if (year < 1950 | year > latest_year)
    stop(sprintf("Year (period) must be between 1950 and %d", latest_year))


  ## Build url
  if (version  == "last") {
    ## Adjust climvar to file names in FTP server
    climvar <- switch(
      climatic_var_single,
      "Tmax" = "tmax",
      "Tmin" = "tmin",
      "Tavg" = "tavg",
      "Prcp" = "prcp"
    )

    if (temp_res == "day") {
      url <- paste(
        "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/DailyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        "_cogeo.tif",
        sep = ""
      )

    } else if (temp_res == "month") {
      aggr <- ifelse(climvar == "prcp", "MonthlySum", "MonthlyAvg")

      url <- paste(
        "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/MonthlyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        aggr,
        "_cogeo.tif",
        sep = ""
      )

    }  else if (temp_res == "year") {
      aggr <- ifelse(climvar == "prcp", "YearlySum", "YearlyAvg")

      url <- paste(
        "https://s3.boku.ac.at/oekbwaldklimadaten/cogeo/YearlyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        aggr,
        "_cogeo.tif",
        sep = ""
      )
    }

  } else if (version  == "4" | version == 4) {
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
        latest_year,
        "_cogeo/DailyDataRasters/",
        climvar,
        "/Downscaled",
        climatic_var_single,
        year,
        "_cogeo.tif",
        sep = ""
      )


    } else {
      stop("Version 4 is only avaliable for daily data")

    }
  }
  invisible(url)
}
