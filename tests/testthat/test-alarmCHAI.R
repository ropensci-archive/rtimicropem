library("ammon")
#################################################################################################
context("alarmCHAI")
#################################################################################################
test_that("alarmCHAI outputs a data table",{
  data(dummyMicroPEMChai)
  expect_that(alarmCHAI(dummyMicroPEMChai), is_a("tbl_df"))
})

test_that("we get the right error messages",{
  data(dummyMicroPEMChai)
  dummyMicroPEMChai2 <- dummyMicroPEMChai$clone()
  dummyMicroPEMChai2$control$nephelometerSlope <- 3
  dummyMicroPEMChai2$measures$flow[1] <- 100
  expect_equal(as.character(alarmCHAI(dummyMicroPEMChai2)$Alarm[1]),
               "Flow outside of normal range at least once")

  dummyMicroPEMChai2 <- dummyMicroPEMChai$clone()
  dummyMicroPEMChai2$control$nephelometerSlope <- 300
  expect_equal(as.character(alarmCHAI(dummyMicroPEMChai2)$Alarm[1]),
               "Nephelometer slope is not 3")


  data("dummyMicroPEMC1")
  dummyMicroPEMC1bis <- dummyMicroPEMC1$clone()
  dummyMicroPEMC1bis$measures$flow <- 0.5
  expect_equal(as.character(alarmCHAI(dummyMicroPEMC1bis)$Alarm[1]),
               "Maybe two days of measures")

  dummyMicroPEMChai2 <- dummyMicroPEMChai$clone()
  dummyMicroPEMChai2$control$nephelometerSlope <- 3
  dummyMicroPEMChai2$measures$flow <- rep(0.5, length(dummyMicroPEMChai2$measures$flow))
  expect_equal(as.character(alarmCHAI(dummyMicroPEMChai2)$Alarm[1]),
               "All is good")

  dummyMicroPEMChai2 <- dummyMicroPEMChai$clone()
  dummyMicroPEMChai2$control$nephelometerSlope <- 3
  dummyMicroPEMChai2$measures$flow <- rep(0.5, length(dummyMicroPEMChai2$measures$flow))
  dummyMicroPEMChai2$measures$rh_corrected_nephelometer <- rep(-1, length(dummyMicroPEMChai2$measures$rh_corrected_nephelometer))
  expect_equal(as.character(alarmCHAI(dummyMicroPEMChai2)$Alarm[2]),
               "Too many negative values")
})
