#' Outputs clean rh_corrected_nephelometer measures for analysis.
#'
#' @importFrom dplyr tbl_df mutate
#' @importFrom changepoint cpt.mean
#' @importFrom lubridate ymd_hms
#' @param micropemObject the MicroPEM object
#' @param hepaStart Boolean indicating whether there were measurements with HEPA filters at the beginning.
#' @param hepaEnd Boolean indicating whether there were measurements with HEPA filters at the end.
#' @return A MicroPEM object.
#' @examples
#' data(micropemChai)
#' cleanMP <- cleaningMeasures(micropemChai)
#' cleanMP$summary()
#' @details
#' rh_corrected_nephelometer values are set to NA if they are negative or
#' if the RH at the same time is higher than 90\%.
#' rh_corrected_nephelometer values are also corrected for the HEPA zeroings (start and end, if there were done):
#' if a stable period longer than 3 minutes can be identified for the HEPA period,
#' using the changepoint cpt.mean function, there is a zero value.
#' There can be no zero values, only one (beginning or end) or two.
#' If there is only one zero value, it is substracted from all rh_corrected_nephelometer values.
#' If there are two, a linear interpolation is done between the two values and the resulting vector
#' is substracted from the rh_corrected_nephelometer values.
#' @export
#'
cleaningMeasures <- function(micropemObject,
                             hepaStart = FALSE,
                             hepaEnd = FALSE) {
    # use a clone!
   micropemObject2 <- micropemObject$clone()
    # If relative humidity is higher than 90%
    # then the corresponding rh_corrected_nephelometer values should be ignored
    toBeErased <- which(!is.na(micropemObject2$
                                 measures$rh) &
                          micropemObject2$
                          measures$rh >= 90)
    micropemObject2$measures$rh_corrected_nephelometer[toBeErased] <- NA

    # If relative humidity is negative
    # then the corresponding rh_corrected_nephelometer values should be ignored
    toBeErased <- which(!is.na(micropemObject2$
                                 measures$rh) &
                          micropemObject2$
                          measures$rh < 0)
    micropemObject2$measures$rh_corrected_nephelometer[toBeErased] <- NA

    # correct time series using HEPA measures
    tableHEPA <- findZeros(micropemObject2$
                             measures$rh_corrected_nephelometer,
                           micropemObject2$
                             measures$datetime,
                           hepaStart,
                           hepaEnd)
    # More than 3 minutes stable reading
    if (tableHEPA$duration[1] >= 180){
      value1 <- tableHEPA$value[1]
    }
    else{
      value1 <- 0
    }

    if (tableHEPA$duration[2] >= 180){
      value2 <- tableHEPA$value[2]
    }
    else{
      value2 <- 0
    }

    # values to substract
    if (value1 == 0 | value2 == 0){
      correction <- rep(value1 + value2,
                        length = nrow(
                          micropemObject2$measures
                        ))
    }
    else{
      correction <- seq(from = value1,
                        to = value2,
                        length = nrow(
                          micropemObject2$measures
                          ))
    }

    # now correct the measures
    micropemObject2$measures <- dplyr::mutate(micropemObject2$measures,
                                             rh_corrected_nephelometer =
                                               rh_corrected_nephelometer -
                                               correction)

    # keep trace of modifications
    micropemObject2$original <- FALSE

    return(micropemObject2)
}
