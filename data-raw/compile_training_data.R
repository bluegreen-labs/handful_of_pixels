library(dplyr)
library(vroom)

#---- read in DEM data ----

# files <- list.files(
#   "data/lulc/dem/",
#   glob2rx("*NASADEM-NC-001-results*"),
#   recursive = TRUE,
#   full.names = TRUE
#   )
# 
# dem <- vroom::vroom(files)
# dem <- dem |>
#   select(
#     Category,
#     ID,
#     NASADEM_NC_001_NASADEM_HGT
#   )

#---- read in NBAR data ----
files <- list.files(
  "data/lulc/nbar/",
  glob2rx("*MCD43A4-061-results*"),
  recursive = TRUE,
  full.names = TRUE
)

nbar <- vroom::vroom(files)
nbar[nbar == 32767] <- NA

#---- convert NBAR to wide ----
nbar_wide<- nbar |>
  select(
    Category,
    ID,
    Date,
    Latitude,
    Longitude,
    starts_with("MCD43A4_061_Nadir")
  ) |>
  tidyr::pivot_wider(
    values_from = starts_with("MCD43A4_061_Nadir"),
    names_from = Date
  )

#---- combine datasets ----
# df <- left_join(nbar_wide, dem)
# 
# read in original land cover labels
sites <- readRDS("data/validation_selection.rds") |>
  bind_rows() |>
  select(
    pixelID,
    LC1
  ) |>
  rename(
    Category = "pixelID"
  )

df <- left_join(nbar_wide, sites)

# save the data
saveRDS(
  df,
  "data/training_data.rds",
  compress = "xz"
)