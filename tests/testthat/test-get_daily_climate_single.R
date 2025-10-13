
test_that("wrong climatic_var_single gives error", {
  expect_error(get_daily_climate_single(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                        climatic_var_single = "precip",
                                        period = 2010))
})

test_that("wrong coords format gives error", {
  expect_error(get_daily_climate_single(coords = c(-5.36, 37.40),
                                        period = 2010))
})

test_that("wrong number of matrix columns gives error", {
  expect_error(get_daily_climate_single(coords = matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 1),
                                        period = 2010))
})

test_that("wrong names of dataframe columns gives error", {
  expect_error(get_daily_climate_single(coords = data.frame(longitude = c(-5.36, -4.05),
                                                            latitude = c(37.40, 38.10)),
                                        period = 2010))
})


test_that("dataframe with reserved column names gives error", {
  expect_error(get_daily_climate_single(coords = data.frame(long = c(-5.36, -4.05),
                                                            lat = c(37.40, 38.10),
                                                            Tmax = c(20, 20)),
                                        period = 2010))
})

test_that("coordinates falling outside the bounding box give error", {
  expect_error(get_daily_climate_single(coords = matrix(c(-41, 37.40), ncol = 2),
                                        period = 2010))
  expect_error(get_daily_climate_single(coords = matrix(c(76, 37.40), ncol = 2),
                                        period = 2010))
  expect_error(get_daily_climate_single(coords = matrix(c(-5.36, 25), ncol = 2),
                                        period = 2010))
  expect_error(get_daily_climate_single(coords = matrix(c(-5.36, 76), ncol = 2),
                                        period = 2010))
})

test_that("coordinates in a different coordinate sistem gives error", {
  expect_error(get_daily_climate_single(coords = terra::vect(matrix(c(-5.36, 37.40), ncol = 2),
                                                             crs = "epsg:4258"),
                                        period = 1950))
})

test_that("year below 1950 or above 2022 gives error", {
  expect_error(get_daily_climate_single(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                        period = 1949))
  expect_error(get_daily_climate_single(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                        period = 2030))
})


test_that("different climatic_var_single give expected results for v4", {

  # Testing for 2 sites and a single day

  skip_on_cran()
  skip_on_ci()

  ## Input matrix
  coords.mat <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  # climatic_var_single = "Tmin"
  expect_identical(
    get_daily_climate_single(coords.mat, period = "2001-01-01",
                             climatic_var_single = "Tmin", version = 4,
                             check_conn = FALSE),
    structure(list(ID_coords = c(1, 2),
                   lon = c(-5.36, -4.05),
                   lat = c(37.4, 38.1),
                   date = c("2001-01-01", "2001-01-01"),
                   Tmin = c(6.25, 6.96)),
              row.names = c(NA, -2L), class = "data.frame"))


  ## climatic_var_single = "Tmax"
  expect_identical(
    get_daily_climate_single(coords.mat, period = "2001-01-01",
                             climatic_var_single = "Tmax", version = 4,
                             check_conn = FALSE),
    structure(list(ID_coords = c(1, 2),
                   lon = c(-5.36, -4.05),
                   lat = c(37.4, 38.1),
                   date = c("2001-01-01", "2001-01-01"),
                   Tmax = c(16.06, 14.97)),
              row.names = c(NA, -2L), class = "data.frame"))


  ## climatic_var_single = "Prcp"
  expect_identical(
    get_daily_climate_single(coords.mat, period = "2001-01-01",
                             climatic_var_single = "Prcp", version = 4,
                             check_conn = FALSE),
    structure(list(ID_coords = c(1, 2),
                   lon = c(-5.36, -4.05),
                   lat = c(37.4, 38.1),
                   date = c("2001-01-01", "2001-01-01"),
                   Prcp = c(8.30, 6.29)),
              row.names = c(NA, -2L), class = "data.frame"))

})


################################################################

test_that("different input formats (points) give expected results", {

  skip_on_cran()
  skip_on_ci()

  ## Input matrix (tested above)
  coords.mat <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  output <- structure(list(ID_coords = c(1, 2),
                           lon = c(-5.36, -4.05),
                           lat = c(37.4, 38.1),
                           date = c("2001-01-01", "2001-01-01"),
                           Tmin = c(6.25, 6.96)),
                      row.names = c(NA, -2L),
                      class = "data.frame")

  #Input data.frame
  coords.df <- as.data.frame(coords.mat)
  names(coords.df) <- c("lon", "lat")
  expect_identical(
    get_daily_climate_single(coords.df, period = "2001-01-01",
                             climatic_var_single = "Tmin", version = 4,
                             check_conn = FALSE),
    output)

  #Input sf
  coords.sf <- sf::st_as_sf(coords.df, coords = c("lon", "lat"))
  expect_identical(
    get_daily_climate_single(coords.sf, period = "2001-01-01",
                             climatic_var_single = "Tmin", version = 4,
                             check_conn = FALSE),
    output)

  #Input SpatVector
  coords.spv <- terra::vect(coords.sf)
  expect_identical(
    get_daily_climate_single(coords.spv, period = "2001-01-01",
                             climatic_var_single = "Tmin", version = 4,
                             check_conn = FALSE),
    output)

})



