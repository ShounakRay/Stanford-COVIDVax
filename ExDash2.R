# install.packages('leaflet')
# install.packages('shiny')
# install.packages('maptools')
# install.packages('rworldmap')
# install.packages('hash')

library(dplyr)
library(readr)
library(leaflet)
library(shiny)
library(maptools)
library(rworldmap)

library(reticulate)
library(hash)
use_condaenv("r-reticulate")
# py_discover_config()
# py_config()

# message('Python package ' + name + ' doesn\'t exist.\n')

# Installs Python Package and Returns it
install_py_package <- function(name) {
  output <- tryCatch(
    {
      dummy <- reticulate::import(name)
      return( reticulate::import(name))
    },
    error = function(e)
    {
      message('ERROR!')
      message(e)
      py_install(name, pip = TRUE)
      dummy <- install_py_package(name)
      return(reticulate::import(name))
    },
    warning = function(w)
    {
      message('WARNING!')
      message(w)
    },
    finally = {}
  )
  return(output)
}

packages <- c()

# read in data from github
data <-  "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv"
data <- read_csv(data)

# extract most recent rows for each country
recent <- data.frame(data) %>%
  group_by (location) %>%
  slice(which.max(date))

# join shapefile to vaccination data for mapping
geo_data <- joinCountryData2Map(recent,joinCode = "ISO3" ,nameJoinColumn = "iso_code")

# shiny code:
ui <- fluidPage(
  tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  leafletOutput("map")
  # can you implement some input elements here (e.g. date slider, variable selector)?
)

server <- function(input, output) {
  # set up map with leaflet
  output$map <- renderLeaflet({
    pal <- colorNumeric("Reds", domain = NULL, reverse = FALSE)
    leaflet() %>% setView(0, 0, 2) %>%
      addPolygons(data = geo_data, weight = 1, fillOpacity = 1.0,
                  fillColor = ~pal(people_vaccinated)) # try other variable names here!
      # how can we make the number of people vaccinated pop up as we hover over different countries?
  })

}

shinyApp(ui = ui, server = server)
