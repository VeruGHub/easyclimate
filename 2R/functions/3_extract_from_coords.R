
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
  ids <- 1:nrow(coords)
  climate_extract <- list()
  
  for (y in years) {
    
    print(y)

    if (y <= 2012) {
      
      climate_extract_tile <- list()
      
    for(ti in unique(tiles)) {
      
      print(ti) 
      
        rawclimate_stack_a <- stack(paste(path, "/", climatic_var, y, "_", ti, ".tif", sep=""))
        climate_extract0 <- raster::extract(rawclimate_stack_a, coords[tiles == ti,])
        climate_extract1 <- data.frame(climate_extract0)
        colnames(climate_extract1) <- paste0("d", 1:365)
        climate_extract2 <- data.frame(climate_extract1,
                                       buffer = NA,
                                       year = y,
                                       tile = ti,
                                       long = coords[tiles == ti, 1],
                                       lat = coords[tiles == ti, 2],
                                       ID = ids[tiles == ti])
        row.names(climate_extract2) <- paste(y, ti, climate_extract2$ID, sep = "_")

        
        #Complete NA cases
        climate_extract_na <- climate_extract2[climate_extract2$d1 <= -9999,]
        
        if(buffer == TRUE & nrow(climate_extract_na) > 0) {
          
          for(b in seq(from = 5000, to = 25000, by = 5000)) { #V: Which units should the buffer have?
            
            climate_extract_na_mirror <- climate_extract_na[climate_extract_na$d1 <= -9999,]
            
            climate_extract_na2 <- raster::extract(x = rawclimate_stack_a, 
                                        y = data.frame(climate_extract_na_mirror[,"long"], 
                                                       climate_extract_na_mirror[,"lat"]), 
                                        buffer = b, 
                                        fun = function(x) {mean(x[x>-9999], na.rm = TRUE)})
            climate_extract_na3 <- data.frame(climate_extract_na2)
            colnames(climate_extract_na3) <- paste0("d", 1:365)
            row.names(climate_extract_na3) <- row.names(climate_extract_na_mirror)
            
            climate_extract_na[row.names(climate_extract_na) %in% 
                                 row.names(climate_extract_na3)[!is.na(climate_extract_na3$d1)], 1:365] <-
              climate_extract_na3[!is.na(climate_extract_na3$d1), 1:365]
            
            climate_extract_na[row.names(climate_extract_na) %in% 
                                 row.names(climate_extract_na3)[!is.na(climate_extract_na3$d1)], "buffer"] <- b

            if(nrow(climate_extract_na[climate_extract_na$d1 <= -9999,]) == 0 | b == 25000) { 
              break 
            }
          }
          
          climate_extract2[row.names(climate_extract2) %in% 
                               row.names(climate_extract_na), 1:365] <-
            climate_extract_na[, 1:365]
          
          climate_extract2[row.names(climate_extract2) %in% 
                             row.names(climate_extract_na), "buffer"] <-
            climate_extract_na[, "buffer"]
        
          } 
        #
        
        climate_extract_tile[ti] <- list(climate_extract2)
        #print(summary(climate_extract_tile[ti]))
        
      }
      
      climate_extract[y] <- list(do.call(rbind, climate_extract_tile))
      #print(summary(climate_extract[y]))
      
      } else { #y > 2012
        
        rawclimate_stack_b <- stack(paste(path, "/", climatic_var, y, ".tif",sep = ""))
        climate_extract0b <- raster::extract(rawclimate_stack_b, coords)
        climate_extract1b <- data.frame(climate_extract0b)
        
        if (ncol(climate_extract1b) == 366) {
          climate_extract2b <- climate_extract1b[,-60] #Correction for leap years. Only 2016
        } else { climate_extract2b <- climate_extract1b }
        
        colnames(climate_extract2b) <- paste0("d", 1:365)
                                   
        climate_extract3b <- data.frame(climate_extract2b,
                                       buffer = NA,
                                       year = y,
                                       tile = NA, 
                                       long = coords[, 1],
                                       lat = coords[, 2],
                                       ID = ids)

        row.names(climate_extract3b) <- paste(y, climate_extract3b$ID, sep = "_")
        
        #Complete NA cases
        climate_extract_nab <- climate_extract3b[climate_extract3b$d1 <= -9999,]
        
        if(buffer == TRUE & nrow(climate_extract_nab) > 0){
          
          for(b in seq(from = 5000, to = 25000, by = 5000)){ #V: Which units should the buffer have?
            
            climate_extract_nab_mirror <- climate_extract_nab[climate_extract_nab$d1 <= -9999,]
            
            climate_extract_na2b <- raster::extract(x = rawclimate_stack_b, 
                                        y = data.frame(long=climate_extract_nab[,"long"], 
                                                       lat=climate_extract_nab[,"lat"]), 
                                        buffer = b, 
                                        fun = function(x) {mean(x[x > -9999], na.rm = TRUE)})
            climate_extract_na3b <- data.frame(climate_extract_na2b)
            colnames(climate_extract_na3b) <- paste0("d", 1:365)
            row.names(climate_extract_na3b) <- row.names(climate_extract_nab_mirror)
            
            climate_extract_nab[row.names(climate_extract_nab) %in% 
                                 row.names(climate_extract5b)[!is.na(climate_extract5b$d1)], 1:365] <-
              climate_extract5b[!is.na(climate_extract5b$d1), 1:365]
            
            climate_extract_nab[row.names(climate_extract_nab) %in% 
                                 row.names(climate_extract_na3b)[!is.na(climate_extract_na3b$d1)], "buffer"] <- b
            
            if(nrow(climate_extract_nab[climate_extract_nab$d1 <= -9999,]) == 0 | b == 25000) { 
              break 
            }
          }
          
          climate_extract3b[row.names(climate_extract3b) %in% 
                             row.names(climate_extract_nab), 1:365] <-
            climate_extract_nab[, 1:365]
          
          climate_extract3b[row.names(climate_extract3b) %in% 
                             row.names(climate_extract_nab), "buffer"] <-
            climate_extract_nab[, "buffer"]
          
        } 
        #
        
      climate_extract[y] <- list(climate_extract3b)
      #print(summary(climate_extract[y]))
      
      } 
  }
  #save(climate_extract, file = paste0(climatic_var, ".RData"))    
  return(do.call(rbind, climate_extract))
}


