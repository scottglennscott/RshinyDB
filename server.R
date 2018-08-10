# This app is for mapping the full collaborators
#
#

library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(reshape2)
library(ggplot2)
library(plotly)
library(data.table)
# Server
source("functions/helper_function.R")
function(input, output, session) {
  cus.pal <- RColorBrewer::brewer.pal(5, "Greens")
  
  # Color palette for leaflet map based on cus.pal object
  pal.major <- leaflet::colorFactor(cus.pal, domain = major.cats)
  
  # Read geojson with world country data
  
  shp <- rgdal::readOGR(dsn = "layers")
  shp@data$level <- as.numeric(shp@data$level)
  shp = subset(shp, shp@data$level <= 2)
  shp@data$admin <- as.character(shp@data$loc_name)
  shp2 <- shp
  collab_raw = fread('layers/All Collabs_salesforce.csv')
  #collabs = read.csv('C:/users/Scottg16/repos/RshinyDB/layers/Collaborators in Salesforce_Policy Engagement.csv')
  
  collab_raw  = as.data.table(collab_raw)
 
  test_data = as.data.table(collab_raw)
   # Values for selectize input
  countries <- shp@data$admin
  countries = as.data.table(countries)
  ISO3 <- shp@data$ihme_lc_id
  mock.data.all <- data.table(countries = countries, ISO3.codes = ISO3)
  
  
  epsg4088 <- leafletCRS(
    crsClass = "L.CRS.Simple",
    code = "EPSG:4088",
    proj4def = "+proj=eqc +lat_ts=0 +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +a=6371007 +b=6371007 +units=m +no_defs",
    resolutions = 2^(16:7)
  )

  
  collabs <- reactive({
    collabs = collab_raw   
    
    collabs  = as.data.table(collabs)
    #collabs <- collabs
    collabs <- subsetData(collabs, cause = input$causes, healthfinance = input$healthfinance,  demo = input$demo, 
                          country = input$countries, count.exp = input$count.exp)
#                      healthSystem = input$healthSystem, risk = input$risks, geo = input$geo, Policy = input$Policy  
                          
    })
  
  output$table = renderDataTable(collabs()[,.(`Full Name`, `Primary Affiliation: Account Name`, `Primary Affiliation Country`, `Email`)])
   
  output$map <- renderLeaflet({
    
      collab_count <- count_countries(collabs())
      #collab_count <- count_countries(collab_raw)
      
     shp2@data <- shp@data %>%
       
       left_join(., collab_count, by=c("admin" = "countries"))
     shp2@data = as.data.table(shp2@data)
     shp2@data[is.na(collabs), collabs := 0]
     
     # Popup
     popup <- paste0("<strong>Country: </strong>",
                     shp2@data$loc_name,
                     "<br><strong>Collaborators: </strong>",
                     shp2@data$collabs
     )
     
     max = max(collab_count[countries != "", collabs])
     #
     bins <- unique(c(0, 1, ceiling(max/500), ceiling(max/250), ceiling(max/100), ceiling(max/50), ceiling(max/25), ceiling(max/10), ceiling(max/8), ceiling(max/4), ceiling(max/2), ceiling(max/1.5), ceiling(max/1.2), ceiling(max), Inf))
     if(length(bins) <=  3){
       color = colorRamp(c("#D5D5D5", "#2A6481"), interpolate = "spline")
     }else{
       color = colorRamp(c("#D5D5D5", "#CBE19F", "#A0CE9F", "#69B46C", "#68B66B", "#009994", "#2A6481"), interpolate = "spline")
     }
     pal <- colorBin(color, domain = shp2@data$collabs, bins = bins)
     
     map <-leaflet(data = shp2, options = leafletOptions(crs = epsg4088)) %>%
           # Add polygons
           addPolygons(fillColor = ~pal(collabs),
                       fillOpacity = 0.6,
                       color = "#BDBDC3",
                       weight = 1,
                       popup = popup) %>%
      #     # Set view on area between Europe & USA
           setView(lng = -27.5097656, lat = 29.0801758, zoom = 2)#%>%
      #     #addLegend(pal = qpal, values = ~gdp_md_est, opacity = 1)
       map
   })
   
}


