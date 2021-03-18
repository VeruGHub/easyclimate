#' Annual dry waves
#'
#' @description identifies the number of consecutive days 
#' without precipitation and summarises them as the 
#' maximum and mean number of days by site and year, 
#' and number of events longer than a threshold selected by the user
#'
#' @param df_sites a data frame with the days in columns and 
#' the sites in rows (output of extract_from_coords)
#' @param years a vector with the period to calculate 
#' the length of consecutive days without precipitation
#' @param threshold threshold to count extreme long events of
#'  days without precipitation. Default is 10
#'
#' @return a data frame with a row per sites and year. 
#' In columns the maximum and mean number of consecutive days
#' without precipitation, and the number dry waves 
#' along the year and the number of daily NAs
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
annual_dry_waves <- function(df_sites, years, threshold = 10) {
  
  library(dplyr)
  library(tidyr)
  
  df_sites[, 1 : 365][df_sites[, 1 : 365] < 0] <- NA
  colnames(df_sites)[1 : 365] <- 1 : 365
  
  p <- df_sites %>%  
    filter(year %in% years) %>% 
    pivot_longer(1 : 365, names_to = "day", values_to = "prec") %>% 
    mutate(event = ifelse(prec == 0, 1, 0), #NAs will be 0 
           start = c(1, diff(event) != 0)) %>% 
    group_by(ID, year) %>% 
    mutate(run = cumsum(start),
           nas = sum(is.na(prec))) %>% 
    filter(event == 1) %>% 
    group_by(ID, year, nas, run) %>% 
    summarise(length = n()) %>% 
    group_by(ID, year, nas) %>% 
    summarise(max_noprec = max(length),
              mean_noprec = mean(length),
              nevents = sum(length > threshold))
  
  return(p)
  
}
