
library(tidyverse)
library(raster)

#coords: points where we wish to have climatic data, with an ID field
#climate_stack: raster stack with the climatic information. It could be a raw data stack (via 1) or a processed data stack (via 2)
#start_year: for each survey and point, the first year when the climatic data is needeed
#end_year: for each survey and point, the last year when the climatic data is needeed. It could be equal to start year
#path: path where the raster are located

extract_from_coords <- function(coords, 
                                var,
                                start_year, 
                                end_year,
                                path) { 
  
  tiles <- tile_selection(data.frame(coordinates(coords)))
  climate_extract <- NULL
  
  for (ti in unique(tiles)) {
    
    print(ti)
    climate_extract_tile <- NULL
  
    for(y in start_year:end_year) {
      
      print(y) 
      rawclimate_stack <- stack(paste(path, "/", var, y, "_",ti,".tif",sep=""))
      climate_extract0 <- extract(rawclimate_stack, coords[tiles == ti,])
      climate_extract1 <- data.frame(climate_extract0)
      climate_extract1$year <- y
      climate_extract1$long <- coordinates(coords)[tiles == ti,1]
      climate_extract1$lat <- coordinates(coords)[tiles == ti,2]
      climate_extract1$id <- coords@data[tiles == ti,"ID"]

      climate_extract_tile <- rbind(climate_extract_tile, climate_extract1)
      
    }

    climate_extract_tile$tile <- ti
    climate_extract <- rbind(climate_extract, climate_extract_tile)
    
  }
  
  return(climate_extract)
  
}



coordskk <- data.frame(mypoints_t[tileej %in% c("A_10","A_9"),])
coordskk <- coordskk %>% 
  rename(ID="Plotcode")
coordinates(coordskk)<- c("CX","CY")

prueba <- extract_from_coords(coords=coordskk,
                    var="Prcp",
                    start_year=1970,
                    end_year=1971,
                    path="E:/easyclimate/1raw/daily") 

#Example IFN data

mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

mypoints <- mypoints %>% 
  dplyr::select(Plotcode, CX, CY, year4, year3, year2) %>% 
  filter(!is.na(CX)&CX!=0) 

mypoints$start_year <- 1970
mypoints$end_year <- 2017

coordinates(mypoints) <- c("CX","CY")
crs(mypoints) <-  "+proj=utm +zone=30 +ellps=intl +units=m +no_defs"
plot(mypoints)

mypoints_t <-spTransform(mypoints,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
plot(mypoints_t)






