
# Loading the libraries
require(rgdal)
require(leaflet)
require(leaflet.extras)
library(plyr)
require(dplyr)
require(readxl)
require(stringr)

# Loading in the Indiana shape file
in.load <- readOGR("./indianacounties/tl_2013_18_cousub.shp", layer = "tl_2013_18_cousub", GDAL1_integer64_policy = TRUE)
# Yey it shows up!
plot(in.load)
