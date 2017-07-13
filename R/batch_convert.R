#' Reading several MicroPEM files and saving the settings and measurement tables to csv.
#'
#' @param path_input path to the directory with files (\code{character})
#' @param path_output path where the files should be created, by default equal to \code{path_input} (\code{character}).
#'
#' The function saves results in the input directory as csv files with a "," as separator.
#' One file is settings.csv with all settings, the other one is measures.csv
#' It saves them directly for not loading all of them at the same time in the session.
#' @examples \dontrun{
#' batch_convert(path_input = c(system.file('extdata', 'dummyCHAI.csv', package = 'micropem'),
#' system.file('extdata', 'dummyCHAI.csv', package = 'micropem')),
#' path_output = getwd())}
#' @export
#'
batch_convert <- function(path_input, path_output = path_input){
  if (file.exists(paste0(path_output,
                         "/settings.csv")) |
      file.exists(paste0(path_output,
                         "/measures.csv"))){
    stop(paste0("There are already a settings.csv and/or a measures.csv
                in the directory ",
                path_output))# nolint
  }

  files <- dir(path = path_input, full.names = TRUE)

 lapply(files[grepl(".csv",  files)], convert_output) %>%
    function_tables(path_output)

}

function_bind <- function(list_micropem, name){
  lapply(list_micropem, add_name, name = name) %>%
    dplyr::bind_rows()
}

function_tables <- function(list_micropem, path_output){
  function_bind(list_micropem, name = "settings") %>%
    readr::write_csv(path = paste0(path_output,
                                   "/settings.csv"),
                     append = FALSE)

  function_bind(list_micropem, name = "measures") %>%
    readr::write_csv(path = paste0(path_output,
                                   "/measures.csv"),
                     append = FALSE)

}

add_name <- function(MP, name){
  df <- dplyr::mutate_(MP[[name]], filename = ~MP$filename)
  if (name == "measures"){
    df <- dplyr::mutate_(df,
                         datetime = lazyeval::interp(~ as.character(datetime)))
  }

  return(df)
}
