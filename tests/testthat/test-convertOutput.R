library("ammon")
library("dplyr")
#################################################################################################
context("Convert Output")
#################################################################################################

test_that("convertOutput works for the CHAI version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convertOutput(system.file("extdata", "dummyCHAI.csv", package = "ammon"),
                            version="CHAI"), is_a("MicroPEM"))

})

test_that("convertOutput works for the Columbia version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(MicroPEMExample <- convertOutput(system.file("extdata", "dummyColumbia.csv",
                                                           package = "ammon"),
                                               version="Columbia1"), is_a("MicroPEM"))

})

test_that("convertOutput works for the Columbia2 version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convertOutput(system.file("extdata", "dummyColumbia2.csv", package =
                                          "ammon"),
                            version="Columbia2"), is_a("MicroPEM"))

})

test_that("One needs to provide a version",{
  skip_on_cran()
  expect_error(convertOutput(system.file("extdata", "dummyColumbia2.csv", package = "ammon")), "Please provide a value for version.")

})
