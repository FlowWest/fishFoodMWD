library(fishFoodMWD)
library(shiny)
library(leaflet)
library(tidyverse)
library(sf)
library(dplyr)

geom <- st_coordinates(ff_fields_gcs$geometry)
# ff_fields
fields_watersheds <- ff_fields_gcs |>
  left_join(st_drop_geometry(ff_watersheds_gcs), by="group_id")
