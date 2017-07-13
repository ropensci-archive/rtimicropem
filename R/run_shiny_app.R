#' Run a built-in Shiny App.
#'
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
    app_dir <- system.file("shiny-examples",
                          "myapp", package = "rtimicropem")
    if (app_dir == "") {
        stop("Could not find example directory. Try re-installing `micropem`.",
             call. = FALSE)
    }

    shiny::runApp(app_dir, display.mode = "normal")
}
# nocov end
