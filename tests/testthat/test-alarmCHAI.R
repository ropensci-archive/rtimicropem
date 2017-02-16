library("rtimicropem")
#################################################################################################
context("alarmCHAI")
#################################################################################################
test_that("alarmCHAI outputs a data table",{
  data(micropemChai)
  expect_that(alarmCHAI(micropemChai), is_a("tbl_df"))
})

test_that("we get the right error messages",{
  data(micropemChai)
  micropemChai2 <- micropemChai$clone()
  micropemChai2$settings$nephelometerSlope <- 3
  micropemChai2$measures$flow[1] <- 100
  expect_equal(as.character(alarmCHAI(micropemChai2)$Alarm[1]),
               "Flow outside of normal range at least once")

  micropemChai2 <- micropemChai$clone()
  micropemChai2$settings$nephelometerSlope <- 300
  expect_equal(as.character(alarmCHAI(micropemChai2)$Alarm[1]),
               "Nephelometer slope is not 3")


  data("micropemC1")
  micropemC1bis <- micropemC1$clone()
  micropemC1bis$measures$flow <- 0.5
  expect_equal(as.character(alarmCHAI(micropemC1bis)$Alarm[1]),
               "Maybe two days of measures")

  micropemChai2 <- micropemChai$clone()
  micropemChai2$settings$nephelometerSlope <- 3
  micropemChai2$measures$flow <- rep(0.5, length(micropemChai2$measures$flow))
  expect_equal(as.character(alarmCHAI(micropemChai2)$Alarm[1]),
               "All is good")

  micropemChai2 <- micropemChai$clone()
  micropemChai2$settings$nephelometerSlope <- 3
  micropemChai2$measures$flow <- rep(0.5, length(micropemChai2$measures$flow))
  micropemChai2$measures$rh_corrected_nephelometer <-
    rep(-1, length(micropemChai2$measures$rh_corrected_nephelometer))
  expect_equal(as.character(alarmCHAI(micropemChai2)$Alarm[2]),
               "Too many negative values")
})
