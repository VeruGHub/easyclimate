# easyclimate 0.2.1

* When asking for climate data for a polygon dataset (sf or SpatVector), the output raster is now masked to the extent of the polygon (issue #39).

# easyclimate 0.2.0

* Added new argument "version" to specify the version of the climate data to download (latest version is v4 - available from 1950 to 2022 and using E-Obs 27.0e; previous version is v3 - available from 1950 to 2020 and using E-Obs 17.0e).

# easyclimate 0.1.11

* Improved check_server diagnosis. Now timing out after 30 seconds, and providing better error messages.

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
