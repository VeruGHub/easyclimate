

test_that("downloading several variables gives expected results", {

  # Testing for 2 sites and a single month

  skip_on_cran()
  skip_on_ci()

  ## Input coordinates
  coords <- matrix(c(-5.36, 37.40, -5.5, 37.5), ncol = 2, byrow = TRUE)

  ## Output data.frame
  expect_identical(
    get_annual_climate(coords, period = 2012,
                        climatic_var = c("Tmin", "Tmax", "Tavg", "Prcp")),
    structure(list(ID_coords = as.double(1:2),
                   lon = c(-5.36, -5.5),
                   lat = c(37.40, 37.5),
                   date = c(2012, 2012),
                   Tmin = c(6.25, 6.51),
                   Tmax = c(16.06, 15.65),
                   Tavg = c(10, 10),
                   Prcp = c(8.30, 8.72)),
              row.names = c(NA, -2L), class = "data.frame"))

  ## Output raster
  output <- get_montly_climate(coords, period = 2012,
                               climatic_var = c("Tmin", "Tmax", "Tavg", "Prcp"),
                               output = "raster")

  library(terra)
  expect_true(inherits(output, "list"))
  expect_identical(names(output), structure(c("Tmin", "Tmax", "Tavg", "Prcp")))
  expect_identical(head(values(output[[1]])),
                   structure(c(6.51, 6.49, 6.46, 6.44, 6.42, 6.40), dim = c(6L, 1L),
                             dimnames = list(NULL, "2012")))
  expect_identical(head(values(output[[2]])),
                   structure(c(15.65, 15.64, 15.53, 15.53, 15.52, 15.51), dim = c(6L, 1L),
                             dimnames = list(NULL, "2012")))
  expect_identical(head(values(output[[3]])),
                   structure(c(10, 10, 10, 10, 10, 10), dim = c(6L, 1L),
                             dimnames = list(NULL, "2012")))
  expect_identical(head(values(output[[4]])),
                   structure(c(8.72, 8.70, 8.67, 8.65, 8.62, 8.59), dim = c(6L, 1L
                   ), dimnames = list(NULL, "2012")))

})
