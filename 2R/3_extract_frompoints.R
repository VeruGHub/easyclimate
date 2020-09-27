
library(tidyverse)
library(raster)

#coords: points where we wish to have climatic data, with an ID field
#var: climatic variable to extract
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
      
      if (y<=2012) {
        
        rawclimate_stack <- stack(paste(path, "/", var, y, "_",ti,".tif",sep=""))
        climate_extract0 <- extract(rawclimate_stack, coords[tiles == ti,])
        climate_extract1 <- data.frame(climate_extract0)
        colnames(climate_extract1) <- paste0("d", 1:365)
        climate_extract1 <- data.frame(climate_extract1,
                                     year=y,
                                     long=coordinates(coords)[tiles == ti,1],
                                     lat=coordinates(coords)[tiles == ti,2],
                                     ID=coords@data[tiles == ti,"ID"])
        row.names(climate_extract1) <- paste(climate_extract1$ID, y, ti, sep="_")
        
        climate_extract_tile <- rbind(climate_extract_tile, climate_extract1)
        
      } else { next }
      }
    
    climate_extract_tile$tile <- ti
    
    save(climate_extract_tile, file=paste0(var,"_",tile,".RData")) #Saving all years per tile
    climate_extract <- rbind(climate_extract, climate_extract_tile)
    
  }
  
  if (ncol(climate_extract)==1) {
    climate_extract <- NULL
  } else { climate_extract <- climate_extract }
    
  for(y in start_year:end_year) {
      
      print(y) 
      
      if (y>2012) {
        
        rawclimate_stack <- stack(paste(path, "/", var, y, ".tif",sep=""))
        climate_extract0 <- extract(rawclimate_stack, coords)
        climate_extract1 <- data.frame(climate_extract0)
        
        if (ncol(climate_extract1)==366) {
          climate_extract1 <- climate_extract1[,-60] #Correction for leap years. Only 2016
        } else { climate_extract1 <- climate_extract1 }
        
        colnames(climate_extract1) <- paste0("d", 1:365)
                                   
        climate_extract1 <- data.frame(climate_extract1,
                                       year=y,
                                       long=coordinates(coords)[,1],
                                       lat=coordinates(coords)[,2],
                                       ID=coords@data[,"ID"],
                                       tile=NA)
        row.names(climate_extract1) <- paste(climate_extract1$ID, y, sep="_")
        
        save(climate_extract1, file=paste0(var,"_",y,".RData")) #Saving one year all tiles
        
      climate_extract <- rbind(climate_extract, climate_extract1)
      
      } else { next }}
  
  save(climate_extract, file=paste0(var,".RData"))    
  return(climate_extract)
  
}


#Example IFN data

mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

mypoints <- mypoints %>% 
  dplyr::select(Plotcode, CX, CY) %>% 
  filter(!is.na(CX)&CX!=0) %>% 
  rename(ID=Plotcode)

coordinates(mypoints) <- c("CX","CY")
crs(mypoints) <-  "+proj=utm +zone=30 +ellps=intl +units=m +no_defs"
plot(mypoints)

mypoints_t <-spTransform(mypoints,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
plot(mypoints_t)

#Tarda mas de un dia
prcp <- extract_from_coords(coords=mypoints_t, 
                             var="Prcp",
                             start_year=1951,
                             end_year=2012,
                             path="E:/easyclimate/1raw/daily")
prcp2 <- extract_from_coords(coords=mypoints_t, 
                   var="Prcp",
                   start_year=2013,
                   end_year=2017,
                   path="E:/easyclimate/1raw/daily")
beep()

prec_final <- rbind(prcp, prcp2)
save(list = c("prec_final"), file = "prcp_IFN234.RData")
