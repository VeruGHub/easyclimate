
test_that("downloading several variables gives expected results", {

  # Testing for 2 sites and a single day

  skip_on_cran()
  skip_on_ci()

  ## Input matrix
  coords.mat <- matrix(c(-5.36, 37.40), ncol = 2, byrow = TRUE)

  # ## Output data.frame
  expect_identical(
    get_daily_climate(coords.mat, period = "2001-01-01", climatic_var = c("Tmin", "Tmax", "Prcp")),
    structure(list(ID_coords = 1,
                   x = -5.36,
                   y = 37.4,
                   date = "2001-01-01",
                   Tmin = 6.50,
                   Tmax = 15.93,
                   Prcp = 8.64),
              row.names = c(NA, -1L), class = "data.frame"))

  # Output raster
  output <- get_daily_climate(coords.mat, period = "2001-01-01", climatic_var = c("Tmin", "Tmax", "Prcp"),
                      output = "raster")

  library(terra)
  expect_true(inherits(output, "list"))
  expect_identical(names(output), structure(c("Tmin", "Tmax", "Prcp")))
  expect_identical(values(output[[1]]),
                   structure(c(6.50), .Dim = c(1L, 1L), .Dimnames = list(NULL, "2001-01-01")))
  expect_identical(values(output[[2]]),
                   structure(c(15.93), .Dim = c(1L, 1L), .Dimnames = list(NULL, "2001-01-01")))
  expect_identical(values(output[[3]]),
                   structure(c(8.64), .Dim = c(1L, 1L), .Dimnames = list(NULL, "2001-01-01")))

  })

