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


unique_values<- unique(fields_watersheds$watershed_name)

value_color <- Polychrome::palette36.colors(length(unique_values))

value_color_map <- setNames(value_color, unique_values)

fields_watersheds <- fields_watersheds |> mutate("colour" = value_color_map[watershed_name])








