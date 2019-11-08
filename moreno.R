
library(raster)
#rasterOptions(maxmemory = 1e+09)
library(RCurl)
library(httr)
library(rgdal)
library(readxl)

#setwd("C:/Users/USUARIO/Desktop/Doctorado/Uceda/Datos/Clima/Moreno")
#setwd("E:/Doctorado/Uceda/Datos/Clima/Moreno")
setwd("C:/Users/vcruzalo/Desktop/Uceda/Datos/Clima/Moreno")

###Descargar archivos ----
#Tarda mucho. No correr
# tile (ver carpeta de Moreno)
tile <- 'B_9'
# all the years to be downloaded, 1970-2000 for worldclim and the survey years of the plots
years <- 1974:2012
#Temperatures are given as celsius * 100 and precipitation is given as mm * 100
# Cada ano tiene 365 datos aunque sea bisiesto

# download the minimum temperature file
for(y in years){
  print(y)
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Tmin",y,"_",tile,".tif", sep="")
  output_file <- paste("Tmin",y,"_",tile,".tif", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
  
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Tmin",y,"_",tile,".hdr", sep="")
  output_file <- paste("Tmin",y,"_",tile,".hdr", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
}

# download the maximum temperature file
for(y in years){
  print(y)
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Tmax",y,"_",tile,".tif", sep="")
  output_file <- paste("Tmax",y,"_",tile,".tif", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
  
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Tmax",y,"_",tile,".hdr", sep="")
  output_file <- paste("Tmax",y,"_",tile,".hdr", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
}

# download the precipitation file
for(y in years){
  print(y)
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Prcp",y,"_",tile,".tif", sep="")
  output_file <- paste("Prcp",y,"_",tile,".tif", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
  
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Prcp",y,"_",tile,".hdr", sep="")
  output_file <- paste("Prcp",y,"_",tile,".hdr", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
}

# cargo la base de datos de quercus-----

#quer <- read.table(file = "E:/Doctorado/Uceda/Analisis/Uceda_data/quercus_bd2.txt",
#                      header = TRUE, sep = ";")
quer <- read.table(file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd2.txt",
                   header = TRUE, sep = ";")

for (i in 1:7) {quer[,i] <- as.character(quer[,i])}
str(quer)

coordinates(quer) <- c("CoordX","CoordY")
crs(quer) <-  "+proj=utm +zone=30 +ellps=intl +units=m +no_defs" #Las coordenadas del GPS estan ahora en ED50
quer_t <-spTransform(quer,CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

querdf <- as.data.frame(cbind(quer, coordinates(quer_t)))
names(querdf)[c(8,15,16)] <- c("Year","X", "Y") 

# Exporto las coordenadas para comprobar si esta bien hecha la transformacion y las pinto en ArcGis
write.table(x = querdf, file="E:/Doctorado/Uceda/Analisis/Uceda_data/Correccion_coordenadas/prueba_coords_R.txt", 
            row.names = FALSE, col.names = TRUE)

querdf$start_year <- querdf$Year #1er ano del que quiero datos
querdf$end_year <- querdf$Year #ultimo ano del que quiero datos de clima
querdf <- querdf[!is.na(querdf$Year),]


# Funcion para sacar de mis coordenadas los datos del raster stack de Moreno ----
#RasterStack: multiple layers with same extent, resolution & projection
extract_climate_variable_from_coords <- function(coords, climate_yearly_stack, 
                                                 stack_start_Year, stack_end_Year, #Años de los datos
                                                 start_Year, end_Year){ #Años target del analisis
  climate_extract <- extract(climate_yearly_stack, coords)
  if(is.na(climate_extract[1])){ #Entiendo que si hay dato para un año en el punto, lo va a haber todos los años
    for(b in seq(from=5000, to=25000, by=5000)){ 
      climate_extract <- extract(climate_yearly_stack, coords, buffer=b, fun=mean)#b is the radius of the buffer
      if(!is.na(climate_extract[1])) break
    }
  }
  if(!is.na(climate_extract[1])){ 
    yearly_climate <- as.data.frame(cbind(as.vector(climate_extract), #Saco datos de clima
                                          as.vector(stack_start_Year:stack_end_Year))) #Los uno a los años de cada dato
    colnames(yearly_climate) <- c('climate_extract','year')
    start_yr <- start_Year#-2
    survey_period <- seq(start_yr, end_Year)
    
    # return the mean of all the years and the mean of the survey period 
    #(survey period puede ser un sólo año o cambiar dependiendo de la variable)
    return(cbind(mean(yearly_climate$climate_extract, na.rm = TRUE),
                 mean(yearly_climate$climate_extract[yearly_climate$year %in% survey_period], na.rm = TRUE)))
  }
  return(NA)
}


#Crop a la extension de Uceda----
#Tarda mucho. No correr cada vez! los datos ya han quedado guardados
#Corto todos los raster a la extensión de mis quercus para que los calculos
#no tarden tanto

extent(xmin(quer_t), xmax(quer_t), ymin(quer_t), ymax(quer_t))
e <- extent(-3.447300, -3.409600, 40.85000, 40.87000)

for (y in years) {
  ini <- stack(paste("Tmin",y,"_",tile,".tif",sep=""))
  cr <- crop(ini, e)
  writeRaster(cr, filename=paste("Tmin",y,"_",tile,"_cr.tif",sep=""), 
              options="INTERLEAVE=BAND", overwrite=TRUE)
}

for (y in years) {
  ini <- stack(paste("Tmax",y,"_",tile,".tif",sep=""))
  cr <- crop(ini, e)
  writeRaster(cr, filename=paste("Tmax",y,"_",tile,"_cr.tif",sep=""), 
              options="INTERLEAVE=BAND", overwrite=TRUE)
}

for (y in years) {
  print(y)
  ini <- stack(paste("Prcp",y,"_",tile,".tif",sep=""))
  cr <- crop(ini, e)
  writeRaster(cr, filename=paste("Prcp",y,"_",tile,"_cr.tif",sep=""), 
              options="INTERLEAVE=BAND", overwrite=TRUE)
}

#####################################

##NUMERO DE HELADAS EN PRIMAVERA-----
#####################################

#set whether the minimum temperature is below 0
spring_frost_fun <- function(x) { 
  x[x < -8000] <- NA; 
  x[!is.na(x)] <- ifelse(x[!is.na(x)] < 0, 1, 0) 
  return(x)
}

spring.frost_stack <- stack()  

for(y in years){
  print(y)
  yr.min <- stack(paste("Tmin",y,"_",tile,"_cr.tif",sep=""))
  # number of days in April, May and June with minimum temperature below 0
  # El dia 91 es el primero de Abril y el 182 el ultimo de junio
  spring.frost <- calc(yr.min[[91:181]], spring_frost_fun)
  spring.frost <- sum(spring.frost)
  spring.frost_stack <- stack(spring.frost_stack, spring.frost) #Como un cbind de rasters
}

# Anado a la tabla las variables que voy a calcular a continuacion
querdf$spring_frosts <- NA
querdf$spring_frosts_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
    climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                        spring.frost_stack,
                                                        min(years), max(years), #Cambio yrs por years
                                                        querdf$start_year[i], #Para heladas sería el año en que nace el quercus
                                                        querdf$end_year[i]) #Para heladas igual que start year
    querdf$spring_frosts[i] <- climate_val[1]
    querdf$spring_frosts_survey[i] <- climate_val[2]
}

summary(querdf$spring_frosts)
summary(querdf$spring_frosts_survey)
hist(querdf$spring_frosts_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

################################

##NUMERO DE HELADAS EN PRIMAVERA AÑO ANTERIOR-----
##################################################

querdf$spring_frosts_a <- NA
querdf$spring_frosts_survey_a <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      spring.frost_stack,
                                                      min(years), max(years), #Cambio yrs por years
                                                      querdf$start_year[i]-1, #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]-1) #Para heladas igual que start year
  querdf$spring_frosts_a[i] <- climate_val[1]
  querdf$spring_frosts_survey_a[i] <- climate_val[2]
}

summary(querdf$spring_frosts_a)
summary(querdf$spring_frosts_survey_a)
hist(querdf$spring_frosts_survey_a)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

################################

##NUMERO DE HELADAS EN JUNIO----
################################

jun.frost_stack <- stack()  
for(y in years){
  print(y)
  yr.min <- stack(paste("Tmin",y,"_",tile,"_cr.tif",sep=""))
  jun.frost <- calc(yr.min[[152:181]], spring_frost_fun)
  jun.frost <- sum(jun.frost)
  jun.frost_stack <- stack(jun.frost_stack, jun.frost) 
}

# Anado a la tabla las variables que voy a calcular a continuacion
querdf$jun_frosts <- NA
querdf$jun_frosts_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      jun.frost_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]) #Para heladas igual que start year
  querdf$jun_frosts[i] <- climate_val[1]
  querdf$jun_frosts_survey[i] <- climate_val[2]
}

summary(querdf$jun_frosts)
summary(querdf$jun_frosts_survey)
hist(querdf$jun_frosts_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

#############################################

##NUMERO DE HELADAS EN JUNIO AÑO ANTERIOR----
#############################################

querdf$jun_frosts_a <- NA
querdf$jun_frosts_survey_a <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      jun.frost_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i]-1, 
                                                      querdf$end_year[i]-1)
  querdf$jun_frosts_a[i] <- climate_val[1]
  querdf$jun_frosts_survey_a[i] <- climate_val[2]
}

