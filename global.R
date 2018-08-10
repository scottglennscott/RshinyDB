# Load major & minor categories for the survey mock data
source("settings/categories.R")
library(data.table)
library(ggplot2)
library(rgdal)
library(leaflet)
# Create color palette

# Read geojson with world country data

shp <- rgdal::readOGR(dsn = "layers")
shp@data$level <- as.numeric(shp@data$level)
shp = subset(shp, shp@data$level <= 2)
shp@data$admin <- as.character(shp@data$loc_name)
shp2 <- shp
# read in collaborator data
collab_raw <- fread('layers/All Collabs_salesforce.csv')

#collabs = read.csv('C:/users/Scottg16/repos/RshinyDB/layers/Collaborators in Salesforce_Policy Engagement.csv')

collabs_raw  = as.data.table(collab_raw)
# Values for selectize input
shp@data = as.data.table(shp@data)

countries <- shp@data$loc_name
countries = na.omit(as.data.table(countries))
ISO3 <- shp@data$ihme_lc_id
mock.data.all <- data.table(countries = countries, ISO3.codes = ISO3)
#mock.data.all <- shp@data[,.(ihme_lc_id, loc_name)]

epsg4088 <- leafletCRS(
  crsClass = "L.CRS.Simple",
  code = "EPSG:4088",
  proj4def = "+proj=eqc +lat_ts=0 +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +a=6371007 +b=6371007 +units=m +no_defs",
  resolutions = 2^(16:7)
)

# Load CFI theme for ggplot2
source("settings/ggplot_theme_cfi.R")

