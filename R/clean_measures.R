#' Outputs clean rh_corrected_nephelometer measures for analysis.
#'
#' @param micropem_object the MicroPEM object
#' @param hepa_start Boolean indicating whether there were measurements with HEPA filters at the beginning.
#' @param hepa_end Boolean indicating whether there were measurements with HEPA filters at the end.
#' @return A MicroPEM object.
#' @examples
#' data(micropemChai)
#' cleanMP <- clean_measures(micropemChai)
#' cleanMP$summary()
#' @details
#' rh_corrected_nephelometer values are set to NA if they are negative or
#' if the RH at the same time is higher than 90\%.
#' rh_corrected_nephelometer values are also corrected for the HEPA zeroings (start and end, if there were done):
#' if a stable period longer than 3 minutes can be identified for the HEPA period,
#' using the changepoint \code{\link[changepoint]{cpt.mean}} function, there is a zero value.
#' There can be no zero values, only one (beginning or end) or two.
#' If there is only one zero value, it is substracted from all rh_corrected_nephelometer values.
#' If there are two, a linear interpolation is done between the two values and the resulting vector
#' is substracted from the rh_corrected_nephelometer values.
#' @export
#'
clean_measures <- function(micropem_object,
                             hepa_start = FALSE,
                             hepa_end = FALSE) {
    # use a clone!
   micropem_object2 <- micropem_object$clone()
    # If relative humidity is higher than 90%
    # then the corresponding rh_corrected_nephelometer values should be ignored
    to_be_erased <- which(!is.na(micropem_object2$
                                 measures$rh) &
                          micropem_object2$
                          measures$rh >= 90)
    micropem_object2$measures$rh_corrected_nephelometer[to_be_erased] <- NA

    # If relative humidity is negative
    # then the corresponding rh_corrected_nephelometer values should be ignored
    to_be_erased <- which(!is.na(micropem_object2$
                                 measures$rh) &
                          micropem_object2$
                          measures$rh < 0)
    micropem_object2$measures$rh_corrected_nephelometer[to_be_erased] <- NA

    # correct time series using HEPA measures
    hepa_table <- find_zeros(micropem_object2$
                             measures$rh_corrected_nephelometer,
                           micropem_object2$
                             measures$datetime,
                           hepa_start,
                           hepa_end)
    # More than 3 minutes stable reading
    if (hepa_table$duration[1] >= 180){
      value1 <- hepa_table$value[1]
    }
    else{
      value1 <- 0
    }

    if (hepa_table$duration[2] >= 180){
      value2 <- hepa_table$value[2]
    }
    else{
      value2 <- 0
    }

    # values to substract
    if (value1 == 0 | value2 == 0){
      correction <- rep(value1 + value2,
                        length = nrow(
                          micropem_object2$measures
                        ))
    }
    else{
      correction <- seq(from = value1,
                        to = value2,
                        length = nrow(
                          micropem_object2$measures
                          ))
    }

    # now correct the measures
    micropem_object2$measures <- dplyr::mutate_(micropem_object2$measures,
                                             rh_corrected_nephelometer =
                                               ~ (rh_corrected_nephelometer -
                                               correction))

    # keep trace of modifications
    micropem_object2$original <- FALSE

    return(micropem_object2)
}
