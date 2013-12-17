#'
#' address.Coordinates is an interface to getGeoCode function in RgoogleMaps package.
#' Interface exists to abstract package dependency from main script.
#'
#' @param address string value of address to geocode
#' @returnType vector
#' @return numeric vector with latitude and longitude
#'
address.Coordinates = function(address) {
  require(RgoogleMaps)
  getGeoCode(address, verbose=1);
}

#'
#' display.Parking accepts a set of locations, and destination co-ordinates, 
#' and plots the locations along with the names in a static Google map image.
#' It relies on GetMap, PlotOnStaticMap, and TextOnStaticMap functions in RgoogleMaps package.
#' Locations are plotted in Cyan circles. The diameter of the circle corresponds to the locations'
#' quartile, classified by number of spaces.
#'
#' @param matches data.frame of locations to plot
#'        data.frame has columns lat, lon, Quartile, and LegalName.
#' @param destination.lat numeric value of destination latitude
#' @param destination.lon numeric value of destination longitude
#' @returnType Not applicable
#' @return Not applicable
#'
display.Parking = function(matches, destination.lat, destination.lon) {
  require(RgoogleMaps)  
  
  # variables to manipulate plots and text
  lat.Offset = 0.0003;
  text.Size  = .75;
  text.Width = 15;
  
  zoom   = min(MaxZoom(range(as.numeric(matches$lat)), range(as.numeric(matches$lon)))); # adjustment to include all plots and text within the map
  
  # get static map image from Google
  map    = GetMap(center   = c(destination.lat, destination.lon),
                  size     = c(640, 640),
                  zoom     = zoom,
                  destfile = "NYCParking.png");
  
  # plot the matches
  PlotOnStaticMap(map, 
                  lat = as.numeric(matches$lat), 
                  lon = as.numeric(matches$lon),
                  cex = 6 - as.numeric(matches$Quartile), # adjustment to plot upper quartile bigger
                  pch = 20,
                  col = 'cyan',
                  add = FALSE,
                  destfile = "NYCParking.png");
  
  # write the location names above the plot
  TextOnStaticMap(map, 
                  lat = as.numeric(matches$lat) + lat.Offset, # adjustment to write text above plot
                  lon = as.numeric(matches$lon),
                  cex = text.Size,
                  col = 'blue',
                  add = TRUE,
                  labels = strtrim(matches$LegalName, text.Width));
  
  # plot the destination
  PlotOnStaticMap(map, 
                  lat = destination.lat, 
                  lon = destination.lon,
                  cex = 2.5,
                  pch = 20,
                  col = 'red',
                  add = TRUE,
                  destfile = "NYCParking.png");
  
  # write destination above plot
  TextOnStaticMap(map, 
                  lat = destination.lat + lat.Offset,
                  lon = destination.lon,
                  "Destination",
                  cex = text.Size,
                  col ='red',
                  add = TRUE);
}

#'
#' nearby.Parking accepts a set of locations, a starting location, and optional search radius, 
#' and returns five locations that are within the search radius. It relies on location.distance
#' function to calculate the distance for each location.
#'
#' @param locations data.frame of locations to calculate distance against
#'        data.frame has two columns lat and lon for latitude and longitude respectively.
#' @param latitude numeric value of latitude of starting point
#' @param longitude numeric value of longitude of starting point
#' @param searchRadius (optional) numeric valude to narrow the locations by distance
#' @returnType data.frame
#' @return data.frame of five locations that are within the search radius
#' 
nearby.Parking = function(locations, latitude, longitude, searchRadius=.25, max.Locations=5) {
    
  # check lat and lon columns exist in data.frame
  stopifnot('lat' %in% colnames(locations), 
            'lon' %in% colnames(locations))
  
  # call location.distance to compute distance for each location
  distance = location.distance(locations[,c("lat","lon")], latitude, longitude);
  
  # assign distance to corresponding locations
  locations$distance = distance;
  
  # narrow the matches within search radius
  matches = locations[locations$distance < searchRadius,];
  
  # order by closest locations
  matches = matches[order(matches$distance),];
  
  # select top 5 locations within search radius
  return (na.omit(matches[1:max.Locations,]));
  #return (na.omit(matches));
}

#'
#' location.distance() applies gdist function to a set of locations for provided starting point,
#' and returns corresponding distances from starting point.
#'
#' @param locations data.frame of locations to calculate distance against
#'        data.frame has two columns lat and lon for latitude and longitude respectively.
#' @param latitude numeric value of latitude of starting point
#' @param longitude numeric value of longitude of starting point
#' @returnType vector
#' @return vector of corresponding distances
#' 
location.distance = function(locations, latitude, longitude){
  require(Imap)
    
  # check latitude and longitude existence and type
  stopifnot(is.numeric(latitude), 
            is.numeric(longitude))
  
  # check latitude and longitude range
  stopifnot(latitude <= 90, 
            latitude >= -90, 
            longitude <= 180, 
            longitude >= -180)
  
  apply(locations, 1, function(location) 
                      {
                        gdist(lon.1=longitude, 
                              lat.1=latitude, 
                              lon.2=as.numeric(location["lon"]), 
                              lat.2=as.numeric(location["lat"]), 
                              units="miles")
                      })
}











