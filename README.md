-   [rtimicropem](#rtimicropem)
-   [Installation](#installation)
-   [Introduction](#introduction)

rtimicropem
===========

[![Build Status](https://travis-ci.org/maelle/rtimicropem.svg?branch=master)](https://travis-ci.org/maelle/rtimicropem) [![Build status](https://ci.appveyor.com/api/projects/status/dfp77q03989j90fw?svg=true)](https://ci.appveyor.com/project/masalmon/rtimicropem) [![codecov.io](https://codecov.io/github/maelle/rtimicropem/coverage.svg?branch=master)](https://codecov.io/github/maelle/rtimicropem?branch=master) [![](https://ropensci.org/badges/126_status.svg)](https://github.com/ropensci/onboarding/issues/126)

Please note that this project is released with a [Contributor Code of Conduct](https://github.com/masalmon/rtimicropem/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.

Installation
============

``` r
library("devtools")
install_github("masalmon/rtimicropem", build_vignettes=TRUE)
```

Introduction
============

This package aims at supporting the analysis of PM2.5 measures made with RTI MicroPEM. [RTI MicroPEM](https://www.rti.org/sites/default/files/brochures/rti_micropem.pdf) are personal monitoring devices (PM2.5 and PM10) developped by [RTI international](https://www.rti.org/).

The goal of the package functions is to help in two main tasks:

-   Checking individual MicroPEM output files after, say, one day of data collection.

-   Building a data base based on output files, and clean and transform the data for further analysis.

For more information check out the [package website](http://www.masalmon.eu/rtimicropem), in particular the [introductory vignette](http://www.masalmon.eu/rtimicropem/articles/vignette_ammon.html).
