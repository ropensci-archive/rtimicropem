findZeros <- function(nephelometer = NULL,
                      timeDateMP = NULL,
                      hepaStart = TRUE,
                      hepaEnd = TRUE){

  nephelometer <- nephelometer[!is.na(nephelometer)]
  # trim first and last values
  nephelometer <- nephelometer[
    2:(length(nephelometer) - 1)]
  timeDateMP <- timeDateMP[
    2:(length(timeDateMP) - 1)]

  if (hepaStart){
    # changepoint for the beginning
    mean1.MP  <- changepoint::cpt.mean(nephelometer[1:50],
                                       method = "AMOC",
                                       penalty = "BIC")
    start1 <-  timeDateMP[1]
    end1 <-  timeDateMP[mean1.MP@cpts[1]]
    value1 <- mean1.MP@param.est$mean[1]
  }
  else{
    start1 <- lubridate::ymd_hms("1900-01-01 12:12:12")
    end1 <- lubridate::ymd_hms("2000-01-01 12:12:12")
    value1 <- 0
  }

  if (hepaEnd){
    # changepoint for the end
    mean2.MP  <- changepoint::cpt.mean(tail(nephelometer, n = 50),
                                       method = "AMOC",
                                       penalty = "BIC")
    start2 <- tail(timeDateMP, n = 50)[
      tail(mean2.MP@cpts, n = 2)][1]
    end2 <- tail(timeDateMP, n = 1)
    value2 <- tail(mean2.MP@param.est$mean, n = 1)
  }
  else{
    start2 <- lubridate::ymd_hms("1900-01-01 12:12:12")
    end2 <- lubridate::ymd_hms("2000-01-01 12:12:12")
    value2 <- 0
  }
  tableZeros1 <- data.frame(start = start1,
                            end = end1,
                            duration =
                              difftime(end1,
                                       start1,
                                       units = "secs"),
                            value = value1)
  tableZeros2 <- data.frame(start = start2,
                            end = end2,
                            duration =
                              difftime(end2,
                                       start2,
                                       units = "secs"),
                            value = value2)
  tableZeros <- rbind(tableZeros1,
                      tableZeros2)
  tableZeros <- dplyr::tbl_df(tableZeros)
  return(tableZeros)
}
