#' An R6 class to represent MicroPEM output information.
#'
#' @docType class
#' @importFrom R6 R6Class
#' @importFrom tidyr gather
#' @importFrom dplyr tbl_df filter_ select_ "%>%" bind_cols
#' @importFrom knitr kable
#' @import ggplot2
#' @import ggiraph
#' @export
#' @keywords data
#' @return Object of \code{\link{R6Class}}.
#' @format \code{\link{R6Class}} object.
#' @examples
#' data("dummyMicroPEMChai")
#' # Plot method, type = "plain" by default.
#' dummyMicroPEMChai$plot()
#' # Example with type = "interactive", for RStudio viewer,
#' # RMardown html documents and Shiny apps.
#' \dontrun{
#' p <- dummyMicroPEMChai$plot(type = "interactive")
#' ggiraph(code = {print(p)}, width = 10, height = 10)}
#' # Summary method
#' dummyMicroPEMChai$summary()
#' # Print method
#' dummyMicroPEMChai$print()
#' @field control Data.frame (\code{dplyr "tbl_df"}) with settings of the MicroPEM device and other information such as download time.
#' @field calibration List of calibration information.
#' @field measures Data.frame (\code{dplyr "tbl_df"}) with all time-varying measures:
#' \describe{
#'   \item{timeDate}{Time and date of each measurement, as a POSIXt object. Depending on the different logs of the time-varying variables there is not a measure for all variables associated to each timepoint.}
#'   \item{nephelometer}{Measures of nephelometer in microgram/meter cube (numeric).}
#'   \item{temperature}{Measures of temperature in centigrade (numeric).}
#'   \item{relativeHumidity}{Measures of relative humidity that are a proportion and as such do not have an unit (numeric).}
#'   \item{battery}{Measures of battery  UNIT PLEASE (numeric).}
#'   \item{orificePressure}{Measures of orifice pressure in inches of water (numeric).}
#'   \item{inletPressure}{Measures of inlet pressure in inches of water (numeric).}
#'   \item{flow}{Measures of flow in liters per minute (numeric).}
#'   \item{xAxis}{x-axis accelerometer UNIT PLEASE (numeric).}
#'   \item{yAxis}{y-axis accelerometer UNIT PLEASE (numeric).}
#'   \item{zAxis}{z-axis accelerometer UNIT PLEASE (numeric).}
#'   \item{vectorSum}{vector sum UNIT PLEASE (numeric).}
#'   \item{shutDownReason}{Shutdown reason (factor).}
#'   \item{wearingCompliance}{Wearing compliance (logical -- empty in CHAI).}
#'   \item{validityWearingComplianceValidation}{Validity wearing compliance (empty in CHAI).}
#'   \item{originalDateTime}{Date and time as character (character).}
#'   }
#' @field original Boolean. Is this an original MicroPEM object (TRUE) or was it e.g. filtered or cleaned (FALSE).
#' @section Methods:
#' \describe{
#'   \item{plot}{Method for getting a quick plot of all time-varying measurements.
#'   Either \code{type ="plain"} or \code{type ="interactive"}, see examples.
#'   The method returns a plot of the \code{ggplot}-class.}
#'   \item{summary}{Method for getting a summary table (\code{dplyr "tbl_df"}) of all time-varying numeric measurements.}
#'   \item{print}{Method for printing both the summary table of all time-varying numeric measurements and all settings from the \code{control} field.}
#'   }
##########################################################################
# CLASS DEFINITION
##########################################################################
MicroPEM <- R6::R6Class("MicroPEM",
                        public = list(
                          control = "tbl_df",
                          calibration = "list",
                          measures = "tbl_df",
                          original = "logical",
                          initialize = function(control,
                                                calibration,
                                                measures,
                                                original = TRUE) {
                            if(any(is.null(c(control,
                                             calibration,
                                             measures)))){
                              stop("all fields must be known")
                            }
                            self$control <- control
                            self$calibration <- calibration
                            self$measures <- measures
                            self$original <- original
                          },
                          plot = function(type = "plain",
                                          logScale = FALSE){
                            plotMicroPEM(self,
                                         type,
                                         logScale)
                          },
                          summary = function(){
                            summaryMicroPEM(self)
                          },
                          print = function(){
                            printMicroPEM(self)
                          }


                        )
)
##########################################################################
# PLOT METHOD
##########################################################################
plotMicroPEM <- function(self, type, logScale, ...){# nolint start
  if (is.null(type)){
    type <- "plain"
  }
  type <-  match.arg(type,
                     c("plain", "interactive"))

  # filter when timeDate not missing
  dataPM <- dplyr::select_(self$measures,
                           .dots = list("timeDate",
                                        "nephelometer",
                                        "temperature",
                                        "relativeHumidity",
                                        "orificePressure",
                                        "inletPressure",
                                        "flow",
                                        "battery"))

  filterCriteria <- lazyeval::interp(~(!is.na(timeDate)))
  dataPM <- dataPM%>%
    dplyr::filter_(.dots = filterCriteria)

  dataLong <- tidyr::gather(dataPM,
                            variable,
                            measurement,
                            nephelometer:battery)
  dataLong <- changeVariable(dataLong)
  red <- "#FF3D31"
  yellow <- "#FF9704"
  brown <- "#000200"
  lightRed <- "#EE9F8E"
  blue <- "#70B6C5"
  green <- "#497866"

  nicePalette <- c(red,
                   yellow,
                   blue,
                   green,
                   lightRed,
                   lightRed,
                   brown)

  if (type == "plain"){

    p <- ggplot(dataLong) +
      geom_point(aes(x = timeDate,
                     y = measurement,
                     col = variable)) +
      facet_grid(variable ~ ., scales = "free_y") +
      theme(panel.margin = unit(2, "lines")) +
      scale_color_manual(values =  nicePalette) +
      theme_bw() +
      xlab("time")
  }

  if (type == "interactive"){
    p <- ggplot(dataLong) +
      geom_point_interactive(aes(x = timeDate,
                                 y = measurement,
                                 col = variable,
                                 tooltip = paste0(timeDate,
                                                  " - ",
                                                  measurement,
                                                  " - ",
                                                  variable))) +
      facet_grid(variable ~ ., scales = "free_y") +
      theme(panel.margin = unit(2, "lines")) +
      theme_bw() +
      xlab("time")

  }
  return(p)
}# nolint end
##########################################################################
# SUMMARY METHOD
##########################################################################
summaryMicroPEM <- function(self){
  numMeasures <- dplyr::select_(self$measures,
                                .dots = ~nephelometer:flow)

  listSummary <- lapply(numMeasures, summaryPM)
  tableSummary <- do.call("rbind", listSummary)
  tableSummary <- dplyr::tbl_df(tableSummary)
  measure <- data.frame(measure = row.names(tableSummary))
  tableSummary <- dplyr::bind_cols(measure,
                                   tableSummary)

  return(dplyr::tbl_df(tableSummary))
}

