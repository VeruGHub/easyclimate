
# this is the main script where you call 
# and run the functions previously created 

library(here)
library(tidyverse)
library(beepr)

# example data
egpoints <- read_csv(here("0aux", "example.csv"))

#### 1_tile_select.R ####

source(here("2R", "functions", "1_select_tiles.R"))

select_tiles(coords = egpoints)

#### 2-download_daily_climate.R ####

source(here("2R", "functions", "2_download_daily_climate.R"))
#It takes a lot downloading when year > 2012. I checked that if year > 2012 it works,
#so if you want to run an example better pick year <= 2012

download_daily_climate(years = 2012:2013, 
                       tiles = unique(select_tiles(coords = egpoints)),
                       climatic_vars = "Prcp",
                       path = here("1raw", "daily"))
beep()

download_daily_climate(years = 2012:2013,
                       tiles = unique(select_tiles(coords = egpoints)),
                       climatic_vars = "Tmin",
                       path = here("1raw", "daily"))
beep()

download_daily_climate(years = 2012:2013,
                       tiles = unique(select_tiles(coords = egpoints)),
                       climatic_vars = "Tmax",
                       path = here("1raw", "daily"))
beep()

#### 3-extract_from_coords.R ####

source(here("2R", "functions", "3_extract_from_coords.R"))
#It takes a lot extracting when year > 2012. 
#To skip this step: 
load("3results/extracts.RData")

myprec <- extract_from_coords(coords = egpoints,
                            climatic_var = "Prcp",
                            years = 2012:2013,
                            path = here("1raw", "daily"),
                            buffer = TRUE)
beep()

mytmax <- extract_from_coords(coords = egpoints,
                              climatic_var = "Tmax",
                              years = 2012:2013,
                              path = here("1raw", "daily"),
                              buffer = TRUE)
beep()

mytmin <- extract_from_coords(coords = egpoints,
                              climatic_var = "Tmin",
                              years = 2012:2013,
                              path = here("1raw", "daily"),
                              buffer = TRUE)
beep()

#save(list = c("myprec", "mytmax", "mytmin"), file = "3results/extracts.RData")

#### 4.1-annual_prec ####

source(here("2R", "functions", "4.1_annual_prec.R"))

myaprec <- annual_prec(df_sites = myprec, 
                       years = 2012:2013,
                       interannual_mean = TRUE, 
                       ref = 2012:2013)

#### 4.2-monthly_prec ####

source(here("2R", "functions", "4.2_monthly_prec.R"))

mymprec <- monthly_prec(df_sites = myprec, 
                       years = 2012:2013,
                       months = 5:8)

#### 4.3-annual_dry_waves ####

source(here("2R", "functions", "4.3_annual_dry_waves.R"))

mydrywaves <- annual_dry_waves(df_sites = myprec, 
                               years = 2012:2013, 
                               threshold = 20)

#### 5.1-annual_temp ####

source(here("2R", "functions", "5.1_annual_temp.R"))

myatemp <- annual_temp(df_sites_min = mytmin, 
                       df_sites_max = mytmax, 
                       years = 2012:2013,
                       interannual_mean = TRUE, 
                       ref = 2012:2013,
                       temp_vars = c("min", "max", "mean"))

#### 5.2-monthly_temp ####

source(here("2R", "functions", "5.2_monthly_temp.R"))

mymtemp <- monthly_temp(df_sites_min = mytmin, 
                        df_sites_max = mytmax,
                        years = 2012:2013, 
                        months = 11:12)

#### 5.3-annual_heat_waves ####

source(here("2R", "functions", "5.3_annual_heat_waves.R"))

myheatwaves <- annual_heat_waves(df_sites_max = mytmax, 
                                 years = 2012:2013, 
                                 threshold = 33) 

#### 5.4-annual_late_frosts ####

source(here("2R", "functions", "5.4_annual_late_frosts.R"))

myfrosts <- annual_late_frosts(df_sites_min = mytmin, 
                               years = 2012:2013, 
                               late_spring = 4:5)

#### 5.5-annual_degree_days ####

source(here("2R", "functions", "5.5_annual_degree_days.R"))

mydegdays <- annual_degree_days(df_sites_min = mytmin, 
                                df_sites_max = mytmax, 
                                years = 2012:2013, 
                                threshold = 10)
