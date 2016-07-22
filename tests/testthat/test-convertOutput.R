library("rtimicropem")
library("dplyr")
#################################################################################################
context("Convert Output")
#################################################################################################

test_that("convert_output works for the CHAI version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convert_output(system.file("extdata", "CHAI.csv", package = "rtimicropem")), is_a("micropem"))

})

test_that("convert_output works for the Columbia version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convert_output(system.file("extdata", "ColumbiaUnix.csv",
                                                           package = "rtimicropem")), is_a("micropem"))

})

test_that("convert_output works for the Columbia2 version of output", {
  skip_on_cran()
  #skip_on_travis()
  expect_that(convert_output(system.file("extdata", "ColumbiaUnix2.csv", package =
                                          "rtimicropem")), is_a("micropem"))

})