############################################################################

test_that("polygon input give expected results", {

  skip_on_cran()
  skip_on_ci()

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  expect_identical(
    subset(get_daily_climate_single(coords, period = "2001-01-01",
                                    climatic_var_single = "Tmin", version = 4,
                                    check_conn = FALSE),
           select = -c(lon, lat)),
    structure(list(ID_coords = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                                 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                                 1, 1, 1, 1),
                   date = c("2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01", "2001-01-01",
                            "2001-01-01", "2001-01-01", "2001-01-01"),
                   Tmin = c(5.17, 5.07,
                            5.07, 5.37, 5.27, 5.07, 5.22, 5.22, 5.32, 5.23, 4.93, 4.83, 5.18, 5.48, 5.28,
                            5.08, 4.88, 4.98, 5.34, 5.54, 5.34, 5.24, 5.24, 5.14, 5.60, 5.29, 5.09, 5.19,
                            5.49, 5.59, 5.55, 5.35, 5.55, 5.45, 5.65, 5.45)),
              row.names = c(NA, 36L
              ), class = "data.frame"))

})


############################################################################

test_that("output raster is correct for v4", {

  skip_on_cran()
  skip_on_ci()

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  output <- get_daily_climate_single(coords, period = "2001-01-01",
                                     climatic_var_single = "Tmin", output = "raster",
                                     version = 4, check_conn = FALSE)

  expect_true(inherits(output, "SpatRaster"))
  expect_identical(dim(output), c(6,6,1))
  expect_identical(round(res(output), digits = 4), c(0.0083, 0.0083))
  expect_identical(as.vector(ext(output)), c(xmin = -5, xmax = -4.95, ymin = 37.95, ymax = 38))
  expect_identical(names(output), "2001-01-01")
  expect_identical(values(output), structure(c(5.17, 5.07, 5.07, 5.37, 5.27, 5.07, 5.22, 5.22, 5.32, 5.23,
                                               4.93, 4.83, 5.18, 5.48, 5.28, 5.08, 4.88, 4.98, 5.34, 5.54,
                                               5.34, 5.24, 5.24, 5.14, 5.60, 5.29, 5.09, 5.19, 5.49, 5.59,
                                               5.55, 5.35, 5.55, 5.45, 5.65, 5.45
  ), .Dim = c(36L, 1L), .Dimnames = list(NULL, "2001-01-01")))

})

############################################################################

test_that("different period formats give expected results", {

  skip_on_cran()
  skip_on_ci()

  coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  expect_identical(
    get_daily_climate_single(coords, period = c("2001-01-01:2001-01-03", "2005-01-01"),
                             version = 4, check_conn = FALSE),
    structure(list(ID_coords = c(1, 1, 1, 1, 2, 2, 2, 2),
                   lon = c(-5.36, -5.36, -5.36, -5.36, -4.05, -4.05, -4.05, -4.05),
                   lat = c(37.4, 37.4, 37.4, 37.4, 38.1, 38.1, 38.1, 38.1),
                   date = c("2001-01-01", "2001-01-02", "2001-01-03", "2005-01-01",
                            "2001-01-01", "2001-01-02", "2001-01-03", "2005-01-01"),
                   Prcp = c(8.30, 0.00, 3.38, 0.00, 6.29, 0.00, 1.36, 0.00)),
              row.names = c(NA, -8L), class = "data.frame"))


  out <- get_daily_climate_single(coords, period = c(2001:2003, 2005),
                                  version = 4, check_conn = FALSE)
  expect_identical(head(out),
                   structure(list(ID_coords = c(1, 1, 1, 1, 1, 1),
                                  lon = c(-5.36, -5.36, -5.36, -5.36, -5.36, -5.36),
                                  lat = c(37.4, 37.4, 37.4, 37.4, 37.4, 37.4),
                                  date = c("2001-01-01", "2001-01-02", "2001-01-03",
                                           "2001-01-04", "2001-01-05", "2001-01-06"),
                                  Prcp = c(8.30, 0.00, 3.38, 1.93, 12.60, 4.13)),
                             row.names = c(NA, 6L), class = "data.frame"))

  expect_identical(tail(out),
                   structure(list(ID_coords = c(2, 2, 2, 2, 2, 2),
                                  lon = c(-4.05, -4.05, -4.05, -4.05, -4.05, -4.05),
                                  lat = c(38.1, 38.1, 38.1, 38.1, 38.1, 38.1),
                                  date = c("2005-12-26", "2005-12-27", "2005-12-28",
                                           "2005-12-29", "2005-12-30", "2005-12-31"),
                                  Prcp = c(5.68, 0.00, 0.00, 0.00, 0.00, 0.00)),
                             row.names = 2915:2920, class = "data.frame"))

})
