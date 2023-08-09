library(tidyverse)
library(sf)

# import the watersheds shapefile
watersheds <-
  read_sf(dsn = "data-raw/shp", layer = "project_watershed_groups") |>
  janitor::clean_names() |>
  select(group_id,
         huc10,
         watershed_name = name,
         return_id
  )

# use this layer to define the project CRS
project_crs <- st_crs(watersheds)

returns <-
  read_sf(dsn = "data-raw/shp", layer = "project_returns_20230807") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(return_name = name,
         return_id,
         ds_return_id = dtfbs_id,
         ds_fbs_dist = dist_fbs,
         ds_fbs_name = fbs_name
  ) |>
  mutate(return_direct = case_when(ds_return_id == return_id ~ "Direct", TRUE ~ "Indirect"))

distances <-
  read_sf(dsn = "data-raw/shp", layer = "ricefields_groups_distances_20230808") |>
  janitor::clean_names() |>
  select(unique_id,
         return_id,
         dist_fbs,
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

fields <-
  read_sf(dsn = "data-raw/shp", layer = "ricefield_groups") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(unique_id, county) |>
  st_join(select(watersheds,
                 group_id)) |>
  mutate(area_ac = units::drop_units(units::set_units(st_area(geometry), "acre")),
         volume_af = area_ac * 5/12) # |>
  #left_join(distances, by=join_by(unique_id))

# BASEMAP LAYERS

streams <-
  read_sf(dsn = "data-raw/shp", layer = "project_rearing_streams") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(stream_id = id, stream_name = river)

canals <-
  read_sf(dsn = "data-raw/shp", layer = "project_return_canals") |>
  janitor::clean_names() |>
  st_transform(project_crs) |>
  select(canal_id = objectid, canal_name = name)

#export this dataset
usethis::use_data(watersheds, overwrite = TRUE)
usethis::use_data(returns, overwrite = TRUE)
usethis::use_data(fields, overwrite = TRUE)
usethis::use_data(distances, overwrite = TRUE)
usethis::use_data(streams, overwrite = TRUE)
usethis::use_data(canals, overwrite = TRUE)
