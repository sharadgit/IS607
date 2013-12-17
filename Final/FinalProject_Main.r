
# load required functions
source("FinalProject_Support.R");

# load clean data saved from DataLoad script
load("NYCParkingLatLon.dat");

# get address latitude and longitude
address = address.Coordinates("CUNY Graduate Center");
lat = address["lat"];
lon = address["lon"];

# nyc object should load from saved data
if (exists("nyc")) {
  # get parking garages nearby
  matches = nearby.Parking(nyc, lat, lon, max.Locations=6);
  # display the garages in a static map
  display.Parking(matches, lat, lon);
}
