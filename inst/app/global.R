library(fishFoodMWD)
library(shiny)
library(leaflet)
library(tidyverse)
library(sf)
library(dplyr)

geom <- st_coordinates(ff_fields_gcs$geometry)

fields_watersheds <- ff_fields_gcs |>
  left_join(st_drop_geometry(ff_watersheds_gcs), by="group_id")

fields_returns <- fields_watersheds |>
  left_join(st_drop_geometry(ff_returns), by="return_id")

fields_distances <- fields_watersheds |>
  left_join(ff_distances, by="unique_id")








