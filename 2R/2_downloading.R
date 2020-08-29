
library(tidyverse)
library(httr)

#year: a vector of years whose climatic information you need
#tile: a vector of tiles expaning the extent you need
#var: variables to be downloaded (Prcp, Tmax, Tmin)
#path: path to save the data (within the working directory) 

download.daily.climate <- function (year, tile, var, path) {
  
  info <- expand.grid(var, tile)
  
  url <- function (var, tile, y) {
        paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/",
              gsub("_", "/", tile),"/", var,y,"_",tile,".tif", sep="")}
  url_v2 <- function (var, y) {
    paste("ftp://palantir.boku.ac.at/Public/ClimateData/v2/AllDataRasters/Downscaled",
          var,y,".tif", sep="")}
  
  out <- function (var, tile, y, path) {
    paste(getwd(), "/", path, "/", var, y, "_", tile, ".tif", sep="")}
  out_v2 <- function (var, y, path) {
    paste(getwd(), "/", path, "/", var, y, ".tif", sep="")}
  
  for (y in year) {
    
    if (y < 1950 | y > 2017) { print(paste0("No available data for ", y)) }else{
      
      if (y >=1950 & y <= 2012) {
      
      userurl <- mapply(url, info[,1], info[,2], y)
      userout <- mapply(out, info[,1], info[,2], y, path)
      for (i in 1:length(userurl)){
        try(GET(userurl[i], authenticate('guest', ""), write_disk(userout[i], overwrite = TRUE)))
        try(GET(gsub(".tif", ".hdr", userurl[i]), authenticate('guest', ""), write_disk(gsub(".tif", ".hdr", userout[i]), overwrite = TRUE)))
        # try(GET(gsub(".tif", ".aux.xml", userurl[i]), authenticate('guest', ""), write_disk(gsub(".tif", ".tif.aux.xml", userout[i]), overwrite = TRUE)))
      } 
       
      }else{ #>2012
          
          userurl <- mapply(url_v2, info[,1], y)
          userout <- mapply(out_v2, info[,1], y, path)
          for (i in 1:length(userurl)){
            try(GET(userurl[i], authenticate('guest', ""), write_disk(userout[i], overwrite = TRUE)))
            try(GET(gsub(".tif", ".aux.xml", userurl[i]), authenticate('guest', ""), write_disk(gsub(".tif", ".aux.xml", userout[i]), overwrite = TRUE)))
          }
        }}}
}


#Example IFN data

mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

mypoints <- mypoints %>% 
  dplyr::select(Plotcode, CX, CY, year4, year3, year2) %>% 
  filter(!is.na(CX)&CX!=0) #4 pcs con CX=0. Arreglar

summary(mypoints)
mean(mypoints$year4-mypoints$year3)
mean(mypoints$year3-mypoints$year2)

coordinates(mypoints) <- c("CX","CY")
crs(mypoints) <-  "+proj=utm +zone=30 +ellps=intl +units=m +no_defs"
##PREGUNTAR A PALO: todo pasado a zona 30?
plot(mypoints)

mypoints_t <-spTransform(mypoints,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
plot(mypoints_t)

path <- "1raw/daily"
tile <- c("A_8", "A_9", "A_10",
          "B_8", "B_9", "B_10",
          "C_8", "C_9", "C_10") #España peninsular 
var <- c("Tmin", "Tmax", "Prcp")
year <- seq(from=min(mypoints$year2-11), to=2012, by=1) #to=max(mypoints$year4)


download.daily.climate(year, tile, var, path)