summary(querdf$jun_frosts_a)
summary(querdf$jun_frosts_survey_a)
hist(querdf$jun_frosts_survey_a)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

#####################################################

##MOMENTO DE LA HELADA MAS TARDIA DE LA PRIMARERA----
#####################################################

late_frost_fun <- function(x) { 
  x[x < -8000] <- NA; 
  x[!is.na(x)] <- ifelse(x[!is.na(x)] < 0, 1, 0)
  for (i in 181:1) {
    if(!is.na(x)) {
      if(x[[i]]==1) {
      return(i)
      break
    }}
  }
}

late.frost_stack <- stack()  
for(y in years){
  print(y)
  yr.min <- stack(paste("Tmin",y,"_",tile,"_cr.tif",sep=""))
  late.frost <- calc(yr.min[[1:181]], late_frost_fun)
  late.frost_stack <- stack(late.frost_stack, late.frost) 
}

querdf$late_frosts <- NA
querdf$late_frosts_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      late.frost_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]) #Para heladas igual que start year
  querdf$late_frosts[i] <- climate_val[1]
  querdf$late_frosts_survey[i] <- climate_val[2]
}

summary(querdf$late_frosts)
summary(querdf$late_frosts_survey)
hist(querdf$late_frosts_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

####################################

##MOMENTO DE LA HELADA MAS TARDIA DE LA PRIMARERA AÑO ANTERIOR----
##################################################################

querdf$late_frosts_a <- NA
querdf$late_frosts_survey_a <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      late.frost_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i]-1, 
                                                      querdf$end_year[i]-1) 
  querdf$late_frosts_a[i] <- climate_val[1]
  querdf$late_frosts_survey_a[i] <- climate_val[2]
}

