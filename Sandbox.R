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
source_python('py_helpers.py')

# # Installs Python Package and Returns it
# install_py_package <- function(name) {
#   output <- tryCatch(
#     {
#       dummy <- reticulate::import(name)
#       return( reticulate::import(name))
#     },
#     error = function(e)
#     {
#       message('ERROR!')
#       message(e)
#       py_install(name, pip = TRUE)
#       dummy <- install_py_package(name)
#       return(reticulate::import(name))
#     },
#     warning = function(w)
#     {
#       message('WARNING!')
#       message(w)
#     },
#     finally = {}
#   )
#   return(output)
# }
#
# # This is just to to use Python directly in the R environment without sourcing
# packages <- hash(c('pandas', 'scipy', 'numpy'), c('pd', 'scp', 'np'))
# py_modules <- lapply(keys(packages), install_py_package)
# for(ref in values(packages)) {
#   assign(ref, py_modules[match(ref, values(packages))])
# }

# Ingest the Data from GitHub
data <-  "https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv"
data <- read_csv(data)

# Manipulate the Data as Required in Python
manip_data(data)

# UI Component of Shiny App
ui <- fluidPage(
  tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
  leafletOutput("map")
)

# Server Component of Shiny App
server <- function(input, output)
{
  # set up map with leaflet
  output$map <- renderLeaflet({...})
}

# Initialize the Server
shinyApp(ui = ui, server = server)
