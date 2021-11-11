
test_that("wrong climatic_var gives error", {
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                 climatic_var = "precip",
                                 period = 2010))
})

test_that("wrong coords format gives error", {
  expect_error(get_daily_climate(coords = c(-5.36, 37.40),
                                 period = 2010))
})

test_that("wrong number of matrix columns gives error", {
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 1),
                                 period = 2010))
})

test_that("wrong names of dataframe columns gives error", {
  expect_error(get_daily_climate(coords = data.frame(longitude = c(-5.36, -4.05),
                                                     latitude = c(37.40, 38.10)),
                                 period = 2010))
})


test_that("dataframe with reserved column names gives error", {
  expect_error(get_daily_climate(coords = data.frame(long = c(-5.36, -4.05),
                                                     lat = c(37.40, 38.10),
                                                     Tmax = c(20, 20)),
                                 period = 2010))
})

test_that("coordinates falling outside the bounding box give error", {
  expect_error(get_daily_climate(coords = matrix(c(-41, 37.40), ncol = 2),
                                 period = 2010))
  expect_error(get_daily_climate(coords = matrix(c(76, 37.40), ncol = 2),
                                 period = 2010))
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 25), ncol = 2),
                                 period = 2010))
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 76), ncol = 2),
                                 period = 2010))
})

test_that("year below 1950 or above 2020 gives error", {
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                 period = 1949))
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                 period = 2021))
})




############################################################

test_that("different climatic_var give expected results", {

  # Testing for 2 sites and a single day

  skip_on_cran()

  ## Input matrix
  coords.mat <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  # climatic_var = "Tmin"
  expect_identical(
    get_daily_climate(coords.mat, period = "2001-01-01", climatic_var = "Tmin"),
    structure(list(ID_coords = c(1, 2),
                   x = c(-5.36, -4.05),
                   y = c(37.4, 38.1),
                   date = c("2001-01-01", "2001-01-01"),
                   Tmin = c(650, 664)),
              row.names = c(NA, -2L), class = "data.frame"))


  ## climatic_var = "Tmax"
  expect_identical(
    get_daily_climate(coords.mat, period = "2001-01-01", climatic_var = "Tmax"),
    structure(list(ID_coords = c(1, 2),
                   x = c(-5.36, -4.05),
                   y = c(37.4, 38.1),
                   date = c("2001-01-01", "2001-01-01"),
                   Tmax = c(1593, 1492)),
              row.names = c(NA, -2L), class = "data.frame"))


  ## climatic_var = "Prcp"
  expect_identical(
    get_daily_climate(coords.mat, period = "2001-01-01", climatic_var = "Prcp"),
    structure(list(ID_coords = c(1, 2),
                   x = c(-5.36, -4.05),
                   y = c(37.4, 38.1),
                   date = c("2001-01-01", "2001-01-01"),
                   Prcp = c(864, 664)),
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
                           x = c(-5.36, -4.05),
                           y = c(37.4, 38.1),
                           date = c("2001-01-01", "2001-01-01"),
                           Tmin = c(650, 664)),
                      row.names = c(NA, -2L),
                      class = "data.frame")

  #Input data.frame
  coords.df <- as.data.frame(coords.mat)
  names(coords.df) <- c("lon", "lat")
  expect_identical(
    get_daily_climate(coords.df, period = "2001-01-01", climatic_var = "Tmin"),
    output)

  ## output with sf and SpatVector does not include lon & lat columns
  output <- subset(output, select = -c(lon, lat))

  #Input sf
  coords.sf <- sf::st_as_sf(coords.df, coords = c("lon", "lat"))
  expect_identical(
    get_daily_climate(coords.sf, period = "2001-01-01", climatic_var = "Tmin"),
    output)

  #Input SpatVector
  coords.spv <- terra::vect(coords.sf)
  expect_identical(
    get_daily_climate(coords.spv, period = "2001-01-01", climatic_var = "Tmin"),
    output)

})



############################################################################

