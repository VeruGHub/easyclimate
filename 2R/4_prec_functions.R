

library(tidyverse)

anual_prec <- function (raw, years, mean) {
  
  raw[raw<0] <- NA
  p <- raw %>%  
    filter(year %in% years) %>% 
    rowwise() %>% 
    mutate(anual=ifelse(is.null(sum(c_across(d1:d365))),NA, sum(c_across(d1:d365)))) %>%
    mutate(anual=anual/100) %>% 
    arrange(year) %>% 
    select(ID, year, anual) %>% 
    pivot_wider(names_from = year, values_from = anual)
  
  if (mean==TRUE) {
    return( p %>% rowwise() %>%  mutate(manual=mean(c_across(as.character(years)), na.rm=TRUE)))
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
anualifn1 <- anual_prec(prec_final, 1951:1960, mean=FALSE)
anualifn2 <- anual_prec(prec_final, 1961:1970, mean=FALSE)
anualifn3 <- anual_prec(prec_final, 1971:1980, mean=FALSE)
anualifn4 <- anual_prec(prec_final, 1981:1990, mean=FALSE)
anualifn5 <- anual_prec(prec_final, 1991:2000, mean=FALSE)
anualifn6 <- anual_prec(prec_final, 2001:2010, mean=FALSE)
anualifn7 <- anual_prec(prec_final, 2011:2017, mean=FALSE)

anualifn <- anualifn1 %>% 
  left_join(anualifn2) %>% 
  left_join(anualifn3) %>% 
  left_join(anualifn4) %>% 
  left_join(anualifn5) %>% 
  left_join(anualifn6) %>% 
  left_join(anualifn7) %>% 
  rowwise() %>%  
  mutate(manual=mean(c_across(`1951`:`2017`), na.rm=TRUE))

write_csv(anualifn, "3results/anual_prec.csv")

#Comparación para precipitación entre Moreno y Gonzalo
mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

anualifn %>% 
  dplyr::select(ID, manual) %>% 
  left_join(dplyr::select(mypoints, Plotcode, PREC_ANUAL, Provincia3), by=c("ID"="Plotcode")) %>%
  mutate(CA=ifelse(Provincia3 %in% c(1,20,48), "Pais Vasco",
                   ifelse(Provincia3 %in% c(6,10), "Extremadura", 
                          ifelse(Provincia3 %in% c(8,17,25,43), "Cataluña",
                                 ifelse(Provincia3 %in% c(15,27,32,36), "Galicia",
                                        ifelse(Provincia3==28, "Madrid",
                                               ifelse(Provincia3==30, "Murcia", "La Rioja"))))))) %>% 
  ggplot() +
  geom_point(aes(x=PREC_ANUAL, y=manual, color=factor(CA)), size=0.5) +
  geom_abline(slope=1, intercept=0) +
  ylab("Moreno") + xlab("Gonzalo")
  
  



