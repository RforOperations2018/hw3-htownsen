
# CREATING A MAP
#Map will include: 
#•	Basemap
#•	One layer of points
#•	One layer of lines
#•	One layer of polygons
#•	A legend which helps users identify what they are looking at

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
# 2017 Cartographic Boundary Files
usa.load <- readOGR("./uscounties/cb_2017_us_county_500k.shp", layer = "cb_2017_us_county_500k", GDAL1_integer64_policy = TRUE)
# This one shows up too woohoo!
plot(usa.load)

# Reading in the data for Indiana
indf <- read_excel("PercentNotCompleteHSIN.xlsx")

# Reading in the data for Ohio
ohdf <- read_excel("PercentNotCompleteHSOH.xlsx")

# Row binding the two datasets (OH and IN)
inohdf <- rbind(indf, ohdf)
# Rename the last column
colnames(inohdf)[4] <- "nothsgrad"

# Going to Merge on GEOID and FIPS
# Just having the matching GEOID's, only want OH and IN
inoh <- usa.load[usa.load$GEOID %in% inohdf$FIPS,]
# Merging the shape data with the education data
inoh@data <- merge(inoh@data, inohdf, sort = FALSE, by.x = "GEOID", by.y = "FIPS")

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


# Shape with fills
pal <- colorNumeric(
  palette = "Reds",
  domain = inoh$nothsgrad)

leaflet(data = inoh) %>%
  addProviderTiles("Stamen.Toner") %>%
  addPolygons(color = ~pal(nothsgrad), popup = ~paste0("<b>", `County-State`, ":</b> ", nothsgrad, "percent")) %>%
  addLegend(position = "bottomright", pal = pal, values = inoh$nothsgrad, title = "Did Not Graduate HS")

