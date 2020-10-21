

library(tidyverse)

####1-ANUAL PRECIPITATION####

annual_prec <- function (raw, years, mean) {
  
  raw[,1:365][raw[,1:365]<0] <- NA
  p <- raw %>%  
    filter(year %in% years) %>% 
    rowwise() %>% 
    mutate(anual=sum(c_across(d1:d365), na.rm=TRUE),
           nas=sum(is.na(c_across(d1:d365)))) %>%
    mutate(anual=anual/100) %>% 
    arrange(year) %>% 
    select(ID, year, anual, nas) 
    # pivot_wider(names_from = year, values_from = anual)
  
  if (mean==TRUE) {
    return( p %>% group_by(ID) %>%  mutate(manual=mean(anual, na.rm=TRUE)))
  } else {return(p)}

}

#Ejemplo con datos del IFN
load("C:/Users/veruk/Desktop/Disco/easyclimate/3results/prcp_IFN234.RData")

nas <- prec_final %>% #Plots de la costa; -32768 viene de datos a partir de 2013
  filter(across(d1:d365)<0) 

ggplot(data = map_data("world", region = c("Spain","Portugal"))) + 
  geom_polygon(aes(x = long, y = lat, group = group), fill = "white", color = "black") + 
  coord_fixed(1.3) +
  geom_point(data=nas, aes(x=long, y=lat, color=factor(d1))) 


#No me lo hace de una vez porque no tengo memoria ram suficiente
anualifn1 <- annual_prec(prec_final, 1951:1960, mean=FALSE)
anualifn2 <- annual_prec(prec_final, 1961:1970, mean=FALSE)
anualifn3 <- annual_prec(prec_final, 1971:1980, mean=FALSE)
anualifn4 <- annual_prec(prec_final, 1981:1990, mean=FALSE)
anualifn5 <- annual_prec(prec_final, 1991:2000, mean=FALSE)
anualifn6 <- annual_prec(prec_final, 2001:2010, mean=FALSE)
anualifn7 <- annual_prec(prec_final, 2011:2017, mean=FALSE)

anualifn <- anualifn1 %>% 
  bind_rows(anualifn2, anualifn3, anualifn4, anualifn5,
            anualifn6, anualifn7) %>% 
  group_by(ID) %>% 
  mutate(manual=mean(anual, na.rm=TRUE),
         manual_gonz= mean(filter(., year %in% 1970:2000)$anual, na.rm=TRUE))

write_csv(anualifn, "3results/anual_prec.csv")

#Comparación para precipitación entre Moreno y Gonzalo
mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

anualifn %>% 
  dplyr::select(ID, manual_gonz) %>% 
  group_by(ID) %>% 
  slice(1) %>% 
  left_join(dplyr::select(mypoints, Plotcode, PREC_ANUAL, Provincia3), by=c("ID"="Plotcode")) %>%
  mutate(CA=ifelse(Provincia3 %in% c(1,20,48), "Pais Vasco",
                   ifelse(Provincia3 %in% c(6,10), "Extremadura", 
                          ifelse(Provincia3 %in% c(8,17,25,43), "Cataluña",
                                 ifelse(Provincia3 %in% c(15,27,32,36), "Galicia",
                                        ifelse(Provincia3==28, "Madrid",
                                               ifelse(Provincia3==30, "Murcia", "La Rioja"))))))) %>% 
  ggplot() +
  geom_point(aes(x=PREC_ANUAL, y=manual_gonz, color=factor(CA)), size=0.5) +
  geom_abline(slope=1, intercept=0) +
  ylab("Moreno") + xlab("Gonzalo")
  

####2-MONTH PRECIPITATION####

library(lubridate)

month_prec <- function (raw, years, months) {
  
  ds <- data.frame(ndays=days_in_month(month(1:12))) %>% 
    add_row(ndays=0, .before = 1) %>% 
    mutate(startday=cumsum(ndays)+1,
           finday=c(startday[-1],365)-1) %>% 
    select(startday, finday) %>% 
    slice(months[1],months[length(months)])

  raw[,1:365][raw[,1:365]<0] <- NA
  colnames(raw)[1:365] <- 1:365
  
  p <- raw %>%  
    filter(year %in% years) %>% 
    select(ID, year, as.character(ds[1,1]:ds[2,2])) %>% 
    pivot_longer(as.character(ds[1,1]:ds[2,2]), names_to = "day", values_to = "prec") %>% 
    mutate(month=month(as.Date(paste(year, day), '%Y %j'))) %>% 
    group_by(ID, year, month) %>% 
    summarise(monthly=ifelse(is.null(sum(prec)),NA, sum(prec, na.rm=TRUE)),
              nas=sum(is.na(prec))) %>%
    mutate(monthly=monthly/100) 
    # arrange(year) %>% 
    # pivot_wider(names_from = year, values_from = monthly)
  
  return(p)
  
}

#Ejemplo con datos del IFN
monthifn1 <- month_prec(prec_final, 1951:1960, 1:12)
monthifn2 <- month_prec(prec_final, 1961:1970, 1:12)
monthifn3 <- month_prec(prec_final, 1971:1980, 1:12)
monthifn4 <- month_prec(prec_final, 1981:1990, 1:12)
monthifn5 <- month_prec(prec_final, 1991:2000, 1:12)
monthifn6 <- month_prec(prec_final, 2001:2010, 1:12)
monthifn7 <- month_prec(prec_final, 2011:2017, 1:12)

monthifn <- monthifn1 %>% 
  rbind(monthifn2) %>% 
  rbind(monthifn3) %>% 
  rbind(monthifn4) %>% 
  rbind(monthifn5) %>% 
  rbind(monthifn6) %>% 
  rbind(monthifn7) %>% 
  group_by(ID, month) %>% 
  mutate(mmonth=mean(monthly, na.rm=TRUE))

write_csv(monthifn, "3results/month_prec.csv")

