library(dplyr)
library(vroom)

#---- read in original land cover labels ----
sites <- readRDS("data/competition_selection.rds") |>
  bind_rows() |>
  select(
    pixelID,
    LC1,
    lat,
    lon
  )

#---- read in NBAR data ----
files <- list.files(
  "data/lulc_competition/nbar/",
  glob2rx("*MCD43A4-061-results*"),
  recursive = TRUE,
  full.names = TRUE
)

nbar <- vroom::vroom(files)
nbar[nbar == 32767] <- NA

nbar_wide<- nbar |>
  select(
    Category,
    Date,
    starts_with("MCD43A4_061_Nadir")
  ) |>
  rename(
    pixelID = Category
  ) |>
  tidyr::pivot_wider(
    values_from = starts_with("MCD43A4_061_Nadir"),
    names_from = Date
  )

#---- read in LST data ----
files <- list.files(
  "data/lulc_competition/lst/",
  glob2rx("*MOD11A2-061-results*"),
  recursive = TRUE,
  full.names = TRUE
)

lst <- vroom::vroom(files)

lst_wide<- lst |>
  select(
    Category,
    Date,
    MOD11A2_061_LST_Day_1km
  ) |>
  rename(
    pixelID = Category
  ) |>
  mutate(
    MOD11A2_061_LST_Day_1km = MOD11A2_061_LST_Day_1km - 273.15,
    MOD11A2_061_LST_Day_1km = ifelse(MOD11A2_061_LST_Day_1km < -100, NA, MOD11A2_061_LST_Day_1km)
  ) |>
  tidyr::pivot_wider(
    values_from = starts_with("MOD11A2_061_LST_Day_1km"),
    names_from = Date
  ) |>
  select(
    pixelID,
    starts_with("2012")
  )

#---- combine datasets ----

df <- left_join(sites, nbar_wide)
df <- left_join(df, lst_wide)

# save the data
saveRDS(
  df,
  "data/complete_competition_data.rds",
  compress = "xz"
)

#---- generate training and testing samples ---

# select packages
# avoiding tidy catch alls
library(rsample)
set.seed(0)

# create a data split across
# land cover classes
ml_df_split <- df |>
  rsample::initial_split(
    strata = LC1,
    prop = 0.8
  )

# select training and testing
# data based on this split
train <- rsample::training(ml_df_split)
test <- rsample::testing(ml_df_split)

# save the data
saveRDS(
  train,
  "data/training_data.rds",
  compress = "xz"
)

# save the data
saveRDS(
  test |> select(-pixelID, -LC1, -lat, -lon),
  "data/test_data.rds",
  compress = "xz"
)

# save the data - do not upload
saveRDS(
  test,
  "data/test_data_complete.rds",
  compress = "xz"
)

# save test labels (don't upload)
