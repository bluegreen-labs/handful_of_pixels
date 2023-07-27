# create scaling dataset for modelling chapter

# load library
library(daymetr)
library(terra)

# Download daily data
daymetr::download_daymet_tiles(
  tiles = 11935,
  start = 2012,
  end = 2012,
  param = c("tmin","tmax"),
  path = "data-raw/",
  silent = TRUE
  )

# calculate the daily mean values
r <- daymetr::daymet_grid_tmean(
  path = "data-raw",
  product = 11935,
  year = 2012,
  internal = TRUE
)

# reproject to lat lon
r <- terra::project(
  r,
  "+init=epsg:4326"
)

# subset to first 180 days
ma_nh_temp <- terra::subset(
  r,
  1:180
)

# write to file
terra::writeRaster(
  ma_nh_temp,
  "data/daymet_mean_temperature.tif",
  gdal = c("COMPRESS=DEFLATE"),
  overwrite = TRUE
)
