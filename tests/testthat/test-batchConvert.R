#################################################################################################
context("batchConvert")
#################################################################################################
test_that("batchConvert outputs files",{
  skip_on_cran()
  path_to_directory <- system.file("batchtestfiles", package = "ammon")
  batchConvert(path_to_directory, version = "CHAI")
  expect_true(file.exists(paste0(path_to_directory, "/", "settings.csv")))
  expect_true(file.exists(paste0(path_to_directory, "/", "measures.csv")))

})

test_that("batch_read_agd outputs errors",{
  skip_on_cran()
  path_to_directory <- system.file("batchtestfiles", package = "ammon")
  expect_error(batchConvert(path_to_directory, version = "CHAI"),"There are already")


  file.remove(paste0(path_to_directory, "/", "settings.csv"))
  file.remove(paste0(path_to_directory, "/", "measures.csv"))
})
