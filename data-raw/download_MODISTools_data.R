# Download basic MODIS dataset, this should be pre-downloaded
# as the ORNL DAAC can be horrendously slow.
#
# Students should initiate the download but probably will realize
# that it will take too long, we need to offer a fix if they
# want to proceed quickly

# data documentation:
# https://www.bu.edu/lcsc/data-documentation/

# load libraries
library(MODISTools)
library(terra)

# download and save phenology data
phenology_2012 <- mt_subset(
  product = "MCD12Q2",
  lat = 46.6756,
  lon = 7.85480,
  band = "Greenup.Num_Modes_01",
  start = "2012-01-01",
  end = "2012-12-31",
  km_lr = 100,
  km_ab = 100,
  site_name = "swiss",
  internal = TRUE,
  progress = FALSE
)

saveRDS(
  phenology_2012,
  "data/phenology_2012.rds",
  compress = "xz"
)

# download and save land cover data
land_cover_2012 <- mt_subset(
  product = "MCD12Q1",
  lat = 46.6756,
  lon = 7.85480,
  band = "LC_Type1",
  start = "2012-01-01",
  end = "2012-12-31",
  km_lr = 100,
  km_ab = 100,
  site_name = "swiss",
  internal = TRUE,
  progress = FALSE
)

saveRDS(
  land_cover_2012,
  "data/land-cover_2012.rds",
  compress = "xz"
)

# download LAI data
lai_2012 <- mt_subset(
  product = "MCD15A3H",
  lat = 46.6756,
  lon = 7.85480,
  band = c("Lai_500m","FparLai_QC"),
  start = "2012-01-01",
  end = "2012-12-31",
  km_lr = 100,
  km_ab = 100,
  site_name = "swiss",
  internal = TRUE,
  progress = TRUE
)

saveRDS(
  lai_2012,
  "data/lai_2012.rds",
  compress = "xz"
)

message("all done...")
