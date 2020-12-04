

library(tidyverse)

####1-AVERAGE ANUAL TEMPERATURE####

# -raw_min: a data.frame of minimum temperatures with the days in columns and the locations 
# in rows (output of extract_from_coords)
# -raw_max: a data.frame of maximum temperatures with the days in columns and the locations 
# in rows (output of extract_from_coords)
# -years: period to calculate anual precipitation
# -mean=TRUE: it calculates the mean temperature for each location
# -vars: variables to be calculated (min, max, mean)


average_temp <- function (raw_min, raw_max, years, mean, vars) {
  
  raw_min[,1:365][raw_min[,1:365]<0] <- NA
  raw_max[,1:365][raw_max[,1:365]<0] <- NA
  
  if ("min" %in% vars) {
    
    tmin <- raw_min %>% #En tmin puede haber NAs en dias concretos para un punto dado -- hay que poner na.rm=TRUE
      filter(year %in% years) %>% 
      rowwise() %>%
      mutate(anual=ifelse(is.null(mean(c_across(d1:d365))),NA, mean(c_across(d1:d365), na.rm=TRUE)),
             nas=sum(is.na(c_across(d1:d365)))) %>%
      mutate(anual=anual/100) %>% 
      arrange(year) %>% 
      select(ID, year, anual, nas) 
      # pivot_wider(names_from = year, values_from = anual)
    
    if (mean==TRUE) {
      tmin <- tmin %>% group_by(ID) %>%  mutate(manual=mean(anual, na.rm=TRUE))
    }
    
    }else{ tmin <- NA
    
  } 
  
  if ("max" %in% vars) {
    
    tmax <- raw_max %>% 
      filter(year %in% years) %>% 
      rowwise() %>%
      mutate(anual=ifelse(is.null(mean(c_across(d1:d365))),NA, mean(c_across(d1:d365), na.rm=TRUE)),
             nas=sum(is.na(c_across(d1:d365)))) %>%
      mutate(anual=anual/100) %>% 
      arrange(year) %>% 
      select(ID, year, anual, nas) 
      # pivot_wider(names_from = year, values_from = anual)
    
    if (mean==TRUE) {
      tmax <- tmax %>% group_by(ID) %>%  mutate(manual=mean(anual, na.rm=TRUE))
    }
    
  }else{ tmax <- NA
    
  } 
  
  if ("mean" %in% vars) {
    
    raw_mean <- (select(raw_max, d1:d365) + select(raw_min, d1:d365))/2
    raw_mean <- cbind(raw_mean, raw_min[,c("year","long","lat","ID","tile")])
    
    tmean <- raw_mean %>% 
      filter(year %in% years) %>% 
      rowwise() %>%
      mutate(anual=ifelse(is.null(mean(c_across(d1:d365))),NA, mean(c_across(d1:d365), na.rm=TRUE)),
             nas=sum(is.na(c_across(d1:d365)))) %>%
      mutate(anual=anual/100) %>% 
      arrange(year) %>% 
      select(ID, year, anual, nas) 
      # pivot_wider(names_from = year, values_from = anual)
    
    if (mean==TRUE) {
      tmean <- tmean %>% group_by(ID) %>%  mutate(manual=mean(anual, na.rm=TRUE))
    }
    
  }else{ tmean <- NA
    
  } 
  
  return(list(tmin, tmax, tmean))
  
}

####SIN PROBAR
#Ejemplo con datos del IFN
# load("C:/Users/veruk/Desktop/Disco/easyclimate/3results/tmin_IFN234.RData")
# load("C:/Users/veruk/Desktop/Disco/easyclimate/3results/tmax_IFN234.RData")
# 
# nas <- tmin_final %>% 
#   filter(across(d1:d365)<0) 
# 
# ggplot(data = map_data("world", region = c("Spain","Portugal"))) + 
#   geom_polygon(aes(x = long, y = lat, group = group), fill = "white", color = "black") + 
#   coord_fixed(1.3) +
#   geom_point(data=nas, aes(x=long, y=lat, color=factor(d1))) 

