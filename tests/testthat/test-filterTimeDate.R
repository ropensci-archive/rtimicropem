library("ammon")
library("lubridate")
#################################################################################################
context("filterTimeDate")
###############################################################################################

test_that("filterTimeDate outputs a MicroPEM object",{
  data("dummyMicroPEMChai")
  shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,untilTime=NULL,
                                    fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12))
  expect_that(shorterMicroPEM, is_a("MicroPEM"))
})

test_that("We get the right length in one example",{
  data("dummyMicroPEMChai")
  shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,untilTime=NULL,
                                    fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12))
  expect_that(nrow(shorterMicroPEM$measures), equals(8678))
})

test_that("it works with several calls",{
  data("dummyMicroPEMChai")
  shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,
                                    fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12))
  expect_that(shorterMicroPEM, is_a("MicroPEM"))
  shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,
                                    untilTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12))
  expect_that(shorterMicroPEM, is_a("MicroPEM"))
  shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,
                                    fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12),
                                    untilTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(13))
  expect_that(shorterMicroPEM, is_a("MicroPEM"))
})

test_that("Arguments for time are checked",{
  expect_error(filterTimeDate(MicroPEMObject=dummyMicroPEMChai), "Provide at least one of the two times fromTime and untilTime.")
  expect_error(filterTimeDate(MicroPEMObject=dummyMicroPEMChai,
                              fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(15),
                              untilTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(13)),
               "fromTime must be smaller than untilTime.")
})
