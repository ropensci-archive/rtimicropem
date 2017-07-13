#' Identify time gaps in the data collection period
#'
#' @param micropem a R6 micropem object
#' @param column by default "rh_corrected_nephelometer",
#' but could be "nephelometer", the column in which to look for gaps (\code{character}).
#'
#' @return A data.frame with all the rows of measures where the nephelometer measures is
#' missing with a time to previous missing values smaller than the nephelometer log.
#' @export
#'
#' @examples
#' micropem_na <- convert_output(system.file("extdata", "file_with_na.csv",
#'                                           package = "rtimicropem"))
#' micropem_na$plot()
#' identify_lags(micropem_na)
#'
identify_lags <- function(micropem,
                          column = "rh_corrected_nephelometer"){
  data_na <- dplyr::filter_(micropem$measures,
                            lazyeval::interp(~ is.na(micropem$measures[, column])))

  dplyr::filter_(data_na,
                lazyeval::interp(~ difftime(datetime, lag(datetime),
                                            units = "secs") <
                                   micropem$settings[["nephelometer_log_interval"]]))
}
