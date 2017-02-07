-   [Installation](#installation)
-   [Introduction](#introduction)

[![Build Status](https://travis-ci.org/masalmon/rtimicropem.svg?branch=master)](https://travis-ci.org/masalmon/rtimicropem) [![Build status](https://ci.appveyor.com/api/projects/status/6nt0r1qsblfm07im?svg=true)](https://ci.appveyor.com/project/masalmon/rtimicropem-4jo57) [![codecov.io](https://codecov.io/github/masalmon/rtimicropem/coverage.svg?branch=master)](https://codecov.io/github/masalmon/rtimicropem?branch=master)

Please note that this package is under development.

Furthermore, this project is released with a [Contributor Code of Conduct](https://github.com/masalmon/rtimicropem/blob/master/CONDUCT.md). By participating in this project you agree to abide by its terms.

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
