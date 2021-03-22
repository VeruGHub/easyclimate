#' Annual growing degree days
#'
#' @description calculates the number of degree days by site and year
#'
#' @param df_sites_min a data frame of minimum temperatures 
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords)
#' @param df_sites_max a data frame of minimum temperatures 
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords)
#' @param years a vector with the period to calculate 
#' annual growing degree days
#' @param threshold temperature (ºC) above which a day
#'  will be considered a growing degree day. Default is 10.
#'
#' @return a data frame with a row per point and year. 
#' In columns the number of degree days and the number of daily NAs
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso, Paloma Ruiz-Benito
#' 
annual_degree_days <- function(df_sites_min, df_sites_max, years, threshold = 5.5) {
  
  library(dplyr)
  library(tidyr)
  
  df_sites_min[, 1 : 365][df_sites_min[, 1 : 365] <= -9999] <- NA
  df_sites_max[, 1 : 365][df_sites_max[, 1 : 365] <= -9999] <- NA
  
  raw_mean <- (dplyr::select(df_sites_max, d1 : d365) + 
                 dplyr::select(df_sites_min, d1 : d365))/2
  raw_mean <- cbind(raw_mean, df_sites_min[, c("year","long","lat","ID","tile")])
  colnames(raw_mean)[1 : 365] <- 1 : 365
  
  deg <- raw_mean %>% 
    filter(year %in% years) %>% 
    pivot_longer(1 : 365, names_to = "day", values_to = "tmean") %>% 
    mutate(tmean = tmean / 100,
           event = ifelse(tmean > threshold, 1, 0), #NAs will be 0  
           start = c(1, diff(event) != 0)) %>% 
    group_by(year, ID) %>%
    mutate(run = cumsum(start)) 
  
  deg2 <- deg %>% 
    filter(event == 1) %>% 
    group_by(year, ID, run) %>%
    summarise(nas = sum(is.na(tmean)),
              deg_days = sum(event)) %>% 
    group_by(year, ID) %>% 
    summarise(nas = sum(nas),
              deg_days = max(deg_days)) %>% 
    complete(ID, year, fill = list(deg_days = 0))
  
  return(deg2)
  
}
