library("RTImicropem")
library("lubridate")
#################################################################################################
context("cleaningMeasures")
#################################################################################################
test_that("cleaningMeasures outputs a micropem object",{
  data("micropemChai")
  cleanDatamicropem <- cleaningMeasures(micropemObject=micropemChai)
  expect_that(cleanDatamicropem, is_a("micropem"))
  cleanDatamicropem <- cleaningMeasures(micropemObject=micropemChai,
                                        hepaStart = TRUE, hepaEnd = TRUE)
  expect_that(cleanDatamicropem, is_a("micropem"))
})
