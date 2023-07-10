
#' Get daily data for one climatic variable
#'
#' Extract daily climate data (temperature or precipitation) for a given set of
#' points or polygons within Europe.
#'
#' @param climatic_var_single Character. Climatic variable to be downloaded.
#' One of 'Tmax', 'Tmin' or 'Prcp'.
#' @param output Character. Either "df", which returns a dataframe with daily
#' climatic values for each point/polygon, or "raster", which returns a
#' [terra::SpatRaster()] object.
#' @param check_conn Logical. Check the connection to the server before
#' attempting data download?
#' @inheritParams get_daily_climate
#'
#' @return A data.frame (if output = "df") or a [terra::SpatRaster()] object
#' (if output = "raster").
#'
#' @keywords internal
#' @noRd
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
#' @author Francisco Rodriguez-Sanchez, Veronica Cruz-Alonso, Sophia Ratcliffe


get_daily_climate_single <- function(coords = NULL,
                                     climatic_var_single = "Prcp",
                                     period = NULL,
                                     output = "df",
                                     version = 4,
                                     check_conn = TRUE) {

  #### Check arguments ####

  ## version
  if (!version %in% c(4, 3)) {
    stop("version must be 3 or 4")
  }


  ## climatic_var_single
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Prcp")) {
    stop("climatic_var_single must be one of 'Tmax', 'Tmin' or 'Prcp'")
  }

  if (climatic_var_single %in% names(coords)) {
    stop("Coords cannot have a column with the same name as ", climatic_var_single,
         ". Please change it.")
  }

  ## coords
  if (!inherits(coords, c("matrix", "data.frame", "sf", "sfc", "sfg", "SpatVector")))
    stop("Coords must be either a matrix, data.frame, tbl_df, sf or SpatVector object")

  if (inherits(coords, "matrix")) {
    stopifnot(ncol(coords) == 2)
  }

  if (inherits(coords, "data.frame") & !inherits(coords, "sf")) {
    stopifnot("lon" %in% names(coords))
    stopifnot("lat" %in% names(coords))
  }

  if ("ID_coords" %in% names(coords)) {
    warning("The variable ID_coords will be overwritten. Consider renaming it")
  }

  #### Convert matrix, data.frame, sf to SpatVector ####

  if (!inherits(coords, "SpatVector")) {
    coords.spatvec <- terra::vect(coords)
  } else {
    coords.spatvec <- coords
  }

  # If missing CRS, assume lonlat (EPSG:4326)
  if (terra::crs(coords.spatvec) == "") {
    terra::crs(coords.spatvec) <- "epsg:4326"
  }

  stopifnot(terra::crs(coords.spatvec, describe = TRUE)$code == "4326")


  ## Add ID variable
  coords.spatvec$ID_coords <- seq(from = 1, to = nrow(coords.spatvec), by = 1)

  ## Warn (or stop) if asking data for too many points or too large area
  # so as not to saturate FTP server
  if (nrow(coords.spatvec) > 10000) {  # change limits if needed
    stop("Asking for climate data for >10000 sites. Please reduce the number of sites or download original rasters directly from ftp://palantir.boku.ac.at/Public/ClimateData/ so as not to saturate the server")
  }

  if (terra::geomtype(coords.spatvec) == "polygons") {

    if (sum(suppressWarnings(terra::expanse(coords.spatvec, unit = "km"))) >
        10000) {  # change limits if needed
      stop("Asking for climate data for too large area. Please reduce the polygon area or download original rasters directly from ftp://palantir.boku.ac.at/Public/ClimateData/ so as not to saturate the server")
    }

  }

  ## Check that SpatVector extent is within bounds
  if (terra::ext(coords.spatvec)$xmin < -40.5 |
      terra::ext(coords.spatvec)$xmax > 75.5 |
      terra::ext(coords.spatvec)$ymin < 25.25 |
      terra::ext(coords.spatvec)$ymax > 75.5) {
    stop("Coordinates fall out of the required extent (-40.5, 75.5, 25.25, 75.5)")
  }


  #### Period ####

  ## Convert to dates
  days <- period_to_days(period)

  ## Extract years
  years <- as.numeric(sort(unique(format(days, "%Y"))))

  ## Check years are within bounds
  if (version == 3) {
    if (any(years < 1950 | years > 2020))
      stop("Year (period) must be between 1950 and 2020")
  }
  if (version == 4) {
    if (any(years < 1950 | years > 2022))
      stop("Year (period) must be between 1950 and 2022")
  }

  #### Build urls for all required years ####

  urls <- unlist(lapply(years,
                        build_url,
                        climatic_var_single = climatic_var_single,
                        version = version))

  ## Check if the server is working
  if (isTRUE(check_conn)) {
    if (isTRUE(check_server(verbose = FALSE))) {
      message("Connecting to the server...")
    } else {
      message("Problems retrieving the data. Please run 'check_server()' to diagnose the problems.\n")
    }
  }
  ###

  urls.vsicurl <- paste0("/vsicurl/", urls)

  #### Connect and combine all required rasters ####

  ras.list <- lapply(urls.vsicurl, terra::rast)

  ## Name raster layers with their dates
  for (i in seq_along(years)) {
    names(ras.list[[i]]) <- seq.Date(from = as.Date(paste0(years[i], "-01-01")),
                                     to = as.Date(paste0(years[i], "-12-31")),
                                     by = 1)
  }

  ## Combine all years
  rasters <- ras.list[[1]]
  if (length(ras.list) > 1) {
    for (i in 2:length(ras.list)) {
      terra::add(rasters) <- ras.list[[i]]
    }
  }

  ## Subset required dates only
  rasters.sub <- terra::subset(rasters, subset = as.character(days))

  #### Extract ####

  message(paste0("\nDownloading ", climatic_var_single,
                 " data... This process might take several minutes"))

  if (output == "df") {

    out <- terra::extract(rasters.sub, coords.spatvec, xy = TRUE)

    ## Reshape to long format
    out <- reshape_terra_extract(out, climvar = climatic_var_single)

    ## Merge with original coords data
    if (terra::is.polygons(coords.spatvec)) {
      # if polygons, keep coordinates from raster cells
      coords.spatvec.df <- terra::as.data.frame(coords.spatvec)
    } else {
      # else (ie for point coordinates) keep input coords rather than raster cells
      out <- subset(out, select = -c(lon, lat))
      spatvec.coords <- terra::crds(coords.spatvec, df = TRUE)
      names(spatvec.coords) <- c("lon", "lat")
      coords.spatvec.df <- data.frame(terra::as.data.frame(coords.spatvec),
                                      spatvec.coords)
    }

    out <- merge(coords.spatvec.df, out, by.x =  "ID_coords", by.y = "ID", all = TRUE)

    ## Rasters codify NA as very negative values (-32768).
    # So, if value <-9000, it is NA
    out[, climatic_var_single] <- ifelse(out[, climatic_var_single] < -9000, NA,
                                         out[, climatic_var_single])

    ## Real climatic values
    out[,climatic_var_single] <- out[,climatic_var_single]/100

  }

  ## If output == "raster", return a cropped raster
  if (output == "raster") {

    if (terra::geomtype(coords.spatvec) == "polygons") {
      out <- terra::crop(rasters.sub, coords.spatvec, mask = TRUE)
    } else {
      out <- terra::crop(rasters.sub, coords.spatvec)
    }

    ## Rasters codify NA as very negative values (-32768).
    # So, if value <-9000, it is NA
    out <- terra::subst(out, -9000:-33000, NA)

    ## Real climatic values
    out <- out/100

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

    days.list <- lapply(split(ini.fin, seq_len(nrow(ini.fin))),
                        function(x) {
                          seq.Date(from = as.Date(x$ini),
                                   to = as.Date(x$fin),
                                   by = 1)})
    days <- do.call("c", days.list)
    names(days) <- NULL

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

    ## check correct format ("YYYY-MM-DD")
    apply(ini.fin, c(1, 2), function(x) {

      if (!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", x))

        stop("Please provide dates as 'YYYY-MM-DD'")

    })


    days.list <- lapply(split(ini.fin, seq_len(nrow(ini.fin))),
                        function(x) {
                          seq.Date(from = as.Date(x$ini),
                                   to = as.Date(x$fin),
                                   by = 1)})

    days <- do.call("c", days.list)

    names(days) <- NULL

  }

  invisible(days)

}


reshape_terra_extract <- function(df.wide, climvar) {

  df.wide <- df.wide[,!names(df.wide) %in% c("lon", "lat")]
  names(df.wide)[names(df.wide) %in% c("x", "y")] <- c("lon", "lat")

  names(df.wide)[!names(df.wide) %in% c("ID", "lon", "lat")] <-
    paste0(climvar, ".", names(df.wide)[!names(df.wide) %in% c("ID", "lon", "lat")])

  df.long <- stats::reshape(df.wide, direction = "long",
                            idvar = c("ID", "lon", "lat"),
                            varying = names(df.wide)[!names(df.wide) %in%
                                                       c("ID", "lon", "lat")],
                            timevar = "date")

  df.long <- df.long[order(df.long$ID, df.long$date), ]
  row.names(df.long) <- NULL

  df.long

}

