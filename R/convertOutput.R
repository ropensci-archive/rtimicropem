#' Uses output file from MicroPEM to create a MicroPEM object.
#'
#' @importFrom dplyr tbl_df mutate_
#' @importFrom lazyeval interp
#' @importFrom lubridate hms hour minute second force_tz mdy dmy
#' @param path the path to the file
#' @param version the version of the output file, either 'CHAI', 'Columbia1' or 'Columbia2'.
#' See the data in inst/data to see
#' which one applies.
#' @return A \code{MicroPEM} object.
#' @examples
#' MicroPEMExample <- convertOutput(system.file('extdata', 'dummyCHAI.csv', package = 'ammon'),
#'  version='CHAI')
#' MicroPEMExample$plot()
#' @export
convertOutput <- function(path, version = NULL) {
    if (is.null(version)) {
        stop("Please provide a value for version.")
    }
    version <- match.arg(version, c("CHAI", "Columbia1", "Columbia2"))
    if (version == "CHAI") {
        functionDate <- lubridate::mdy
    }
    if (version == "Columbia1") {
        functionDate <- lubridate::dmy
    }
    if (version == "Columbia2") {
        functionDate <- lubridate::mdy
    }
    ###########################################
    # READ THE DATA
    ###########################################
    dataPEM <- read.csv(path, skip = 28, header = FALSE, fill = TRUE)
    dataPEM <- dataPEM[dataPEM[, 1] != "Errored Line", ]
    dataPEM[, 1] <- as.character(dataPEM[, 1])
    dataPEM[, 2] <- as.character(dataPEM[, 2])
    dataPEM <- dplyr::tbl_df(dataPEM)

    # isolate names and erase spaces and hyphens
    if (version == "CHAI") {
        namesPEM <- read.csv(path, skip = 25, header = FALSE, nrow = 1)
    } else {
        namesPEM <- read.csv(path, skip = 24, header = FALSE, nrow = 1)
    }
    namesPEM <- unlist(lapply(as.list(namesPEM), toString))
    namesPEM <- gsub(" ", "", namesPEM)
    namesPEM <- sub("-", "", namesPEM)
    names(dataPEM) <- namesPEM
print(namesPEM)
    # convert month names if they are abbreviated
    dataPEM$Date <- tolower(dataPEM$Date)
    dataPEM$Date <- gsub("jan", "01", dataPEM$Date)
    dataPEM$Date <- gsub("feb", "02", dataPEM$Date)
    dataPEM$Date <- gsub("mar", "03", dataPEM$Date)
    dataPEM$Date <- gsub("apr", "04", dataPEM$Date)
    dataPEM$Date <- gsub("may", "05", dataPEM$Date)
    dataPEM$Date <- gsub("jun", "06", dataPEM$Date)
    dataPEM$Date <- gsub("jul", "07", dataPEM$Date)
    dataPEM$Date <- gsub("aug", "08", dataPEM$Date)
    dataPEM$Date <- gsub("sep", "09", dataPEM$Date)
    dataPEM$Date <- gsub("oct", "10", dataPEM$Date)
    dataPEM$Date <- gsub("nov", "11", dataPEM$Date)
    dataPEM$Date <- gsub("dec", "12", dataPEM$Date)

    # get original date time
    originalDateTime <- paste(dataPEM$Date, dataPEM$Time, sep = " ")

    # convert date and time
    dataPEM <- mutate_(dataPEM,
                       Date = interp(~ functionDate(Date)))
    dataPEM <- mutate_(dataPEM,
                       Time = interp(~ hms(Time)))
#       dplyr::mutate(Date = lubridate::force_tz(Date,
#         "Atlantic/Madeira")) %>%
      # Warning: Time does not have time zone
      # create a variable with date and time together
    dataPEM <- transformTimeDate(resTable = dataPEM)
    timeDate <- dataPEM$dateTime
    nephelometer <- as.numeric(dataPEM$RHCorrectedNephelometer)
    temperature <- dataPEM$Temp
    relativeHumidity <- dataPEM$RH
    battery <- dataPEM$Battery
    inletPressure <- dataPEM$InletPress

    if (version == "CHAI") {
        orificePressure <- dataPEM$OrificePress
    } else {
        orificePressure <- dataPEM$FlowOrificePress
    }

    flow <- dataPEM$Flow

    xAxis <- dataPEM$Xaxis
    yAxis <- dataPEM$Yaxis
    zAxis <- dataPEM$Zaxis
    vectorSum <- dataPEM$VectorSumComposite
    if (version == "CHAI") {
        shutDownReason <- dataPEM$ShutDownReason
        wearingCompliance <- dataPEM$WearingCompliance
        validityWearingComplianceValidation <-
          dataPEM$ValidityWearingCompliancevalidation
        if (is.na(validityWearingComplianceValidation[1])) {
            validityWearingComplianceValidation <- rep(0, length(flow))
        }
    } else {
        names(dataPEM)[14] <- "shutDownReason"
        shutDownReason <- dataPEM$"shutDownReason"
        wearingCompliance <- rep(NA, length(flow))
        validityWearingComplianceValidation <- rep(0, length(flow))
    }

    ###########################################
    # READ THE TOP OF THE FILE
    ###########################################
    participantID <- read.csv(path, skip = 7, header = FALSE, nrow = 1)[1, 2]
    if (is.na(participantID)) {
        participantID <- path
    }


    downloadDate <- mdy(read.csv(path, skip = 1,
                                 header = FALSE,
                                 nrow = 1)[1, 2],
                        tz = "Asia/Kolkata")

    totalDownloadTime <- read.csv(path, skip = 2,
                                  header = FALSE,
                                  nrow = 1)[1, 2]

    deviceSerial <- read.csv(path, skip = 4,
                             header = FALSE,
                             nrow = 1)[1, 2]

    dateTimeHardware <- functionDate(read.csv(path,
                                              skip = 5,
                                              header = FALSE,
                                              nrow = 1)[1, 2],
                                     tz = "Asia/Kolkata")

    dateTimeSoftware <- functionDate(read.csv(path, skip = 6,
                                              header = FALSE,
                                              nrow = 1)[1, 2],
                                     tz = "Asia/Kolkata")

    version <- read.csv(path, skip = 6, header = FALSE,
                        nrow = 1)[1, 3]

    filterID <- toString(read.csv(path, skip = 8,
                                  header = FALSE,
                                  nrow = 1)[1, 2])

    participantWeight <- read.csv(path, skip = 9,
                                  header = FALSE,
                                  nrow = 1)[1, 2]

    inletAerosolSize <- read.csv(path, skip = 10,
                                 header = FALSE,
                                 nrow = 1)[1, 2]

    laserCyclingVariablesDelay <- read.csv(path, skip = 11,
                                           header = FALSE,
                                           nrow = 1)[1, 2]

    laserCyclingVariablesSamplingTime <- read.csv(path, skip = 11,
                                                  header = FALSE,
                                                  nrow = 1)[1, 3]

    laserCyclingVariablesOffTime <- read.csv(path, skip = 11,
                                             header = FALSE,
                                             nrow = 1)[1, 4]

    SystemTimes <- paste0(read.csv(path, skip = 12,
                                   header = FALSE,
                                   nrow = 1)[1, 2],
                          read.csv(path, skip = 12,
                                   header = FALSE,
                                   nrow = 1)[1, 3])

    tempTable <- read.csv(path, skip = 14,
                          header = FALSE, nrow = 10)
    tempTable <- cbind(tempTable[, 2:ncol(tempTable)],
                       rep(NA, nrow(tempTable)))
    nephelometerSlope <- tempTable[1, 1]
    nephelometerOffset <- tempTable[1, 2]
    nephelometerLogInterval <- tempTable[1, 3]
    temperatureSlope <- tempTable[2, 1]
    temperatureOffset <- tempTable[2, 2]
    temperatureLog <- tempTable[2, 3]
    humiditySlope <- tempTable[3, 1]
    humidityOffset <- tempTable[3, 2]
    humidityLog <- tempTable[3, 3]
    inletPressureSlope <- tempTable[4, 1]
    inletPressureOffset <- tempTable[4, 2]
    inletPressureLog <- tempTable[4, 3]
    inletPressureHighTarget <- tempTable[4, 4]
    inletPressureLowTarget <- tempTable[4, 5]
    orificePressureSlope <- tempTable[5, 1]
    orificePressureOffset <- tempTable[5, 2]
    orificePressureLog <- tempTable[5, 3]
    orificePressureHighTarget <- tempTable[5, 4]
    orificePressureLowTarget <- tempTable[5, 5]
    flowLog <- tempTable[6, 3]
    flowHighTarget <- tempTable[6, 4]
    flowLowTarget <- tempTable[6, 5]
    flowWhatIsThis <- tempTable[6, 6]
    accelerometerLog <- tempTable[7, 3]
    batteryLog <- tempTable[8, 3]
    ventilationSlope <- tempTable[9, 1]
    ventilationOffset <- tempTable[9, 2]

    ###########################################
    # control table
    ###########################################
    control <- data.frame(downloadDate = downloadDate,
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
    control <- dplyr::tbl_df(control)
    ###########################################
    # CREATE THE OBJECT
    ###########################################
    if (sum(is.na(xAxis)) == length(xAxis)) {
        xAxis <- rep(0, length(xAxis))
    }

    if (sum(is.na(yAxis)) == length(yAxis)) {
        yAxis <- rep(0, length(yAxis))
    }

    if (sum(is.na(zAxis)) == length(zAxis)) {
        zAxis <- rep(0, length(zAxis))
    }

    if (sum(is.na(vectorSum)) == length(vectorSum)) {
        vectorSum <- rep(0, length(vectorSum))
    }

    measures <- data.frame(timeDate = timeDate,
                           nephelometer = nephelometer,
                           temperature = temperature,
                           relativeHumidity = relativeHumidity,
                           battery = battery,
                           orificePressure = orificePressure,
                           inletPressure = inletPressure,
                           flow = flow,
                           xAxis = xAxis,
                           yAxis = yAxis,
                           zAxis = zAxis,
                           vectorSum = vectorSum,
                           shutDownReason = shutDownReason,
                           wearingCompliance = wearingCompliance,
                           validityWearingComplianceValidation =
                             validityWearingComplianceValidation,
                           originalDateTime = originalDateTime)

    measures <- dplyr::tbl_df(measures)

    microPEMObject <- MicroPEM$new(control = control,
                          calibration = list(NA),
                          measures = measures,
                          original = TRUE)
    return(microPEMObject)
}
########################################################################
# update time
transformTimeDate <- function(resTable) {

  mutateCall <- lazyeval::interp( ~ update(b,
                                           hour = lubridate::hour(a),
                                           minute = lubridate::minute(a),
                                           second = lubridate::second(a)),
                                  a = as.name("Time"),
                                  b = as.name("Date"))

  resTable %>% dplyr::mutate_(.dots = setNames(list(mutateCall),
                                               "dateTime"))
}
