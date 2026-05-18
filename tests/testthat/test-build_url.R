test_that("wrong climatic_var gives error", {
  expect_error(build_url("precip", 2010))
})

latest_year <- get_latest_year()

test_that(sprintf("year below 1950 or above %d gives error", latest_year), {
  expect_error(build_url("Tmin", 1949))
  expect_error(build_url("Tmin", latest_year + 1))
})

test_that("built url is correct for daily climate", {
  expect_identical(build_url("Tmin", 2008, version = "4"),
                   "ftp://palantir.boku.ac.at/Public/ClimateData/v4_cogeo/AllDataRasters/tmin/DownscaledTmin2008_cogeo.tif")
})

test_that("built url is correct for daily climate", {
  expect_identical(build_url("Tmin", 2008, version = "last"),
                   "https://s3.boku.ac.at/oekbwaldklimadaten/v31_cogeo/DailyDataRasters/tmin/DownscaledTmin2008_cogeo.tif")
})

