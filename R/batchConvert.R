#' Reading several MicroPEM files and converting the settings and measurement tables to csv.
#'
#' @importFrom readr read_csv
#' @param pathDir path to the directory with files
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
batchConvert <- function(pathDir){
  # find files to transform
  listFiles <- list.files(pathDir,
                           full.names = TRUE)
  listFiles <- listFiles[grepl(".csv",
                                 listFiles) == TRUE]

  if (file.exists(paste0(pathDir,
                         "/settings.csv")) |
      file.exists(paste0(pathDir,
                         "/measures.csv"))){
    stop("There are already a settings.csv and/or a measures.csv in the directory !")# nolint
  }

  # prepare file with measures

  readr::write_csv(data.frame("timeDate", "nephelometer",
                              "temperature", "relativeHumidity",
                              "battery", "orificePressure",
                              "inletPressure", "flow",
                              "xAxis", "yAxis", "zAxis",
                              "vectorSum", "shutDownReason",
                              "wearingCompliance",
                              "validityWearingComplianceValidation",
                              "originalDateTime",
                              "filename"),
                   path = paste0(pathDir,
                                 "/measures.csv"),
                   append = TRUE)

  # prepare file with settings
  readr::write_csv(data.frame("downloadDate", "totalDownloadTime",
                              "deviceSerial", "dateTimeHardware",
                              "dateTimeSoftware", "version",
                              "participantID", "filterID",
                              "participantWeight", "inletAerosolSize",
                              "laserCyclingVariablesDelay",
                              "laserCyclingVariablesSamplingTime",
                              "laserCyclingVariablesOffTime", "SystemTimes",
                              "nephelometerSlope", "nephelometerOffset",
                              "nephelometerLogInterval", "temperatureSlope",
                              "temperatureOffset", "temperatureLog",
                              "humiditySlope", "humidityOffset",
                              "humidityLog", "inletPressureSlope",
                              "inletPressureOffset", "inletPressureLog",
                              "inletPressureHighTarget",
                              "inletPressureLowTarget",
                              "orificePressureSlope", "orificePressureOffset",
                              "orificePressureLog", "orificePressureHighTarget",
                              "orificePressureLowTarget", "flowLog",
                              "flowHighTarget", "flowLowTarget",
                              "flowWhatIsThis", "accelerometerLog",
                              "batteryLog", "ventilationSlope",
                              "ventilationOffset",
                              "filename"),
                   path = paste0(pathDir,
                                 "/settings.csv"),
                   append = TRUE)

  # loop over files
  for (file in listFiles){
    converted <- convertOutput(file)
    settings <- converted$control
    settings <- mutate_(settings,
                        filename = ~ file) # nolint

    readr::write_csv(settings,
                       path = paste0(pathDir,
                                     "/settings.csv"),
                       append = TRUE)


    measures <- converted$measures
    measures <- mutate_(measures,
                        filename = ~ file) # nolint

    readr::write_csv(measures,
                     path = paste0(pathDir,
                                   "/measures.csv"),
                     append = TRUE)



  }


}
