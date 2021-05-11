#' Annual spring late frosts
#'
#' @description calculates the number of days with minimum temperatures
#' below zero in late spring 
#' (defined as certain months by the user) by site and year.
#' Additionally, it gives the average temperature of late frost days
#'
#' @param df_sites_min a data frame of minimum temperatures 
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords) 
#' @param years a vector with the period to calculate spring frost
#' @param late_spring a vector with the months considered as late spring. Default is 5 (May)
#'
#' @return a data frame with a row per sites and year.
#' In columns the number of late frost,
#' the mean of the minimum temperature of the days of late frost 
#' and the number of daily NAs
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
annual_late_frosts <- function(df_sites_min, years, late_spring = 5) {
  
  library(dplyr)
  library(tidyr)
  library(lubridate)
  
  ds <- data.frame(ndays = days_in_month(month(1 : 12))) %>% 
    add_row(ndays = 0, .before = 1) %>% 
    mutate(startday = cumsum(ndays) + 1,
           finday = c(startday[-1], 365) - 1) %>% 
    dplyr::select(startday, finday) %>% 
    slice(late_spring[1], late_spring[length(late_spring)])
  
  df_sites_min[,1 : 365][df_sites_min[, 1 : 365] <= -9999] <- NA
  colnames(df_sites_min)[1 : 365] <- 1 : 365
  
  frost <- df_sites_min %>%  
    filter(year %in% years) %>% 
    dplyr::select(ID, year, as.character(ds[1, 1] : ds[2 , 2])) %>% 
    pivot_longer(as.character(ds[1, 1] : ds[2, 2]),
                 names_to = "day", values_to = "tmin") %>% 
    mutate(month = month(as.Date(day, '%j'))) %>%
    mutate(event = ifelse(tmin < 0, 1, 0)) #NAs will be 0 
  
  frost2 <- frost %>% 
    filter(event == 1) %>% 
    group_by(ID, year) %>% 
    summarise(mean_frost = mean(tmin) / 100)
    
   frost3 <- frost %>% 
     group_by(ID, year) %>% 
     summarise(nas = sum(is.na(tmin)),
               n_frost = sum(event)) %>% 
     left_join(frost2, by = c("ID", "year")) %>% 
     ungroup()
  
  return(frost3)
  
}