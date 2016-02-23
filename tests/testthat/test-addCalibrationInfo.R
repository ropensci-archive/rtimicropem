library("ammon")
#################################################################################################
context("addCalibrationInfo")
#################################################################################################
test_that("addCalibrationInfo outputs a MicroPEM object",{
  data(dummyMicroPEMChai)
  expect_that(addCalibrationInfo(dummyMicroPEMChai), is_a("MicroPEM"))
})
