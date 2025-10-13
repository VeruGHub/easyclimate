

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
                   Tmin = c( 12.54, 11.88),
                   Tmax = c(25.29, 25.08),
                   Tavg = c(18.91, 18.48),
                   Prcp = c(427.33, 463.85)),
              row.names = c(NA, -2L), class = "data.frame"))

  ## Output raster
  output <- get_annual_climate(coords, period = 2012,
                               climatic_var = c("Tmin", "Tmax", "Tavg", "Prcp"),
                               output = "raster")

  library(terra)
  expect_true(inherits(output, "list"))
  expect_identical(names(output), structure(c("Tmin", "Tmax", "Tavg", "Prcp")))
  expect_identical(head(values(output[[1]])),
                   structure(c(11.88, 11.90, 11.93, 11.95, 11.96, 11.99), dim = c(6L, 1L),
                             dimnames = list(NULL, "2012")))
  expect_identical(head(values(output[[2]])),
                   structure(c(25.08, 25.08, 25.07, 25.08, 25.07, 25.08), dim = c(6L, 1L),
                             dimnames = list(NULL, "2012")))
  expect_identical(head(values(output[[3]])),
                   structure(c(18.48, 18.49, 18.50, 18.51, 18.51, 18.53), dim = c(6L, 1L),
                             dimnames = list(NULL, "2012")))
  expect_identical(head(values(output[[4]])),
                   structure(c(463.85, 464.17, 465.77, 466.49,464.75, 461.11), dim = c(6L, 1L
                   ), dimnames = list(NULL, "2012")))

})
