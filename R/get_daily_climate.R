
#' Get daily climate data
#'
#' Extract daily climate data for a given set of points or polygons.
#'
#' @param coords A matrix, dataframe, [sf::sf()], or [terra::SpatVector()] object
#' containing point or polygon coordinates (in lonlat/geographic format).
#' If `coords` is a matrix, it must have only two columns: the first with longitude
#' and the second with latitude data.
#' If `coords` is a data.frame, it must contain two columns called `lon` and `lat`
#' with longitude and latitude coordinates, respectively.
#' @param climatic_var Character. Climatic variable to be downloaded. One of 'Tmax', 'Tmin' or 'Prcp'.
#' @param period Either a single number (representing a year between 1950 and 2017),
#' a date in "YYYY-MM-DD" format (to obtain data for a single day),
#' or a vector with the format "start:end".
#' Various elements can be concatenated in the vector
#' (e.g. c(2000:2005, 2010:2015, 2017), c("2000-01-01:2000-01-15", "2000-02-01"))
#' @param output Character. Either "df", which returns a dataframe with daily climatic values
#' for each point/polygon, or "raster", which returns a [terra::SpatRaster()] object.
#' @param ... further arguments for [terra::extract()]. Note you could use this to
#' directly calculate summary statistics (e.g. mean) for each polygon.
#'
#' @return A data.frame or a [terra::SpatRaster()] object (if output = "raster").
#' @export
#'
#' @examples
#' \dontrun{
#' library(easyclimate)
#'
#' # Coords as matrix
#' coords <- matrix(c(-5.36, 37.40), ncol = 2)
#' ex <- get_daily_climate(coords, period = "2008-09-27")  # single day
#' ex <- get_daily_climate(coords, period = 2008)  # entire year
#' ex <- get_daily_climate(coords, period = c(2008, 2010))  # several years
#' ex <- get_daily_climate(coords, period = c("2008-09-27", "2008-09-30"))  # specific period
#'
#' ex <- get_daily_climate(coords, period = "2008-09-27", climatic_var = "Tmin")
#'
#' # Coords as data.frame
#' coords <- as.data.frame(coords)
#' names(coords) <- c("lon", "lat")  # must have these columns
#' ex <- get_daily_climate(coords, period = "2008-09-27")  # single day
#'
#' # Coords as sf
#' coords <- sf::st_as_sf(coords, coords = c("lon", "lat"))
#' ex <- get_daily_climate(coords, period = "2008-09-27")  # single day
#'
#' # Several points
#' coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)
#' ex <- get_daily_climate(coords, period = "2008-09-27", output = "raster")  # raster output
#'
#' ## Polygons
#' coords <- terra::vect("POLYGON ((-5 38, -5 37.5, -4.5 37.5, -4.5 38, -5 38))")
#'
#' # Return raster
#' ex <- get_daily_climate(coords, period = "2008-09-27", output = "raster")
#'
#' # Calculate average across polygon
#' ex <- get_daily_climate(coords, period = "2008-09-27", fun = "mean")
#' # Calculate min across polygon
#' ex <- get_daily_climate(coords, period = "2008-09-27", fun = "min")
#'
#'# easily convert sf to SpatVector
#' # coords <- vect(poly.sf)
#'
#' }
#'
#' @author Veronica Cruz-Alonso, Sophia Ratcliffe, Francisco Rodríguez-Sánchez


