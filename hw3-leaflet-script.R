# HALEY TOWNSEND
# CREATING A MAP - HOMEWORK 3
# Map will include: 
#•	A Basemap
#•	One map with a layer of points
#o	Students may use either circles or markers
#•	One map with a layer of lines
#•	One map with a layer of polygons
#•	One of the maps must contain a variable which changes of the 
# color of the elements or the marker with an accompanying legend
#•	One map must contain a functioning layersControl() 
# 1 to 3 maps overall


# Loading the libraries
require(rgdal)
require(leaflet)
require(leaflet.extras)
library(plyr)
require(dplyr)
require(readxl)
require(stringr)

################################################################################################################
# Loading in the Indiana counties shape file
in.load <- readOGR("./indianacounties/tl_2013_18_cousub.shp", layer = "tl_2013_18_cousub", GDAL1_integer64_policy = TRUE)
# Yey it shows up!
#plot(in.load)

# Loading in the USA counties shape file
# 2017 Cartographic Boundary Files
usa.load <- readOGR("./uscounties/cb_2017_us_county_500k.shp", layer = "cb_2017_us_county_500k",
                    GDAL1_integer64_policy = TRUE)
# This one shows up too woohoo!
#plot(usa.load)

# Datasets found here: https://data.ers.usda.gov/reports.aspx?ID=17826
# Reading in the data for Indiana
indf <- read_excel("PercentPovertyIN.xlsx")

# Reading in the data for Ohio
ohdf <- read_excel("PercentPovertyOH.xlsx")

# Row binding the two datasets (OH and IN)
inohdf <- rbind(indf, ohdf)

# Going to Merge on GEOID and FIPS
# Just having the matching GEOID's, only want OH and IN
inoh <- usa.load[usa.load$GEOID %in% inohdf$FIPS,]
# Merging the shape data with the education data
inoh@data <- merge(inoh@data, inohdf, sort = FALSE, by.x = "GEOID", by.y = "FIPS")
#################################################################################################################

# MAP WITH POINTS LAYER: Crashes in Monroe County, IN in 2015
crashes <- read.csv("MonroeCountyINCrashes.csv")
crashesclean <- na.omit(crashes)

# Just going to use crashes from 2015 
crashes15 <- crashesclean[crashesclean$Year=="2015" & crashesclean$Latitude!=0.00000,]


# Color Pallette: markers by time of week
palcrash <- colorFactor(c("#ee82ee", "#3b0054"), c("Weekend", "Weekday"))

leaflet() %>%
  addProviderTiles("OpenMapSurfer.Roads", options = providerTileOptions(noWrap = TRUE)) %>%
  addCircleMarkers(data = crashes15, lng = ~Longitude, lat = ~Latitude, radius = 1.5, color = ~palcrash(Weekend.)) %>%
  addLegend(position = "topright" , pal = palcrash, values = crashes15$Weekend., title = "Time of Week")

# MAP WITH FILLED POLYGONS: Poverty by County in OH and IN
pal <- colorNumeric(
  palette = "Reds",
  domain = inoh$poverty16)

leaflet(data = inoh) %>%
  addProviderTiles("Stamen.Toner", options = providerTileOptions(noWrap = TRUE)) %>%
  addPolygons(color = ~pal(poverty16), popup = ~paste0("<b>", COUNTY, ":</b> ", poverty16, "%")) %>%
  addLegend(position = "bottomright", pal = pal, values = inoh$poverty16, 
            title = "Percent of Population<br>in Poverty (2016)")

# Layering the points map and polygon map
# With legends and layers control
leaflet() %>%
  addProviderTiles("Stamen.Toner", group="Poverty", options = providerTileOptions(noWrap = TRUE)) %>%
  addProviderTiles("OpenMapSurfer.Roads", group="Crashes", options = providerTileOptions(noWrap = TRUE)) %>%
  addPolygons(data = inoh, group="Poverty", color = ~pal(poverty16), popup = ~paste0("<b>", COUNTY, ":</b> ", poverty16, "%")) %>%
  addCircleMarkers(data = crashes15, group="Crashes", lng = ~Longitude, lat = ~Latitude, radius = 1.5, color = ~palcrash(Weekend.)) %>%
  addLegend(position = "topright", group="Crashes", pal = palcrash, values = crashes15$Weekend., title = "Time of Week") %>%
  addLegend(position = "bottomright", group="Poverty", pal = pal, values = inoh$poverty16, 
            title = "Percent of Population<br>in Poverty (2016)") %>%
  addLayersControl(
    overlayGroups = c("Poverty", "Crashes"),
    options = layersControlOptions(collapsed = FALSE))


