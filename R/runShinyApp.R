#' Run a built-in Shiny App.
#'
#' @return Nothing, it does something.
#' @examples
#' \dontrun{
#' run_shiny_app()
#' }
#' @export
run_shiny_app <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    message("run_shiny_app needs the shiny package, \n
              Install it via install.packages('shiny')")
    return(NULL)
  }

  if (!requireNamespace("xtable", quietly = TRUE)) {
    message("run_shiny_app needs the xtable package, \n
              Install it via install.packages('xtable')")
    return(NULL)
  }
    # nocov start
    appDir <- system.file("shiny-examples",
                          "myapp", package = "rtimicropem")
    if (appDir == "") {
        stop("Could not find example directory. Try re-installing `micropem`.",
             call. = FALSE)
    }

    shiny::runApp(appDir, display.mode = "normal")
}
# nocov end
