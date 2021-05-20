
#' Get daily climate data
#'
#' Extract daily climate data for a given set of points or polygons within Europe.
#'
#'
#' @param coords A matrix, dataframe, [sf::sf()], or [terra::SpatVector()] object
#' containing point or polygon coordinates in decimal degrees (lonlat/geographic format).
#' Longitude must fall between -40.5 and 75.5 degrees, and latitude between 25.5 and 75.5 degrees.
#' If `coords` is a matrix, it must have only two columns: the first with longitude
#' and the second with latitude data.
#' If `coords` is a data.frame, it must contain at least two columns called `lon` and `lat`
#' with longitude and latitude coordinates, respectively.
#' @param climatic_var Character. Climatic variable to be downloaded. One of 'Tmax', 'Tmin' or 'Prcp'.
#' @param period Either numbers (representing years between 1950 and 2017),
#' or dates in "YYYY-MM-DD" format (to obtain data for specific days).
#' To specify a sequence of years or dates use the format 'start:end' (e.g. YYYY:YYYY or "YYYY-MM-DD:YYYY-MM-DD", see examples).
#' Various elements can be concatenated in the vector
#' (e.g. c(2000:2005, 2010:2015, 2017), c("2000-01-01:2000-01-15", "2000-02-01"))
#' @param output Character. Either "df", which returns a dataframe with daily climatic values
#' for each point/polygon, or "raster", which returns a [terra::SpatRaster()] object.
#' @param ... further arguments for [terra::extract()]. Note you could use this to
#' directly calculate summary statistics (e.g. mean) for each polygon (see examples)`.
#'
#' @return A data.frame or a [terra::SpatRaster()] object (if output = "raster").
#' Note temperature values are in ºC\*100, and precipitation values in mm\*100, to avoid floating values.
#' @export
#'
#' @references
#' Werner Rammer, Christoph Pucher, Mathias Neumann. 2018.
#' Description, Evaluation and Validation of Downscaled Daily Climate Data Version 2.
#' ftp://palantir.boku.ac.at/Public/ClimateData/
#'
#' @examples
#' \dontrun{
#' library(easyclimate)
#'
#' # Coords as matrix
#' coords <- matrix(c(-5.36, 37.40), ncol = 2)
#' ex <- get_daily_climate(coords, period = "2001-01-01")  # single day
#' ex <- get_daily_climate(coords, period = c("2001-01-01", "2001-01-03"))  # 1st AND 3rd Jan 2001
#' ex <- get_daily_climate(coords, period = "2001-01-01:2001-01-03")  # 1st TO 3rd Jan 2001
#' ex <- get_daily_climate(coords, period = 2008)  # entire year
#' ex <- get_daily_climate(coords, period = c(2008, 2010))  # 2008 AND 2010
#' ex <- get_daily_climate(coords, period = 2008:2010)  # 2008 TO 2010
#'
#' ex <- get_daily_climate(coords, period = "2001-01-01", climatic_var = "Tmin")
#'
#' # Coords as data.frame
#' coords <- as.data.frame(coords)
#' names(coords) <- c("lon", "lat")  # must have these columns
#' ex <- get_daily_climate(coords, period = "2001-01-01")  # single day
#'
#' # Coords as sf
#' coords <- sf::st_as_sf(coords, coords = c("lon", "lat"))
#' ex <- get_daily_climate(coords, period = "2001-01-01")  # single day
#'
#' # Several points
#' coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)
#' ex <- get_daily_climate(coords, period = "2001-01-01", output = "raster")  # raster output
#'
#' ## Polygons
#' coords <- terra::vect("POLYGON ((-5 38, -5 37.5, -4.5 37.5, -4.5 38, -5 38))")
#'
#' # Return raster
#' ex <- get_daily_climate(coords, period = "2001-01-01", output = "raster")
#'
#' # Calculate average across polygon
#' ex <- get_daily_climate(coords, period = "2001-01-01", fun = "mean")
#' # Calculate min across polygon
#' ex <- get_daily_climate(coords, period = "2008-09-27", fun = "min")
#'
#'
#' }
#'
#'
#' coords <- matrix(c(-5.36, 37.40, -5.36, 37.40, 4.05, 38.10), ncol = 2, byrow = TRUE)
#' coords <- data.frame(lon = c(-5.36123456, -5.36123456, -5.36123456, 4.05123456),
#' lat = c(37.40123456, 37.40123456, 37.40123456, 38.10123456),
#' dat = c(1,2,2, 3), dat2 = c(4,5,5,6))
#' ex <- get_daily_climate(coords, period = "2001-01-01")  # single day
#' @author Veronica Cruz-Alonso, Francisco Rodriguez-Sanchez, Sophia Ratcliffe


