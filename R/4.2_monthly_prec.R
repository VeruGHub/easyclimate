#' Monthly precipitation
#'
#' @description calculate monthly precipitation from daily values
#'
#' @param df_sites a data frame with the days in columns 
#' and the sites in rows (output of extract_from_coords)
#' @param years a vector with the period to calculate monthly precipitation
#' @param months a numeric vector including values from 1 to 12
#'
#' @return a data frame with a row per sites, year and month. 
#' In columns the monthly precipitation and the number of daily NAs
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
monthly_prec <- function(df_sites, years, months) {
  
  library(dplyr)
  library(tidyr)
  library(lubridate)
  
  ds <- data.frame(ndays = days_in_month(month(1 : 12))) %>% #Day limits for the selected months
    add_row(ndays = 0, .before = 1) %>% 
    mutate(startday = cumsum(ndays) + 1,
           finday = c(startday[-1], 365) - 1) %>% 
    dplyr::select(startday, finday) %>% 
    slice(months[1], months[length(months)])
  
  df_sites[, 1 : 365][df_sites[, 1 : 365] < 0] <- NA
  colnames(df_sites)[1 : 365] <- 1 : 365
  
  p <- df_sites %>%  
    filter(year %in% years) %>% 
    dplyr::select(ID, year, as.character(ds[1, 1] : ds[2, 2])) %>% 
    pivot_longer(as.character(ds[1, 1] : ds[2, 2]),
                 names_to = "day", values_to = "prec") %>% 
    mutate(month = month(as.Date(day, '%j'))) %>% 
    group_by(ID, year, month) %>% 
    summarise(monthly = ifelse(is.null(sum(prec)),
                               NA, sum(prec, na.rm = TRUE)),
              nas = sum(is.na(prec))) %>%
    mutate(monthly = monthly / 100) 
  
  return(p)
  
}