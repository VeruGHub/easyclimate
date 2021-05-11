#' Annual precipitation
#'
#' @description calculate annual precipitation from daily values.
#' for each year or across years if interannual_mean = TRUE. 
#' Additionally, it calculates annual precipitation anomaly
#' from a reference period if a reference period (years) is given
#'
#' @param df_sites a data frame with the days in columns
#'  and the sites in rows (output of extract_from_coords)
#' @param years a vector with the period to calculate annual precipitation
#' @param interannual_mean if TRUE calculates the mean 
#' interannual annual precipitation for each site for the selected years
#' Default = FALSE
#' @param ref period of reference (years) to calculate anomalies
#'
#' @return a data frame with a row per sites and year. 
#' In columns the annual precipitation and the number of daily NAs. 
#' Optionally the interannual mean precipitation 
#' and annual precipitation anomaly 
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
annual_prec <- function(df_sites, years,
                        interannual_mean = FALSE, ref = NA) {
  
  library(dplyr)
  library(tidyr)
  
  df_sites[, 1 : 365][df_sites[, 1 : 365] < 0] <- NA
  p <- df_sites %>%  
    filter(year %in% years) %>% 
    rowwise() %>% 
    mutate(anual = sum(c_across(d1 : d365), na.rm=TRUE),
           nas = sum(is.na(c_across(d1 : d365)))) %>%
    mutate(anual = anual / 100) %>% 
    arrange(year) %>% 
    dplyr::select(ID, year, anual, nas) 
  
  if (interannual_mean == TRUE) {
    p <- p %>% group_by(ID) %>%  
      mutate(manual = mean(anual, na.rm = TRUE))
  } 
  
  if (!is.na(ref[1])) {
    ref_p <- df_sites %>% 
      filter(year %in% ref) %>% 
      rowwise() %>%
      mutate(anual = ifelse(is.null(sum(c_across(d1 : d365))),
                            NA, sum(c_across(d1 : d365), na.rm = TRUE))) %>%
      group_by(ID) %>%  
      mutate(ref = mean(anual, na.rm = TRUE)) %>% 
      mutate(ref = ref / 100) %>% 
      slice(1) %>% 
      dplyr::select(ID, ref) 
    p <- p %>% 
      left_join(ref_p, by = "ID") %>% 
      mutate(dev = anual - ref) 
    
  } else {}
  
  return(p)
}