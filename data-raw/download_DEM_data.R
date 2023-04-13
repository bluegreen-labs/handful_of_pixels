# Download basic MODIS dataset, this should be pre-downloaded
# as the ORNL DAAC can be horrendously slow.
#
# Students should initiate the download but probably will realize
# that it will take too long, we need to offer a fix if they
# want to proceed quickly

# load libraries
library(terra)
library(geodata)

# download SRTM data
if (!file.exists("data-raw/srtm_38_03.tif")){
  geodata::elevation_3s(
    lat = 46.6756,
    lon = 7.85480,
    path = "data-raw/"
  )
}

# post processing for lessons

phenology <- readRDS("data/phenology_2012.rds")
phenology <- phenology |>
  mutate(
    value = ifelse(value > 32656, NA, value),
    value = format(as.Date("1970-01-01") + value, "%j")
  )
phenology_raster <- mt_to_terra(phenology, reproject = TRUE)

# crop the dem
dem <- terra::crop(
  x = dem,
  y = phenology_raster
)

# resample the dem
dem <- terra::resample(
  x = dem,
  y = phenology_raster
)