summary(querdf$late_frosts_a)
summary(querdf$late_frosts_survey_a)
hist(querdf$late_frosts_survey_a)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

####################################

##TEMPERATURA MAXIMA DEL VERANO-----
####################################

summer_max_fun <- function(x) { 
  x[!is.na(x)] <- max(x[!is.na(x)]/100) 
  return(x)
}

summer.max_stack <- stack()  
for(y in years){
  print(y)
  yr.max <- stack(paste("Tmax",y,"_",tile,"_cr.tif",sep=""))
  summer.max <- calc(yr.max[[182:273]], summer_max_fun)
  summer.max_stack <- stack(summer.max_stack, summer.max) 
}

querdf$summer_max <- NA
querdf$summer_max_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      summer.max_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]) #Para heladas igual que start year
  querdf$summer_max[i] <- climate_val[1]
  querdf$summer_max_survey[i] <- climate_val[2]
}

summary(querdf$summer_max)
summary(querdf$summer_max_survey)
hist(querdf$summer_max_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

##################################

##TEMPERATURA MAXIMA DEL VERANO ANTERIOR-----
#############################################

querdf$summer_max_a <- NA
querdf$summer_max_survey_a <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      summer.max_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i]-1, #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]-1) #Para heladas igual que start year
  querdf$summer_max_a[i] <- climate_val[1]
  querdf$summer_max_survey_a[i] <- climate_val[2]
}

summary(querdf$summer_max_a)
summary(querdf$summer_max_survey_a)
hist(querdf$summer_max_survey_a)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

##################################

##TEMPERATURA MAXIMA DE JULIO-----
##################################

jul.max_stack <- stack()  
for(y in years){
  print(y)
  yr.max <- stack(paste("Tmax",y,"_",tile,"_cr.tif",sep=""))
  jul.max <- calc(yr.max[[182:212]], summer_max_fun)
  jul.max_stack <- stack(jul.max_stack, jul.max) 
}

querdf$jul_max <- NA
querdf$jul_max_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      jul.max_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]) #Para heladas igual que start year
  querdf$jul_max[i] <- climate_val[1]
  querdf$jul_max_survey[i] <- climate_val[2]
}

