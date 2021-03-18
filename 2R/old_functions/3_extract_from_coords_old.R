
#' Extract form coordinates
#' 
#' @description extract climatic information for given coordinates from the downloaded files
#' 
#' @param coords data frame with coordinates of sites to extract the climatic data, where first column is long and second column is lat
#' @param climatic_var the climatic variables to extract (Prcp, Tmax, Tmin)
#' @param years vector with the period to extract climatic variables
#' @param path path to read the data (within the working directory) 
#' @param buffer if TRUE and in cases where there is not climatic data, a mean value based on a buffer 
#' around each site (5000 to 25000 m) is given. Default is FALSE. buffer = TRUE considerably increases computation time
#'
#' @return
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso, Sophia Ratcliffe


extract_from_coords <- function(coords, 
                                climatic_var,
                                years,
                                path,
                                buffer = FALSE) { 

  library(raster)
  source("2R/functions/1_select_tiles.R")
  
  tiles <- select_tiles(coords)
  names(coords) <- c("long", "lat")
  climate_extract <- NULL
  
  for (ti in unique(tiles)) {
    
    print(ti)
    climate_extract_tile <- NULL
  
    for(y in years) {
      
      print(y) 
      
      if (y <= 2012) {
        
        rawclimate_stack <- stack(paste(path, "/", climatic_var, y, "_", ti, ".tif", sep=""))
        climate_extract0 <- raster::extract(rawclimate_stack, coords[tiles == ti,])
        climate_extract1 <- data.frame(climate_extract0)
        colnames(climate_extract1) <- paste0("d", 1:365)
        climate_extract1 <- data.frame(climate_extract1,
                                       buffer = NA,
                                       year = y,
                                       long = coords[tiles == ti, 1],
                                       lat = coords[tiles == ti, 2],
                                       ID = 1:nrow(climate_extract1))
        row.names(climate_extract1) <- paste(y, ti, climate_extract1$ID, sep = "_")

        
        #Complete NA cases
        climate_extract_na <- climate_extract1[climate_extract1$d1 <= -9999,]
        
        if(buffer == TRUE & nrow(climate_extract_na) > 0) {
          
          for(b in seq(from = 5000, to = 25000, by = 5000)) { #V: Which units should the buffer have?
            
            climate_extract_na2 <- climate_extract_na[climate_extract_na$d1 <= -9999,]
            
            climate_extract2 <- raster::extract(x = rawclimate_stack, 
                                        y = data.frame(climate_extract_na2[,"long"], 
                                                       climate_extract_na2[,"lat"]), 
                                        buffer = b, 
                                        fun = function(x) {mean(x[x>-9999], na.rm = TRUE)})
            climate_extract3 <- data.frame(climate_extract2)
            colnames(climate_extract3) <- paste0("d", 1:365)
            row.names(climate_extract3) <- row.names(climate_extract_na2)
            
            climate_extract_na[row.names(climate_extract_na) %in% 
                                 row.names(climate_extract3)[!is.na(climate_extract3$d1)], 1:365] <-
              climate_extract3[!is.na(climate_extract3$d1), 1:365]
            
            climate_extract_na[row.names(climate_extract_na) %in% 
                                 row.names(climate_extract3)[!is.na(climate_extract3$d1)], "buffer"] <- b

            if(nrow(climate_extract_na[climate_extract_na$d1 <= -9999,]) == 0 | b == 25000) { 
              break 
            }
          }
          
          climate_extract1[row.names(climate_extract1) %in% 
                               row.names(climate_extract_na), 1:365] <-
            climate_extract_na[, 1:365]
          
          climate_extract1[row.names(climate_extract1) %in% 
                             row.names(climate_extract_na), "buffer"] <-
            climate_extract_na[, "buffer"]
        
          } else { next }
        #
        
        climate_extract_tile <- rbind(climate_extract_tile, climate_extract1)
        
      } else { next }
      }
    
    climate_extract_tile$tile <- ti
    
    #save(climate_extract_tile, file = paste0(var, "_", ti, ".RData")) #Saving all years per tile
    climate_extract <- rbind(climate_extract, climate_extract_tile)
    
  }
  
  if (ncol(climate_extract) == 1) { 
    climate_extract <- NULL
  } else { climate_extract <- climate_extract }
    
  for(y in years) {
      
      print(y) 
      
      if (y > 2012) {
        
        rawclimate_stack <- stack(paste(path, "/", climatic_var, y, ".tif",sep = ""))
        climate_extract0 <- raster::extract(rawclimate_stack, coords)
        climate_extract1 <- data.frame(climate_extract0)
        
        if (ncol(climate_extract1) == 366) {
          climate_extract1 <- climate_extract1[,-60] #Correction for leap years. Only 2016
        } else { climate_extract1 <- climate_extract1 }
        
        colnames(climate_extract1) <- paste0("d", 1:365)
                                   
        climate_extract1 <- data.frame(climate_extract1,
                                       buffer = NA,
                                       year = y,
                                       long = coords[, 1],
                                       lat = coords[, 2],
                                       ID = 1:nrow(climate_extract1),
                                       tile = NA)
        row.names(climate_extract1) <- paste(y, climate_extract1$ID, sep = "_")
        
        #Complete NA cases
        climate_extract_na <- climate_extract1[climate_extract1$d1 <= -9999,]
        
        if(buffer == TRUE & nrow(climate_extract_na) > 0){
          
          for(b in seq(from = 5000, to = 25000, by = 5000)){ #V: Which units should the buffer have?
            
            climate_extract_na2 <- climate_extract_na[climate_extract_na$d1 <= -9999,]
            
            climate_extract2 <- raster::extract(x = rawclimate_stack, 
                                        y = data.frame(long=climate_extract_na2[,"long"], 
                                                       lat=climate_extract_na2[,"lat"]), 
                                        buffer = b, 
                                        fun = function(x) {mean(x[x > -9999], na.rm = TRUE)})
            climate_extract3 <- data.frame(climate_extract2)
            colnames(climate_extract3) <- paste0("d", 1:365)
            row.names(climate_extract3) <- row.names(climate_extract_na2)
            
            climate_extract_na[row.names(climate_extract_na) %in% 
                                 row.names(climate_extract3)[!is.na(climate_extract3$d1)], 1:365] <-
              climate_extract3[!is.na(climate_extract3$d1), 1:365]
            
            climate_extract_na[row.names(climate_extract_na) %in% 
                                 row.names(climate_extract3)[!is.na(climate_extract3$d1)], "buffer"] <- b
            
            if(nrow(climate_extract_na[climate_extract_na$d1 <= -9999,]) == 0 | b == 25000) { 
              break 
            }
          }
          
          climate_extract1[row.names(climate_extract1) %in% 
                             row.names(climate_extract_na), 1:365] <-
            climate_extract_na[, 1:365]
          
          climate_extract1[row.names(climate_extract1) %in% 
                             row.names(climate_extract_na), "buffer"] <-
            climate_extract_na[, "buffer"]
          
        } else { next }
        #
        
        #save(climate_extract1, file = paste0(var, "_", y, ".RData")) #Saving one year all tiles
        
      climate_extract <- rbind(climate_extract, climate_extract1)
      
      } else { next }}
  
  #save(climate_extract, file = paste0(var, ".RData"))    
  return(climate_extract)
  
}


