
test_that("coordinate input gives expected result", {

  skip_on_cran()
  skip_on_ci()

  coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  expect_identical(
   get_annual_climate_single(coords, period = 2001,
                                     climatic_var_single = "Tmax"),
    structure(list(ID_coords = c(1, 2),
                   lon = c(-5.36, -4.05),
                   lat = c(37.4, 38.1),
                   date = c(2001, 2001),
                   Tmin = c(7.10, 6.69)),
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

  output <- get_annual_climate_single(coords, period = 2001,
                                       climatic_var_single = "Tavg",
                                       output = "raster")

  expect_true(inherits(output, "SpatRaster"))
  expect_identical(dim(output), c(6,6,1))
  expect_identical(round(res(output), digits = 4), c(0.0083, 0.0083))
  expect_identical(as.vector(ext(output)), c(xmin = -5.00, xmax = -4.95, ymin = 37.95, ymax = 38.00))
  expect_identical(names(output), "2001")

  expect_identical(values(output), structure(c(5.17, 5.07, 5.07, 5.37, 5.27, 5.07, 5.27, 5.27, 5.37, 5.27,
                                               4.97, 4.86, 5.27, 5.56, 5.36, 5.16, 4.96, 5.06, 5.46, 5.66,
                                               5.46, 5.36, 5.35, 5.25, 5.76, 5.46, 5.25, 5.35, 5.65, 5.74,
                                               5.76, 5.55, 5.75, 5.64, 5.84, 5.64
  ), .Dim = c(36L, 1L), .Dimnames = list(NULL, "2001-01")))

})
