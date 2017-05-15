library("shiny")
library("dplyr")
library("lubridate")
library("xtable")
library("rtimicropem")
library("DT")
library("rbokeh")
library("ggplot2")

shinyServer(function(input, output) {


  microPEMObject <- eventReactive(input$go, {

    file <- reactive({input$file1})
    if (is.null(input$file1))
    return(NULL)

    else {
      convert_output(file()$datapath)
    }
       })

  output$Settings<- DT::renderDataTable({
    file <- reactive({input$file1})
    if (is.null(input$file1))
      return(NULL)

    else {
      data.frame(value = t(microPEMObject()$settings))

    }
  }, options = list(pageLength = 41))




    output$Summary <- DT::renderDataTable({
      microPEMObject()$summary()
    })

    output$Alarms <- DT::renderDataTable({
      alarmCHAI(microPEMObject())
    })


    output$plotPM <- rbokeh::renderRbokeh({microPEMObject()$
        plot(type="interactive")})

    output$plotPM2 <- renderPlot({microPEMObject()$plot(type="plain")+
        ggplot2::theme(legend.position="none")
                             },
                             width = 600, height = 600)



})

