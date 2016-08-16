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
#' data("micropemChai")
#' # Plot method, type = "plain" by default.
#' micropemChai$plot()
#' # Example with type = "interactive", for RStudio viewer,
#' # RMardown html documents and Shiny apps.
#' \dontrun{
#' library("ggiraph")
#' p <- micropemChai$plot(type = "interactive")
#' ggiraph(code = {print(p)}, width = 1, height = 5)}
#' # Summary method
#' micropemChai$summary()
#' # Print method
#' micropemChai$print()
#' @field settings Data.frame (\code{dplyr "tbl_df"}) with settings of the micropem device and other information such as download time.
#' @field calibration List of calibration information.
#' @field filename Filename from which the oject was built.
#' @field measures Data.frame (\code{dplyr "tbl_df"}) with all time-varying measures, possibly:
#' \describe{
#'   \item{datetime}{Time and date of each measurement, as a POSIXt object. Depending on the different logs of the time-varying variables there is not a measure for all variables associated to each timepoint.}
#'   \item{rh_corrected_nephelometer}{Measures of nephelometer in microgram/meter cube (numeric).}
#'   \item{temp}{Measures of temperature in centigrade (numeric).}
#'   \item{rh}{Measures of relative humidity that are a proportion and as such do not have an unit (numeric).}
#'   \item{battery}{Measures of battery  UNIT PLEASE (numeric).}
#'   \item{orifice_press}{Measures of orifice pressure in inches of water (numeric).}
#'   \item{inlet_press}{Measures of inlet pressure in inches of water (numeric).}
#'   \item{flow}{Measures of flow in liters per minute (numeric).}
#'   \item{x_axis}{x-axis accelerometer UNIT PLEASE (numeric).}
#'   \item{y_axis}{y-axis accelerometer UNIT PLEASE (numeric).}
#'   \item{z_axis}{z-axis accelerometer UNIT PLEASE (numeric).}
#'   \item{vector_sum_composite}{vector sum UNIT PLEASE (numeric).}
#'   \item{message}{Shutdown reason (factor).}
#'   }
#' @field original Boolean. Is this an original micropem object (TRUE) or was it e.g. filtered or cleaned (FALSE).
#' @section Methods:
#' \describe{
#'   \item{plot}{Method for getting a quick plot of all time-varying measurements.
#'   Either \code{type ="plain"} or \code{type ="interactive"}, see examples.
#'   The method returns a plot of the \code{ggplot}-class.}
#'   \item{summary}{Method for getting a summary table (\code{dplyr "tbl_df"}) of all time-varying numeric measurements.}
#'   \item{print}{Method for printing both the summary table of all time-varying numeric measurements and all settings from the \code{settings} field.}
#'   }
##########################################################################
# CLASS DEFINITION
##########################################################################
micropem <- R6::R6Class("micropem",
                        public = list(
                          settings = "tbl_df",
                          calibration = "list",
                          measures = "tbl_df",
                          original = "logical",
                          filename = "character",
                          initialize = function(settings,
                                                calibration,
                                                measures,
                                                filename,
                                                original = TRUE) {
                            if(any(is.null(c(settings,
                                             calibration,
                                             measures)))){
                              stop("all fields must be known")
                            }
                            self$settings <- settings
                            self$calibration <- calibration
                            self$measures <- measures
                            self$original <- original
                            self$filename <- filename
                          },
                          plot = function(type = "plain",
                                          logScale = FALSE){
                            plotmicropem(self,
                                         type,
                                         logScale)
                          },
                          summary = function(){
                            summarymicropem(self)
                          },
                          print = function(){
                            printmicropem(self)
                          }


                        )
)
##########################################################################
# PLOT METHOD
##########################################################################
plotmicropem <- function(self, type, logScale, ...){# nocov start
  if (is.null(type)){
    type <- "plain"
  }
  type <-  match.arg(type,
                     c("plain", "interactive"))

  # filter when datetime not missing
  dataPM <- dplyr::select_(self$measures,
                           .dots = list("datetime",
                                        "rh_corrected_nephelometer",
                                          "temp",
                                          "rh",
                                          "flow",
                                          "inlet_press",
                                          "orifice_press",
                                          "battery"))

  filterCriteria <- lazyeval::interp(~(!is.na(datetime)))
  dataPM <- dataPM %>%
    dplyr::filter_(.dots = filterCriteria)

  dataLong <- tidyr::gather(dataPM,
                            variable,
                            measurement,
                            rh_corrected_nephelometer:battery)

  filterCriteria2 <- lazyeval::interp(~(!is.na(measurement)))
  dataLong <- dataLong %>%
    dplyr::filter_(.dots = filterCriteria2)

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
      geom_point(aes(x = datetime,
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
      geom_point_interactive(aes(x = datetime,
                                 y = measurement,
                                 col = variable,
                                 tooltip = paste0(datetime,
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
}# nocov end
##########################################################################
# SUMMARY METHOD
##########################################################################
summarymicropem <- function(self){
  dplyr::select_(self$measures,
                 .dots = ~rh_corrected_nephelometer:flow) %>%
    purrr::map(summaryPM) %>%
    dplyr::bind_rows() %>%
    dplyr::mutate_(measure = lazyeval::interp(~dplyr::select_(self$measures,
                                            .dots = ~rh_corrected_nephelometer:flow) %>%
                     names)) %>%
    dplyr::select_(.dots = list(quote(measure),
                                quote(no._of_not_missing_values),
                                quote(median),
                                quote(mean),
                                quote(minimum),
                                quote(maximum),
                                quote(variance)))
}

summaryPM <- function(x) {
  sumup <- tibble::tibble_(list(no._of_not_missing_values = ~sum(!is.na(x)),
                                median = ~median(x, na.rm = TRUE),
                                mean = ~mean(x, na.rm = TRUE),
                                minimum = ~min(x, na.rm = TRUE),
                                maximum = ~max(x, na.rm = TRUE),
                                variance = ~var(x, na.rm = TRUE)))

  return(sumup)
}

##########################################################################
# PRINT METHOD
##########################################################################
# nocov start
printmicropem <- function(self){
  cat("An object of class micropem (R6 class)")
  cat("\n")
  cat("A summary of measures is:")
  print(knitr::kable(self$summary()))
  cat( "\n", "Settings were:")
  settingsTable <- data.frame(value = t(self$settings)[,1])
  print(knitr::kable(settingsTable))
}

changeVariable <- function(dat) {
  mutateCall <- lazyeval::interp( ~ factor(a$variable,
                                           levels = c("rh_corrected_nephelometer",
                                                      "temp",
                                                      "rh",
                                                      "flow",
                                                      "inlet_press",
                                                      "orifice_press",
                                                      "battery")),
                                  a = dat)

  dat %>% dplyr::mutate_(.dots = setNames(list(mutateCall),
                                          "variable"))
}
# nocov end
