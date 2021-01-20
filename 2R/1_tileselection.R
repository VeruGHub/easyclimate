
library(tidyverse)
library(raster)
library(rgdal)
library(magick)

#The objective of this script is to find the best way to assign a tile to each spatial point 
#where we want to download the climatic data

grid <- raster("docs/WithGrids.tif") #Tiles
plot(grid)

grid <- image_read("docs/WithGrids.tif") #Tiles
plot(grid)

#IMPORTANT
#To run this script is needed to download one tif in each tile and load it as follows.
#To use the rest of scripts you only need to run tile_selection function which is the 
#final product of this script

A_8 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","A_8.tif",sep=""))
A_9 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","A_9.tif",sep=""))
A_10 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","A_10.tif",sep=""))
B_8 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","B_8.tif",sep=""))
B_9 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","B_9.tif",sep=""))
B_10 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","B_10.tif",sep=""))
C_8 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","C_8.tif",sep=""))
C_9 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","C_9.tif",sep=""))
C_10 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","C_10.tif",sep=""))
D_8 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","D_8.tif",sep=""))
D_9 <- stack(paste("E:/easyclimate/1raw/daily/Prcp",1970,"_","D_9.tif",sep=""))

spaintiles <- list("A_8"=A_8, "A_9"=A_9, "A_10"=A_10, 
                   "B_8"=B_8, "B_9"=B_9, "B_10"=B_10, 
                   "C_8"=C_8, "C_9"=C_9, "C_10"=C_10,
                   "D_8"=D_8, "D_9"=D_9)

#Option 1: loading everytime a raster in each tile
tile <- rep(NA, length(mypoints_t)) #It works with any spatial points data.frame. To use this one load first the data of the example below
for (i in 1:length(spaintiles)) {
  a <- cellFromXY(object = spaintiles[[i]], mypoints_t)
  tile <- ifelse(!is.na(a), names(spaintiles)[i], tile)
}


#Option 2: loading the extent of each tile
tileextent <- NULL
for (i in 1:length(spaintiles)) {
  e0 <- extent(spaintiles[[i]])
  e <- data.frame(xmin=e0@xmin,
                  xmax=e0@xmax,
                  ymin=e0@ymin,
                  ymax=e0@ymax)
  e$tile <- names(spaintiles)[i]
  tileextent <- rbind(tileextent,e)
}

write.table(tileextent, "Oaux/tileextent.txt", row.names = FALSE)
save(list = c("tileextent"), file = "0aux/tileextent.RData")


#coords: data frame where first column is long and second column is lat

tile_selection <- function(coords) {

  coords1 <- data.frame(coordinates(coords))
  
  contain <- function (x, y) {
  ifelse(
    x[1] < y[,"xmax"] & x[1] > y[,"xmin"] & 
      x[2] < y[,"ymax"] & x[2] > y[,"ymin"],
       y[,"tile"], NA) }
  
  load("0aux/tileextent.RData")
  tile <- rep(NA, length(coords))

  for (i in 1:nrow(tileextent)) {
    tilei <- tileextent[i,]
    a <- apply(coords1, 1, contain, y=tilei)
    tile <- ifelse(!is.na(a), a, tile)
  }

  return(tile)
  
}

#Example with SFI data
mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

mypoints <- mypoints %>% 
  dplyr::select(Plotcode, CX, CY) %>% 
  filter(!is.na(CX)&CX!=0) 

coordinates(mypoints) <- c("CX","CY")
crs(mypoints) <-  "+proj=utm +zone=30 +ellps=intl +units=m +no_defs"
plot(mypoints)

mypoints_t <-spTransform(mypoints,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
plot(mypoints_t)

tilesfi <- tile_selection(mypoints_t)
