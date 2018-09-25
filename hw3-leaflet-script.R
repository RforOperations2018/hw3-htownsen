
# Loading the libraries
require(rgdal)
require(leaflet)
require(leaflet.extras)
library(plyr)
require(dplyr)
require(readxl)
require(stringr)

# Loading in the Indiana counties shape file
in.load <- readOGR("./indianacounties/tl_2013_18_cousub.shp", layer = "tl_2013_18_cousub", GDAL1_integer64_policy = TRUE)
# Yey it shows up!
plot(in.load)

# Loading in the USA counties shape file
usa.load <- readOGR("./uscounties/cb_2017_us_county_500k.shp", layer = "cb_2017_us_county_500k", GDAL1_integer64_policy = TRUE)
# This one shows up too woohoo!
plot(usa.load)

# Blank map with single basemap option
leaflet() %>%
  addProviderTiles("OpenStreetMap.HOT", options = providerTileOptions(noWrap = TRUE))

# Blank map with three basemap options
# It's not letting me mix Stamen or Thuderstorm maps in the mix
leaflet() %>%
  addTiles(group = "OSM (default)", options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles("OpenStreetMap.HOT", group = "HOT", options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles("OpenMapSurfer.Roads", group = "Roads", options = providerTileOptions(noWrap = TRUE)) %>%
  # Layers control
  # chooses which basemap is visible
  # creates radiobuttons
  addLayersControl(
    baseGroups = c("OSM (default)", "HOT", "Roads"),
    options = layersControlOptions(collapsed = FALSE)
  )
