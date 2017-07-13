#' Uses output file from MicroPEM to create a \code{micropem} object.
#'
#' @param path the path to the file (\code{character})
#' @return A \code{micropem} object.
#' @examples
#' micropem_example <- convert_output(system.file('extdata', 'CHAI.csv', package = 'rtimicropem'))
#' micropem_example$plot()
#' micropem_example$plot(title = "wow")
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
    pm_data <- data.frame(name = dummy[25:length(dummy)])
    pm_data <- tibble::as_tibble(pm_data)
    names_pm_data <- strsplit(dummy[23], ",")[[1]]
    goal_length <- length(strsplit(dummy[25], ",")[[1]])
    if (length(names_pm_data) == (goal_length - 1)){
      names_pm_data <- c(names_pm_data, "message")
    }
    names_pm_data <- tolower(names_pm_data)
    names_pm_data <- gsub(" ", "_", names_pm_data)
    names_pm_data <- gsub("-", "_", names_pm_data)
    measures <-  suppressWarnings(tidyr::separate_(pm_data,
                                                  "name",
                                       names_pm_data,
                                       sep = ","))
    # known wrong dates
    potential_errors <- c("21/05/105",
                          "35/01/16",
                          "2901/01/29",
                          "0B/02/16",
                          "106/06/14",
                          "15/06/106",
                          "106/06/15",
                          "11/0909/15",
                          "12/0909/15")

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
    measures <- measures %>% dplyr::mutate_(datetime = lazyeval::interp(
      ~ update(date,
               hour = lubridate::hour(time),
               minute = lubridate::minute(time),
               second = lubridate::second(time))
    )) %>%
      dplyr::select_(.dots = list(quote( - date), quote( - time))) %>%
      dplyr::select_(.dots = list(quote(datetime), quote(dplyr::everything())))

    measures$rh_corrected_nephelometer <-
      as.numeric(measures$rh_corrected_nephelometer)
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

    # download_date
    download_date <- strsplit(dummy[2], ",")[[1]][2]
    download_date <- transform_date(download_date)

    # total_download_time
    total_download_time <- as.numeric(strsplit(dummy[3], ",")[[1]][2])
    # device_serial
    device_serial <- as.character(strsplit(dummy[4], ",")[[1]][2])
    # datetime_hardware
    datetime_hardware <- strsplit(dummy[5], ",")[[1]][2]
    datetime_hardware <- transform_date(datetime_hardware)

    # datetime_software
    datetime_software <- strsplit(dummy[6], ",")[[1]][2]
    datetime_software <- transform_date(datetime_software)

    # version
    version <- as.character(strsplit(dummy[6], ",")[[1]][3])

    # participantID
    participantID <- strsplit(dummy[7], ",")[[1]][2]# nolint

    # filterID
    filterID <- strsplit(dummy[8], ",")[[1]][2]# nolint

    # participant_weight
    participant_weight <- suppressWarnings(
      as.numeric(strsplit(dummy[9], ",")[[1]][2]))

    # inlet_aerosol_size
    inlet_aerosol_size <- as.character(strsplit(dummy[10], ",")[[1]][2])

    # laser_cycling_variables_delay
    laser_temp <- strsplit(dummy[11], ",")[[1]]
    laser_cycling_variables_delay <- as.numeric(laser_temp[2])

    # laser_cycling_variables_sampling_time
    laser_cycling_variables_sampling_time <- as.numeric(laser_temp[3])# nolint

    # laser_cycling_variables_off_time
    laser_cycling_variables_off_time <- as.numeric(laser_temp[4])# nolint

    # system_times
    system_times <- as.character(paste(strsplit(dummy[12], ",")[[1]][2],
                         strsplit(dummy[12], ",")[[1]][3]))

    # nephelometer_slope
    nephelometer_temp <- strsplit(dummy[14], ",")[[1]]
    nephelometer_slope <- as.numeric(nephelometer_temp[2])
    # nephelometer_offset
    nephelometer_offset <- as.numeric(nephelometer_temp[3])
    # nephelometer_log_interval
    nephelometer_log_interval <- as.numeric(nephelometer_temp[4])

    # temperature_slope
    temperature_temp <- strsplit(dummy[15], ",")[[1]]
    temperature_slope <- as.numeric(temperature_temp[2])
    # temperature_offset
    temperature_offset <- as.numeric(temperature_temp[3])
    # temperature_log
    temperature_log <- as.numeric(temperature_temp[4])

    # humidity_slope
    humidity_temp <- strsplit(dummy[16], ",")[[1]]
    humidity_slope <- as.numeric(humidity_temp[2])
    # humidity_offset
    humidity_offset <- as.numeric(humidity_temp[3])
    # humidity_log
    humidity_log <- as.numeric(humidity_temp[4])

    # inlet_pressure_slope
    inlet_pressure_temp <- strsplit(dummy[17], ",")[[1]]
    inlet_pressure_slope <- as.character(inlet_pressure_temp[2])
    # inlet_pressure_offset
    inlet_pressure_offset <- as.numeric(inlet_pressure_temp[3])
    # inlet_pressure_log
    inlet_pressure_log <- as.numeric(inlet_pressure_temp[4])
    # inlet_pressure_high_target
    inlet_pressure_high_target <- as.numeric(inlet_pressure_temp[5])
    # inlet_pressure_low_target
    inlet_pressure_low_target <- as.numeric(inlet_pressure_temp[6])

    # orifice_pressure_slope
    orifice_pressure_temp <- strsplit(dummy[18], ",")[[1]]
    orifice_pressure_slope <- as.character(orifice_pressure_temp[2])
    # orifice_pressure_offset
    orifice_pressure_offset <- as.numeric(orifice_pressure_temp[3])
    # orifice_pressure_log
    orifice_pressure_log <- as.numeric(orifice_pressure_temp[4])
    # orifice_pressure_high_target
    orifice_pressure_high_target <- as.numeric(orifice_pressure_temp[5])
    # orifice_pressure_low_target
    orifice_pressure_low_target <- as.numeric(orifice_pressure_temp[6])

    # flow_log
    flow_temp <- strsplit(dummy[19], ",")[[1]]
    flow_log <- as.numeric(flow_temp[4])
    # flow_high_target
    flow_high_target <- as.numeric(flow_temp[5])
    # flow_low_target
    flow_low_target <- as.numeric(flow_temp[6])
    # flow_rate
    flow_rate <- as.numeric(flow_temp[7])
    # accelerometer_log
    accelerometer_log <- as.numeric(strsplit(dummy[20], ",")[[1]][4])
    # battery_log
    battery_log <- as.numeric(strsplit(dummy[21], ",")[[1]][4])
    # ventilation_slope
    ventilation_slope <-
      suppressWarnings(as.numeric(strsplit(dummy[22], ",")[[1]][2]))
    # ventilation_offset
    ventilation_offset <-
      suppressWarnings(as.numeric(strsplit(dummy[22], ",")[[1]][3]))
    ###########################################
    # settings table
    ###########################################
    settings <- tibble::tibble(download_date = download_date,
                    total_download_time = total_download_time,
                    device_serial = device_serial,
                    datetime_hardware = datetime_hardware,
                    datetime_software = datetime_software,
                    version = version,
                    participantID = participantID,# nolint
                    filterID = filterID,# nolint
                    participant_weight = participant_weight,
                    inlet_aerosol_size = inlet_aerosol_size,
                    laser_cycling_variables_delay =
                      laser_cycling_variables_delay,
                    laser_cycling_variables_sampling_time =# nolint
                      laser_cycling_variables_sampling_time,# nolint
                    laser_cycling_variables_off_time =# nolint
                      laser_cycling_variables_off_time,# nolint
                    system_times = system_times,
                    nephelometer_slope = nephelometer_slope,
                    nephelometer_offset = nephelometer_offset,
                    nephelometer_log_interval =
                      nephelometer_log_interval,
                    temperature_slope = temperature_slope,
                    temperature_offset = temperature_offset,
                    temperature_log = temperature_log,
                    humidity_slope = humidity_slope,
                    humidity_offset = humidity_offset,
                    humidity_log = humidity_log,
                    inlet_pressure_slope =
                      inlet_pressure_slope,
                    inlet_pressure_offset =
                      inlet_pressure_offset,
                    inlet_pressure_log = inlet_pressure_log,
                    inlet_pressure_high_target =
                      inlet_pressure_high_target,
                    inlet_pressure_low_target =
                      inlet_pressure_low_target,
                    orifice_pressure_slope =
                      orifice_pressure_slope,
                    orifice_pressure_offset =
                      orifice_pressure_offset,
                    orifice_pressure_log =
                      orifice_pressure_log,
                    orifice_pressure_high_target =
                      orifice_pressure_high_target,
                    orifice_pressure_low_target =
                      orifice_pressure_low_target,
                    flow_log = flow_log,
                    flow_high_target = flow_high_target,
                    flow_low_target = flow_low_target,
                    flow_rate = flow_rate,
                    accelerometer_log = accelerometer_log,
                    battery_log = battery_log,
                    ventilation_slope = ventilation_slope,
                    ventilation_offset = ventilation_offset)
    settings <- tibble::as_tibble(settings)
    ###########################################
    # CREATE THE OBJECT
    ###########################################


    micropem_object <- micropem$new(settings = settings,
                          calibration = list(NA),
                          measures = measures,
                          original = TRUE,
                          filename = pathological::replace_extension(
                            path, new_extension = "csv",
                            include_dir = FALSE))
    return(micropem_object)
}
