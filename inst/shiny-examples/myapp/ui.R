library("shiny")
library("dplyr")
library("lubridate")
library("xtable")
library("shinydashboard")
library("datasets")
library("DT")
library("rbokeh")
library("rtimicropem")
options(RCHART_LIB = 'highcharts')
shinyUI(fluidPage(

  titlePanel("Exploring RTI MicroPEM output"),

  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Choose file to explore',
                accept = c(
                  'text/csv',
                  'text/comma-separated-values',
                  'text/tab-separated-values',
                  'text/plain',
                  '.csv',
                  '.tsv'
                )),
      selectInput('graphtype', 'Plot type (interactive takes a while to load!)',
                  c("plain", "interactive"),
                  selected = "plain"),
      actionButton("go", "Go")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Summary",
                 DT::dataTableOutput("Summary")),
        tabPanel("Alarms",
                 DT::dataTableOutput("Alarms")),
        tabPanel("Plot",
                 conditionalPanel(condition = "input.graphtype == 'interactive'",
                                  rbokehOutput("plotPM")),
                 conditionalPanel(condition = "input.graphtype == 'plain'",
                                  plotOutput("plotPM2"))),

        tabPanel("Settings",
                 DT::dataTableOutput("Settings"))
    )
  )
  )

  ))


