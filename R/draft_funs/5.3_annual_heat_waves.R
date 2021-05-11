#' Annual heat waves
#'
#' @description calculates for each site and year, 
#' the length of the maximum heat wave (no. of days), 
#' the average length and the no. of these events along the year. 
#' A heat wave is consider as consecutive days
#' with maximum temperature above a threshold defined by the user
#'
#' @param df_sites_max a data frame of maximum temperatures
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords) 
#' @param years a vector with the period to calculate heat waves
#' @param threshold threshold of temperature to consider 
#' a day as part of a heat wave (ºC). Default is 30.
#'
#' @return a data frame with a row per sites and year. 
#' In columns the length of the maximum and mean heat wave 
#' and the number of heat waves along the year and the number of daily NAs
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
annual_heat_waves <- function(df_sites_max, years, threshold = 30) {
  
  library(dplyr)
  library(tidyr)
  
  df_sites_max[,1 : 365][df_sites_max[,1 : 365] <= -9999] <- NA
  colnames(df_sites_max)[1 : 365] <- 1 : 365
  
  heat <- df_sites_max %>%  
    filter(year %in% years) %>% 
    mutate(year = as.factor(year),
           ID = as.factor(ID)) %>% 
    pivot_longer(1 : 365, names_to = "day", values_to = "tmax") %>% 
    mutate(event = ifelse(tmax >= threshold * 100, 1, 0), #NAs will be 0 
           start = c(1, diff(event) != 0)) %>% 
    group_by(ID, year, .drop = FALSE) %>% 
    mutate(run = cumsum(start)) 
  
  heat2 <- heat %>% 
    filter(event == 1) %>% 
    group_by(ID, year, run, .drop = TRUE) %>% 
    summarise(length = n()) %>% 
    group_by(ID, year) %>% 
    summarise(n_heatwave = n(),
              max_heatwave = max(length),
              mean_heatwave = mean(length)) 
  
  heat3 <- heat %>% 
    group_by(ID, year) %>%
    summarise(nas = sum(is.na(tmax))) %>% 
    left_join(heat2, by = c("ID", "year")) %>% 
    mutate(n_heatwave = ifelse(is.na(n_heatwave), 0, n_heatwave)) 
    
  return(heat3)
  
}