test_that("wrong climatic_var gives error", {
  expect_error(build_url("precip", 2010))
})

test_that("year below 1950 or above 2017 gives error", {
  expect_error(build_url("Tmin", 1949))
  expect_error(build_url("Tmin", 2018))
})

test_that("built url is correct", {
  expect_identical(build_url("Tmin", 2008),
                   "ftp://palantir.boku.ac.at/Public/ClimateData/v2_cogeo/AllDataRasters/tmin/DownscaledTmin2008_cogeo.tif")
})

test_that("built url exists", {
  expect_true(RCurl::url.exists(build_url("Tmin", 2008)))
})
