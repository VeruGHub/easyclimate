
test_that("period_to_months throws error with badly formatted dates", {
  expect_error(period_to_months("2008-1"))
  expect_error(period_to_months("2008-1:2008-3"))
  expect_error(period_to_months(c("2008-1", "2008-10")))
})


test_that("period_to_monts works with number input", {
  expect_identical(period_to_months(period = 2010),
                   as.Date(c("2010-01-01", "2010-02-01","2010-03-01","2010-04-01","2010-05-01",
                             "2010-06-01","2010-07-01","2010-08-01","2010-09-01","2010-10-01",
                             "2010-11-01","2010-12-01")))
  expect_identical(period_to_months(period = 2010:2011),
                   as.Date(c("2010-01-01", "2010-02-01","2010-03-01","2010-04-01","2010-05-01",
                             "2010-06-01","2010-07-01","2010-08-01","2010-09-01","2010-10-01",
                             "2010-11-01","2010-12-01",
                             "2011-01-01", "2011-02-01","2011-03-01","2011-04-01","2011-05-01",
                             "2011-06-01","2011-07-01","2011-08-01","2011-09-01","2011-10-01",
                             "2011-11-01","2011-12-01")))
})


test_that("period_to_months works with character input", {

  expect_identical(period_to_months(period = "2008-09"),
                   as.Date(paste0("2008-09", "-01")))
  expect_identical(period_to_months(period = c("2008-01", "2008-09")),
                   as.Date(c(paste0("2008-01", "-01"), paste0("2008-09", "-01"))))
  expect_identical(period_to_months(period = c("2008-01:2008-09")),
                   seq.Date(from = as.Date(paste0("2008-01", "-01")), to = as.Date(paste0("2008-09", "-01")), by = "month"))
  expect_identical(period_to_months(period = "2008-01:2008-09"),
                   seq.Date(from = as.Date(paste0("2008-01", "-01")), to = as.Date(paste0("2008-09", "-01")), by = "month"))
  expect_identical(period_to_months(period = c("2008-01:2008-09", "2017-01")),
                   c(seq.Date(from = as.Date(paste0("2008-01", "-01")), to = as.Date(paste0("2008-09", "-01")), by = "month"),
                     as.Date(paste0("2017-01", "-01"))))
})