summaryPM <- function(x) {

  sumup <- data.frame(sum(!is.na(x)),
                      median(x, na.rm = TRUE),
                      mean(x, na.rm = TRUE),
                      min(x, na.rm = TRUE),
                      max(x, na.rm = TRUE),
                      var(x, na.rm = TRUE))
  names(sumup) <- c("No. of not missing values",
                    "Median",
                    "Mean",
                    "Minimum",
                    "Maximum",
                    "Variance")
  return(sumup)
}

##########################################################################
# PRINT METHOD
##########################################################################
# nocov start
printMicroPEM <- function(self){
  cat("An object of class MicroPEM (R6 class)")
  cat("A summary of measures is:")
  print(knitr::kable(self$summary()))
  cat( "\n", "Settings were:")
  controlTable <- data.frame(value = t(self$control)[,1])
  print(knitr::kable(controlTable))
}

changeVariable <- function(dat) {
  mutateCall <- lazyeval::interp( ~ factor(a$variable,
                                           levels = c("nephelometer",
                                                      "temperature",
                                                      "relativeHumidity",
                                                      "flow",
                                                      "inletPressure",
                                                      "orificePressure",
                                                      "battery")),
                                  a = dat)

  dat %>% dplyr::mutate_(.dots = setNames(list(mutateCall),
                                          "variable"))
}
# nocov end
