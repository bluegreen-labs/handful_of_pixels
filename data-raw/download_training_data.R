library(dplyr)
library(appeears)

options(keyring_backend="file")
set.seed(0)

#---- download validation site data ----

# From geo-wiki download reference / validation data
# https://zenodo.org/record/6572482/files/Global%20LULC%20reference%20data%20.csv?download=1
# This contains >130K samples, reduce to 1500 stratified random?

if (!file.exists("data/validation_sites.rds")) {
  validation_sites <- readr::read_csv(
    "https://zenodo.org/record/6572482/files/Global%20LULC%20reference%20data%20.csv?download=1"
  )
  
  saveRDS(validation_sites, "data/validation_sites.rds", compress = "xz")
} else {
  validation_sites <- readRDS("data/validation_sites.rds")
}

# only take a sample of 450 locations
# across 9 classes from the validation
# dataset (competition 4) with a high
# degree of coverage (>90%) and a high
# confidence (0) and we limit the locations
# to the northern hemisphere

if (!file.exists("data/validation_selection.rds")) {
  validation_selection <- validation_sites |>
    filter(
      (competition == 4 | competition == 1),
      perc1 > 80,
      confidence_LC <= 30,
      lat > 0
    ) |>
    group_by(
      LC1
    ) |>
    sample_n(
      min(n(), 150)
    ) |>
    ungroup()
 
  # split validation selection
  # by land cover type
  validation_selection <- validation_selection |>
    group_by(LC1) |>
    group_split()
   
  saveRDS(validation_selection, "data/validation_selection.rds", compress = "xz")
} else {
  validation_selection <- readRDS("data/validation_selection.rds")
}

#---- format appeears download tasks ----

# for every row download the data for this
# location and the specified reflectance
# bands
task_nbar <- lapply(validation_selection, function(x){
  
  product <- "MCD43A4.061"
  layer <- c(
    paste0("Nadir_Reflectance_Band", 1:7),
    paste0("BRDF_Albedo_Band_Mandatory_Quality_Band", 1:7)
  )
  
  base_query <- x |>
    rowwise() |>
    do({
      data.frame(
        task = paste0("nbar_lc_",.$LC1),
        subtask = as.character(.$pixelID),
        latitude = .$lat,
        longitude = .$lon,
        start = "2012-01-01",
        end = "2012-12-31",
        product = product,
        layer = as.character(layer)
      )
    }) |>
    ungroup()
  
  # build a task JSON string 
  task <- rs_build_task(
    df = base_query
  )
  
  # return task
  return(task)
})

task_lst <- lapply(validation_selection, function(x){
  
  product <- "MOD11A2.061"
  layer <- c(
    paste0("LST_Day_1km"),
    paste0("QC_Day")
  )
  
  base_query <- x |>
    rowwise() |>
    do({
      data.frame(
        task = paste0("lst_lc_",.$LC1),
        subtask = as.character(.$pixelID),
        latitude = .$lat,
        longitude = .$lon,
        start = "2012-01-01",
        end = "2012-12-31",
        product = product,
        layer = as.character(layer)
      )
    }) |>
    ungroup()
  
  # build a task JSON string 
  task <- rs_build_task(
    df = base_query
  )
  
  # return task
  return(task)
})

# download dem data
task_dem <- lapply(validation_selection, function(x){
  
  # construct basic query
  df <- data.frame(
    task = paste0("dem_lc_", x$LC1),
    subtask = as.character(x$pixelID),
    latitude = x$lat,
    longitude = x$lon,
    start = "2012-01-01",
    end = "2012-12-31",
    product = "NASADEM_NC.001",
    layer = c(
      "NASADEM_HGT"
    )
  )
  
  # build a task JSON string 
  task <- rs_build_task(
    df = df
  )
  
  # return task
  return(task)
})

#--- schedule all downloads in batches of 10 ----

# request the task to be executed
# 4h (in seconds) time-out per request (~40h total)
status_altitude <- rs_request_batch(
  request = task_dem,
  workers = 10,
  user = "khufkens",
  path = "./data/lulc/dem",
  verbose = TRUE,
  time_out = 28800
)

status_nbar <- rs_request_batch(
  request = task_nbar,
  workers = 10,
  user = "khufkens",
  path = "./data/lulc/nbar",
  verbose = TRUE,
  time_out = 28800
)

#--- download regional data for model run ----


# load the required libraries
library(terra)

# create a SpatRaster ROI from the terra demo file
roi <- terra::rast("./data/LAI.tiff")

product <- "MCD43A4.061"
layer <- c(
  paste0("Nadir_Reflectance_Band", 1:7)
)

df <- data.frame(
  task = "raster_download",
  subtask = "swiss",
  start = "2012-01-01",
  end = "2012-12-31",
  product = product,
  layer = as.character(layer)
)

# build the area based request/task
# rename the task name so data will
# be saved in the "raster" folder
# as defined by the task name
df$task <- "raster"
task <- rs_build_task(
  df = df,
  roi = roi,
  format = "geotiff"
)

# request the task to be executed
rs_request(
  request = task,
  user = "khufkens",
  transfer = TRUE,
  path = "data/lulc/raster/",
  verbose = TRUE
)
