

test_that("wrong climatic_var_single gives error", {
  expect_error(get_monthly_climate_single(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                        climatic_var_single = "precip",
                                        period = 2010))
})

test_that("wrong coords format gives error", {
  expect_error(get_monthly_climate_single(coords = c(-5.36, 37.40),
                                        period = 2010))
})

test_that("wrong number of matrix columns gives error", {
  expect_error(get_monthly_climate_single(coords = matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 1),
                                        period = 2010))
})

test_that("wrong names of dataframe columns gives error", {
  expect_error(get_monthly_climate_single(coords = data.frame(longitude = c(-5.36, -4.05),
                                                            latitude = c(37.40, 38.10)),
                                        period = 2010))
})


test_that("dataframe with reserved column names gives error", {
  expect_error(get_monthly_climate_single(coords = data.frame(long = c(-5.36, -4.05),
                                                            lat = c(37.40, 38.10),
                                                            Tmax = c(20, 20)),
                                        period = 2010))
})

test_that("coordinates falling outside the bounding box give error", {
  expect_error(get_monthly_climate_single(coords = matrix(c(-41, 37.40), ncol = 2),
                                        period = 2010))
  expect_error(get_monthly_climate_single(coords = matrix(c(76, 37.40), ncol = 2),
                                        period = 2010))
  expect_error(get_monthly_climate_single(coords = matrix(c(-5.36, 25), ncol = 2),
                                        period = 2010))
  expect_error(get_monthly_climate_single(coords = matrix(c(-5.36, 76), ncol = 2),
                                        period = 2010))
})

test_that("coordinates in a different coordinate sistem gives error", {
  expect_error(get_monthly_climate_single(coords = terra::vect(matrix(c(-5.36, 37.40), ncol = 2),
                                                             crs = "epsg:4258"),
                                        period = 1950))
})

test_that("year below 1950 or above 2024 gives error", {
  expect_error(get_monthly_climate_single(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                        period = 1949))
  expect_error(get_monthly_climate_single(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                        period = 2030))
})

############################################################


test_that("different climatic_var_single give expected results", {

  # Testing for 2 sites and two months

  skip_on_cran()
  skip_on_ci()
  skip_if_not(suppressWarnings(check_server(verbose = FALSE)))

  ## Input matrix
  coords.mat <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  # climatic_var_single = "Tmin"
  expect_identical(
    get_monthly_climate_single(coords.mat, period = c("2001-01", "2001-06"),
                             climatic_var_single = "Tmin",
                             check_conn = FALSE),
    structure(list(ID_coords = c(1, 1, 2, 2),
                   lon = c(-5.36, -5.36, -4.05, -4.05),
                   lat = c(37.4, 37.4, 38.1, 38.1),
                   date = c("2001-01", "2001-06", "2001-01", "2001-06"),
                   Tmin = c(7.10, 16.64, 6.69, 18.62)),
              row.names = c(NA, -4L), class = "data.frame"))


  ## climatic_var_single = "Tmax"
  expect_identical(
    get_monthly_climate_single(coords.mat, period = c("2001-01", "2001-06"),
                             climatic_var_single = "Tmax",
                             check_conn = FALSE),
    structure(list(ID_coords = c(1, 1, 2, 2),
                   lon = c(-5.36, -5.36, -4.05, -4.05),
                   lat = c(37.4, 37.4, 38.1, 38.1),
                   date = c("2001-01", "2001-06", "2001-01", "2001-06"),
                   Tmax = c(15.06, 34.09, 12.85, 33.20)),
              row.names = c(NA, -4L), class = "data.frame"))


  ## climatic_var_single = "Prcp"
  expect_identical(
    get_monthly_climate_single(coords.mat, period = c("2001-01", "2001-06"),
                             climatic_var_single = "Prcp",
                             check_conn = FALSE),
    structure(list(ID_coords = c(1, 1, 2, 2),
                   lon = c(-5.36, -5.36, -4.05, -4.05),
                   lat = c(37.4, 37.4, 38.1, 38.1),
                   date = c("2001-01", "2001-06", "2001-01", "2001-06"),
                   Prcp = c(135.66, 0.00, 90.93, 0.10)),
              row.names = c(NA, -4L), class = "data.frame"))

})


################################################################

test_that("different input formats (points) give expected results", {

  skip_on_cran()
  skip_on_ci()
  skip_if_not(suppressWarnings(check_server(verbose = FALSE)))

  ## Input matrix (tested above)
  coords.mat <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  output <- structure(list(ID_coords = c(1, 2),
                           lon = c(-5.36, -4.05),
                           lat = c(37.4, 38.1),
                           date = c("2001-01", "2001-01"),
                           Tmin = c(7.10, 6.69)),
                      row.names = c(NA, -2L), class = "data.frame")

  #Input data.frame
  coords.df <- as.data.frame(coords.mat)
  names(coords.df) <- c("lon", "lat")
  expect_identical(
    get_monthly_climate_single(coords.df, period = "2001-01",
                             climatic_var_single = "Tmin",
                             check_conn = FALSE),
    output)

  #Input sf
  coords.sf <- sf::st_as_sf(coords.df, coords = c("lon", "lat"))
  expect_identical(
    get_monthly_climate_single(coords.sf, period = "2001-01",
                             climatic_var_single = "Tmin",
                             check_conn = FALSE),
    output)

  #Input SpatVector
  coords.spv <- terra::vect(coords.sf)
  expect_identical(
    get_monthly_climate_single(coords.spv, period = "2001-01",
                             climatic_var_single = "Tmin",
                             check_conn = FALSE),
    output)

})



