
library(tidyverse)
library(sf)

#Basado en parcelas del IFN
mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

summary(mypoints)

subset1 <- mypoints %>% 
  filter(Provincia4 %in% c("15")) %>% 
  slice(sample(1:275, size=50))
subset2 <- mypoints %>% 
  filter(Provincia4 %in% c("30")) %>% 
  slice(sample(1:1012, size=50))

subset <- subset1 %>% 
  bind_rows(subset2) %>% 
  select(Provincia4, CX, CY) %>% 
  rename(Region=Provincia4)

write_delim(x = subset, file = "0aux/example.csv", delim = ";")

#Cleaning de Paloma/Julen

mypoints <- read.csv(file = "0aux/example.csv", sep = ";")

mypoints <- st_as_sf(x = mypoints,
                     coords = c("CX", "CY"),
                     crs = "+proj=utm +zone=30 +ellps=intl +units=m +no_defs")

mypoints_t <- st_transform(mypoints, 
                           "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") %>% 
  mutate(CX = unlist(map(geometry, 1)),
         CY = unlist(map(geometry, 2))) %>% 
  as_tibble() %>% 
  dplyr::select(-c(Region, geometry))

mypoints_t$tile <- tile_selection(mypoints_t) #Correr tile_selection

example <- mypoints_t %>% 
  filter(tile %in% c("A_8","C_10")) %>% 
  select(-tile)

write_csv(x = example,file = "0aux/example.csv")



