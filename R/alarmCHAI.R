#' Generates alarm indicators for a MicroPEMObject.
#'
#' @importFrom dplyr tbl_df
#' @param MicroPEMObject the MicroPEM object
#' @return A \code{data table} with a column for the name of the indicator and a column with booleans. If no
#' alarm was flagged, the \code{data table} only has one line indicating that all is good.
#' @examples
#' data(dummyMicroPEMChai)
#' alarmCHAI(dummyMicroPEMChai)
#' @export
#'
alarmCHAI <- function(MicroPEMObject) {
    Alarm <- NULL
    Action <- NULL
    # nephelometer slope
    if (MicroPEMObject$control$nephelometerSlope != 3) {
        Alarm <- c(Alarm, "Nephelometer slope is not 3")
        Action <- c(Action, "Please contact Sreekanth")
    }

    # flow should be between 0.45 and 0.55
    if (any(MicroPEMObject$measures$flow < 0.45, na.rm = TRUE) |
        any(MicroPEMObject$measures$flow > 0.55, na.rm = TRUE)) {
        Alarm <- c(Alarm, "Flow outside of normal range at least once")
        Action <- c(Action, "Please contact Sreekanth")
    }

    # Not too many measures
    if (sum(!is.na(MicroPEMObject$measures$nephelometer)) > 10000) {
        Alarm <- c(Alarm, "Maybe two days of measures")
        Action <- c(Action, "Please contact Sreekanth")
    }

    # More than 2% negative values
    if (sum(MicroPEMObject$measures$nephelometer < 0, na.rm = TRUE) >
        0.02 * length(MicroPEMObject$measures$nephelometer)) {
        Alarm <- c(Alarm, "Too many negative values")
        Action <- c(Action, "Please contact Sreekanth")
    }
    if (is.null(Alarm)) {
        Alarm <- c("All is good")
        Action <- c(Action, "Nothing to do")
    }
    alarmTable <- data.frame(Alarm = Alarm, Action = Action)
    alarmTable <- dplyr::tbl_df(alarmTable)
    return(alarmTable)
}
