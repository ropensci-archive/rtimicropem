[![Build Status](https://travis-ci.org/masalmon/ammon.svg?branch=master)](https://travis-ci.org/masalmon/ammon) [![Build status](https://ci.appveyor.com/api/projects/status/6a9mh4llv8uew4xx?svg=true)](https://ci.appveyor.com/project/masalmon/ammon) [![codecov.io](https://codecov.io/github/masalmon/ammon/coverage.svg?branch=master)](https://codecov.io/github/masalmon/ammon?branch=master)

Please note that this package is undergoing major changes.

Installation
============

``` r
library("devtools")
install_github("masalmon/ammon", build_vignettes=TRUE)
```

Introduction
============

This package aims at supporting the analysis of PM2.5 measures made with RTI MicroPEM. It is called ammon like Zeus Ammon (<https://en.wikipedia.org/wiki/Amun#Greece> ) because it helps us to Analyse Micropem MONitoring data in a very good, nearly godly, way.

The goal of the package functions is to get a time series of PM2.5 measures ready for analysis, with a good level of confidence in the measures. For this, the package provides a function for transforming the output of a RTI MicroPEM into an object of a R6 class called `MicroPEM`, functions for examining this information in order to look for possible problems in the data, and a function for cleaning the time series of PM2.5 based on the values of other variables such as relative humidity. The package moreover provides a Shiny app used for the field work of the CHAI project, but that could easily be adapted to other contexts. This vignette aims at providing an overview of the functionalities of the package.

From input data to `MicroPEM` objects
=====================================

The MicroPEM device outputs a csv file with all the information about the measures:

-   the measures themselves (relative humidity corrected nephelometer),

-   other measures that can help interpret them or check that no problem occured (temperature, relative humidity, battery, orifice pressure, inlet pressure, flow, accelerometer variables, reasons for shutdown, and variables related to user compliance),

-   a reminder of parameters set by the user (calibration parameters, frequency of measures)

-   and information about the device (filter ID, version of the software, etc). This is a lot of information, compiled in a handy csv format that is optimal for not loosing any data along the way, but not practical for analysis.

Therefore, the `ammon` package offers a R6 class called `MicroPEM` for storing the information, that will be easier to use by other functions. The class has fields with measures over time and a field that is a list containing all the information located at the top of the MicroPEM output file, called `control`. Here is a picture of a RTI MicroPEM output file showing how the information is stored in the R6 class.

![alt text](outputRTI.png)

We will start by presenting the `control` field.

`control` Slot
--------------

This field is a data.frame (dplyr tbl\_df) that includes 41 variables:

-   `downloadDate` which is the date at which the files was downloaded from the device to a PC. It is a `POSIXt`.

-   `totalDownloadTime` gives the total download time, in seconds.

-   `deviceSerial` is the serial number of the device, which could be useful for e.g. finding a faulty device based on many output files.

-   `dateTimeHardware` indicates the date of release of the device. It is a `POSIXt`.

-   `dateTimeSoftware` indicates the date of release of the software used on the device. It is a `POSIXt`.

-   `version` indicates the version of the software.

-   `participantID` indicated the participantID, deduced either from the corresponding cell in the output file, or from the filename.

-   `filterID` is the ID number of the filter used for these measures.

-   `participantWeight` is a numeric variable.

-   `inletAerosolSize` is a factor variable, either "PM2.5" or "PM10". Please note that this variable does not provide confirmation that this aerosol size was measured, since it was chosen by hand by the person preparing the device for these measures. One could choose "PM2.5" and put the inlet for PM10, in which case PM10, not PM2.5, would be measured.

-   `laserCyclingVariablesDelay`

-   `laserCyclingVariablesSamplingTime`

-   `laserCyclingVariablesOffTime`

-   `SystemTimes` indicates whether the device was always on, or whether it was on/off, in which case the length of the on and off periods are given in seconds.

-   `nephelometerSlope`

-   `nephelometerOffset`

-   `nephelometerLogInterval` indicates how many seconds there are between measures of PM.

-   `temperatureSlope`

-   `temperatureOffset`

-   `temperatureLog` indicates how many seconds there are between measures of temperature.

-   `humiditySlope`

-   `humidityOffset`

-   `humidityLog` indicates how many seconds there are between measures of humidity.

-   `inletPressureSlope`

-   `inletPressureOffset`

-   `inletPressureLog` indicates how many seconds there are between measures of inlet pressure.

-   `inletPressureHighTarget`

-   `inletPressureLowTarget`

-   `orificePressureSlope`

-   `orificePressureOffset`

-   `orificePressureLog` indicates how many seconds there are between measures of orifice pressure.

-   `orificePressureHighTarget`

-   `orificePressureLowTarget`

-   `flowLog` indicates how many seconds there are between measures of flow.

-   `flowHighTarget`

-   `flowLowTarget`

-   `flowWhatIsThis`

-   `accelerometerLog`

-   `batteryLog` indicates how many seconds there are between measures of battery.

-   `ventilationSlope`

-   `ventilationOffset`

Time-varying measures
---------------------

This field is a data.frame (dplyr tbl\_df) with these 15 columns:

-   `timeDate` is a `POSIXt` giving the date and time of each measure.

-   `temperature` is a numeric variable, in centigrade.

-   `relativeHumidity` is a proportion.

-   `battery`is a numeric variable.

-   `orifice pressure` and `inlet pressure` are numeric variables, in inches of water.

-   `flow` is a numeric variable, in liters per minute.

-   `xAxis`, `yAxis` and `zAxis` are accelerometer measures in three dimensions, with `vectorSum` being their sum.

-   `shutDownReason` is a factor variable indicating the reason for shutdown, in case a shutdown happened at this timepint.

-   `wearingCompliance` and `validityWearingCompliance` are respectively a logical and a character variables.

The `convertOutput` function.
-----------------------------

The `convertOutput` only takes two arguments as input: the path to the output file, and the version of the output file, either "CHAI" or "Columbia" (version with one blank line after each line with content). The result of a call to this function is an object of the class `MicroPEM`. Below is a example of a call to `convertOutput`.

``` r
library("ammon")
MicroPEMExample <- convertOutput(system.file("extdata", "dummyCHAI.csv", package = "ammon"),
version="CHAI")
class(MicroPEMExample)
```

    ## [1] "MicroPEM" "R6"

Visualizing information contained in a `MicroPEM` object
========================================================

Plot method
-----------

The R6 `microPEM` class has its own plot method. It allows to draw a plot of all time-varying measures against the `timeDate` field. It takes two arguments: the `MicroPEM` object to be plotted, and the type of plots to be produced, either a "plain" ggplot2 plot with 6 facets, or its interactive version produced with the ggiraph package -- the corresponding values of type are respectively "plain" and "interactive".

Below we show to examples of uses of the plot method on a `MicroPEM` object.

This is a "plain" plot.

``` r
data("dummyMicroPEMChai")
par(mar=c(1,4,2,1))
dummyMicroPEMChai$plot()
```

![](README_files/figure-markdown_github/unnamed-chunk-3-1.png)<!-- -->

This is a nicer and interactive representation: you can look at what happens if you put your mouse over the time series. It is to be used as visualization tool as well, not as a plot method for putting a nice figure in a paper.

``` r
library("ggiraph")
p <- dummyMicroPEMChai$plot(type = "interactive")
ggiraph(code = {print(p)}, width = 10, height = 10)
```

`summary` method
----------------

Plotting the `MicroPEM` object is already a good way to notice any problem. Another methods aims at providing more compact information about the time-varying measures. It is called `summary` and outputs a table with summary statistics for each time-varying measures, except timeDate.

Below is an example of use of this method.

``` r
library("xtable")
data("dummyMicroPEMChai")
results <- dummyMicroPEMChai$summary()
print(xtable(results),  type = "html", include.rownames = FALSE, floating=FALSE)
```

<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Tue Feb 23 16:08:37 2016 -->
<table border="1">
<tr>
<th>
measure
</th>
<th>
No. of no missing values
</th>
<th>
Median
</th>
<th>
Mean
</th>
<th>
Minimum
</th>
<th>
Maximum
</th>
<th>
Variance
</th>
</tr>
<tr>
<td>
nephelometer
</td>
<td align="right">
8634
</td>
<td align="right">
49.00
</td>
<td align="right">
49.37
</td>
<td align="right">
45.00
</td>
<td align="right">
93.00
</td>
<td align="right">
1.68
</td>
</tr>
<tr>
<td>
temperature
</td>
<td align="right">
2878
</td>
<td align="right">
84.50
</td>
<td align="right">
84.68
</td>
<td align="right">
82.30
</td>
<td align="right">
87.60
</td>
<td align="right">
1.72
</td>
</tr>
<tr>
<td>
relativeHumidity
</td>
<td align="right">
8634
</td>
<td align="right">
54.60
</td>
<td align="right">
55.01
</td>
<td align="right">
46.20
</td>
<td align="right">
64.90
</td>
<td align="right">
7.67
</td>
</tr>
<tr>
<td>
battery
</td>
<td align="right">
1464
</td>
<td align="right">
4.10
</td>
<td align="right">
4.09
</td>
<td align="right">
3.90
</td>
<td align="right">
4.30
</td>
<td align="right">
0.01
</td>
</tr>
<tr>
<td>
orificePressure
</td>
<td align="right">
2878
</td>
<td align="right">
0.15
</td>
<td align="right">
0.15
</td>
<td align="right">
0.14
</td>
<td align="right">
0.16
</td>
<td align="right">
0.00
</td>
</tr>
<tr>
<td>
inletPressure
</td>
<td align="right">
2878
</td>
<td align="right">
0.11
</td>
<td align="right">
0.11
</td>
<td align="right">
0.10
</td>
<td align="right">
0.13
</td>
<td align="right">
0.00
</td>
</tr>
<tr>
<td>
flow
</td>
<td align="right">
2878
</td>
<td align="right">
0.77
</td>
<td align="right">
0.77
</td>
<td align="right">
0.77
</td>
<td align="right">
0.78
</td>
<td align="right">
0.00
</td>
</tr>
</table>
`compareSettings` function
--------------------------

When analysing the measures, one is also interesting into knowing if the parameters were set in a consistent way. Two functionalities the `ammon` package allow to explore the upper part of an output MicroPEM file, that is, the settings. The first one is not a function, it simply corresponds to looking at the `control` field:

``` r
library("xtable")
data("dummyMicroPEMChai")
settings <- dummyMicroPEMChai$control
print(xtable(settings),  type = "html", include.rownames = FALSE, floating=FALSE)
```

    ## Warning in formatC(x = structure(1435948200, tzone = "Asia/Kolkata", class
    ## = c("POSIXct", : class of 'x' was discarded

    ## Warning in formatC(x = structure(1360866600, tzone = "Asia/Kolkata", class
    ## = c("POSIXct", : class of 'x' was discarded

    ## Warning in formatC(x = structure(1390501800, tzone = "Asia/Kolkata", class
    ## = c("POSIXct", : class of 'x' was discarded

<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Tue Feb 23 16:08:37 2016 -->
<table border="1">
<tr>
<th>
downloadDate
</th>
<th>
totalDownloadTime
</th>
<th>
deviceSerial
</th>
<th>
dateTimeHardware
</th>
<th>
dateTimeSoftware
</th>
<th>
version
</th>
<th>
participantID
</th>
<th>
filterID
</th>
<th>
participantWeight
</th>
<th>
inletAerosolSize
</th>
<th>
laserCyclingVariablesDelay
</th>
<th>
laserCyclingVariablesSamplingTime
</th>
<th>
laserCyclingVariablesOffTime
</th>
<th>
SystemTimes
</th>
<th>
nephelometerSlope
</th>
<th>
nephelometerOffset
</th>
<th>
nephelometerLogInterval
</th>
<th>
temperatureSlope
</th>
<th>
temperatureOffset
</th>
<th>
temperatureLog
</th>
<th>
humiditySlope
</th>
<th>
humidityOffset
</th>
<th>
humidityLog
</th>
<th>
inletPressureSlope
</th>
<th>
inletPressureOffset
</th>
<th>
inletPressureLog
</th>
<th>
inletPressureHighTarget
</th>
<th>
inletPressureLowTarget
</th>
<th>
orificePressureSlope
</th>
<th>
orificePressureOffset
</th>
<th>
orificePressureLog
</th>
<th>
orificePressureHighTarget
</th>
<th>
orificePressureLowTarget
</th>
<th>
flowLog
</th>
<th>
flowHighTarget
</th>
<th>
flowLowTarget
</th>
<th>
flowWhatIsThis
</th>
<th>
accelerometerLog
</th>
<th>
batteryLog
</th>
<th>
ventilationSlope
</th>
<th>
ventilationOffset
</th>
</tr>
<tr>
<td align="right">
1435948200.00
</td>
<td align="right">
18
</td>
<td>
MP1411
</td>
<td align="right">
1360866600.00
</td>
<td align="right">
1390501800.00
</td>
<td>
v2.0.5136.37657
</td>
<td>
C:/Users/msalmon/Documents/R/win-library/3.2/ammon/extdata/dummyCHAI.csv
</td>
<td>
CM1411
</td>
<td>
</td>
<td>
PM2.5
</td>
<td align="right">
1
</td>
<td align="right">
1
</td>
<td align="right">
8
</td>
<td>
No cycling - Always OnNA
</td>
<td>
10.000
</td>
<td align="right">
0
</td>
<td align="right">
10
</td>
<td>
10.000
</td>
<td align="right">
0
</td>
<td align="right">
30
</td>
<td>
10.000
</td>
<td align="right">
0
</td>
<td align="right">
10
</td>
<td>
40.950.000
</td>
<td align="right">
0
</td>
<td align="right">
30
</td>
<td align="right">
1280
</td>
<td align="right">
768
</td>
<td>
40.950.000
</td>
<td align="right">
0
</td>
<td align="right">
30
</td>
<td align="right">
2167
</td>
<td align="right">
1592
</td>
<td align="right">
30
</td>
<td align="right">
900
</td>
<td align="right">
200
</td>
<td align="right">
0.50
</td>
<td align="right">
5
</td>
<td align="right">
60
</td>
<td>
</td>
<td align="right">
</td>
</tr>
</table>
Then, in some cases, once one has collected several output files from RTI MicroPEM devices, before using the measures one would like to check that e.g. the nephelometer slope is the same for all measures. The `compareSettings` function answers this need. It takes two arguments as input: the directory in which all (and only) the output files are, and the version of this output files (either "CHAI" or "Columbia"). It outputs a data.frame with all parameters as columns, each file corresponding to a line.

ADD EXAMPLE LATER.

Shiny app developped for the CHAI project
-----------------------------------------

In the context of the CHAI project, we developped a Shiny app based on the previous functions, that allows to explore a MicroPEM output file. The app is called by the function `runShinyApp` with no argument. There is one side panel where one can choose the file to analyse. There are four tabs:

-   One with the output of a call to `summaryTimeVarying`,

-   One with the output of a call to the `alarmCHAI` function that performs a few checks specific to the CHAI project,

-   One with the output of a call to the plot method,

-   One with the output of a call to `summarySettings`.

This app allows the exploration of a MicroPEM output file with no R experience.

Below we show screenshots of the app.

![alt text](shinyTabSummary.png)

![alt text](shinyTabAlarm.png)

![alt text](shinyTabPlot.png)

![alt text](shinyTabSettings.png)

Modifying a `microPEM` object
=============================

The `filterTimeDate` function
-----------------------------

One could be interested in only a part of the time-varying measures, e.g. the measures from the afternoon. Using the `filterTimeDate`function on a `MicroPEM` object, one can get a `MicroPEM` object with shorter fields for the time-varying variables, based on the values of `fromTime`and `untilTime` that should be `POSIXct`.

In the code below, we only keep measures from the first 12 hours of measures.

``` r
# load the lubridate package
library('lubridate')
# load the dummy MicroPEM object
data('dummyMicroPEMChai')
# look at the dimensions of the data.frame
print(dummyMicroPEMChai$measures)
```

    ## Source: local data frame [17,279 x 16]
    ## 
    ##               timeDate nephelometer temperature relativeHumidity battery
    ##                 (time)        (dbl)       (dbl)            (dbl)   (dbl)
    ## 1  2015-07-03 08:02:18           NA          NA               NA      NA
    ## 2  2015-07-03 08:02:32           NA          NA               NA      NA
    ## 3  2015-07-03 08:05:51           NA          NA               NA      NA
    ## 4  2015-07-03 08:05:52           NA          NA               NA      NA
    ## 5  2015-07-03 08:05:55           NA          NA               NA      NA
    ## 6  2015-07-03 08:06:00           NA          NA               NA     4.3
    ## 7  2015-07-03 08:06:05           NA          NA               NA      NA
    ## 8  2015-07-03 08:06:10           51        83.4             56.2     4.3
    ## 9  2015-07-03 08:06:15           NA          NA               NA      NA
    ## 10 2015-07-03 08:06:20           51          NA             56.4      NA
    ## ..                 ...          ...         ...              ...     ...
    ## Variables not shown: orificePressure (dbl), inletPressure (dbl), flow
    ##   (dbl), xAxis (dbl), yAxis (dbl), zAxis (dbl), vectorSum (dbl),
    ##   shutDownReason (fctr), wearingCompliance (lgl),
    ##   validityWearingComplianceValidation (dbl), originalDateTime (fctr).

``` r
# command for only keeping measures from the first twelve hours
shorterMicroPEM <- filterTimeDate(MicroPEMObject=dummyMicroPEMChai,
untilTime=NULL,
fromTime=min(dummyMicroPEMChai$measures$timeDate, na.rm=TRUE) + hours(12))
# look at the dimensions of the data.frame
print(shorterMicroPEM$measures)
```

    ## Source: local data frame [8,678 x 16]
    ## 
    ##               timeDate nephelometer temperature relativeHumidity battery
    ##                 (time)        (dbl)       (dbl)            (dbl)   (dbl)
    ## 1  2015-07-03 20:02:20           49          NA             54.3      NA
    ## 2  2015-07-03 20:02:25           NA          NA               NA      NA
    ## 3  2015-07-03 20:02:30           49          NA             54.5      NA
    ## 4  2015-07-03 20:02:35           NA          NA               NA      NA
    ## 5  2015-07-03 20:02:40           49        85.9             54.7      NA
    ## 6  2015-07-03 20:02:45           NA          NA               NA      NA
    ## 7  2015-07-03 20:02:50           49          NA             54.1      NA
    ## 8  2015-07-03 20:02:55           NA          NA               NA      NA
    ## 9  2015-07-03 20:03:00           49          NA             53.8      NA
    ## 10 2015-07-03 20:03:05           NA          NA               NA      NA
    ## ..                 ...          ...         ...              ...     ...
    ## Variables not shown: orificePressure (dbl), inletPressure (dbl), flow
    ##   (dbl), xAxis (dbl), yAxis (dbl), zAxis (dbl), vectorSum (dbl),
    ##   shutDownReason (fctr), wearingCompliance (lgl),
    ##   validityWearingComplianceValidation (dbl), originalDateTime (fctr).

The `cleaningMeasures` function
-------------------------------

For now, the `cleaningMeasures` function returns a MicroPEM-object where the nephelometer values are set to NA if the relative humidity at the same time is higher than 90% or if the values were negative. Nephelometer values are also corrected for the HEPA zeroings (start and end, if there were done): if a stable period longer than 3 minutes can be identified for the HEPA period, using the changepoint cpt.mean function, there is a zero value. There can be no zero values, only one (beginning or end) or two. If there is only one zero value, it is substracted from all nephelometer values. If there are two, a linear interpolation is done between the two values and the resulting vector is substracted from the nephelometer values.