#No me lo hace de una vez porque no tengo memoria ram suficiente
#Para un periodo tampoco me calcula min, max y mean a la vez
# anualifn1 <- average_temp(raw_min=tmin_final, raw_max=tmax_final, 
#                           years=1951:1952, mean=TRUE, vars=c("mean"))
# anualifn2 <- average_temp(tmin_final, tmax_final, 
#                           1961:1970, mean=TRUE, vars=c("min","max","mean"))
# anualifn3 <- average_temp(tmin_final, tmax_final, 
#                           1971:1980, mean=TRUE, vars=c("min","max","mean"))
# anualifn4 <- average_temp(tmin_final, tmax_final, 
#                           1981:1990, mean=TRUE, vars=c("min","max","mean"))
# anualifn5 <- average_temp(tmin_final, tmax_final, 
#                           1991:2000, mean=TRUE, vars=c("min","max","mean"))
# anualifn6 <- average_temp(tmin_final, tmax_final, 
#                           2001:2010, mean=TRUE, vars=c("min","max","mean"))
# anualifn7 <- average_temp(tmin_final, tmax_final, 
#                           2011:2017, mean=TRUE, vars=c("min","max","mean"))


####2-MEAN MONTHLY TEMPERATURE####

library(lubridate)

# -raw_min: a data.frame of minimum temperatures with the days in columns and the locations 
# in rows (output of extract_from_coords)
# -raw_max: a data.frame of maximum temperatures with the days in columns and the locations 
# in rows (output of extract_from_coords)
# -years: period to calculate month temperatures
# -months: a numeric vector including values from 1 to 12

month_temp <- function (raw_min, raw_max, years, months) {
  
  ds <- data.frame(ndays=days_in_month(month(1:12))) %>% 
    add_row(ndays=0, .before = 1) %>% 
    mutate(startday=cumsum(ndays)+1,
           finday=c(startday[-1],365)-1) %>% 
    select(startday, finday) %>% 
    slice(months[1],months[length(months)])
  
  raw_min[,1:365][raw_min[,1:365]<0] <- NA
  raw_max[,1:365][raw_max[,1:365]<0] <- NA
  
  raw_mean <- (select(raw_max, 1:365) + select(raw_min, 1:365))/2
  raw_mean <- cbind(raw_mean, raw_min[,c("year","long","lat","ID","tile")])
  colnames(raw_mean)[1:365] <- 1:365
  
  tmean <- raw_mean %>% 
    filter(year %in% years) %>% 
    select(ID, year, as.character(ds[1,1]:ds[2,2])) %>% 
    pivot_longer(as.character(ds[1,1]:ds[2,2]), names_to = "day", values_to = "tmean") %>% 
    mutate(month=month(as.Date(paste(year, day), '%Y %j'))) %>% 
    group_by(ID, year, month) %>% 
    summarise(monthly=ifelse(is.null(mean(tmean, na.rm=TRUE)),NA, mean(tmean, na.rm=TRUE)),
              nas=sum(is.na(tmean))) %>%
    mutate(monthly=monthly/100) 
    # arrange(year) %>% 
    # pivot_wider(names_from = year, values_from = monthly)
  
  return(tmean)
  
}

#Ejemplo con datos del IFN
load("C:/Users/veruk/Desktop/Disco/easyclimate/3results/tmin_IFN234.RData")
load("C:/Users/veruk/Desktop/Disco/easyclimate/3results/tmax_IFN234.RData")

tmonth1 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                          years=1951:1960, months=1:12)
tmonth2 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                      years=1961:1970, months=1:12)
tmonth3 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                      years=1971:1980, months=1:12)
tmonth4 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                      years=1981:1990, months=1:12)
tmonth5 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                      years=1991:2000, months=1:12)
tmonth6 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                      years=2001:2010, months=1:12)
tmonth7 <- month_temp(raw_min=tmin_final, raw_max=tmax_final, 
                      years=2011:2017, months=1:12)

tmonth <- tmonth1 %>% 
  bind_rows(tmonth2, tmonth3, tmonth4, tmonth5, tmonth6, tmonth7) %>% 
  group_by(ID, month) %>% 
  mutate(mmonth=mean(monthly, na.rm=TRUE))

write_csv(tmonth, "3results/month_meantemp.csv")

