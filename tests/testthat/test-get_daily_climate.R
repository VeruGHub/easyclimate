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

test_that("wrong names of datafame columns gives error", {
  expect_error(get_daily_climate(coords = data.frame(longitude = c(-5.36, -4.05),
                                                     latitude = c(37.40, 38.10)),
                                 period = 2010))
})

test_that("coordinates fall out of the required extent (-40.5, 75.5, 25.25, 75.5)", {
  expect_error(get_daily_climate(coords = matrix(c(-41, 37.40), ncol = 2),
                                 period = 2010))
  expect_error(get_daily_climate(coords = matrix(c(76, 37.40), ncol = 2),
                                 period = 2010))
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 25), ncol = 2),
                                 period = 2010))
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 76), ncol = 2),
                                 period = 2010))
})

test_that("year below 1950 or above 2017 gives error", {
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                 period = 1949))
  expect_error(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                 period = 2018))
})

test_that("output format is right", {
  expect_true(inherits(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                         period = 2010),
                       "data.frame"))
  expect_true(inherits(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2, byrow = TRUE),
                                         period = 2010,
                                         output = "raster"),
                       "SpatRaster"))
})

test_that("get daily climate works", {
  #Input matrix
  expect_identical(get_daily_climate(coords = matrix(c(-5.36, 37.40, -4.05, 38.10, -4.05, 38.10), ncol = 2, byrow = TRUE),
                                 period = "2008-09-27",
                                 climatic_var = "Tmin")[,"Tmin"],
               c(1663,-5.36)) #-5.36 es una coordenada!!
  expect_identical(get_daily_climate(coords = matrix(c(-5.36, 37.40), ncol = 2),
                                 period = c("2008-01-27","2008-09-27"),
                                 climatic_var = "Tmin")[,"Tmin"],
               c(553,1663))
  #Input data.frame
  expect_identical(get_daily_climate(coords = data.frame(lon = c(-5.36, -4.05, -4.05), lat = c(37.40, 38.10, 38.10)),
                                     period = "2008-09-27",
                                     climatic_var = "Tmin")[,"Tmin"],
                   c(1663,-5.36)) #-5.36 es una coordenada!!
  expect_identical(get_daily_climate(coords = data.frame(lon = -5.36, lat = 37.40),
                                     period = c("2008-01-27","2008-09-27"),
                                     climatic_var = "Tmin")[,"Tmin"],
                   c(553,1663))
  #Input sf
  expect_identical(get_daily_climate(coords = sf::st_as_sf(data.frame(lon = c(-5.36, -4.05, -4.05), lat = c(37.40, 38.10, 38.10)),
                                                           coords = c("lon", "lat")),
                                     period = "2008-09-27",
                                     climatic_var = "Tmin")[,"Tmin"],
                   c(1663,-5.36)) #-5.36 es una coordenada
  expect_identical(get_daily_climate(coords = sf::st_as_sf(data.frame(lon = -5.36, lat = 37.40),
                                                           coords = c("lon", "lat")),
                                     period = c("2008-01-27","2008-09-27"),
                                     climatic_var = "Tmin")[,"Tmin"],
                   c(553,1663))
  #Input SpatVector
  expect_equal(get_daily_climate(coords = terra::vect("POLYGON ((-5 38, -5 37.5, -4.5 37.5, -4.5 38, -5 38))"),
                                     period = "2008-09-27",
                                     climatic_var = "Tmin",
                                     fun = "mean")[,"Tmin"],
                   1546.01, tolerance=1e-2)
  expect_equal(get_daily_climate(coords = terra::vect("POLYGON ((-5 38, -5 37.5, -4.5 37.5, -4.5 38, -5 38))"),
                                     period = c("2008-01-27","2008-09-27"),
                                     climatic_var = "Tmin",
                                     fun = "mean")[,"Tmin"],
                   c(408.99,1546.01), tolerance=1e-2)
})
