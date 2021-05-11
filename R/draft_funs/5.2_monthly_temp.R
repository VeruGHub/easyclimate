#' Monthly temperature
#'
#' @description calculates mean temperatures per month, year and site
#'
#' @param df_sites_min a data frame of minimum temperatures 
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords)
#' @param df_sites_max a data frame of maximum temperatures
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords)
#' @param years a vector with the period to calculate month temperatures
#' @param months a vector with the a numeric vector 
#' including values from 1 to 12
#'
#' @return a data frame with a row per sites, year and month.
#' In columns the monthly temperature and the number of daily NAs
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
monthly_temp <- function(df_sites_min, df_sites_max,
                       years, months) {
  
  library(dplyr)
  library(tidyr)
  library(lubridate)
  
  ds <- data.frame(ndays = days_in_month(month(1 : 12))) %>% 
    add_row(ndays = 0, .before = 1) %>% 
    mutate(startday = cumsum(ndays) + 1,
           finday = c(startday[-1], 365) - 1) %>% 
    dplyr::select(startday, finday) %>% 
    slice(months[1], months[length(months)])
  
  df_sites_min[, 1 : 365][df_sites_min[,1 : 365] <= -9999] <- NA
  df_sites_max[, 1 : 365][df_sites_max[,1 : 365] <= -9999] <- NA
  
  raw_mean <- (dplyr::select(df_sites_max, 1 : 365) +
                 dplyr::select(df_sites_min, 1 : 365)) / 2
  raw_mean <- cbind(raw_mean, 
                    df_sites_min[, c("year", "long", "lat", "ID", "tile")])
  colnames(raw_mean)[1 : 365] <- 1 : 365
  
  tmean <- raw_mean %>% 
    filter(year %in% years) %>% 
    dplyr::select(ID, year, as.character(ds[1, 1] : ds[2, 2])) %>% 
    pivot_longer(as.character(ds[1, 1] : ds[2, 2]), 
                 names_to = "day", values_to = "tmean") %>% 
    mutate(month = month(as.Date(day, '%j'))) %>% 
    group_by(ID, year, month) %>% 
    summarise(monthly = ifelse(is.null(mean(tmean, na.rm = TRUE)),
                               NA, mean(tmean, na.rm = TRUE)),
              nas = sum(is.na(tmean))) %>%
    mutate(monthly = monthly/100) 
  
  return(tmean)
  
}