

count_countries <- function(mock_data){
  #countries[,collabs := 0]
  mock_data = as.data.table(mock_data)
  #mock_data[,`Primary Affiliation Country`] <- as.character(mock_data[,`Primary Affiliation Country`])
  #mock_data[, `Secondary Affiliation Country`] <- as.character(mock_data[,`Secondary Affiliation Country`])
  mock.count.1 <- mock_data[,.(`Primary Affiliation Country`)]
  mock.count.2 <- mock_data[`Primary Affiliation Country` != `Secondary Affiliation Country`, .(`Secondary Affiliation Country`)]  
  mock.count.1[, count1 := 1]
  mock.count.2[, count2 := 1]
  mock.count.1 = as.data.table(mock.count.1)
  mock.count.1 <- unique(mock.count.1[, count1 := sum(count1), by = `Primary Affiliation Country`])
  mock.count.2 <- unique(mock.count.2[, count2 := sum(count2), by = `Secondary Affiliation Country`])
  setnames(mock.count.1, "Primary Affiliation Country", "countries")    
  setnames(mock.count.2, "Secondary Affiliation Country", "countries")    
  mock.count <- merge(mock.count.1, mock.count.2, by = 'countries', all = T)    
  mock.count[is.na(count1), count1 := 0]
  mock.count[is.na(count2), count2 := 0]
  mock.count[, collabs := count1 + count2]
  mock_data <- merge(countries, mock.count[,.(countries, collabs)], by = 'countries', all = T)
  mock_data[is.na(collabs) & countries != "", collabs := 0]
  return(mock_data)
  
  
}

subsetData = function(subdata = collabs, risk = "-", cause = "-", SDG = F, healthfinance = F, demo = F, healthSystem = F, 
                      geo = F, Policy = F, count.exp = '', country = '-'){
  subdata = as.data.table(subdata)
  if(risk != "-"){
    subdata = subdata[`Risk Factors` %like% risk]
  }
  if(cause != "-"){
    subdata = subdata[(`A. Comm, Mat, Neo, Nutri Diseases` %like% cause) | (`B. Non-communicable Diseases` %like% cause) | (`C. Injuries` %like% cause)]
  }    
  if(SDG){
    subdata = subdata[`SDG Monitoring and Evaluation` == 1]
  }   
  if(demo){
    subdata = subdata[!(`Demography Expert` %like% "I do not have expertise in demography")]
  }   
  if(healthSystem){
    subdata = subdata[`Health Systems Expert` != "I do not have expertise in Health Systems"]
  }   
  if(geo){
    subdata = subdata[`Geospatial Analysis/Geostatistics Expert` != FALSE]
  }
  if(Policy){
    subdata = subdata[`SDG Monitoring and Evaluation` == 1]
  }     
  if(healthfinance){
    subdata = subdata[`Health Financing Expert` == TRUE]
  }    
  if(count.exp != "-"){
    subdata = subdata[`Countries and Territories` %like% count.exp]
  }    
  if(country != "-"){
    subdata = subdata[`Primary Affiliation Country` %like% country | `Secondary Affiliation Country` %like% country]
  }

  
   return(subdata)
}

makeMap <- function(collab_subset){
  collab_count <- count_countries(collab_subset)
  
  shp2@data <- shp@data %>%
    
    left_join(., collab_count, by=c("admin" = "countries"))
  shp2@data = as.data.table(shp2@data)
  shp2@data[is.na(collabs), collabs := 0]
  
  return(shp2)
}

makeColor <- function(collab_subset){
  collab_count <- count_countries(collab_subset)
  max = max(collab_count$collabs)
  #
  bins <- unique(c(0,ceiling(max/500), ceiling(max/250), ceiling(max/100), ceiling(max/50), ceiling(max/25), ceiling(max/10), ceiling(max/8), ceiling(max/4), ceiling(max/2), ceiling(max/1.5), ceiling(max/1.2), ceiling(max), Inf))
  if(length(bins) <=  3){
    color = colorRamp(c("#D5D5D5", "#2A6481"), interpolate = "spline")
  }else{
    color = colorRamp(c("#D5D5D5", "#CBE19F", "#A0CE9F", "#69B46C", "#68B66B", "#009994", "#2A6481"), interpolate = "spline")
  }
  pal <- colorBin(color, domain = shp2@data$collabs, bins = bins)
  return(pal)
}

makePopup <- function(collab_subset){
  collab_count <- count_countries(collab_subset)
  
  shp2@data <- shp@data %>%
    
    left_join(., collab_count, by=c("admin" = "countries"))
  shp2@data = as.data.table(shp2@data)
  shp2@data[is.na(collabs), collabs := 0]

  # Popup
  popup <- paste0("<strong>Country: </strong>",
                  shp2@data$name,
                  "<br><strong>Collaborators: </strong>",
                  shp2@data$collabs
  )
  return(popup)
}


