library(shiny)

server <- shinyServer(function(input, output, session) {

  ## Creating the dataframe
  d <- reactive({
    data.frame(
      x = 1:3
      , y = 4:6
      , z = 7:9
    )
  })

  ## Calling renderPlot
  output$plotxy <- renderPlot({
    plot( d()$x, d()$y )
  })

  output$plotxz <- renderPlot({
    plot( d()$x, d()$z )
  })

  output$plotzy <- renderPlot({
    plot( d()$z, d()$y )
  })

})

ui <- shinyUI(
  fluidPage(
    plotOutput("plotxy"),
    plotOutput("plotxz"),
    plotOutput("plotzy")
  )
)

shinyApp(ui = ui, server = server)
