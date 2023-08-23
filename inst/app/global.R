library(fishFoodMWD)
library(shiny)
library(leaflet)
library(tidyverse)
library(sf)
library(dplyr)

geom <- st_coordinates(ff_fields_gcs$geometry)
<<<<<<< HEAD
# ff_fields
=======

>>>>>>> d5309a195f0b9fb6df9bb3bb297ab9eec99adeb5
fields_watersheds <- ff_fields_gcs |>
  left_join(st_drop_geometry(ff_watersheds_gcs), by="group_id")

fields_returns <- fields_watersheds |>
  left_join(st_drop_geometry(ff_returns), by="return_id")
<<<<<<< HEAD
#
# fields_returns <- fields_returns |>
#   mutate(return_direct = ifelse(is.na(fields_returns$return_direct), "NA", fields_returns$return_direct))
=======
>>>>>>> d5309a195f0b9fb6df9bb3bb297ab9eec99adeb5

fields_distances <- fields_watersheds |>
  left_join(ff_distances, by="unique_id")


<<<<<<< HEAD
# unique_values<- unique(fields_watersheds$watershed_name)
#
# value_color <- Polychrome::palette36.colors(length(unique_values))
#
# value_color_map <- setNames(value_color, unique_values)
#
# fields_watersheds <- fields_watersheds |> mutate("colour" = value_color_map[watershed_name])



=======
>>>>>>> d5309a195f0b9fb6df9bb3bb297ab9eec99adeb5






