
extract_varX <- function(in_df, varX_raster, varX="mat", buff_cor=NULL){
  df <- cbind(in_df[is.na(in_df[[varX]]),c("plotcode",'longitude','latitude')], 
              extract(varX_raster,
                      in_df[is.na(in_df[[varX]]),c("longitude","latitude")],
                      buffer=buff_cor, fun=mean))
  df <- as.data.frame(df)
  colnames(df) <- c("plotcode",'longitude','latitude', varX)
  return(df)
}

extract_mat_full <- function(country, in_df, mat_raster){
  mat_plots <- cbind(in_df[in_df$country==country,c('plotcode','country','longitude','latitude')], 
                           extract(mat_raster,
                                   in_df[in_df$country==country,c("longitude","latitude")]))
  colnames(mat_plots) <- c("plotcode",'country','longitude','latitude',"mat")
  
  if(nrow(mat_plots[is.na(mat_plots$mat),])>0){
    for(b in seq(from=5000, to=25000, by=5000)){
      print(b)
      tbl <- extract_varX(mat_plots, mat_raster, 'mat', buff_cor = b)
      mat_plots$mat[is.na(mat_plots$mat)] <- 
        tbl[match(mat_plots$plotcode[is.na(mat_plots$mat)], tbl$plotcode),c("mat")]
      
      n_na <- nrow(mat_plots[is.na(mat_plots$mat),])
      print(n_na)
      if(n_na ==0){
        b <- 30000
      }
    }
  }
  return(mat_plots)
}

extract_map_full <- function(country, in_df, map_raster){
  df_return <- cbind(in_df[in_df$country==country,c('plotcode','country','longitude','latitude')], 
                     extract(map_raster,
                             in_df[in_df$country==country,c("longitude","latitude")]))
  colnames(df_return) <- c("plotcode",'country','longitude','latitude', "map")
  
  if(nrow(df_return[is.na(df_return$map),])>0){
    for(b in seq(from=5000, to=25000, by=5000)){
      print(b)
      tbl <- extract_varX(df_return, map_raster, 'map', buff_cor = b)
      df_return$map[is.na(df_return$map)] <- 
        tbl[match(df_return$plotcode[is.na(df_return$map)], tbl$plotcode),c("map")]
      
      n_na <- nrow(df_return[is.na(df_return$map),])
      print(n_na)
      if(n_na ==0){
        b <- 30000
      }
    }
  }
  return(df_return)
}

extract_sgdd_full <- function(country, in_df, sgdd_raster){
  df_return <- cbind(in_df[in_df$country==country,c('plotcode','country','longitude','latitude')], 
                     extract(sgdd_raster,
                             in_df[in_df$country==country,c("longitude","latitude")]))
  colnames(df_return) <- c("plotcode",'country','longitude','latitude', "sgdd")
  
  if(nrow(df_return[is.na(df_return$sgdd),])>0){
    for(b in seq(from=5000, to=25000, by=5000)){
      print(b)
      tbl <- extract_varX(df_return, sgdd_raster, 'sgdd', buff_cor = b)
      df_return$sgdd[is.na(df_return$sgdd)] <- 
        tbl[match(df_return$plotcode[is.na(df_return$sgdd)], tbl$plotcode),c("sgdd")]
      
      n_na <- nrow(df_return[is.na(df_return$sgdd),])
      print(n_na)
      if(n_na ==0){
        b <- 30000
      }
    }
  }
  return(df_return)
}

extract_spring_frosts_full <- function(country, in_df, sf_raster){
  df_return <- cbind(in_df[in_df$country==country,c('plotcode','country','longitude','latitude')], 
                     extract(sf_raster,
                             in_df[in_df$country==country,c("longitude","latitude")]))
  colnames(df_return) <- c("plotcode",'country','longitude','latitude', "spring_frosts")
  
  if(nrow(df_return[is.na(df_return$spring_frosts),])>0){
    for(b in seq(from=5000, to=25000, by=5000)){
      print(b)
      tbl <- extract_varX(df_return, sf_raster, 'spring_frosts', buff_cor = b)
      df_return$spring_frosts[is.na(df_return$spring_frosts)] <- 
        tbl[match(df_return$plotcode[is.na(df_return$spring_frosts)], tbl$plotcode),c("spring_frosts")]
      
      n_na <- nrow(df_return[is.na(df_return$spring_frosts),])
      print(n_na)
      if(n_na ==0){
        b <- 30000
      }
    }
  }
  return(df_return)
}

extract_climate_variable_from_coords <- function(coords, climate_yearly_stack, 
                                                 stack_start_Year, stack_end_Year,
                                                 start_Year, end_Year){
  climate_extract <- extract(climate_yearly_stack, coords)
  if(is.na(climate_extract[1])){
    for(b in seq(from=5000, to=25000, by=5000)){
      climate_extract <- extract(climate_yearly_stack, coords, buffer=b, fun=mean)
      if(!is.na(climate_extract[1])){
        b <-30000
      }
    }
  }
  if(!is.na(climate_extract[1])){
    # take the mean of the survey period
    yearly_climate <- as.data.frame(cbind(as.vector(climate_extract), 
                                          as.vector(stack_start_Year:stack_end_Year)))
    colnames(yearly_climate) <- c('climate_extract','year')
    start_yr <- start_Year-2
    survey_period <- seq(start_yr, end_Year)
    
    return(mean(yearly_climate$climate_extract[yearly_climate$year %in% survey_period]))
  }
  return(NA)
}

