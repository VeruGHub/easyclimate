#' Get annual data for one climatic variable
#'
#' Extract annual climate data (temperature or precipitation) for a given set of
#' points or polygons within Europe.
#'
#' @param climatic_var_single Character. Climatic variable to be downloaded.
#' One of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'.
#' @param output Character. Either "df", which returns a dataframe with annual
#' climatic values for each point/polygon, or "raster", which returns a
#' [terra::SpatRaster()] object.
#' @inheritParams get_annual_climate
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
#' @author Veronica Cruz-Alonso, Francisco Rodriguez-Sanchez


get_annual_climate_single <- function(coords = NULL,
                                       climatic_var_single = "Prcp",
                                       period = NULL,
                                       output = "df") {

  #### Check arguments ####

  ## climatic_var_single
  if (!climatic_var_single %in% c("Tmax", "Tmin", "Tavg", "Prcp")) {
    stop("climatic_var_single must be one of 'Tmax', 'Tmin', 'Tavg' or 'Prcp'")
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
  # so as not to saturate server
  if (nrow(coords.spatvec) > 1000000) {  # change limits if needed
    stop("Asking for climate data for >1000000 sites. Please reduce the number of sites or download original rasters directly from ftp://palantir.boku.ac.at/Public/ClimateData/ so as not to saturate the server")
  }

  if (terra::geomtype(coords.spatvec) == "polygons") {

    if (sum(suppressWarnings(terra::expanse(coords.spatvec, unit = "km"))) >
        100000) {  # change limits if needed
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

  ## Extract years
  years <- period_to_years(period)

  ## Check years are within bounds
  if (any(years < 1950 | years > 2024)) {
    stop("Year (period) must be between 1950 and 2024")
  }

  #### Build urls for all required years ####

  urls <- unlist(lapply(years,
                        build_key,
                        climatic_var_single = climatic_var_single,
                        temp_res = "year"))

  #### Connect and combine all required rasters ####
  # Credentials for connecting to the server

  s3 <- paws::s3(
    config = list(
      credentials = list(
        creds = list(
          access_key_id = "NFKG4NAOIJ1H5QHJFBBD",
          secret_access_key = "07XoO5wixfafcZ2tq7UJqsQfAI2C960OlVXjjKMH"
        )
      ),
      endpoint = "https://s3.boku.ac.at",
      region = "eu-central-1",
      s3_force_path_style = TRUE
    )
  )

  obj.list <- lapply(urls,
                     function (one_url) {s3$get_object(
                       Bucket = "oekbwaldklimadaten",
                       Key = one_url)
                     })

  ras.list <- lapply(obj.list,
                     function (one_obj) {
                       temp.file <- tempfile(fileext = ".tif")
                       writeBin(one_obj$Body, temp.file)
                       terra::rast(temp.file)
                     })

  ## Combine all years
  rasters <- ras.list[[1]]
  if (length(ras.list) > 1) {
    for (i in 2:length(ras.list)) {
      terra::add(rasters) <- ras.list[[i]]
    }
  }

  ## Name raster layers with their dates
  names(rasters) <- years

  #### Extract ####

  message(paste0("\nDownloading ", climatic_var_single,
                 " data... This process might take several minutes"))

  if (output == "df") {

    out <- terra::extract(rasters, coords.spatvec, xy = TRUE)

    ## Reshape to long format and join with coverage
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

    ## Real climatic values
    out[,climatic_var_single] <- out[,climatic_var_single]/100

    invisible(out)

  }

  ## If output == "raster", return a cropped raster
  if (output == "raster") {

    if (terra::geomtype(coords.spatvec) == "polygons") {
      out <- terra::crop(rasters.sub, coords.spatvec, mask = TRUE)
    } else {
      out <- terra::crop(rasters.sub, coords.spatvec)
    }

    ## Real climatic values
    out <- out/100

    invisible(out)

  }

}




period_to_years <- function(period) {

  stopifnot(length(period) >= 1)

  if (!inherits(period, c("numeric", "integer")))
    stop("Period must be a number")

    ini.fin <- data.frame(ini = period[c(TRUE, diff(period) != 1)],
                          fin = period[c(diff(period) != 1, TRUE)])

    years.list <- lapply(split(ini.fin, seq_len(nrow(ini.fin))),
                          function(x) {
                            seq(from = x$ini,
                                to = x$fin,
                                by = 1)})
    years <- do.call("c", years.list)
    names(years) <- NULL
    #invisible(years)
    years
}




