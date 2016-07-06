#' Reading several MicroPEM files and converting the settings and measurement tables to csv.
#'
#' @importFrom readr read_csv
#' @param path_input path to the directory with files
#' @param path_output path where the files should be created, by default equal to \code{path_input}.
#' See the data in inst/data to see
#' which one applies.
#'
#' The function saves results in the input directory as csv files with a "," as separator.
#' One file is settings.csv with all settings, the other one is measures.csv
#' It saves them directly for not loading all of them at the same time in the session.
#' @return
#' @export
#'
#' @examples
batchConvert <- function(path_input, path_output = path_input){
  # find files to transform
  listFiles <- list.files(path_input,
                           full.names = TRUE)
  listFiles <- listFiles[grepl(".csv",
                                 listFiles) == TRUE]

  if (file.exists(paste0(path_output,
                         "/settings.csv")) |
      file.exists(paste0(path_output,
                         "/measures.csv"))){
    stop(paste0("There are already a settings.csv and/or a measures.csv in the directory ",
                path_output))# nolint
  }

  list_micropem <- lapply(listFiles, convertOutput)
  settings <- dplyr::bind_rows(lapply(list_micropem, "[[", "control"))
  measures <- dplyr::bind_rows(lapply(list_micropem, "[[", "measures"))

    readr::write_csv(settings,
                       path = paste0(path_output,
                                     "/settings.csv"),
                       append = TRUE)

    readr::write_csv(measures,
                     path = paste0(path_output,
                                   "/measures.csv"),
                     append = TRUE)


}
