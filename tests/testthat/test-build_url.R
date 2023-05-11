test_that("wrong climatic_var gives error", {
  expect_error(build_url("precip", 2010))
})

test_that("year below 1950 or above 2022 gives error", {
  expect_error(build_url("Tmin", 1949))
  expect_error(build_url("Tmin", 2030))
})

test_that("built url is correct", {
  expect_identical(build_url("Tmin", 2008),
                   "ftp://palantir.boku.ac.at/Public/ClimateData/v4_cogeo/AllDataRasters/tmin/DownscaledTmin2008_cogeo.tif")
})

test_that("built url is correct for v3", {
  expect_identical(build_url("Tmin", 2008, version = 3),
                   "ftp://palantir.boku.ac.at/Public/ClimateData/v3_cogeo/AllDataRasters/tmin/DownscaledTmin2008_cogeo.tif")
})

# Better to check server status differently than giving package error if server not working
# test_that("server is running and built url exists", {
#   skip_on_cran()
#   skip_on_ci()
#   expect_true(check_server())
# })