############################################################################

test_that("polygon input give expected results", {

  skip_on_cran()
  skip_on_ci()

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  expect_identical(
    subset(get_monthly_climate_single(coords, period = "2001-01",
                                    climatic_var_single = "Tmin"),
           select = -c(lon, lat)),
    structure(list(ID_coords = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                                 1, 1, 1, 1),
                   date = c("2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01", "2001-01", "2001-01",
                            "2001-01", "2001-01", "2001-01"),
                   Tmin = c(5.64, 5.74, 5.25, 5.06, 4.86, 5.07, 5.84, 5.65, 5.35, 4.96,
                            4.97, 5.27, 5.64, 5.35, 5.36, 5.16, 5.27, 5.37, 5.75, 5.25,
                            5.46, 5.36, 5.37, 5.07, 5.55, 5.46, 5.66, 5.56, 5.27, 5.07,
                            5.76, 5.76, 5.46, 5.27, 5.27, 5.17)),
              row.names = c(NA, 36L
              ), class = "data.frame"))

})


############################################################################


test_that("output raster is correct", {

  skip_on_cran()
  skip_on_ci()

  library(terra)

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  output <- get_monthly_climate_single(coords, period = "2001-01",
                                       climatic_var_single = "Tmin",
                                       output = "raster")

  expect_true(inherits(output, "SpatRaster"))
  expect_identical(dim(output), c(6,6,1))
  expect_identical(round(res(output), digits = 4), c(0.0083, 0.0083))
  expect_identical(as.vector(ext(output)), c(xmin = -5.00, xmax = -4.95, ymin = 37.95, ymax = 38.00))
  expect_identical(names(output), "2001-01")

  expect_identical(values(output), structure(c(5.17, 5.07, 5.07, 5.37, 5.27, 5.07, 5.27, 5.27, 5.37, 5.27,
                                               4.97, 4.86, 5.27, 5.56, 5.36, 5.16, 4.96, 5.06, 5.46, 5.66,
                                               5.46, 5.36, 5.35, 5.25, 5.76, 5.46, 5.25, 5.35, 5.65, 5.74,
                                               5.76, 5.55, 5.75, 5.64, 5.84, 5.64
  ), .Dim = c(36L, 1L), .Dimnames = list(NULL, "2001-01")))

})

############################################################################

test_that("different period formats give expected results", {

  skip_on_cran()
  skip_on_ci()
  skip_if_not(suppressWarnings(check_server(verbose = FALSE)))

  coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  expect_identical(
    get_monthly_climate_single(coords, period = c("2001-01:2001-03", "2005-01"),
                               check_conn = FALSE),
    structure(list(ID_coords = c(1, 1, 1, 1, 2, 2, 2, 2),
                   lon = c(-5.36, -5.36, -5.36, -5.36, -4.05, -4.05, -4.05, -4.05),
                   lat = c(37.4, 37.4, 37.4, 37.4, 38.1, 38.1, 38.1, 38.1),
                   date = c("2001-01", "2001-02", "2001-03", "2005-01",
                            "2001-01", "2001-02", "2001-03", "2005-01"),
                   Prcp = c(135.66, 16.61, 122.98, 0.00, 90.93, 21.92, 105.65, 0.00)),
              row.names = c(NA, -8L), class = "data.frame"))


  out <- get_monthly_climate_single(coords, period = c(2001:2003, 2005),
                                    check_conn = FALSE)
  expect_identical(head(out),
                   structure(list(ID_coords = c(1, 1, 1, 1, 1, 1),
                                  lon = c(-5.36, -5.36, -5.36, -5.36, -5.36, -5.36),
                                  lat = c(37.4, 37.4, 37.4, 37.4, 37.4, 37.4),
                                  date = c("2001-01", "2001-02", "2001-03",
                                           "2001-04", "2001-05", "2001-06"),
                                  Prcp = c(135.66, 16.61, 122.98, 3.33, 43.95, 0.00)),
                             row.names = c(NA, 6L), class = "data.frame"))

  expect_identical(tail(out),
                   structure(list(ID_coords = c(2, 2, 2, 2, 2, 2),
                                  lon = c(-4.05, -4.05, -4.05, -4.05, -4.05, -4.05),
                                  lat = c(38.1, 38.1, 38.1, 38.1, 38.1, 38.1),
                                  date = c("2005-07", "2005-08", "2005-09",
                                           "2005-10", "2005-11", "2005-12"),
                                  Prcp = c(0.00, 0.00, 14.68, 66.50, 16.87, 35.63)),
                             row.names = 91:96, class = "data.frame"))

})
