
library(tidyverse)

mypoints <- read_csv(file = "1raw/example_plot_clima_pedroTFM.csv", col_names = TRUE)

summary(mypoints)

subset1 <- mypoints %>% 
  filter(Provincia4 %in% c("15")) %>% 
  slice(sample(1:275, size=50))
subset2 <- mypoints %>% 
  filter(Provincia4 %in% c("30")) %>% 
  slice(sample(1:1012, size=50))

subset <- subset1 %>% 
  bind_rows(subset2) %>% 
  select(Provincia4, CX, CY) %>% 
  rename(Region=Provincia4)

write_delim(x = subset, file = "0aux/example.csv", delim = ";")

#Actualizar con cambios que ha hecho Paloma


