library(easyclimate)
library(ggplot2)
library(dplyr)


# Analysing the climate at spatial points for a given period --------------

## Example 1: Introducing coordinates as a data frame ##  ------------------

coords <- data.frame(
  lon = rnorm(3, mean = -5.36, sd = 0.3),
  lat = rnorm(3, mean = 37.40, sd = 0.3)
)

ggplot() +
  borders(regions = c("Spain", "Portugal", "France")) +
  geom_point(data = coords, aes(x = lon, y = lat)) +
  coord_fixed(xlim = c(-10, 2), ylim = c(36, 44), ratio = 1.3) +
  xlab("Longitude") +
  ylab("Latitude") +
  theme_bw()

Sys.time() # to know how much time it takes to download

daily <- get_daily_climate(
  coords = coords,
  period = 2008:2010,
  climatic_var = c("Prcp","Tmin","Tmax"))

Sys.time()

kable(head(daily))

daily <- daily |>
  mutate(
    date = as.Date(date),
    month = months(date),
    year = format(date, format = "%y")
  )

clim_site1 <- daily |>
  filter(ID_coords == 1)

ggplot(clim_site1) +
  geom_line(aes(x = date, y = Prcp), colour = "steelblue") +
  labs(x = "Date", y = "Daily precipitation (mm)") +
  theme_bw()

coords_mat <- as.matrix(coords)

## Example 2: Introducing coordinates as a matrix --------------------------
mat_prcp <- get_daily_climate(
  coords = coords_mat,
  period = 2008, # single year
  climatic_var = "Prcp"
)

## Example 3: Introducing coordinates as simple feature objects -----------

## Here we introduce coordinates as a sf object, and retrieve
## minimum temperature for a single day (1 January 2001).

library(sf)

coords_sf <- st_as_sf(
  coords,
  coords = c("lon", "lat")
)

sf_tmin <- get_daily_climate(
  coords = coords_sf,
  period = "2001-01-01", # single day
  climatic_var = "Tmin"
)

ggplot() +
  borders(regions = c("Spain", "Portugal", "France")) +
  geom_point(data = sf_tmin, aes(x = lon, y = lat, color = Tmin), size = 2) +
  coord_fixed(xlim = c(-10, 2), ylim = c(36, 44), ratio = 1.3) +
  scale_color_gradient2(name = "Minimum\ntemperature (ºC)",
                        low = "#4B8AB8", mid = "#FAFBC5", high = "#C54A52",
                        midpoint = mean(sf_tmin$Tmin)) +
  ylab("Latitude") + xlab("Longitude") +
  theme_bw()



# Analysing the climate of an area for a given period ---------------------

library(easyclimate)
library(terra)


## Example 1: introducing polygons and returning data frames ---------------

# If you wish to download the climatic data of a specific region, you need to specify
# at least four corners of the polygon including the area and specify the type of
# output you want to obtain (i.e. a data frame - df or a raster - raster). You can also
# provide the polygons of interest in a sf object.

coords_t <- vect("POLYGON ((-4.5 41, -4.5 40.5, -5 40.5, -5 41))")

Sys.time() # to know how much it takes to download

df_tmax <- get_daily_climate(
  coords_t,
  period = c("2012-01-01", "2012-08-01"),
  climatic_var = "Tmax",
  output = "df" # return dataframe
)

library(dplyr)

clim_df <- df_tmax |>
  mutate(
    date = as.Date(date)
  )
library(ggplot2)

tapply(clim_df$Tmax, clim_df$date, summary)

ggplot() +
  geom_raster(data = clim_df,
              aes(x = lon, y = lat, fill = Tmax)) +
  scale_fill_gradient2(name = "Maximum\ntemperature",
                       low = "#4B8AB8", mid = "#FAFBC5", high = "#C54A52",
                       midpoint = 21, ) +
  facet_wrap(~date) +
  ylab("Latitude") + xlab("Longitude") +
  theme_bw()


## Example 2: introducing polygons and returning rasters -------------------

# You can get a (multi-layer) raster directly as output, if you specify output = raster:

library(tidyterra)

ras_tmax <- get_daily_climate(
  coords_t,
  period = c("2012-01-01", "2012-08-01"),
  climatic_var = "Tmax",
  output = "raster" # return raster
)

ggplot() +
  geom_spatraster(data = ras_tmax, alpha = 0.9) +
  facet_wrap(~lyr, ncol = 2) +
  scale_fill_whitebox_c(name = "Minimum\ntemperature (ºC)", palette = "muted") +
  theme_bw()
