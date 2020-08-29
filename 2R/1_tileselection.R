
library(tidyverse)
library(raster)
library(rgdal)

mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

mypoints <- mypoints %>% 
  dplyr::select(Plotcode, CX, CY) %>% 
  filter(!is.na(CX)&CX!=0) #4 pcs con CX=0. Arreglar

coordinates(mypoints) <- c("CX","CY")
crs(mypoints) <-  "+proj=utm +zone=30 +ellps=intl +units=m +no_defs"
##PREGUNTAR A PALO: todo pasado a zona 30?
plot(mypoints)

mypoints_t <-spTransform(mypoints,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
plot(mypoints_t)


grid <- raster("docs/WithGrids.tif")

plot(grid)
summary(values(grid))
plot(grid<250)

