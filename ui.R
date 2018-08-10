
#
# This is a template for creating a leaflet chroropleth map shiny application.
# This app uses mock data that resembles survey answers to several major & minor categories
# This app is based on rstudio's 'superzip' example authored by Joe Cheng.
#
# Author: Jasper Ginn
#

library(shiny)
library(leaflet)
library(plotly)
library(data.table)
# Shiny UI
sidebarLayout(
  sidebarPanel(id = "controls",
             class = "panel panel-default", fixed = TRUE,
             draggable = FALSE, top = 60, left = "auto",
             right = 20, bottom = "auto",
              height = "auto",
             h2("Select Options"),
             selectInput("countries", "Collaborator Location",
                         choices = c("-", countries),
                         selected = "-"),
             # Selectize input for category
             selectInput("causes", "Select cause of expertise",
                         choices = c("-", causes.cat),
                         selected = "-"),
             # Selectize input for category
             selectInput("risks", "Select risk of expertise (Under construction)",
                         choices = c("-", rei.cat),
                         selected = "-"),
             selectInput("count.exp", "Countries of expertise", 
                           choices = c("-", countries),
                           selected = "-"),
             checkboxInput("healthfinance", "Expertise in health financing",
                           value = FALSE),
             checkboxInput("SDG", "Expertise in SDG monitoring and evaluations (Under construction)",
                           value = FALSE),
             checkboxInput("demo", "Demography expert (Under construction)",
                           value = FALSE),
             checkboxInput("geo", "Expertise in geospatial analysis (under construction)",
                           value = FALSE),
             checkboxInput("Policy", "Policy engagement interest (Under construction)",
                           value = FALSE)
             
             # Add output for country & category that has been selected
),

mainPanel(
navbarPage("GBD Collaborators. Do Not Share", id="nav",
           tabPanel("Interactive map",
                    div(class="outer",
                        tags$head(
                          # Include our custom CSS
                           includeCSS("www/styles.css")
                        ),
                        # Output leaflet map
                        leafletOutput("map", width="100%", height="1000px"),
                        # Sidebar panel
                  

                        #
                        # Add citation. Textouput does not work. Not sure why.
                        #

                        tags$div(id="cite",
                                  textOutput("lastUpdate"), "             "
                        )
                      )
                  ),
           tabPanel("Collaborator table",
                    div(class="outer",
                        tags$head(
                          # Include our custom CSS
                          includeCSS("www/styles.css")
                        ),
                        # Output leaflet map
                        fluidPage(
                          fluidRow(
                            column(12,
                                  dataTableOutput('table')
                            )
                          )
                        )
                        
    
                    )
           ),
           

           conditionalPanel("false", icon("crosshair"))
)
)
)

