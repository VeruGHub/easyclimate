
test_that("period_to_years throws error with badly formatted dates", {
  expect_error(period_to_years("2008"))
  expect_error(period_to_years("200"))
  expect_error(period_to_years("2008-01:2008-03"))
})


test_that("period_to_monts works with different inputs", {
  expect_identical(period_to_years(period = 2010),
                   2010)
  expect_identical(period_to_years(period = 2010:2011),
                   c(2010, 2011))
  expect_identical(period_to_years(period = c(2010:2013, 2020)),
                   c(2010, 2011, 2012, 2013, 2020))
})

