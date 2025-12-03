library(terra)

test_that("coordinate input gives expected result", {

  skip_on_cran()
  skip_on_ci()

  coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  expect_identical(
   get_annual_climate_single(coords, period = 2001,
                                     climatic_var_single = "Tmin"),
    structure(list(ID_coords = c(1, 2),
                   lon = c(-5.36, -4.05),
                   lat = c(37.4, 38.1),
                   date = c(2001, 2001),
                   Tmin = c(11.86, 11.24)),
              row.names = c(NA, -2L), class = "data.frame"))

})

############################################################################

test_that("polygon input give expected results", {

  skip_on_cran()
  skip_on_ci()

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  expect_identical(
    subset(get_annual_climate_single(coords, period = 2001,
                                      climatic_var_single = "Tmin"),
           select = -c(lon, lat)),
    structure(list(ID_coords = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                                 1, 1, 1, 1),
                   date = rep(2001, 36),
                   Tmin = c(10.30, 10.15, 10.13, 10.49, 10.35, 10.17, 10.39,
                            10.41, 10.48, 10.41, 10.13, 10.02, 10.33, 10.67,
                            10.49, 10.28, 10.13, 10.24, 10.55, 10.76, 10.57,
                            10.48, 10.56, 10.40, 10.83, 10.52, 10.35, 10.52,
                            10.84, 10.89, 10.87, 10.63, 10.82, 10.81, 10.96,
                            10.84)),
              row.names = c(NA, 36L
              ), class = "data.frame"))

})


############################################################################


test_that("output raster is correct", {

  skip_on_cran()
  skip_on_ci()


  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  output <- get_annual_climate_single(coords, period = 2001,
                                       climatic_var_single = "Tavg",
                                       output = "raster")

  expect_true(inherits(output, "SpatRaster"))
  expect_identical(dim(output), c(6,6,1))
  expect_identical(round(res(output), digits = 4), c(0.0083, 0.0083))
  expect_identical(round(as.vector(ext(output)), digits = 2),
                   round(c(xmin = -5.00, xmax = -4.95, ymin = 37.95, ymax = 38.00), digits = 2))
  expect_identical(names(output), "2001")

  expect_identical(values(output), structure(c(16.53, 16.37, 16.34, 16.74, 16.60,
                                               16.39, 16.59, 16.63, 16.72, 16.66,
                                               16.36, 16.24, 16.52, 16.90, 16.73,
                                               16.51, 16.37, 16.47, 16.74, 16.99,
                                               16.81, 16.72, 16.81, 16.64, 17.06,
                                               16.74, 16.57, 16.76, 17.10, 17.16,
                                               17.11, 16.88, 17.07, 17.07, 17.23,
                                               17.10),
                                             .Dim = c(36L, 1L), .Dimnames = list(NULL, "2001")))

})
