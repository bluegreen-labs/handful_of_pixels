library(terra)
#library(tidymodels)
#library(tidyverse)

# select packages
# avoiding tidy catch alls
library(parsnip)
library(workflows)
library(rsample)
library(tune)
library(dplyr)

df <- readRDS("data/training_data.rds") |>
  dplyr::select(
    LC1,
    contains("band1"),
    contains("band2"),
    contains("band3"),
    contains("band4")
  )

# create a data split across
# land cover classes
parts <- caret::createDataPartition(
  df$LC1,
  p = 0.8,
  list = FALSE
)

# select training and testing
# data based on this split
train <- df[parts, ]
test <- df[-parts, ]

## Tune and train model.
xgb_spec <- parsnip::boost_tree(
  trees = 50,
  tree_depth = tune(),
  # min_n = tune(),
  # loss_reduction = tune(),
  # sample_size = tune(),
  # mtry = tune(),
  # learn_rate = tune()
  ) |>
  set_engine("xgboost") |>
  set_mode("classification")

xgb_grid <- dials::grid_latin_hypercube(
  tree_depth(),
  #min_n(),
  #loss_reduction(),
  #sample_size=sample_prop(),
  # finalize(
  #   mtry(), 
  #   dplyr::select(train, -LC1)
  #   ),
  #learn_rate(),
  size = 5
)

xgb_wf <- workflows::workflow() |>
  add_formula(as.factor(LC1) ~ .) |>
  add_model(xgb_spec)

folds <- rsample::vfold_cv(train, v = 3)

xgb_res <- tune::tune_grid(
  xgb_wf,
  resamples = folds,
  grid = xgb_grid,
  control = tune::control_grid(save_pred=T)
)

best_auc <- tune::select_best(
  xgb_res,
  "roc_auc"
  )

final_xgb <- tune::finalize_workflow(
  xgb_wf,
  best_auc
)

last_fit <- fit(final_xgb, train)

saveRDS(last_fit, "data/xgboost_model.rds", compress = "xz")

files <- list.files(
  "data/lulc/raster",
  "*Reflectance*",
  recursive = TRUE,
  full.names = TRUE
)

# select only the desired bands as in the training data
files <- files[grepl("Band1|Band2|Band3|Band4", files)]
r <- terra::rast(files)

# the model only works when variable names are consistent
n <- data.frame(
  name = names(r)
) |>
  mutate(
    date = as.Date(substr(name, 40, 46), format = "%Y%j"),
    name = paste(substr(name, 1, 35), date, sep = "_"),
    name = gsub("\\.","_", name)
  )
names(r) <- n$name

# return probabilities
probs_r <- terra::predict(r, last_fit, type = "prob")
#terra::writeRaster(probs_r, "data/xgboost_spatial_probabilities.tif")

# generate the map by selecting maximum probabilities
# from the model output
lulc_map <- terra::app(probs_r, which.max)
