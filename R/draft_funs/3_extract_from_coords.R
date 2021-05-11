
#' Get climate data for a given set of coordinates
#'
#' Extract climatic information for given coordinates from the downloaded files
#'
#' @param coords data frame with coordinates of sites to extract the climatic data, where first column is long and second column is lat
#' @param climatic_var the climatic variable to extract (Prcp, Tmax, Tmin)
#' @param years vector with the period to extract climatic variables
#'
#' @return
#' @export
#'
#' @examples
#'
#' @author Veronica Cruz-Alonso, Sophia Ratcliffe, Francisco Rodríguez-Sánchez


extract_from_coords <- function(coords,
                                climatic_var,
                                years) {


  names(coords) <- c("long", "lat")
  ids <- 1:nrow(coords)
  climate_extract <- list()

  for (y in years) {

    print(y)

    cog_url <- build_url(climatic_var = climatic_var,
                    year = y)

    rawclimate <- terra::rast(cog_url)

    climate_extract1 <- terra::extract(rawclimate, coords)

    if (ncol(climate_extract1) == 366) {
      climate_extract2 <- climate_extract1[,-60] #Correction for leap years
    } else {
        climate_extract2 <- climate_extract1
        }

    colnames(climate_extract2) <- paste0("d", 1:365)

    climate_extract3 <- data.frame(climate_extract2,
                                   buffer = NA,
                                   year = y,
                                   long = coords[, 1],
                                   lat = coords[, 2],
                                   ID = ids)

    row.names(climate_extract3) <- paste(y, climate_extract3$ID, sep = "_")

    climate_extract[y-1950] <- list(climate_extract3)

  }

  return(do.call(rbind, climate_extract))

}
