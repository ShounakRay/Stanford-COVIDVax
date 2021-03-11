library(shiny)
# install.packages('shinydashboard')
library(shinydashboard)
library(fmsb)
library(dplyr)
library(readr)
library(leaflet)
library(maptools)
library(rworldmap)

library(reticulate)
source_python('py_helpers.py')

# read in data from github
data <-  "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv"
data <- read_csv(data)

# extract most recent rows for each country
recent <- data.frame(data) %>%
  group_by (location) %>%
  slice(which.max(date))

data_out <- as.data.frame(manip_data(recent, 'total_vaccinations'))

radarchart(data_out)

ui <- shinyUI(dashboardPage(
  dashboardHeader(title = "Working on it"),
  dashboardSidebar(),
  dashboardBody(# Boxes need to be put in a row (or column)

    # fluidRow(
    #   box(
    #     selectInput(
    #       "School",
    #       "Please select the schools you want to compare",
    #       choices = c("Elementary", "Middle & High")
    #     )
    #   ),
    #
    #   box(
    #     title = "Controls",
    #     sliderInput(
    #       "schoolSize",
    #       "Please filter the schools based upon student population:",
    #       min = 2,
    #       max = 800,
    #       value = c(100, 200),
    #       step = 20
    #     )
    #   )
    # ),
    fluidRow(# box(
      #   selectizeInput("geo_13_14",
      #                  "Select the school, sos my wording:",
      #                  choices = geo_school)
      # ),
      box(
        plotOutput('radarPlot')
      )))
))

server <- shinyServer(function(input, output) {
  output$radarPlot <- renderPlot({
    # Create data: note in High school for several students
    set.seed(99)
    data = data_out
    colors_border = c(rgb(0.2, 0.5, 0.5, 0.9),
                      rgb(0.8, 0.2, 0.5, 0.9) ,
                      rgb(0.7, 0.5, 0.1, 0.9))
    colors_in = c(rgb(0.2, 0.5, 0.5, 0.4),
                  rgb(0.8, 0.2, 0.5, 0.4) ,
                  rgb(0.7, 0.5, 0.1, 0.4))
    radarchart(data)
    legend(x = 0.7,
           y = 1,
           legend = rownames(data[-c(1, 2), ]))
  })
})

# Run the application
shinyApp(ui = ui, server = server)
