#' Generates alarm indicators for a micropem object.
#'
#' @param micropem_object the MicroPEM object
#' @return A \code{data table} with a column for the name of the indicator and a column with booleans. If no
#' alarm was flagged, the \code{data table} only has one line indicating that all is good.
#' @examples
#' data(micropemChai)
#' chai_alarm(micropemChai)
#' @export
#'
chai_alarm <- function(micropem_object) {
    alarm <- NULL
    action <- NULL
    # nephelometer slope
    if (micropem_object$settings[["nephelometer_slope"]] != 3) {
        alarm <- c(alarm, "Nephelometer slope is not 3")
        action <- c(action, "Please contact Sreekanth")
    }

    # flow should be between 0.45 and 0.55
    if (any(micropem_object$measures$flow < 0.45, na.rm = TRUE) |
        any(micropem_object$measures$flow > 0.55, na.rm = TRUE)) {
        alarm <- c(alarm, "Flow outside of normal range at least once")
        action <- c(action, "Please contact Sreekanth")
    }

    # Not too many measures
    no_na <- sum(!is.na(micropem_object$measures$rh_corrected_nephelometer))
    if (no_na > 10000) {
        alarm <- c(alarm, "Maybe two days of measures")
        action <- c(action, "Please contact Sreekanth")
    }

    # More than 2% negative values
    no_neg <- sum(micropem_object$measures$rh_corrected_nephelometer < 0,
                  na.rm = TRUE)

    two_percent <- 0.02 * sum(!is.na(micropem_object$measures$
                                       rh_corrected_nephelometer))

    if (no_neg > two_percent) {
        alarm <- c(alarm, "Too many negative values")
        action <- c(action, "Please contact Sreekanth")
    }
    if (is.null(alarm)) {
        alarm <- c("All is good")
        action <- c(action, "Nothing to do")
    }
    alarms_table <- data.frame(alarm = alarm, action = action)
    alarms_table <- tibble::as_tibble(alarms_table)
    return(alarms_table)
}