get_daily_climate <- function(coords = NULL,
                        climatic_var = "Prcp",
                        period = NULL,
                        output = "df",
                        ...) {

  #### Check arguments ####

  ## climatic_var
  if (!climatic_var %in% c("Tmax", "Tmin", "Prcp"))
    stop("climatic_var must be one of 'Tmax', 'Tmin' or 'Prcp'")

  if (climatic_var %in% names(coords)) {
    stop("coords cannot have a column with the same name as ", climatic_var, ". Please change it.")
  }

  # if ("ID_coords" %in% names(coords)) {
  #   stop("There cannot be a variable called 'ID_coords'. Please rename it")
  # }


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

  #### Convert matrix, data.frame, sf to SpatVector ####
  if (!inherits(coords, "SpatVector")) {
    coords.spatvec <- terra::vect(coords)
    # coords.spatvec <- terra::unique(coords.spatvec)  # remove duplicates
  } else {
    coords.spatvec <- coords
  }

  # Add ID variable
  coords.spatvec$ID_coords <- 1:nrow(coords.spatvec)


  ## Warn (or stop) if asking data for too many points or too large area
  # so as not to saturate FTP server
  if (nrow(coords.spatvec) > 10000) {  # change limits if needed
    warning("Asking for climate data for >10000 sites.
            Please check there are no duplicates in 'coords',
            and consider downloading original rasters so as not to saturate the server")
  }

  if (terra::geomtype(coords.spatvec) == "polygons") {

    if (sum(suppressWarnings(terra::expanse(coords.spatvec, unit = "km"))) > 10000) {  # change limits if needed
      warning("Asking for climate data for too large area.
            Please consider downloading original rasters so as not to saturate the server")
    }

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

    ## Reshape to long format
    if ("y" %in% names(out)) {
      out <- reshape_terra_extract(out, fun = FALSE, climvar = climatic_var)
    } else {
      out <- reshape_terra_extract(out, fun = TRUE, climvar = climatic_var)
    }

    ## Merge with original coords data
    coords.spatvec.df <- terra::as.data.frame(coords.spatvec)
    out <- merge(coords.spatvec.df, out, by.x =  "ID_coords", by.y = "ID", all = TRUE)

    ## Rasters codify NA as very negative values (-32768).
    # So, if value <-10000, it is NA
    out[, climatic_var] <- ifelse(out[, climatic_var] < -10000, NA, out[, climatic_var])

  }

  ## If output == "raster", return a cropped raster
  if (output == "raster") {
    out <- terra::crop(rasters.sub, coords.spatvec)
  }

  invisible(out)

}




period_to_days <- function(period) {

  stopifnot(length(period) >= 1)

  ## period as a number

  if (is.numeric(period)) {

    ini <- period[c(TRUE, diff(period) != 1)]
    fin <- period[c(diff(period) != 1, TRUE)]
    ini.fin <- data.frame(ini = paste0(ini, "-01-01"),
                          fin = paste0(fin, "-12-31"))

    days.list <- apply(ini.fin, 1, function(x) {
      seq.Date(from = as.Date(x["ini"]),
               to = as.Date(x["fin"]),
               by = 1)},
      simplify = FALSE)
    days = do.call("c", days.list)

  }

  ## period as character, e.g. "2005-01-06"

  if (is.character(period)) {

    ini <- do.call(rbind, strsplit(period, split = ":"))[,1]

    if (ncol(do.call(rbind, strsplit(period, split = ":"))) == 2) {
      fin <- do.call(rbind, strsplit(period, split = ":"))[,2]
    } else {
      fin <- ini
    }

    ini.fin <- data.frame(ini = ini, fin = fin)

    # check correct format ("YYYY-MM-DD")
    apply(ini.fin, c(1,2), function(x) {
      if (!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", x))
        stop("Please provide dates as 'YYYY-MM-DD'")
    })


    days.list <- apply(ini.fin, 1, function(x) {
      seq.Date(from = as.Date(x["ini"]),
               to = as.Date(x["fin"]),
               by = 1)},
      simplify = FALSE)

    days = do.call("c", days.list)

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
                            timevar = "date")

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
