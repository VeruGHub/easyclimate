
test_that("period_to_months throws error with badly formatted dates", {
  expect_error(period_to_months("2008-1"))
  expect_error(period_to_months("2008-1:2008-3"))
  expect_error(period_to_months(c("2008-1", "2008-10")))
})


test_that("period_to_monts works with number input", {
  expect_identical(period_to_months(period = 2010),
                   c("2010-01", "2010-02","2010-03","2010-04","2010-05",
                             "2010-06","2010-07","2010-08","2010-09","2010-10",
                             "2010-11","2010-12"))
  expect_identical(period_to_months(period = 2010:2011),
                   c("2010-01", "2010-02","2010-03","2010-04","2010-05",
                             "2010-06","2010-07","2010-08","2010-09","2010-10",
                             "2010-11","2010-12",
                             "2011-01", "2011-02","2011-03","2011-04","2011-05",
                             "2011-06","2011-07","2011-08","2011-09","2011-10",
                             "2011-11","2011-12"))
})


test_that("period_to_months works with character input", {

  expect_identical(period_to_months(period = "2008-09"),
                   "2008-09")
  expect_identical(period_to_months(period = c("2008-01", "2008-09")),
                   c("2008-01", "2008-09"))
  expect_identical(period_to_months(period = c("2008-01:2008-09", "2017-01")),
                   c("2008-01","2008-02","2008-03","2008-04","2008-05",
                     "2008-06","2008-07","2008-08","2008-09","2017-01"))
  expect_identical(period_to_months(period = c(2008)),
                   c("2008-01","2008-02","2008-03","2008-04","2008-05",
                     "2008-06","2008-07","2008-08","2008-09","2008-10",
                     "2008-11","2008-12"))
})

