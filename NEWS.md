# easyclimate 0.1.10

* Improved check_server diagnosis.

# easyclimate 0.1.8

* Queries limited to max. 10000 sites or 10000 km2 to avoid saturating the server.

# easyclimate 0.1.7

* Coordinates (lon, lat) of the output dataframe now match input coordinates to `get_daily_climate`, unless providing a polygon when output coordinates are those of the raster cells enclosed in the polygon.

# easyclimate 0.1.6

* New function `check_server()` to check that the climate data server is working correctly.

# easyclimate 0.1.5

* Now giving the possibility to download multiple climatic variables at once.

# easyclimate 0.1.4

* Now returning temperature data in ºC and precipitation in mm. 

# easyclimate 0.1.3

* Now providing data between 1950 and 2020, using version 3 of the climatic dataset. 
