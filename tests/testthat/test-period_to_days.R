test_that("period_to_days works with numeric input", {
  expect_identical(period_to_days(period = 2009),
                   seq.Date(from = as.Date("2009-01-01"), to = as.Date("2009-12-31"), by = 1))
  expect_identical(period_to_days(period = 2008),
              seq.Date(from = as.Date("2008-01-01"), to = as.Date("2008-12-31"), by = 1))
  expect_identical(period_to_days(period = c(2008:2010)),
                   seq.Date(from = as.Date("2008-01-01"), to = as.Date("2010-12-31"), by = 1))
  expect_identical(period_to_days(period = 2008:2010),
                   seq.Date(from = as.Date("2008-01-01"), to = as.Date("2010-12-31"), by = 1))
  expect_identical(period_to_days(period = c(2008:2010, 2012)),
                   c(seq.Date(from = as.Date("2008-01-01"), to = as.Date("2010-12-31"), by = 1),
                     seq.Date(from = as.Date("2012-01-01"), to = as.Date("2012-12-31"), by = 1)))
  expect_identical(period_to_days(period = c(2008:2010, 2012, 2014)),
                   c(seq.Date(from = as.Date("2008-01-01"), to = as.Date("2010-12-31"), by = 1),
                     seq.Date(from = as.Date("2012-01-01"), to = as.Date("2012-12-31"), by = 1),
                     seq.Date(from = as.Date("2014-01-01"), to = as.Date("2014-12-31"), by = 1)))
})



test_that("period_to_days throws error with badly formatted dates", {
  expect_error(period_to_days("2008-01-5"))
  expect_error(period_to_days("2008-01-5:2008-01-10"))
  expect_error(period_to_days(c("2008-01-5", "2008-01-10")))
})


test_that("period_to_days works with character input", {

  expect_identical(period_to_days(period = "2008-09-27"),
                   seq.Date(from = as.Date("2008-09-27"), to = as.Date("2008-09-27"), by = 1))
  expect_identical(period_to_days(period = c("2008-09-27", "2008-01-27")),
                   c(seq.Date(from = as.Date("2008-09-27"), to = as.Date("2008-09-27"), by = 1),
                     seq.Date(from = as.Date("2008-01-27"), to = as.Date("2008-01-27"), by = 1)))
  expect_identical(period_to_days(period = c("2008-01-27:2008-09-27")),
                   seq.Date(from = as.Date("2008-01-27"), to = as.Date("2008-09-27"), by = 1))
  expect_identical(period_to_days(period = "2008-01-27:2008-09-27"),
                   seq.Date(from = as.Date("2008-01-27"), to = as.Date("2008-09-27"), by = 1))
  expect_identical(period_to_days(period = c("2008-01-27:2008-09-27", "2017-01-27")),
                   c(seq.Date(from = as.Date("2008-01-27"), to = as.Date("2008-09-27"), by = 1),
                     as.Date("2017-01-27")))
})


