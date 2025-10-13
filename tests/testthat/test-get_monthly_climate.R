
test_that("downloading several variables gives expected results", {

  # Testing for 2 sites and a single month

  skip_on_cran()
  skip_on_ci()

  ## Input coordinates
  coords <- matrix(c(-5.36, 37.40, -5.5, 37.5), ncol = 2, byrow = TRUE)

  ## Output data.frame
  expect_identical(
    get_monthly_climate(coords, period = "2001-01",
                      climatic_var = c("Tmin", "Tmax", "Tavg", "Prcp")),
    structure(list(ID_coords = as.double(1:2),
                   lon = c(-5.36, -5.5),
                   lat = c(37.40, 37.5),
                   date = c("2001-01", "2001-01"),
                   Tmin = c(6.78, 6.67),
                   Tmax = c(14.83, 14.52),
                   Tavg = c(10.81, 10.60),
                   Prcp = c(128.56, 138.22)),
              row.names = c(NA, -2L), class = "data.frame"))

  ## Output raster
  output <- get_monthly_climate(coords, period = "2001-01",
                              climatic_var = c("Tmin", "Tmax", "Tavg", "Prcp"),
                              output = "raster")

  library(terra)
  expect_true(inherits(output, "list"))
  expect_identical(names(output), structure(c("Tmin", "Tmax", "Tavg", "Prcp")))
  expect_identical(head(values(output[[1]])),
                   structure(c( 6.67, 6.65, 6.63, 6.61, 6.60, 6.58), dim = c(6L, 1L),
                             dimnames = list(NULL, "2001-01")))
  expect_identical(head(values(output[[2]])),
                   structure(c(14.52, 14.51, 14.41, 14.40, 14.39, 14.39), dim = c(6L, 1L),
                             dimnames = list(NULL, "2001-01")))
  expect_identical(head(values(output[[3]])),
                   structure(c(10.60, 10.58, 10.52, 10.51, 10.49, 10.48), dim = c(6L, 1L),
                             dimnames = list(NULL, "2001-01")))
  expect_identical(head(values(output[[4]])),
                   structure(c(138.22, 137.72, 137.18, 136.67, 136.15, 135.62), dim = c(6L, 1L
                   ), dimnames = list(NULL, "2001-01")))

})
