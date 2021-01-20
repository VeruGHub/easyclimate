########################################################################
## Calculate number days of spring frost and sum of growing degree days
########################################################################

library(raster)
rasterOptions(maxmemory = 1e+09)
library(RCurl)
library(httr)

# the current tile
tile <- 'D_9'
# all the years to be downloaded, 1970-2000 for worldclim and the survey years of the plots
years <- 2000:2002
# load the plot data
sfi_plots <- read.csv(file="plotcode234_latlon_tile.csv")

# setwd("~/Documents/Projects/Paloma/climate/cluster_test")

# to test the code we just try spring frosts as this only needs the minimum temperature file
for(y in years){
  print(y)
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Tmin",y,"_",tile,".tif", sep="")
  output_file <- paste("Tmin",y,"_",tile,".tif", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
  
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tile),"/Tmin",y,"_",tile,".hdr", sep="")
  output_file <- paste("Tmin",y,"_",tile,".hdr", sep="")
  try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
}

#set whether the minimum temperature is below 0
spring_frost_fun <- function(x){ 
  x[x < -8000] <- NA; 
  x[!is.na(x)] <- ifelse(x[!is.na(x)] < 0, 1, 0) 
  return(x)
}
# function to extract the value from the climate stack
extract_climate_variable_from_coords <- function(coords, climate_yearly_stack, 
                                                 stack_start_Year, stack_end_Year,
                                                 start_Year, end_Year){
  climate_extract <- extract(climate_yearly_stack, coords)
  if(is.na(climate_extract[1])){
    for(b in seq(from=5000, to=25000, by=5000)){
      climate_extract <- extract(climate_yearly_stack, coords, buffer=b, fun=mean)
      if(!is.na(climate_extract[1]))break{
        b <-30000
      }
    }
  }
  if(!is.na(climate_extract[1])){
    yearly_climate <- as.data.frame(cbind(as.vector(climate_extract), 
                                          as.vector(stack_start_Year:stack_end_Year)))
    colnames(yearly_climate) <- c('climate_extract','year')
    start_yr <- start_Year-2
    survey_period <- seq(start_yr, end_Year)
    
    # return the mean of all the years and the mean of the survey period
    return(cbind(mean(yearly_climate$climate_extract, na.rm = TRUE),
                 mean(yearly_climate$climate_extract[yearly_climate$year %in% survey_period], na.rm = TRUE)))
  }
  return(NA)
}

spring.frost_stack <- stack()
for(y in years){
  print(y)
  
  yr.min <- stack(paste("Tmin",y,"_",tile,".tif",sep=""))
  # number of days in April, May and June with minimum temperature below 0
  spring.frost <- calc(yr.min[[91:182]], spring_frost_fun)
  spring.frost <- sum(spring.frost)
  spring.frost_stack <- stack(spring.frost_stack, spring.frost)
}

# select the plots in the tile
tile_plots <- sfi_plots[sfi_plots$tile==tile, c("PLOTCODE",'lon','lat')]
tile_plots$spring_frosts <- NA
tile_plots$spring_frosts_survey <- NA

for(i in 1:nrow(tile_plots)){
  plotcode <- tile_plots$plotcode[i]
  if(!is.na(plotcode)){
      
      climate_val <- extract_climate_variable_from_coords(tile_plots[i,c('longitude','latitude')], 
                                                  spring.frost_stack,
                                                  min(yrs), max(yrs), 
                                                  tile_plots$start_year[i],
                                                  tile_plots$end_year[i])
      tile_plots$spring_frosts[i] <- climate_val[1]
      tile_plots$spring_frosts_survey[i] <- climate_val[2]
  }
}
file_name <- paste("sfi_spring_frost_", tile, sep = "")
write.csv(tile_plots, file=file_name, row.names = FALSE)