
#' Download daily climate
#' 
#' @description download climatic data from ftp://palantir.boku.ac.at/Public/ClimateData/
#' 
#' @param years vector with the period to download climatic information
#' @param tiles vector with tiles spanning the extent to download climatic information
#' @param climatic_vars vector of climatic variables to be downloaded (Prcp, Tmax, Tmin)
#' @param path path to save the data (within the working directory) 
#'
#' @return tif, hdr and aux.xml files of the selected climatic variables
#' @export
#'
#' @examples
#' @author Veronica Cruz-Alonso, Sophia Ratcliffe

download_daily_climate <- function (years, tiles, climatic_vars, path) {
  
  library(httr)
  
  info <- expand.grid(climatic_vars, tiles)
  
  url <- function (var, tile, y) {
        paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/",
              gsub("_", "/", tile), "/", var, y, "_", tile, ".tif", sep = "")}
  url_v2 <- function (var, y) {
    var2 <- ifelse(var == "Tmin", "tmin", ifelse(var == "Tmax", "tmax", ifelse(var == "Prcp", "prec", NA)))
    paste("ftp://palantir.boku.ac.at/Public/ClimateData/v2/AllDataRasters/", var2,
          "/Downscaled", var, y, ".tif", sep = "")}
  
  out <- function (var, tile, y, path) {
    paste(path, "/", var, y, "_", tile, ".tif", sep = "")}
  out_v2 <- function (var, y, path) {
    paste(path, "/", var, y, ".tif", sep = "")}
  
  for (y in years) {
    
    print(y)
    
    if (y < 1951 | y > 2017) { print(paste0("No available data for ", y)) } else {
      
      if (y >=1951 & y <= 2012) {
      
      userurl <- mapply(url, info[,1], info[,2], y)
      userout <- mapply(out, info[,1], info[,2], y, path)
      
      for (i in 1:length(userurl)) {
        try(GET(userurl[i], authenticate('guest', ""), write_disk(userout[i], overwrite = TRUE)))
        try(GET(gsub(".tif", ".hdr", userurl[i]), authenticate('guest', ""), write_disk(gsub(".tif", ".hdr", userout[i]), overwrite = TRUE)), silent = TRUE)
        try(GET(gsub(".tif", ".aux.xml", userurl[i]), authenticate('guest', ""), write_disk(gsub(".tif", ".tif.aux.xml", userout[i]), overwrite = TRUE)), silent = TRUE)
      } 
       
      } else { #>2012
          
          userurl <- mapply(url_v2, info[,1], y)
          userout <- mapply(out_v2, info[,1], y, path)
          for (i in 1:length(userurl)) {
            try(GET(userurl[i], authenticate('guest', ""), write_disk(userout[i], overwrite = TRUE)))
          }
      }
    }
  }
}


