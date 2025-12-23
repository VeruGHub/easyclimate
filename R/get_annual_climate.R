
#' Get annual data for multiple climatic variables
#'
#' Extract annual climate data (temperature and precipitation) for a given set of
#' points or polygons within Europe.
#'
#' @inheritParams get_daily_climate
#'
#' @param climatic_var Character. Climatic variables to be downloaded ('Tmax',
#' 'Tmin', 'Tavg' or 'Prcp'). Various elements can be concatenated in the vector.
#' @param period Numbers representing years between 1950 and 2024.
#' To specify a sequence of years use the format 'start:end'
#' (e.g. YYYY:YYYY, see examples). Various elements
#' can be concatenated in the vector (e.g. c(2000:2005, 2010:2015, 2020))
#'
#' @return Either:
#' - A data.frame (if output = "df")
#' - A list of [terra::SpatRaster()] object (if output = "raster")
#'
#' For precipitation, the function returns total (accumulated) precipitation per year.
#' For temperature variables ('Tmin', 'Tmax', 'Tavg') the function returns the average
#' (i.e. the annual average of minimum and maximum daily temperatures, or the average
#' annual temperature).
#'
#' @export
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
#' @author Veronica Cruz-Alonso, Francisco Rodriguez-Sanchez
#'
#' @examplesIf interactive()
#'
#' # Coords as matrix
#' coords <- matrix(c(-5.36, 37.40), ncol = 2)
#' ex <- get_annual_climate(coords, period = 2008)  # 2008
#' ex <- get_annual_climate(coords, period = c(2008, 2010))  # 2008 AND 2010
#' ex <- get_annual_climate(coords, period = 2008:2010)  # 2008 TO 2010
#'
#' ex <- get_annual_climate(coords, period = 2008, climatic_var = "Tmin")
#'
#' # Coords as data.frame or tbl_df
#' coords <- as.data.frame(coords) #coords <- tibble::as_tibble(coords)
#' names(coords) <- c("lon", "lat")  # must have these columns
#' ex <- get_annual_climate(coords, period = 2008)  # single month
#'
#' # Coords as sf
#' coords <- sf::st_as_sf(coords, coords = c("lon", "lat"))
#' ex <- get_annual_climate(coords, period = 2008)  # single month
#'
#' # Several points
#' coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)
#' ex <- get_annual_climate(coords, period = 2008, output = "raster")  # raster output
#'
#' # Multiple climatic variables
#' coords <- matrix(c(-5.36, 37.40), ncol = 2)
#' ex <- get_annual_climate(coords, climatic_var = c("Tmin", "Tmax"), period = 2008)
#'
#' ## Polygons
#' coords <- terra::vect("POLYGON ((-5 38, -5 37.5, -4.5 37.5, -4.5 38, -5 38))")
#'
#' # Return raster
#' ex <- get_annual_climate(coords, period = 2008, output = "raster")
#' ex <- get_annual_climate(coords, climatic_var = c("Tmin", "Tmax"),
#' period = 2008, output = "raster") # Multiple climatic variables
#'
#' # Return dataframe for polygon
#' ex <- get_annual_climate(coords, period = 2008)
#'


get_annual_climate <- function(coords = NULL,
                               climatic_var = "Prcp",
                               period = NULL,
                               output = "df") {

  if (length(climatic_var) == 1) {

    out <- get_annual_climate_single(
      coords = coords,
      climatic_var_single = climatic_var,
      period = period,
      output = output)

  } else {

    out.list <- lapply(X = climatic_var,
                       FUN = function(x) {
                         get_annual_climate_single(
                           coords = coords,
                           climatic_var_single = x,
                           period = period,
                           output = output) })

    if (output == "df") {

      out <- Reduce(function(var1, var2, climvar = climatic_var) {

        merge(var1, var2,
              by = names(var1)[!names(var1) %in% climvar])

      }, out.list)

    }

    if (output == "raster") {

      out <- out.list
      names(out) <- climatic_var

    }
  }

  invisible(out)

}

