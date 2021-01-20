
setwd("~/Documents/Projects/sAPROPOS/data")

library(raster)

finland <- c('H_1','I_1','H_2','I_2','J_2','H_3','I_3','J_3','H_4')
H_1 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/H_1/Prcp1983_H_1.tif")[[1]])
I_1 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/I_1/Prcp1983_I_1.tif")[[1]])
H_2 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/H_2/Prcp1983_H_2.tif")[[1]])
I_2 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/I_2/Prcp1983_I_2.tif")[[1]])
J_2 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/J_2/Prcp1983_J_2.tif")[[1]])
H_3 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/H_3/Prcp1983_H_3.tif")[[1]])
I_3 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/I_3/Prcp1983_I_3.tif")[[1]])
J_3 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/J_3/Prcp1983_J_3.tif")[[1]])
H_4 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/finland/H_4/Prcp1983_H_4.tif")[[1]])

tile_extents <- rbind(cbind(H_1[1],H_1[2],H_1[3],H_1[4],"H_1"), cbind(I_1[1],I_1[2],I_1[3],I_1[4],"I_1"), 
                      cbind(H_2[1],H_2[2],H_2[3],H_2[4],"H_2"), cbind(I_2[1],I_2[2],I_2[3],I_2[4],"I_2"), 
                      cbind(J_2[1],J_2[2],J_2[3],J_2[4],"J_2"), cbind(H_3[1],H_3[2],H_3[3],H_3[4],"H_3"),
                      cbind(I_3[1],I_3[2],I_3[3],I_3[4],"I_3"), cbind(J_3[1],J_3[2],J_3[3],J_3[4],"J_3"),
                      cbind(H_4[1],H_4[2],H_4[3],H_4[4],"H_4"))

Sweden <- c('G_1','F_2','G_2','F_3','G_3','E_4','F_4','G_4','F_5','G_5')
G_1 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/G_1/Prcp2006_G_1.tif")[[1]])
F_2 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/F_2/Prcp2006_F_2.tif")[[1]])
G_2 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/G_2/Prcp2006_G_2.tif")[[1]])
F_3 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/F_3/Prcp2006_F_3.tif")[[1]])
G_3 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/G_3/Prcp2006_G_3.tif")[[1]])
E_4 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/E_4/Prcp2006_E_4.tif")[[1]])
F_4 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/F_4/Prcp2006_F_4.tif")[[1]])
G_4 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/G_4/Prcp2006_G_4.tif")[[1]])
F_5 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/F_5/Prcp2006_F_5.tif")[[1]])
G_5 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/sweden/G_5/Prcp2006_G_5.tif")[[1]])

tile_extents <- rbind(tile_extents,
                      cbind(G_1[1],G_1[2],G_1[3],G_1[4],"G_1"), cbind(F_2[1],F_2[2],F_2[3],F_2[4],"F_2"), 
                      cbind(G_2[1],G_2[2],G_2[3],G_2[4],"G_2"), cbind(F_3[1],F_3[2],F_3[3],F_3[4],"F_3"), 
                      cbind(G_3[1],G_3[2],G_3[3],G_3[4],"G_3"), cbind(E_4[1],E_4[2],E_4[3],E_4[4],"E_4"),
                      cbind(F_4[1],F_4[2],F_4[3],F_4[4],"F_4"), cbind(G_4[1],G_4[2],G_4[3],G_4[4],"G_4"),
                      cbind(F_5[1],F_5[2],F_5[3],F_5[4],"F_5"), cbind(G_5[1],G_5[2],G_5[3],G_5[4],"G_5"))

france <- c('B_6','B_7','C_6','C_7','C_8','D_6','D_7','D_8','E_7','E_8','E_9')
B_6 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/B_6/Prcp2008_B_6.tif")[[1]])
B_7 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/B_7/Prcp2008_B_7.tif")[[1]])
C_6 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/C_6/Prcp2008_C_6.tif")[[1]])
C_7 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/C_7/Prcp2008_C_7.tif")[[1]])
C_8 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/C_8/Prcp2008_C_8.tif")[[1]])
D_6 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/D_6/Prcp2008_D_6.tif")[[1]])
D_7 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/D_7/Prcp2008_D_7.tif")[[1]])
D_8 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/D_8/Prcp2008_D_8.tif")[[1]])
E_7 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/E_7/Prcp2008_E_7.tif")[[1]])
E_8 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/E_8/Prcp2008_E_8.tif")[[1]])
E_9 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/france_data/E_9/Prcp2008_E_9.tif")[[1]])

