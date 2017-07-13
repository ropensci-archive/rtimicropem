#' An R6 class to represent MicroPEM output information.
#'
#' @docType class
#' @importFrom dplyr "%>%"
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
#' library("rbokeh")
#' p <- micropemChai$plot(type = "interactive")
#' p
#' # Summary method
#' micropemChai$summary()
#' # Print method
#' micropemChai$print()
#' }
#' @field settings Data.frame (\code{dplyr "tbl_df"}) with settings of the micropem device and other information such as download time.
#' @field calibration List of calibration information.
#' @field filename Filename from which the oject was built.
#' @field measures Data.frame (\code{dplyr "tbl_df"}) with all time-varying measures, possibly:
#' \describe{
#'   \item{datetime}{Time and date of each measurement, as a POSIXt object. Depending on the different logs of the time-varying variables there is not a measure for all variables associated to each timepoint.}
#'   \item{rh_corrected_nephelometer}{Measures of nephelometer in microgram/meter cube (numeric).}
#'   \item{temp}{Measures of temperature in centigrade (numeric).}
#'   \item{rh}{Measures of relative humidity that are a proportion and as such do not have an unit (numeric).}
#'   \item{battery}{Measures of battery  in Volt (numeric).}
#'   \item{orifice_press}{Measures of orifice pressure in inches of water (numeric).}
#'   \item{inlet_press}{Measures of inlet pressure in inches of water (numeric).}
#'   \item{flow}{Measures of flow in liters per minute (numeric).}
#'   \item{x_axis}{x-axis accelerometer in m/s2 (numeric).}
#'   \item{y_axis}{y-axis accelerometer in m/s2 (numeric).}
#'   \item{z_axis}{z-axis accelerometer in m/s2 (numeric).}
#'   \item{vector_sum_composite}{vector sum m/s2 (numeric).}
#'   \item{message}{Shutdown reason (factor).}
#'   }
#' @field original Boolean. Is this an original micropem object (TRUE) or was it e.g. filtered or cleaned (FALSE).
#' @section Methods:
#' \describe{
#'   \item{plot}{Method for getting a quick plot of all time-varying measurements.
#'   Either \code{type ="plain"} or \code{type ="interactive"}, see examples.
#'   The method returns a plot of the \code{ggplot}-class. One can add a title via the \code{title} argument.}
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
                            if (any(is.null(c(settings,
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
                                          title = NULL){
                            plotmicropem(self,
                                         type,
                                         title)
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
plotmicropem <- function(self, type, title, ...){# nocov start
  if (is.null(type)){
    type <- "plain"
  }
  type <-  match.arg(type,
                     c("plain", "interactive"))

  # filter when datetime not missing
  pm_data <- dplyr::select_(self$measures,
                           .dots = list("datetime",
                                        "rh_corrected_nephelometer",
                                          "temp",
                                          "rh",
                                          "flow",
                                          "inlet_press",
                                          "orifice_press",
                                          "battery"))

  filter_criteria <- lazyeval::interp(~ (!is.na(datetime)))
  pm_data <- pm_data %>%
    dplyr::filter_(.dots = filter_criteria)

  .dots <- names(pm_data)[which(names(pm_data) == "rh_corrected_nephelometer"):
                           which(names(pm_data) == "battery")]
  long_data <- tidyr::gather_(pm_data, "variable", "measurement",
                            .dots)

  filter_criteria2 <- lazyeval::interp(~(!is.na(measurement)))
  long_data <- long_data %>%
    dplyr::filter_(.dots = filter_criteria2)

  long_data <- order_factors(long_data)
  red <- "#FF3D31"
  yellow <- "#FF9704"
  brown <- "#000200"
  light_red <- "#EE9F8E"
  blue <- "#70B6C5"
  green <- "#497866"

  chai_palette <- c(red,
                   yellow,
                   blue,
                   green,
                   light_red,
                   light_red,
                   brown)

  if (type == "plain"){

    p <- ggplot2::ggplot(long_data) +
      ggplot2::geom_point(ggplot2::aes_string(x = "datetime",
                     y = "measurement",
                     col = "variable")) +
      ggplot2::facet_grid(variable ~ ., scales = "free_y") +
      ggplot2::scale_color_manual(values =  chai_palette) +
      ggplot2::theme_bw() +
      ggplot2::theme(strip.text.y = ggplot2::element_text(angle = 0),
            legend.position = "none") +
      ggplot2::xlab("time")
    if (!is.null(title)){
      p <- p + ggplot2::ggtitle(title)
    }
  }

  if (type == "interactive"){
    df <- self$measures %>%
      dplyr::select_(~datetime, ~rh_corrected_nephelometer,
              ~temp, ~rh,
              ~inlet_press,
              ~orifice_press, ~flow,
              ~x_axis)
    .dots <- names(df)[2:ncol(df)]
    df <-  df %>%
      tidyr::gather_("parameter", "value", .dots)

    df <- dplyr::filter_(df, ~!is.na(value))
    plots_list <- lapply(unique(df$parameter),
                                make_plot_one_param,
                                title = title,
                                donnees = df)

    p <- rbokeh::grid_plot(plots_list, ncol = 1)

  }
  return(p)
}# nocov end
##########################################################################
# SUMMARY METHOD
##########################################################################
summarymicropem <- function(self){

  measures <- dplyr::select_(self$measures,
                             .dots = ~rh_corrected_nephelometer:flow)
  measures <- names(measures)

  data_to_summarize <- dplyr::select_(self$measures,
                 .dots = ~rh_corrected_nephelometer:flow)
  lapply(data_to_summarize, summaryPM) %>%
    dplyr::bind_rows() %>%
    dplyr::mutate_(measure = ~measures) %>%
    dplyr::select_(.dots = list(quote(measure),
                                quote(no._of_not_missing_values),
                                quote(median),
                                quote(mean),
                                quote(minimum),
                                quote(maximum),
                                quote(variance)))
}

summaryPM <- function(x) {
  if (methods::is(x, "character")){
    x <- as.numeric(x)
  }
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
  settings_table <- data.frame(value = t(self$settings)[, 1])
  print(knitr::kable(settings_table))
}

order_factors <- function(dat){
  mutate_call <- lazyeval::interp( ~ factor(a$variable,
                                           levels = c("rh_corrected_nephelometer",
                                                      "temp",
                                                      "rh",
                                                      "flow",
                                                      "inlet_press",
                                                      "orifice_press",
                                                      "battery")),
                                  a = dat)

  dplyr::mutate_(dat, .dots = stats::setNames(list(mutate_call),
                                          "variable"))
}
# nocov end
