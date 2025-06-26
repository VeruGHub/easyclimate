
test_that("built key is correct", {
  expect_identical(build_key("Tmin", 2008, temp_res = "day"),
                   "v31_cogeo/DailyDataRasters/tmin/DownscaledTmin2008_cogeo.tif")
  expect_identical(build_key("Tavg", 2008, temp_res = "month"),
                   "v31_cogeo/MonthlyDataRasters/tavg/DownscaledTavg2008MonthlyAvg_cogeo.tif")
  expect_identical(build_key("Tmax", 2008, temp_res = "year"),
                   "v31_cogeo/YearlyDataRasters/tmax/DownscaledTmax2008YearlyAvg_cogeo.tif")
  expect_identical(build_key("Prcp", 2008, temp_res = "year"),
                   "v31_cogeo/YearlyDataRasters/prcp/DownscaledPrcp2008YearlySum_cogeo.tif")

  })