extract_water_availablity_from_coords <- function(coords, pet_stack, prec_stack, start_Year, end_Year){
  
  pet <- extract(pet_stack, coords)
  prec <- extract(prec_stack, coords)
  if(is.na(prec[1])){
    for(b in seq(from=5000, to=25000, by=5000)){
      prec <- extract(prec_stack, coords, buffer=b, fun=mean)
      if(!is.na(prec[1])){
        b <-30000
      }
    }
  }
  monthly_wai <- as.data.frame(cbind(as.vector(pet), as.vector(prec)))
  colnames(monthly_wai) <- c("monthly_pet","monthly_prec")
  monthly_wai$wai <- (monthly_wai$monthly_prec-monthly_wai$monthly_pet)/monthly_wai$monthly_pet
  monthly_wai$ws <- monthly_wai$monthly_prec/monthly_wai$monthly_pet
  monthly_wai$year <- as.numeric(substr(names(s), 2, 5))
  monthly_wai$month <- as.numeric(substr(names(s), 7, length(names(s))))
  
  monthly_wai <- monthly_wai[monthly_wai$monthly_pet>0,]  
  survey_period <- seq(start_Year, end_Year)
  monthly_wai <- monthly_wai[monthly_wai$year %in% survey_period,]
  return(cbind(mean(monthly_wai$wai, na.rm=T), 
               mean(monthly_wai$ws[monthly_wai$month %in% c(6,7,8)], na.rm=T)))
}


extract_summer_water_stress_from_coords <- 
  function(coords, pet_stack, prec_stack, stack_start_Year, stack_end_Year, 
           start_Year, end_Year){
    
    pet <- extract(pet_stack, coords)
    prec <- extract(prec_stack, coords)
    if(is.na(prec[1])){
      for(b in seq(from=5000, to=25000, by=5000)){
        prec <- extract(prec_stack, coords, buffer=b, fun=mean)
        if(!is.na(prec[1])){
          b <-30000
        }
      }
    }
    summer_ws <- as.data.frame(cbind(as.vector(pet), as.vector(prec),
                                      as.vector(stack_start_Year:stack_end_Year)))
    colnames(summer_ws) <- c("pet","prec", "year")
    summer_ws$sws <- summer_ws$prec/summer_ws$pet
    summer_ws$p_pet <- summer_ws$prec-summer_ws$pet
    
    survey_period <- seq(start_Year, end_Year)
    summer_ws <- summer_ws[summer_ws$year %in% survey_period,]
    return(cbind(mean(summer_ws$sws, na.rm=T), mean(summer_ws$p_pet, na.rm=T)))
  }


extract_yearly_water_availablity_from_coords <- 
  function(coords, pet_stack, prec_stack, stack_start_Year, stack_end_Year, 
           start_Year, end_Year){
    
    pet <- extract(pet_stack, coords)
    prec <- extract(prec_stack, coords)
    if(is.na(prec[1])){
      for(b in seq(from=5000, to=25000, by=5000)){
        prec <- extract(prec_stack, coords, buffer=b, fun=mean)
        if(!is.na(prec[1])){
          b <-30000
        }
      }
    }
    yearly_wai <- as.data.frame(cbind(as.vector(pet), as.vector(prec),
                                      as.vector(stack_start_Year:stack_end_Year)))
    colnames(yearly_wai) <- c("pet","prec", "year")
    yearly_wai$wai <- (yearly_wai$prec-yearly_wai$pet)/yearly_wai$pet
    yearly_wai$p_pet <- yearly_wai$prec-yearly_wai$pet
    
    survey_period <- seq(start_Year, end_Year)
    yearly_wai <- yearly_wai[yearly_wai$year %in% survey_period,]
    return(cbind(mean(yearly_wai$wai, na.rm=T), mean(yearly_wai$p_pet, na.rm=T)))
  }


extract_spei_from_coords <- function(coords, spei_stack, start_yr, end_yr) {

  spei <- extract(spei_stack, coords)
  if(is.na(spei[1])){
    for(b in seq(from=5000, to=25000, by=5000)){
      spei <- extract(spei_stack, coords, buffer=b, fun=mean)
      if(!is.na(spei[1])){
        b <-30000
      }
    }
  }
  spei_df <- as.data.frame(as.vector(spei))
  colnames(spei_df) <- c("spei")
  spei_df$year <- as.numeric(substr(names(spei_stack), 2, 5))
  
  survey_period <- seq(start_yr-2, end_yr)
  spei_df <- spei_df[spei_df$year %in% survey_period,]
  
  return(mean(spei_df$spei, na.rm=T))
}

# sum the degrees over 5.5 in a year
sgdd_fun <- function(x){ 
  x[x < -80] <- NA; 
  x[!is.na(x)] <- x[!is.na(x)]-5.5;
  x[x < 0] <- 0; 
  return(x)
}

spring_frost_fun <- function(x){ 
  x[x < -8000] <- NA; 
  x[!is.na(x)] <- ifelse(x[!is.na(x)] < 100, 1, 0) 
  return(x)
}

