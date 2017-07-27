---
title: 'rtimicropem: an R package supporting the analysis of RTI MicroPEM output files'
tags:
  - R
  - sensors
  - PM2.5
authors:
 - name: Maëlle Salmon
   orcid: 0000-0002-2815-0399
   affiliation: 1
 - name: Sreekanth Vakacherla
   orcid: 0000-0003-0400-6584
   affiliation: 2
 - name: Carles Milà
   orcid: 0000-0003-0470-0760
   affiliation: 1
 - name: Julian D. Marshall
   orcid:
   affiliation: 2
 - name: Cathryn Tonne
   orcid: 0000-0003-3919-8264
   affiliation: 1
affiliations:
 - name: ISGlobal, Centre for Research in Environmental Epidemiology (CREAL), Universitat Pompeu Fabra, CIBER Epidemiología y Salud Pública, Barcelona, Spain.
   index: 1
 - name: Department of Civil and Environmental Engineering, University of Washington, Seattle, WA, USA
   index: 2
date: 14 June 2017
bibliography: paper.bib
---

# Summary

rtmicropem [@rtimicropem] is an R package [@R-base] that aims at supporting the analysis of PM2.5 measures made with RTI MicroPEM. [RTI MicroPEM](https://www.rti.org/sites/default/files/brochures/rti_micropem.pdf) are personal monitoring devices (PM2.5 and PM10) developped by [RTI international](https://www.rti.org/). They output csv files containing both settings and measurements corresponding to measurement sessions. These files are not tabular data, that the package transforms into tabular data.

The goal of the package functions is to help in two main tasks:

-   Checking individual MicroPEM output files after, say, one day of data collection. For this the package includes an R6 class representing one file/session of measurements with a plot method and a summary method, and a Shiny app for uploading and exploring single files.

-   Building a data base based on output files, and clean and transform the data for further analysis. For this the package offers a function for saving all RTI MicroPEM output files of a folder into two csv containing, respectively, the settings and measurements of all files.

The documentation includes a transparent report of the data cleaning process used in the [CHAI project](http://www.chaiproject.org/) [@TONNE20171081].

# References
