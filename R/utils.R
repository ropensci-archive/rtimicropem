# function for transforming the dates
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

  if(grepl("\\/....\\/", date)){
    splitted_date <- stringr::str_split(date[grepl("\\/....\\/", date)], "\\/")
    day <- unlist(lapply(splitted_date, "[", 1))
    month <- stringr::str_sub(unlist(lapply(splitted_date, "[", 2)), 1, 2)
    year <- unlist(lapply(splitted_date, "[", 3))
    date[grepl("\\/....\\/", date)] <- paste(month, day, paste0("20",year), sep = "/")
  }

  if(length(date) == 1){
    output <- lubridate::parse_date_time(date, orders = c("dmy", "mdy"), quiet = TRUE)
  }else{
    # now find the best format if several dates
    # which is the one giving the smallest time span
    date_try1 <- lubridate::parse_date_time(date, orders = "dmy", quiet = TRUE)
    date_try2 <- lubridate::parse_date_time(date, orders = "mdy", quiet = TRUE)

    if(!any(is.na(date_try1)) &
       !any(is.na(date_try2))){
      diff1 <- as.numeric(sum(diff(date_try1, units = "secs")))
      diff2 <- as.numeric(sum(diff(date_try2, units = "secs")))

      if(diff1 > diff2){
        output <- date_try2
      }else{
        output <- date_try1
      }
    }else{
      if(any(is.na(date_try1))){
        output <- date_try2
      }else{
        output <- date_try1
      }
    }


  }
  return(output)
}
