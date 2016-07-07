#' Uses output file from MicroPEM to create a \code{micropem} object.
#'
#' @importFrom dplyr tbl_df mutate_ mutate_each_ funs matches
#' @importFrom lazyeval interp
#' @importFrom lubridate hms hour minute second force_tz mdy dmy
#' @importFrom tibble tibble
#' @param path the path to the file
#' @return A \code{micropem} object.
#' @examples
#' micropem_example <- convert_output(system.file('extdata', 'CHAI.csv', package = 'ammon'))
#' micropem_example$plot()
#' @export
convert_output <- function(path) {
    ###########################################
    # READ THE DATA
    ###########################################

    dummy <- readr::read_lines(path)
    dummy <- dummy[dummy != ""]
    dummy <- dummy[!is.na(dummy)]
    dummy <- dummy[!grepl("Errored Line", dummy)]
    dummy <- dummy[gsub(",", "", dummy) != ""]
    dataPEM <- tbl_df(data.frame(name = dummy[25:length(dummy)]))
    names_dataPEM <- strsplit(dummy[23], ",")[[1]]
    goal_length <- length(strsplit(dummy[25], ",")[[1]])
    if(length(names_dataPEM) == (goal_length - 1)){
      names_dataPEM <- c(names_dataPEM, "message")
    }
    names_dataPEM <- tolower(names_dataPEM)
    names_dataPEM <- gsub(" ", "_", names_dataPEM)
    names_dataPEM <- gsub("-", "_", names_dataPEM)
    measures <-  suppressWarnings(tidyr::separate(dataPEM,
                                                  name,
                                       names_dataPEM,
                                       sep = ","))
    # known wrong dates
    measures$date <- gsub("21/05/105", "5/21/2015", measures$date)
    measures$date <- gsub("35/01/16", "29/01/2016", measures$date)
    measures$date <- gsub("2901/01/29", "1/29/2016", measures$date)
    measures$date <- gsub("0B/02/16", "2/11/2016", measures$date)
    measures$date <- gsub("106/06/14", "6/14/2015", measures$date)
    measures$date <- gsub("15/06/106", "6/15/2015", measures$date)
    measures$date <- gsub("106/06/15", "6/15/2015", measures$date)
    # transform dates
    measures$date <- transform_date(measures$date)
    measures$time <- lubridate::hms(measures$time)
    measures <- measures %>% mutate_(datetime = lazyeval::interp(
      ~ update(date,
               hour = hour(time),
               minute = minute(time),
               second = second(time))
    )) %>%
      select_(.dots = list(quote(-date), quote(-time)))%>%
      select_(.dots = list(quote(datetime), quote(dplyr::everything())))

    measures$rh_corrected_nephelometer <- as.numeric(measures$rh_corrected_nephelometer)
    measures$temp <- as.numeric(measures$temp)
    measures$rh <- as.numeric(measures$rh)
    measures$battery <- as.numeric(measures$battery)
    measures$inlet_press <- as.numeric(measures$inlet_press)
    names(measures) <- gsub("flow_", "", names(measures))
    measures$orifice_press <- as.numeric(measures$orifice_press)

    measures$flow <- as.numeric(measures$flow)
    measures$x_axis <- as.numeric(measures$x_axis)
    measures$y_axis <- as.numeric(measures$y_axis)
    measures$z_axis <- as.numeric(measures$z_axis)
    measures$vector_sum_composite <- as.numeric(measures$vector_sum_composite)
    ###########################################
    # READ THE TOP OF THE FILE
    ###########################################

    # downloadDate
    downloadDate <- strsplit(dummy[2], ",")[[1]][2]
    downloadDate <- transform_date(downloadDate)

    # totalDownloadTime
    totalDownloadTime <- as.numeric(strsplit(dummy[3], ",")[[1]][2])
    # deviceSerial
    deviceSerial <- as.character(strsplit(dummy[4], ",")[[1]][2])
    # dateTimeHardware
    dateTimeHardware <- strsplit(dummy[5], ",")[[1]][2]
    dateTimeHardware <- transform_date(dateTimeHardware)

    # dateTimeSoftware
    dateTimeSoftware <- strsplit(dummy[6], ",")[[1]][2]
    dateTimeSoftware <- transform_date(dateTimeSoftware)

    # version
    version <- as.character(strsplit(dummy[6], ",")[[1]][3])

    # participantID
    participantID <- strsplit(dummy[7], ",")[[1]][2]

    # filterID
    filterID <- strsplit(dummy[8], ",")[[1]][2]

    # participantWeight
    participantWeight <- suppressWarnings(
      as.numeric(strsplit(dummy[9], ",")[[1]][2]))

    # inletAerosolSize
    inletAerosolSize <- as.character(strsplit(dummy[10], ",")[[1]][2])

    # laserCyclingVariablesDelay
    laser_temp <- strsplit(dummy[11], ",")[[1]]
    laserCyclingVariablesDelay <- as.numeric(laser_temp[2])

    # laserCyclingVariablesSamplingTime
    laserCyclingVariablesSamplingTime <- as.numeric(laser_temp[3])

    # laserCyclingVariablesOffTime
    laserCyclingVariablesOffTime <- as.numeric(laser_temp[4])

    # SystemTimes
    SystemTimes <- as.character(paste(strsplit(dummy[12], ",")[[1]][2],
                         strsplit(dummy[12], ",")[[1]][3]))

    # nephelometerSlope
    nephelometer_temp <- strsplit(dummy[14], ",")[[1]]
    nephelometerSlope <- as.numeric(nephelometer_temp[2])
    # nephelometerOffset
    nephelometerOffset <- as.numeric(nephelometer_temp[3])
    # nephelometerLogInterval
    nephelometerLogInterval <- as.numeric(nephelometer_temp[4])

    # temperatureSlope
    temperature_temp <- strsplit(dummy[15], ",")[[1]]
    temperatureSlope <- as.numeric(temperature_temp[2])
    # temperatureOffset
    temperatureOffset <- as.numeric(temperature_temp[3])
    # temperatureLog
    temperatureLog <- as.numeric(temperature_temp[4])

    # humiditySlope
    humidity_temp <- strsplit(dummy[16], ",")[[1]]
    humiditySlope <- as.numeric(humidity_temp[2])
    # humidityOffset
    humidityOffset <- as.numeric(humidity_temp[3])
    # humidityLog
    humidityLog <- as.numeric(humidity_temp[4])

    # inletPressureSlope
    inletPressure_temp <- strsplit(dummy[17], ",")[[1]]
    inletPressureSlope <- as.character(inletPressure_temp[2])
    # inletPressureOffset
    inletPressureOffset <- as.numeric(inletPressure_temp[3])
    # inletPressureLog
    inletPressureLog <- as.numeric(inletPressure_temp[4])
    # inletPressureHighTarget
    inletPressureHighTarget <- as.numeric(inletPressure_temp[5])
    # inletPressureLowTarget
    inletPressureLowTarget <- as.numeric(inletPressure_temp[6])

    # orificePressureSlope
    orificePressure_temp <- strsplit(dummy[18], ",")[[1]]
    orificePressureSlope <- as.character(orificePressure_temp[2])
    # orificePressureOffset
    orificePressureOffset <- as.numeric(orificePressure_temp[3])
    # orificePressureLog
    orificePressureLog <- as.numeric(orificePressure_temp[4])
    # orificePressureHighTarget
    orificePressureHighTarget <- as.numeric(orificePressure_temp[5])
    # orificePressureLowTarget
    orificePressureLowTarget <- as.numeric(orificePressure_temp[6])

    # flowLog
    flow_temp <- strsplit(dummy[19], ",")[[1]]
    flowLog <- as.numeric(flow_temp[4])
    # flowHighTarget
    flowHighTarget <- as.numeric(flow_temp[5])
    # flowLowTarget
    flowLowTarget <- as.numeric(flow_temp[6])
    # flowWhatIsThis
    flowWhatIsThis <- as.numeric(flow_temp[7])
    # accelerometerLog
    accelerometerLog <- as.numeric(strsplit(dummy[20], ",")[[1]][4])
    # batteryLog
    batteryLog <- as.numeric(strsplit(dummy[21], ",")[[1]][4])
    # ventilationSlope
    ventilationSlope <- suppressWarnings(as.numeric(strsplit(dummy[22], ",")[[1]][2]))
    # ventilationOffset
    ventilationOffset <- suppressWarnings(as.numeric(strsplit(dummy[22], ",")[[1]][3]))
    ###########################################
    # settings table
    ###########################################
    settings <- tibble::tibble(downloadDate = downloadDate,
                    totalDownloadTime = totalDownloadTime,
                    deviceSerial = deviceSerial,
                    dateTimeHardware = dateTimeHardware,
                    dateTimeSoftware = dateTimeSoftware,
                    version = version,
                    participantID = participantID,
                    filterID = filterID,
                    participantWeight = participantWeight,
                    inletAerosolSize = inletAerosolSize,
                    laserCyclingVariablesDelay =
                      laserCyclingVariablesDelay,
                    laserCyclingVariablesSamplingTime =
                      laserCyclingVariablesSamplingTime,
                    laserCyclingVariablesOffTime =
                      laserCyclingVariablesOffTime,
                    SystemTimes = SystemTimes,
                    nephelometerSlope = nephelometerSlope,
                    nephelometerOffset = nephelometerOffset,
                    nephelometerLogInterval =
                      nephelometerLogInterval,
                    temperatureSlope = temperatureSlope,
                    temperatureOffset = temperatureOffset,
                    temperatureLog = temperatureLog,
                    humiditySlope = humiditySlope,
                    humidityOffset = humidityOffset,
                    humidityLog = humidityLog,
                    inletPressureSlope =
                      inletPressureSlope,
                    inletPressureOffset =
                      inletPressureOffset,
                    inletPressureLog = inletPressureLog,
                    inletPressureHighTarget =
                      inletPressureHighTarget,
                    inletPressureLowTarget =
                      inletPressureLowTarget,
                    orificePressureSlope =
                      orificePressureSlope,
                    orificePressureOffset =
                      orificePressureOffset,
                    orificePressureLog =
                      orificePressureLog,
                    orificePressureHighTarget =
                      orificePressureHighTarget,
                    orificePressureLowTarget =
                      orificePressureLowTarget,
                    flowLog = flowLog,
                    flowHighTarget = flowHighTarget,
                    flowLowTarget = flowLowTarget,
                    flowWhatIsThis = flowWhatIsThis,
                    accelerometerLog = accelerometerLog,
                    batteryLog = batteryLog,
                    ventilationSlope = ventilationSlope,
                    ventilationOffset = ventilationOffset)
    settings <- dplyr::tbl_df(settings)
    ###########################################
    # CREATE THE OBJECT
    ###########################################


    micropem_object <- micropem$new(settings = settings,
                          calibration = list(NA),
                          measures = measures,
                          original = TRUE,
                          filename = path)
    return(micropem_object)
}
########################################################################
transform_date <- function(date){
  date <- tolower(date)
  date <- gsub("jan", "01", date)
  date <- gsub("feb", "02", date)
  date <- gsub("mar", "03", date)
  date <- gsub("apr", "04", date)
  date <- gsub("may", "05", date)
  date <- gsub("jun", "06", date)
  date <- gsub("jul", "07", date)
  date <- gsub("aug", "08", date)
  date <- gsub("sep", "09", date)
  date <- gsub("oct", "10", date)
  date <- gsub("nov", "11", date)
  date <- gsub("dec", "12", date)
  date <- gsub("0101", "01", date)
  date <- gsub("0202", "02", date)
  date <- gsub("0303", "03", date)
  date <- gsub("0404", "04", date)
  date <- gsub("0505", "05", date)
  date <- gsub("0606", "06", date)
  date <- gsub("0707", "07", date)
  date <- gsub("0808", "08", date)
  date <- gsub("0909", "09", date)
  date <- gsub("1010", "10", date)
  date <- gsub("1111", "11", date)
  date <- gsub("1212", "12", date)
  lubridate::parse_date_time(date, orders = c("mdy", "dmy"))
}
