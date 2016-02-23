#' Filter measures of the MicroPEM object in a given time interval.
#'
#' @importFrom dplyr filter
#' @param fromTime A POSIXct object defining the smallest observation timepoint
#' @param untilTime A POSIXct object defining the biggest observation timepoint
#' @param MicroPEMObject A MicroPEMObject object
#' @return A \code{MicroPEM} object.
#' @examples
#' # load the lubridate package
#' library('lubridate')
#' # load the dummy MicroPEM object
#' data('dummyMicroPEMChai')
#' # look at the dimensions of the data.frame
#' print(dummyMicroPEMChai$measures)
#' # command for erasing measures from the first twelve hours
#' shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,
#' untilTime=NULL,
#' fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12))
#'# look at the dimensions of the data.frame
#' print(shorterMicroPEM$measures)
#' @export
filterTimeDate <- function(MicroPEMObject = MicroPEMObject,
                           fromTime = NULL, untilTime = NULL) {
    if (is.null(untilTime) & is.null(fromTime)) {
        stop("Provide at least one of the two times fromTime and untilTime.")

    }

    if (is.null(fromTime)) {
        fromTime <- min(MicroPEMObject$measures$timeDate,
                        na.rm = TRUE)
    }
    if (is.null(untilTime)) {
        untilTime <- max(MicroPEMObject$measures$timeDate,
                         na.rm = TRUE)
    }

    if (!is.null(untilTime) & !is.null(fromTime)) {
        if (fromTime > untilTime) {
            stop("fromTime must be smaller than untilTime.")
        }
    }

    MicroPEMObject$measures <- dplyr::filter(
      MicroPEMObject$measures,
      timeDate >= fromTime & timeDate <= untilTime
    )

    MicroPEMObject$original <- FALSE

    return(MicroPEMObject)
}