summary(querdf$jul_max)
summary(querdf$jul_max_survey)
hist(querdf$jul_max_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

####################################

##TEMPERATURA MAXIMA DE AGOSTO------
####################################

ago.max_stack <- stack()  
for(y in years){
  print(y)
  yr.max <- stack(paste("Tmax",y,"_",tile,"_cr.tif",sep=""))
  ago.max <- calc(yr.max[[213:243]], summer_max_fun)
  ago.max_stack <- stack(ago.max_stack, ago.max) 
}

querdf$ago_max <- NA
querdf$ago_max_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      ago.max_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], #Para heladas sería el año en que nace el quercus
                                                      querdf$end_year[i]) #Para heladas igual que start year
  querdf$ago_max[i] <- climate_val[1]
  querdf$ago_max_survey[i] <- climate_val[2]
}

summary(querdf$ago_max)
summary(querdf$ago_max_survey)
hist(querdf$ago_max_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

###################################

##TEMPERATURA MEDIA DEL VERANO-----
###################################

summer_med_fun <- function(x) { 
  x[!is.na(x)] <- mean(x[!is.na(x)]/100) 
  return(x)
}

#Haciendo la media de maximas y minimas todo junto, da igual que si hago primero maximas, luego 
#minimas y luego sumo y divido entre 2

summer.med_stack <- stack()  
for(y in years){
  print(y)
  yr.med <- stack(paste("Tmax",y,"_",tile,"_cr.tif",sep=""), paste("Tmin",y,"_",tile,"_cr.tif",sep=""))
  summer.med <- calc(yr.med[[182:273]], summer_med_fun)
  summer.med_stack <- stack(summer.med_stack, summer.med) 
}

querdf$summer_med <- NA
querdf$summer_med_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      summer.med_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$summer_med[i] <- climate_val[1]
  querdf$summer_med_survey[i] <- climate_val[2]
}

summary(querdf$summer_med)
summary(querdf$summer_med_survey)
hist(querdf$summer_med_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

##################################

##TEMPERATURA MEDIA DEL VERANO ANTERIOR-----
############################################

querdf$summer_med_a <- NA
querdf$summer_med_survey_a <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      summer.med_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i]-1, 
                                                      querdf$end_year[i]-1) 
  querdf$summer_med_a[i] <- climate_val[1]
  querdf$summer_med_survey_a[i] <- climate_val[2]
}

summary(querdf$summer_med_a)
summary(querdf$summer_med_survey_a)
hist(querdf$summer_med_survey_a)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

##################################

##TEMPERATURA MEDIA DEL JULIO-----
##################################

jul.med_stack <- stack()  
for(y in years){
  print(y)
  yr.med <- stack(paste("Tmax",y,"_",tile,"_cr.tif",sep=""), paste("Tmin",y,"_",tile,"_cr.tif",sep=""))
  jul.med <- calc(yr.med[[182:212]], summer_med_fun)
  jul.med_stack <- stack(jul.med_stack, jul.med) 
}

querdf$jul_med <- NA
querdf$jul_med_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      jul.med_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$jul_med[i] <- climate_val[1]
  querdf$jul_med_survey[i] <- climate_val[2]
}

summary(querdf$jul_med)
summary(querdf$jul_med_survey)
hist(querdf$jul_med_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

###################################

##TEMPERATURA MEDIA DEL AGOSTO-----
###################################

ago.med_stack <- brick()  
for(y in 1975){
  print(y)
  yr.med <- stack(paste("Tmax",y,"_",tile,"_cr.tif",sep=""), paste("Tmin",y,"_",tile,"_cr.tif",sep=""))
  ago.med <- calc(yr.med[[213:243]], summer_med_fun)
  ago.med_stack <- stack(ago.med_stack, ago.med) 
}

querdf$ago_med <- NA
querdf$ago_med_survey <- NA

for(i in 1:nrow(querdf)){ #Aplico la funcion creada anteriormente a mis coordenadas
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      ago.med_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$ago_med[i] <- climate_val[1]
  querdf$ago_med_survey[i] <- climate_val[2]
}

summary(querdf$ago_med)
summary(querdf$ago_med_survey)
hist(querdf$ago_med_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

##########################

##PRECIPITACION ANUAL-----
##########################

anual_prcp_fun <- function(x) { 
  x[!is.na(x)] <- sum(x[!is.na(x)]/100) 
  return(x)
}

anual.prcp_stack <- stack()  

for(y in years){
  print(y)
  yr.prcp <- stack(paste("Prcp",y,"_",tile,"_cr.tif",sep=""))
  anual.prcp <- calc(yr.prcp, anual_prcp_fun)
  anual.prcp_stack <- stack(anual.prcp_stack, anual.prcp)
}

querdf$anual_prcp <- NA
querdf$anual_prcp_survey <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      anual.prcp_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$anual_prcp[i] <- climate_val[1]
  querdf$anual_prcp_survey[i] <- climate_val[2]
}

summary(querdf$anual_prcp)
summary(querdf$anual_prcp_survey)
hist(querdf$anual_prcp_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

#############################

##PRECIPITACION PRIMAVERA----
#############################

spring.prcp_stack <- stack()  

for(y in years){
  print(y)
  yr.prcp <- stack(paste("Prcp",y,"_",tile,"_cr.tif",sep=""))
  spring.prcp <- calc(yr.prcp[[91:181]], anual_prcp_fun)
  spring.prcp_stack <- stack(spring.prcp_stack, spring.prcp)
}

querdf$spring_prcp <- NA
querdf$spring_prcp_survey <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      spring.prcp_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$spring_prcp[i] <- climate_val[1]
  querdf$spring_prcp_survey[i] <- climate_val[2]
}

summary(querdf$spring_prcp)
summary(querdf$spring_prcp_survey)
hist(querdf$spring_prcp_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

#########################

##PRECIPITACION PRIMAVERA ANTERIOR----
######################################

querdf$spring_prcp_a <- NA
querdf$spring_prcp_survey_a <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      spring.prcp_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i]-1, 
                                                      querdf$end_year[i]-1) 
  querdf$spring_prcp_a[i] <- climate_val[1]
  querdf$spring_prcp_survey_a[i] <- climate_val[2]
}

