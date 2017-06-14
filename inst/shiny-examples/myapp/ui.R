library("shiny")
library("dplyr")
library("lubridate")
library("xtable")
library("datasets")
library("DT")
library("rbokeh")
library("rtimicropem")
library("ggplot2")
options(RCHART_LIB = "highcharts")
shiny::shinyUI(shiny::fluidPage(

  shiny::titlePanel("Exploring RTI MicroPEM output"),

  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::fileInput("file1", "Choose file to explore",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values",
                  "text/tab-separated-values",
                  "text/plain",
                  ".csv",
                  ".tsv"
                )),
      shiny::selectInput("graphtype",
                         "Plot type (interactive takes a while to load!)",
                  c("plain", "interactive"),
                  selected = "plain"),
      shiny::actionButton("go", "Go")
    ),
    shiny::mainPanel(
      shiny::tabsetPanel(
        shiny::tabPanel("Summary",
                 DT::dataTableOutput("Summary")),
        shiny::tabPanel("Alarms",
                 DT::dataTableOutput("Alarms")),
        shiny::tabPanel("Plot",
                        shiny::conditionalPanel(condition =
                                    "input.graphtype == 'interactive'",
                                  rbokeh::rbokehOutput("plotpm")),
                        shiny::conditionalPanel(condition = "input.graphtype == 'plain'",
                                                shiny::plotOutput("plotpm2"))),

        shiny::tabPanel("Settings",
                 DT::dataTableOutput("Settings"))
    )
  )
  )

  ))
