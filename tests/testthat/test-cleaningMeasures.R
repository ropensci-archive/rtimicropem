library("ammon")
library("lubridate")
#################################################################################################
context("cleaningMeasures")
#################################################################################################
test_that("cleaningMeasures outputs a MicroPEM object",{
  data("dummyMicroPEMChai")
  cleanDataMicroPEM <- cleaningMeasures(MicroPEMObject=dummyMicroPEMChai)
  expect_that(cleanDataMicroPEM, is_a("MicroPEM"))
  cleanDataMicroPEM <- cleaningMeasures(MicroPEMObject=dummyMicroPEMChai,
                                        hepaStart = TRUE, hepaEnd = TRUE)
  expect_that(cleanDataMicroPEM, is_a("MicroPEM"))
})

test_that("cleaningMeasures also works for MicroPEM that were truncated",{
  data("dummyMicroPEMChai")
  shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,untilTime=NULL,
                                    fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) +
                                      hours(12))
  cleanDataMicroPEM <- cleaningMeasures(MicroPEMObject=shorterMicroPEM)
  expect_that(cleanDataMicroPEM, is_a("MicroPEM"))
})
