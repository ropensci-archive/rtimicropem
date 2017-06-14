library("shiny")
library("dplyr")
library("lubridate")
library("xtable")
library("rtimicropem")
library("DT")
library("rbokeh")
library("ggplot2")

shiny::shinyServer(function(input, output) {


  micropem_object <- shiny::eventReactive(input$go, {

    file <- shiny::reactive({input$file1})
    if (is.null(input$file1))
    return(NULL)

    else {
      convert_output(file()$datapath)
    }
       })

  output$Settings <- DT::renderDataTable({
    file <- shiny::reactive({input$file1})
    if (is.null(input$file1))
      return(NULL)

    else {
      data.frame(value = t(micropem_object()$settings))

    }
  }, options = list(pageLength = 41))




    output$Summary <- DT::renderDataTable({
      micropem_object()$summary()
    })

    output$Alarms <- DT::renderDataTable({
      chai_alarm(micropem_object())
    })


    output$plotpm <- rbokeh::renderRbokeh({micropem_object()$
        plot(type = "interactive")})

    output$plotpm2 <- shiny::renderPlot({micropem_object()$plot(type = "plain") +
        ggplot2::theme(legend.position = "none")
                             },
                             width = 600, height = 600)

})
