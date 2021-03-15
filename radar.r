library(shiny)
# install.packages('shinydashboard')
library(shinydashboard)
library(fmsb)
library(dplyr)
library(readr)
library(ECharts2Shiny)

library(reticulate)
source_python('py_helpers.py')

#######################################################
################ FMSB INGESTION ####################

# read in data from github
data <-  "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv"
data <- read_csv(data)

#######################################################
################ DATA MANIPULATION ####################

# extract most recent rows for each country
recent <- data.frame(data) %>%
  group_by (location) %>%
  slice(which.max(date))

data_out <- as.data.frame(manip_data(recent, 'total_vaccinations',
                                     top_n = 4, early_out=FALSE))

radarchart(data_out)

#######################################################
################ FMSB DASHBOARDING ####################

ui <- shinyUI(dashboardPage(
  dashboardHeader(title = "Radar Charts"),
  dashboardSidebar(),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      box(
        selectInput(
          "metric_type",
          "Please select the metric you wish to investigate",
          choices = c("total_vaccinations", "people_vaccinated",
                      "daily_vaccinations", "total_vaccinations_per_hundred")
        )
      ),

      box(
        title = "Controls",
        sliderInput(
          "top_boundary",
          "Please filter the schools based upon student population:",
          min = 3,
          max = 100,
          value = 10,
          step = 1
        )
      )
    ),
    fluidRow(
      # box(selectizeInput("geo_13_14",
      #                           "Select the school, sos my wording:")),
             box(loadEChartsLibrary(),
               plotOutput('radarPlot')))
  )
))
server <- shinyServer(function(input, output) {
  output$radarPlot <- renderPlot({
    # Create data: note in High school for several students
    set.seed(99)
    data = data_out
    radarchart(as.data.frame(manip_data(recent, input$metric_type, top_n=input$top_boundary)))
    # radarchart(as.data.frame(manip_data(recent, input$download)))
  },
  width = 800,
  height = 600)
})

# FMSB BASED SHINY DASHBOARD
# shinyApp(ui = ui, server = server)

#######################################################
################ E CHARTS EXPERIMENTAL ################

# (NOT FULLY FUNCTIONAL)
ui_echarts <- fluidPage(
  # We MUST load the ECharts javascript library in advance
  loadEChartsLibrary(),

  tags$div(id="test", style="width:50%;height:400px;"),
  deliverChart(div_id = "test")
)

# (NOT FULLY FUNCTIONAL)
server_echarts <- function(input, output) {
  renderRadarChart(div_id = "test",
                  data = data_out)
}

# E CHARTS BASED SHINY DASHBOARD (NOT FULLY FUNCTIONAL)
shinyApp(ui = ui_echarts, server = server_echarts)
