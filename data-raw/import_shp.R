library(tidyverse)
library(sf)

# import the watersheds shapefile
ff_watersheds <-
  read_sf(dsn = "data-raw/shp", layer = "project_watershed_groups") |>
  janitor::clean_names() |>
  select(group_id,
         huc10,
         watershed_name = group_name,
         return_id
  ) |>
  mutate(return_id = replace_na(return_id, 0))

# use this layer to define the project CRS
project_crs <- st_crs(ff_watersheds)

ff_returns <-
  read_sf(dsn = "data-raw/shp", layer = "project_returns_20230807") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(return_name = name,
         return_id,
         water_sup,
         ds_return_id = dtfbs_id,
         ds_fbs_dist = dist_fbs,
         ds_fbs_name = fbs_name
  ) |>
  mutate(return_direct = case_when(ds_return_id == return_id ~ "Direct", TRUE ~ "Indirect"))

ff_distances <-
  read_sf(dsn = "data-raw/shp", layer = "ricefields_groups_distances_20230815") |>
  janitor::clean_names() |>
  select(unique_id,
         return_id,
         ds_fbs_dist = dist_fbs,
         return_dis,
         totdist_ft,
         totdist_mi,
         fbs_name,
         totrect_ft,
         totrect_mi,
         return_rec,
         wet_dry = hydro
  )  |>
  st_drop_geometry()


ff_fields <-
  read_sf(dsn = "data-raw/shp", layer = "ricefield_groups") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(unique_id, county, elev_grp)

watershed_xw <- ff_fields |>
  st_centroid() |>
  st_join(ff_watersheds) |>
  st_drop_geometry() |>
  select(unique_id, group_id)

ff_fields <- ff_fields |>
  left_join(watershed_xw) |>
  mutate(area_ac = units::drop_units(units::set_units(st_area(geometry), "acre")),
         volume_af = area_ac * 5/12) |>
  st_zm()

# BASEMAP LAYERS

ff_streams <-
  read_sf(dsn = "data-raw/shp", layer = "project_rearing_streams") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(stream_id = id, stream_name = river)

ff_canals <-
  read_sf(dsn = "data-raw/shp", layer = "project_return_canals") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(canal_id = objectid, canal_name = name)

ff_wetdry <-
  read_sf(dsn = "data-raw/shp", layer = "wet_and_dry_sides_20230802") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(wet_dry = hydro, area_name, source) |>
  st_zm()

ff_aoi <-
  read_sf(dsn = "data-raw/shp", layer = "project_boundary") |>
  st_transform(project_crs) |>
  summarize() |>
  st_zm()

# Go back and add the return type to the watersheds layer
ff_watersheds <- ff_watersheds |>
  left_join(ff_returns |> st_drop_geometry() |> select(return_id, return_direct)) |>
  mutate(return_direct = dplyr::case_when(return_direct %in% c("Direct", "Indirect") ~ return_direct, TRUE ~ "Lateral")) |>
  rename(return_category = return_direct)

# FULLY JOINED FIELDS DATASET TO USE IN LEAFLET

ff_fields_joined <- ff_fields |>
  left_join(ff_watersheds |> st_drop_geometry(), by = join_by("group_id")) |>
  left_join(ff_returns |> st_drop_geometry() |> select(-return_direct), by = join_by("return_id")) |>
  left_join(ff_distances |> select(-return_id), by = join_by("unique_id"))

# export tabular datasets
usethis::use_data(ff_distances, overwrite = TRUE)

# export spatial datasets
usethis::use_data(ff_watersheds, overwrite = TRUE)
usethis::use_data(ff_returns, overwrite = TRUE)
usethis::use_data(ff_fields, overwrite = TRUE)
usethis::use_data(ff_streams, overwrite = TRUE)
usethis::use_data(ff_canals, overwrite = TRUE)
usethis::use_data(ff_wetdry, overwrite = TRUE)
usethis::use_data(ff_fields_joined, overwrite = TRUE)
usethis::use_data(ff_aoi, overwrite = TRUE)

# reproject spatial datasets to WGS84 GCS to use for Leaflet maps
leaflet_crs <- "+proj=longlat +datum=WGS84"

ff_watersheds_gcs <- ff_watersheds |> st_transform(leaflet_crs) |> mutate(object_id = paste0("W",row_number()))
ff_returns_gcs <- ff_returns |> st_transform(leaflet_crs) |> mutate(object_id = paste0("R",row_number()))
ff_fields_gcs <- ff_fields |> st_transform(leaflet_crs) |> mutate(object_id = paste0("F",row_number()))
ff_streams_gcs <- ff_streams |> st_transform(leaflet_crs) |> mutate(object_id = paste0("S",row_number()))
ff_canals_gcs <- ff_canals |> st_transform(leaflet_crs) |> mutate(object_id = paste0("C",row_number()))
ff_wetdry_gcs <- ff_wetdry |> st_transform(leaflet_crs) |> mutate(object_id = paste0("D",row_number()))
ff_fields_joined_gcs <- ff_fields_joined |> st_transform(leaflet_crs) |> mutate(object_id = paste0("F",row_number()))
ff_aoi_gcs <- ff_aoi |> st_transform(leaflet_crs) |> mutate(object_id = paste0("A",row_number()))

ff_watersheds_gcs |> usethis::use_data(overwrite = TRUE)
ff_returns_gcs |> usethis::use_data(overwrite = TRUE)
ff_fields_gcs |> usethis::use_data(overwrite = TRUE)
ff_streams_gcs |> usethis::use_data(overwrite = TRUE)
ff_canals_gcs |> usethis::use_data(overwrite = TRUE)
ff_wetdry_gcs |> usethis::use_data(overwrite = TRUE)
ff_fields_joined_gcs |> usethis::use_data(overwrite = TRUE)
ff_aoi_gcs |> usethis::use_data(overwrite = TRUE)

