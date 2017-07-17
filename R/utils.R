############################################################
#                                                          #
#           function for transforming the dates            #
#                                                          #
############################################################

transform_date <- function(date){
  date <- tolower(date)
  date <- gsub("jan", "01", date)
  date <- gsub("feb", "02", date)
  date <- gsub("mar", "03", date)
  date <- gsub("apr", "04", date)
  date <- gsub("may", "05", date)
  date <- gsub("jun", "06", date)
  date <- gsub("jul", "07", date)
  date <- gsub("aug", "08", date)
  date <- gsub("sep", "09", date)
  date <- gsub("oct", "10", date)
  date <- gsub("nov", "11", date)
  date <- gsub("dec", "12", date)
  # day moismois year court -> mois day year long

  splitted_date <- stringr::str_split(date[grepl("\\/....\\/", date)], "\\/")
  day <- unlist(lapply(splitted_date, "[", 1))
  month <- stringr::str_sub(unlist(lapply(splitted_date, "[", 2)), 1, 2)
  year <- unlist(lapply(splitted_date, "[", 3))
  date[grepl("\\/....\\/", date)] <-
    paste(month, day, paste0("20", year), sep = "/")

  if (length(date) == 1){
    output <-
      lubridate::parse_date_time(date, orders = c("dmy", "mdy"),
                                 quiet = TRUE)
  }else{
    # now find the best format if several dates
    # which is the one giving the smallest time span
    date_try1 <- lubridate::parse_date_time(date, orders = "dmy", quiet = TRUE)
    date_try2 <- lubridate::parse_date_time(date, orders = "mdy", quiet = TRUE)

    if (!any(is.na(date_try1)) &
       !any(is.na(date_try2))){
      diff1 <- as.numeric(sum(diff(date_try1, units = "secs")))
      diff2 <- as.numeric(sum(diff(date_try2, units = "secs")))

      if (diff1 > diff2){
        output <- date_try2
      }else{
        output <- date_try1
      }
    }else{
      if (any(is.na(date_try1))){
        output <- date_try2
      }else{
        output <- date_try1
      }
    }


  }

  if(all(is.na(output))){
    output <- lubridate::ymd(date)
  }

  return(output)
}

############################################################
#                                                          #
#            function for plotting one variable            #
#                                                          #
############################################################


make_plot_one_param <- function(x, donnees, title){
  data <- dplyr::filter_(donnees, lazyeval::interp(~parameter == x))

  rbokeh::figure(width = 700, height = 175)  %>%
    rbokeh::ly_points(x = datetime, y = value, data = data) %>%
    rbokeh::ly_text(min(data$datetime), stats::quantile(data$value, 0.95),
                    text = paste(x, title),
            font_size = "14pt") %>%
    rbokeh::ly_abline(h = 0)
}

############################################################
#                                                          #
#                function for finding zeros                #
#                                                          #
############################################################


find_zeros <- function(nephelometer = NULL,
                       mp_timedate = NULL,
                       hepa_start = TRUE,
                       hepa_end = TRUE){

  nephelometer <- nephelometer[!is.na(nephelometer)]
  # trim first and last values
  nephelometer <- nephelometer[
    2:(length(nephelometer) - 1)]
  mp_timedate <- mp_timedate[
    2:(length(mp_timedate) - 1)]

  if (hepa_start){
    # changepoint for the beginning
    mp_mean1  <- changepoint::cpt.mean(nephelometer[1:50],
                                       method = "AMOC",
                                       penalty = "BIC")
    start1 <-  mp_timedate[1]
    end1 <-  mp_timedate[mp_mean1@cpts[1]]
    value1 <- mp_mean1@param.est$mean[1]
  }
  else{
    start1 <- lubridate::ymd_hms("1900-01-01 12:12:12")
    end1 <- lubridate::ymd_hms("2000-01-01 12:12:12")
    value1 <- 0
  }

  if (hepa_end){
    # changepoint for the end
    mean2.MP  <- changepoint::cpt.mean(utils::tail(nephelometer, n = 50),
                                       method = "AMOC",
                                       penalty = "BIC")
    start2 <- utils::tail(mp_timedate, n = 50)[
      utils::tail(mean2.MP@cpts, n = 2)][1]
    end2 <- utils::tail(mp_timedate, n = 1)
    value2 <- utils::tail(mean2.MP@param.est$mean, n = 1)
  }
  else{
    start2 <- lubridate::ymd_hms("1900-01-01 12:12:12")
    end2 <- lubridate::ymd_hms("2000-01-01 12:12:12")
    value2 <- 0
  }
  zeros_table1 <- data.frame(start = start1,
                            end = end1,
                            duration =
                              difftime(end1,
                                       start1,
                                       units = "secs"),
                            value = value1)
  zeros_table2 <- data.frame(start = start2,
                            end = end2,
                            duration =
                              difftime(end2,
                                       start2,
                                       units = "secs"),
                            value = value2)
  zeros_table <- rbind(zeros_table1,
                      zeros_table2)
  zeros_table <- dplyr::tbl_df(zeros_table)
  return(zeros_table)
}