test_that("polygon input give expected results", {

  skip_on_cran()
  skip_on_ci()

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  expect_identical(
    subset(get_daily_climate(coords, period = "2001-01-01", climatic_var = "Tmin"),
           select = -c(x, y)),
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
                   Tmin = c(535, 525,
                            524, 554, 543, 523, 542, 542, 551, 541, 510, 500, 539, 569, 548,
                            528, 508, 517, 556, 576, 555, 545, 545, 534, 583, 553, 532, 542,
                            572, 581, 580, 560, 579, 569, 589, 568)),
              row.names = c(NA, 36L
              ), class = "data.frame"))

})


############################################################################

test_that("output raster is correct", {

  skip_on_cran()
  skip_on_ci()

  library(terra)

  coords <- terra::vect("POLYGON ((-5 38, -5 37.95, -4.95 37.95, -4.95 38, -5 38))")

  output <- get_daily_climate(coords, period = "2001-01-01", climatic_var = "Tmin", output = "raster")

  expect_true(inherits(output, "SpatRaster"))
  expect_identical(dim(output), c(6,6,1))
  expect_identical(round(res(output), digits = 4), c(0.0083, 0.0083))
  expect_identical(as.vector(ext(output)), c(xmin = -5, xmax = -4.95, ymin = 37.95, ymax = 38))
  expect_identical(names(output), "2001-01-01")
  expect_identical(values(output), structure(c(535, 525, 524, 554, 543, 523, 542, 542, 551, 541,
                                               510, 500, 539, 569, 548, 528, 508, 517, 556, 576, 555, 545, 545,
                                               534, 583, 553, 532, 542, 572, 581, 580, 560, 579, 569, 589, 568
  ), .Dim = c(36L, 1L), .Dimnames = list(NULL, "2001-01-01")))

})

############################################################################

test_that("different period formats give expected results", {

  skip_on_cran()
  skip_on_ci()

  coords <- matrix(c(-5.36, 37.40, -4.05, 38.10), ncol = 2, byrow = TRUE)

  expect_identical(
    get_daily_climate(coords, period = c("2001-01-01:2001-01-03", "2005-01-01")),
    structure(list(ID_coords = c(1, 1, 1, 1, 2, 2, 2, 2),
                   x = c(-5.36, -5.36, -5.36, -5.36, -4.05, -4.05, -4.05, -4.05),
                   y = c(37.4, 37.4, 37.4, 37.4, 38.1, 38.1, 38.1, 38.1),
                   date = c("2001-01-01", "2001-01-02", "2001-01-03", "2005-01-01",
                            "2001-01-01", "2001-01-02", "2001-01-03", "2005-01-01"),
                   Prcp = c(864, 0, 293, 0, 664, 0, 159, 0)),
              row.names = c(NA, -8L), class = "data.frame"))


  out <- get_daily_climate(coords, period = c(2001:2003, 2005))
  expect_identical(head(out),
                   structure(list(ID_coords = c(1, 1, 1, 1, 1, 1),
                                  x = c(-5.36, -5.36, -5.36, -5.36, -5.36, -5.36),
                                  y = c(37.4, 37.4, 37.4, 37.4, 37.4, 37.4),
                                  date = c("2001-01-01", "2001-01-02", "2001-01-03",
                                           "2001-01-04", "2001-01-05", "2001-01-06"),
                                  Prcp = c(864, 0, 293, 189, 1177, 447)),
                             row.names = c(NA, 6L), class = "data.frame"))

  expect_identical(tail(out),
                   structure(list(ID_coords = c(2, 2, 2, 2, 2, 2),
                                  x = c(-4.05, -4.05, -4.05, -4.05, -4.05, -4.05),
                                  y = c(38.1, 38.1, 38.1, 38.1, 38.1, 38.1),
                                  date = c("2005-12-26", "2005-12-27", "2005-12-28",
                                           "2005-12-29", "2005-12-30", "2005-12-31"),
                                  Prcp = c(770, 6, 0, 0, 0, 0)),
                             row.names = 2915:2920, class = "data.frame"))

})