tile_extents <- rbind(tile_extents,
                      cbind(B_6[1],B_6[2],B_6[3],B_6[4],"B_6"), cbind(B_7[1],B_7[2],B_7[3],B_7[4],"B_7"), 
                      cbind(C_6[1],C_6[2],C_6[3],C_6[4],"C_6"), cbind(C_7[1],C_7[2],C_7[3],C_7[4],"C_7"), 
                      cbind(C_8[1],C_8[2],C_8[3],C_8[4],"C_8"), cbind(D_6[1],D_6[2],D_6[3],D_6[4],"D_6"),
                      cbind(D_7[1],D_7[2],D_7[3],D_7[4],"D_7"), cbind(D_8[1],D_8[2],D_8[3],D_8[4],"D_8"), 
                      cbind(E_7[1],E_7[2],E_7[3],E_7[4],"E_7"), cbind(E_8[1],E_8[2],E_8[3],E_8[4],"E_8"), 
                      cbind(E_9[1],E_9[2],E_9[3],E_9[4],"E_9"))

Germany <- c('E_5','E_6','F_6','F_7')
E_5 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/germany/E_5/Prcp1991_E_5.tif")[[1]])
E_6 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/germany/E_6/Prcp1991_E_6.tif")[[1]])
F_6 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/germany/F_6/Prcp1991_F_6.tif")[[1]])
F_7 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/germany/F_7/Prcp1991_F_7.tif")[[1]])

tile_extents <- rbind(tile_extents,
                      cbind(E_5[1],E_5[2],E_5[3],E_5[4],"E_5"), cbind(E_6[1],E_6[2],E_6[3],E_6[4],"E_6"),
                      cbind(F_6[1],F_6[2],F_6[3],F_6[4],"F_6"), cbind(F_7[1],F_7[2],F_7[3],F_7[4],"F_7"))

Spain <- c('A_8','A_9','A_10','B_8','B_9','B_10',"C_9","C_10","D_8","D_9")
A_8 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/A_8/Prcp1990_A_8.tif")[[1]])
A_9 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/A_9/Prcp1990_A_9.tif")[[1]])
A_10 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/A_10/Prcp1990_A_10.tif")[[1]])
B_8 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/B_8/Prcp1990_B_8.tif")[[1]])
B_9 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/B_9/Prcp1990_B_9.tif")[[1]])
B_10 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/B_10/Prcp1990_B_10.tif")[[1]])
C_9 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/C_9/Prcp1990_C_9.tif")[[1]])
C_10 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/C_10/Prcp1990_C_10.tif")[[1]])
D_8 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/D_8/Prcp1990_D_8.tif")[[1]])
D_9 <- extent(stack("/Volumes/FREESIAS/Data/Spatial/Climate/Moreno/spain/D_9/Prcp1990_D_9.tif")[[1]])


tile_extents <- rbind(tile_extents,
                      cbind(A_8[1],A_8[2],A_8[3],A_8[4],"A_8"), cbind(A_9[1],A_9[2],A_9[3],A_9[4],"A_9"),
                      cbind(A_10[1],A_10[2],A_10[3],A_10[4],"A_10"), cbind(B_8[1],B_8[2],B_8[3],B_8[4],"B_8"), 
                      cbind(B_9[1],B_9[2],B_9[3],B_9[4],"B_9"), cbind(B_10[1],B_10[2],B_10[3],B_10[4],"B_10"),
                      cbind(C_9[1],C_9[2],C_9[3],C_9[4],"C_9"), cbind(C_10[1],C_10[2],C_10[3],C_10[4],"C_10"),
                      cbind(D_9[1],D_9[2],D_9[3],D_9[4],"D_9"))

tile_extents <- as.data.frame(tile_extents)
colnames(tile_extents) <- c("ymin","ymax","xmin","xmax","tile")
tile_extents$ymin <- as.numeric(as.character(tile_extents$ymin))
tile_extents$ymax <- as.numeric(as.character(tile_extents$ymax))
tile_extents$xmin <- as.numeric(as.character(tile_extents$xmin))
tile_extents$xmax <- as.numeric(as.character(tile_extents$xmax))
tile_extents$tile <- as.character(tile_extents$tile)

save(tile_extents, file="climate_moreno_tile_extents.RData")

plots <- read.csv(file="FunDiv_plots_Nadja.csv", header=TRUE, stringsAsFactors=FALSE)
# remove the plots in the Canary Islands
plots <- plots[plots$latitude>30,]

plots_fi <- plots[plots$country=='FI',c("plotcode",'longitude','latitude')]

x <- plots_fi$latitude[1];x
y <- plots_fi$longitude[1];y

tile_extents$tile[(y>tile_extents$ymin & y<tile_extents$ymax) & (x>tile_extents$xmin & x<tile_extents$xmax)]