summary(querdf$spring_prcp_a)
summary(querdf$spring_prcp_survey_a)
hist(querdf$spring_prcp_survey_a)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

#########################

##PRECIPITACION JUNIO----
#########################

jun.prcp_stack <- stack()  

for(y in years){
  print(y)
  yr.prcp <- stack(paste("Prcp",y,"_",tile,"_cr.tif",sep=""))
  jun.prcp <- calc(yr.prcp[[152:181]], anual_prcp_fun)
  jun.prcp_stack <- stack(jun.prcp_stack, jun.prcp)
}

querdf$jun_prcp <- NA
querdf$jun_prcp_survey <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      jun.prcp_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$jun_prcp[i] <- climate_val[1]
  querdf$jun_prcp_survey[i] <- climate_val[2]
}

summary(querdf$jun_prcp)
summary(querdf$jun_prcp_survey)
hist(querdf$jun_prcp_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)


##########################

##PRECIPITACION VERANO----
##########################

summer.prcp_stack <- stack()  

for(y in years){
  print(y)
  yr.prcp <- stack(paste("Prcp",y,"_",tile,"_cr.tif",sep=""))
  summer.prcp <- calc(yr.prcp[[182:273]], anual_prcp_fun)
  summer.prcp_stack <- stack(summer.prcp_stack, summer.prcp)
}

querdf$summer_prcp <- NA
querdf$summer_prcp_survey <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      summer.prcp_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$summer_prcp[i] <- climate_val[1]
  querdf$summer_prcp_survey[i] <- climate_val[2]
}

summary(querdf$summer_prcp)
summary(querdf$summer_prcp_survey)
hist(querdf$summer_prcp_survey)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)

##############################

##PRECIPITACION SEPTIEMBRE----
##############################

sept.prcp_stack <- stack()  

for(y in years){
  print(y)
  yr.prcp <- stack(paste("Prcp",y,"_",tile,"_cr.tif",sep=""))
  sept.prcp <- calc(yr.prcp[[224:273]], anual_prcp_fun)
  sept.prcp_stack <- stack(sept.prcp_stack, sept.prcp)
}

querdf$sept_prcp <- NA
querdf$sept_prcp_survey <- NA

for(i in 1:nrow(querdf)){ 
  climate_val <- extract_climate_variable_from_coords(querdf[i,c("X","Y")], 
                                                      sept.prcp_stack,
                                                      min(years), max(years), 
                                                      querdf$start_year[i], 
                                                      querdf$end_year[i]) 
  querdf$sept_prcp[i] <- climate_val[1]
  querdf$sept_prcp_survey[i] <- climate_val[2]
}

summary(querdf$sept_prcp)
summary(querdf$sept_prcp_survey)
hist(querdf$sept_prcp_survey)


#write.table(x = querdf, file = "E:/Doctorado/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
#            sep = ";", row.names = FALSE, col.names = TRUE)
write.table(x = querdf, file = "C:/Users/vcruzalo/Desktop/Uceda/Analisis/Uceda_data/quercus_bd3.txt", 
            sep = ";", row.names = FALSE, col.names = TRUE)
