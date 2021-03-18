#' Annual temperature
#'
#' @description calculates yearly mean, maximum and minimum temperatures
#' for each year or across years if interannual_mean = TRUE. 
#' Additionally, it calculates the anomalies of mean temperatures 
#' from a reference period if a reference period (years) is given
#'
#' @param df_sites_min a data frame of minimum temperatures
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords)
#' @param df_sites_max a data frame of maximum temperatures 
#' with the days in columns and the sites in rows 
#' (output of extract_from_coords)
#' @param years a vector with the period to calculate annual temperature
#' @param interannual_mean if TRUE calculates the mean 
#' interannual temperature for each site.
#' Default = FALSE
#' @param ref a vector with the period of reference (years)
#' to calculate anomalies
#' @param temp_vars a vector with the variables 
#' to be calculated (min, max, mean)
#'
#' @return a list containing as many data frames as 
#' temperature variables are specified (min, max, mean). 
#' Each data frame has a row per site and year. 
#' In columns the annual temperature and the number of daily NAs. 
#' Optionally the interannual mean temperature and annual temperature anomaly 
#' @export
#'
#' @examples
#' 
#' @author Veronica Cruz-Alonso
#' 
annual_temp <- function(df_sites_min, df_sites_max, years,
                         interannual_mean = FALSE, ref = NA,
                         temp_vars) {
  
  library(dplyr)
  library(tidyr)
  
  df_sites_min[, 1 : 365][df_sites_min[,1 : 365] <= -9999] <- NA
  df_sites_max[, 1 : 365][df_sites_max[,1 : 365] <= -9999] <- NA
  
  if ("min" %in% temp_vars) {
    
    tmin <- df_sites_min %>% #En tmin puede haber NAs en dias concretos para un punto dado -- hay que poner na.rm=TRUE
      filter(year %in% years) %>% 
      rowwise() %>%
      mutate(anual = ifelse(is.null(mean(c_across(d1 : d365))),
                            NA, mean(c_across(d1 : d365), na.rm = TRUE)),
             nas = sum(is.na(c_across(d1 : d365)))) %>%
      mutate(anual = anual / 100) %>% 
      arrange(year) %>% 
      dplyr::select(ID, year, anual, nas) 
    
    if (interannual_mean==TRUE) {
      tmin <- tmin %>%
        group_by(ID) %>% 
        mutate(manual = mean(anual, na.rm = TRUE))
    }
    
    if (!is.na(ref[1])) {
      ref_tmin <- df_sites_min %>% 
        filter(year %in% ref) %>% 
        rowwise() %>%
        mutate(anual = ifelse(is.null(mean(c_across(d1 : d365))),
                              NA, mean(c_across(d1 : d365), na.rm = TRUE))) %>%
        group_by(ID) %>%  
        mutate(ref = mean(anual, na.rm = TRUE)) %>% 
        mutate(ref = ref / 100) %>% 
        slice(1) %>% 
        dplyr::select(ID, ref) 
      tmin <- tmin %>% 
        left_join(ref_tmin, by = "ID") %>% 
        mutate(dev = anual - ref)
    }
    
  }else{ tmin <- NA
  
  } 
  
  if ("max" %in% temp_vars) {
    
    tmax <- df_sites_max %>% 
      filter(year %in% years) %>% 
      rowwise() %>%
      mutate(anual = ifelse(is.null(mean(c_across(d1 : d365))),
                            NA, mean(c_across(d1 : d365), na.rm = TRUE)),
             nas = sum(is.na(c_across(d1 : d365)))) %>%
      mutate(anual = anual / 100) %>% 
      arrange(year) %>% 
      dplyr::select(ID, year, anual, nas) 
    
    if (interannual_mean == TRUE) {
      tmax <- tmax %>%
        group_by(ID) %>% 
        mutate(manual = mean(anual, na.rm = TRUE))
    }
    
    if (!is.na(ref[1])) {
      ref_tmax <- df_sites_max %>% 
        filter(year %in% ref) %>% 
        rowwise() %>%
        mutate(anual = ifelse(is.null(mean(c_across(d1 : d365))),
                              NA, mean(c_across(d1 : d365), na.rm = TRUE))) %>%
        group_by(ID) %>%  
        mutate(ref = mean(anual, na.rm = TRUE)) %>% 
        mutate(ref = ref / 100) %>% 
        slice(1) %>% 
        dplyr::select(ID, ref) 
      tmax <- tmax %>% 
        left_join(ref_tmax, by = "ID") %>% 
        mutate(dev = anual - ref)
    }
    
  }else{ tmax <- NA
  
  } 
  
  if ("mean" %in% temp_vars) {
    
    raw_mean <- (dplyr::select(df_sites_max, d1 : d365) +
                   dplyr::select(df_sites_min, d1 : d365)) / 2
    raw_mean <- cbind(raw_mean,
                      df_sites_min[, c("year", "long", "lat", "ID", "tile")])
    
    tmean <- raw_mean %>% 
      filter(year %in% years) %>% 
      rowwise() %>%
      mutate(anual = ifelse(is.null(mean(c_across(d1 : d365))),
                            NA, mean(c_across(d1 : d365), na.rm = TRUE)),
             nas = sum(is.na(c_across(d1 : d365)))) %>%
      mutate(anual = anual / 100) %>% 
      arrange(year) %>% 
      dplyr::select(ID, year, anual, nas) 
    
    if (interannual_mean == TRUE) {
      tmean <- tmean %>% 
        group_by(ID) %>% 
        mutate(manual = mean(anual, na.rm = TRUE))
    }
    
    if (!is.na(ref[1])) {
      ref_tmean <- raw_mean %>% 
        filter(year %in% ref) %>% 
        rowwise() %>%
        mutate(anual = ifelse(is.null(mean(c_across(d1 : d365))),
                              NA, mean(c_across(d1 : d365),
                                       na.rm = TRUE))) %>%
        group_by(ID) %>%  
        mutate(ref = mean(anual, na.rm = TRUE)) %>% 
        mutate(ref = ref / 100) %>% 
        slice(1) %>% 
        dplyr::select(ID, ref) 
      tmean <- tmean %>% 
        left_join(ref_tmean, by = "ID") %>% 
        mutate(dev = anual - ref)
    }
    
  }else{ tmean <- NA
  
  } 
  
  final <- list(tmin, tmax, tmean)
  names(final) <- c("min", "max", "mean")
  return(final)
  
}