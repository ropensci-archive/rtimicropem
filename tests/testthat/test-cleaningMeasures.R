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