get_daily_climate <- function(coords = NULL,
                        climatic_var = "Prcp",
                        period = NULL,
                        output = "df",
                        ...) {

  #### Check arguments ####

  ## climatic_var
  if (!climatic_var %in% c("Tmax", "Tmin", "Prcp"))
    stop("climatic_var must be one of 'Tmax', 'Tmin' or 'Prcp'")


  ## coords
  if (!inherits(coords, c("matrix", "data.frame", "sf", "SpatVector")))
    stop("coords must be either a matrix, data.frame, sf or SpatVector object")

  if (inherits(coords, "matrix")) {
    stopifnot(ncol(coords) == 2)
  }

  if (inherits(coords, "data.frame") & !inherits(coords, "sf")) {
    stopifnot("lon" %in% names(coords))
    stopifnot("lat" %in% names(coords))
  }

###V: Stop para raster + un punto -- no tiene sentido. Probar antes a actualiar paquete

  #### Convert matrix, data.frame, sf to SpatVector ####
  if (!inherits(coords, "SpatVector")) {
    # coords <- coords[!duplicated(coords), ]
    coords.spatvec0 <- terra::vect(coords)
    coords.spatvec <- terra::unique(coords.spatvec0)  # remove duplicates
  } else {
    coords.spatvec <- coords
  }

  ## Check that SpatVector extent is within bounds
  if (terra::ext(coords.spatvec)$xmin < -40.5 |
      terra::ext(coords.spatvec)$xmax > 75.5 |
      terra::ext(coords.spatvec)$ymin < 25.25 |
      terra::ext(coords.spatvec)$ymax > 75.5) {
    stop("coordinates fall out of the required extent (-40.5, 75.5, 25.25, 75.5)")
  }


  #### period: convert to dates ####
  days <- period_to_days(period)

  ## Extract years
  years <- as.numeric(sort(unique(format(days, "%Y"))))

  # Check years are within bounds
  if (any(years < 1950 | years > 2017))
    stop("Year (period) must be between 1950 and 2017")



  #### Build urls for all required years ####
  urls <- unlist(lapply(years, build_url, climatic_var = climatic_var))
  urls.vsicurl <- paste0("/vsicurl/", urls)


  #### Connect and combine all required rasters ####

  ras.list <- lapply(urls.vsicurl, terra::rast)

  # Name raster layers with their dates
  for (i in 1:length(years)) {
    names(ras.list[[i]]) <- seq.Date(from = as.Date(paste0(years[i], "-01-01")),
                                     to = as.Date(paste0(years[i], "-12-31")),
                                     by = 1)
  }

  # Combine all years
  rasters <- ras.list[[1]]
  if (length(ras.list) > 1) {
    for (i in 2:length(ras.list)) {
      terra::add(rasters) <- ras.list[[i]]
    }
  }


  ## Subset required dates only
  rasters.sub <- terra::subset(rasters, subset = as.character(days))


  ## Extract!
  if (output == "df") {
    out <- terra::extract(rasters.sub, coords.spatvec, xy = TRUE, ...)

    ## Same rows than original data #In progress
    # out2 <- terra::merge(coords.spatvec0, out, all.x = TRUE,
    #                      by.x = c("lon", "lat"), by.y = c("x", "y"))
    #Se duplican row.names

    ## Reshape to long format
    if ("y" %in% names(out)) {
      out <- reshape_terra_extract(out, fun = FALSE, climvar = climatic_var)
    } else {
      out <- reshape_terra_extract(out, fun = TRUE, climvar = climatic_var)
    }


  }


  ## If output == "raster", return a cropped raster
  #V: con una sola coordenada el output no puede ser raster porque no hace el crop
  if (output == "raster") {
    out <- terra::crop(rasters.sub, coords.spatvec)
  }

  invisible(out)

}




period_to_days <- function(period) {

  stopifnot(length(period) >= 1)

  ## period as a number

  if (is.numeric(period)) {

    ini <- period[c(TRUE, diff(period)!=1)]
    fin <- period[c(diff(period)!=1, TRUE)]
    days <- as.Date(NULL)

    for (i in 1:length(ini)) {

      days0 <- seq.Date(from = as.Date(paste0(ini[i], "-01-01")),
                        to = as.Date(paste0(fin[i], "-12-31")),
                        by = 1)

      days <- c(days, days0)
    }

  }

  ## period as character, e.g. "2005-01-06"

  # check correct format ("YYYY-MM-DD")
  if (is.character(period)) {
    if (any(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", period)))
      stop("Please provide dates as 'YYYY-MM-DD'")
  }

  if (is.character(period)) {

    ini <- do.call(rbind, strsplit(period, split = ":"))[,1]

    if (ncol(do.call(rbind, strsplit(period, split = ":"))) == 2) {
      fin <- do.call(rbind, strsplit(period, split = ":"))[,2]
    } else {
      fin <- ini
    }

    days <- as.Date(NULL)

    for (i in 1:length(ini)) {

      days0 <- seq.Date(from = as.Date(ini[i]),
                        to = as.Date(fin[i]),
                        by = 1)
      days <- c(days, days0)
    }

  }

  invisible(days)

}



reshape_terra_extract <- function(df.wide, fun = FALSE, climvar) {

  # Output of terra::extract is different if using 'fun'
  # (e.g. to summarise values within polygons)

  # First, simple use for points without using 'fun':

  if (!isTRUE(fun)) {

      names(df.wide)[!names(df.wide) %in% c("ID", "x", "y")] <-
        paste0(climvar, ".", names(df.wide)[!names(df.wide) %in% c("ID", "x", "y")])

      df.long <- stats::reshape(df.wide, direction = "long",
                            idvar = c("ID", "x", "y"),
                            varying = names(df.wide)[!names(df.wide) %in% c("ID", "x", "y")],
                            timevar = "date",
                            new.row.names = NULL)

  } else {# Reshaping output of terra::extract when fun has been used

    names(df.wide) <- gsub("\\.", "-", names(df.wide))
    names(df.wide) <- gsub("^X", paste0(climvar, "."), names(df.wide))
    df.long <- stats::reshape(df.wide, direction = "long",
                        idvar = c("ID"),
                        varying = names(df.wide)[!names(df.wide) %in% c("ID")],
                        timevar = "date")

  }

  df.long <- df.long[order(df.long$ID, df.long$date), ]
  row.names(df.long) <- NULL

  df.long

}
