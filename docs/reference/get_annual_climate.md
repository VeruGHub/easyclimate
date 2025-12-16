# Get annual data for multiple climatic variables

Extract annual climate data (temperature and precipitation) for a given
set of points or polygons within Europe.

## Usage

``` r
get_annual_climate(
  coords = NULL,
  climatic_var = "Prcp",
  period = NULL,
  output = "df"
)
```

## Arguments

- coords:

  A [matrix](https://rdrr.io/r/base/matrix.html),
  [data.frame](https://rdrr.io/r/base/data.frame.html),
  [tibble::tbl_df](https://tibble.tidyverse.org/reference/tbl_df-class.html),
  [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html), or
  [`terra::SpatVector()`](https://rspatial.github.io/terra/reference/SpatVector-class.html)
  object containing point or polygon coordinates in decimal degrees
  (lonlat/geographic format). Longitude must fall between -40.5 and 75.5
  degrees, and latitude between 25.5 and 75.5 degrees. If `coords` is a
  matrix, it must have only two columns: the first with longitude and
  the second with latitude data. If `coords` is a data.frame or a
  tbl_df, it must contain at least two columns called `lon` and `lat`
  with longitude and latitude coordinates, respectively.

- climatic_var:

  Character. Climatic variables to be downloaded ('Tmax', 'Tmin', 'Tavg'
  or 'Prcp'). Various elements can be concatenated in the vector.

- period:

  Numbers representing years between 1950 and 2024. To specify a
  sequence of years use the format 'start:end' (e.g. YYYY:YYYY, see
  examples). Various elements can be concatenated in the vector (e.g.
  c(2000:2005, 2010:2015, 2020))

- output:

  Character. Either "df", which returns a dataframe with monthly
  climatic values for each point/polygon, or "raster", which returns a
  [`terra::SpatRaster()`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  object (within a list when more than one climatic variable is
  downloaded).

## Value

Either:

- A data.frame (if output = "df")

- A list of
  [`terra::SpatRaster()`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  object (if output = "raster")

## References

Pucher C. 2023. Description and Evaluation of Downscaled Daily Climate
Data Version 4. https://doi.org/10.6084/m9.figshare.22962671.v1

Werner Rammer, Christoph Pucher, Mathias Neumann. 2018. Description,
Evaluation and Validation of Downscaled Daily Climate Data Version 2.
ftp://palantir.boku.ac.at/Public/ClimateData/

Adam Moreno, Hubert Hasenauer. 2016. Spatial downscaling of European
climate data. International Journal of Climatology 36: 1444–1458.

## Author

Veronica Cruz-Alonso, Francisco Rodriguez-Sanchez

## Examples

``` r
if (FALSE) { # interactive()

# Coords as matrix
coords <- matrix(c(-5.36, 37.40), ncol = 2)
ex <- get_monthly_climate(coords, period = 2008)  # 2008
ex <- get_monthly_climate(coords, period = c(2008, 2010))  # 2008 AND 2010
ex <- get_monthly_climate(coords, period = 2008:2010)  # 2008 TO 2010

ex <- get_monthly_climate(coords, period = 2008, climatic_var = "Tmin")

# Coords as data.frame or tbl_df
coords <- as.data.frame(coords) #coords <- tibble::as_tibble(coords)
names(coords) <- c("lon", "lat")  # must have these columns
ex <- get_monthly_climate(coords, period = 2008)  # single month

# Coords as sf
coords <- sf::st_as_sf(coords, coords = c("lon", "lat"))
ex <- get_monthly_climate(coords, period = 2008)  # single month

# Several points
coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)
ex <- get_monthly_climate(coords, period = 2008, output = "raster")  # raster output

# Multiple climatic variables
coords <- matrix(c(-5.36, 37.40), ncol = 2)
ex <- get_monthly_climate(coords, climatic_var = c("Tmin", "Tmax"), period = 2008)

## Polygons
coords <- terra::vect("POLYGON ((-5 38, -5 37.5, -4.5 37.5, -4.5 38, -5 38))")

# Return raster
ex <- get_monthly_climate(coords, period = 2008, output = "raster")
ex <- get_monthly_climate(coords, climatic_var = c("Tmin", "Tmax"),
period = 2008, output = "raster") # Multiple climatic variables

# Return dataframe for polygon
ex <- get_monthly_climate(coords, period = 2008)
}
```
