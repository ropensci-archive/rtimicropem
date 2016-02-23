#' Extracts parameters settings and some other control variables from the top of the output files of a given directory.
#'
#' @importFrom dplyr tbl_df
#' @param directory the directory with all output files, of the same version.
#' @param version the version of the output files, either 'CHAI' or 'Columbia'
#' @return A data frame tbl (class defined in the \code{dplyr} package).
#' @export
#'
compareSettings <- function(directory, version) {
    # nocov start
    files <- list.files(directory, full.names = TRUE)
    files <- files[grepl(".csv", files)]
    tableComparison <- NULL
    for (file in files) {
        MicroPEMObject <- convertOutput(
          file, version = version)
        tableComparison <- rbind(tableComparison,
                                 MicroPEMObject$control())
    }

    tableComparison <- dplyr::tbl_df(tableComparison)
    return(tableComparison)
}  # nocov end
