library("ammon")
library("dplyr")
#################################################################################################
context("Convert Output")
#################################################################################################

test_that("convertOutput works for the CHAI version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convertOutput(system.file("extdata", "dummyCHAI.csv", package = "ammon")), is_a("MicroPEM"))

})

test_that("convertOutput works for the Columbia version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convertOutput(system.file("extdata", "dummyColumbiaUnix.csv",
                                                           package = "ammon")), is_a("MicroPEM"))

})

test_that("convertOutput works for the Columbia2 version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convertOutput(system.file("extdata", "dummyColumbiaUnix2.csv", package =
                                          "ammon")), is_a("MicroPEM"))

})
