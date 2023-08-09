#' @title Plot fields
#' @description Plot all fields. Displays the watersheds, return points, and waterways as well. Returns are distinguished as draining directly into the fish-bearing stream or via a seocndary waterway.
#' @importFrom tidyverse
#' @importFrom sf
plot_fields <- function() {
  ggplot() +
    geom_sf(data = fishFoodMWD::watersheds, color="white") +
    geom_sf(data = fishFoodMWD::fields, color="orange") +
    geom_sf(data = fishFoodMWD::returns, aes(color=return_direct)) +
    geom_sf(data = fishFoodMWD::canals, aes(color="Indirect")) +
    geom_sf(data = fishFoodMWD::streams, aes(color="Direct")) +
    scale_color_manual(values = c("Direct" = "blue", "Indirect" = "darkred")) +
    theme_minimal()
}

#' @title Plot distances
#' @description Plot all fields showing their calculated flow distances. Distance table is first joined to the fields table. Displays the watersheds, return points, and waterways on the basemap.
#' @importFrom tidyverse
#' @importFrom sf
plot_distances <- function() {
  df <- left_join(fishFoodMWD::fields, fishFoodMWD::distances)
  ggplot2::ggplot() +
    geom_sf(data = df, aes(fill=totdist_mi, color=totdist_mi)) +
    geom_sf(data = fishFoodMWD::returns) +
    geom_sf(data = fishFoodMWD::canals) +
    geom_sf(data = fishFoodMWD::streams) +
    scale_fill_viridis_c(aesthetics = c("colour", "fill"), direction=-1) +
    theme_minimal()
}

#' @title Plot watersheds
#' @description Plot all watersheds (groups) showing their type of flow: lateral to fish-bearing stream, direct to fish-bearing stream via return point outlet, or indirect to fish-bearing stream via return point outlet and secondary canal. Displays the watersheds, return points, and waterways on the basemap.
#' @importFrom tidyverse
#' @importFrom sf
plot_watersheds <- function() {
  df <- left_join(fishFoodMWD::watersheds, st_drop_geometry(fishFoodMWD::returns)) |>
    mutate(category = case_when(is.na(ds_fbs_dist) ~ "Lateral",
                                ds_fbs_dist==0 ~ "Direct",
                                TRUE ~ "Indirect"))
  ggplot() +
    geom_sf(data = df, aes(fill=category)) +
    geom_sf(data = fishFoodMWD::returns, aes(color=return_direct)) +
    geom_sf(data = fishFoodMWD::canals, aes(color="Indirect")) +
    geom_sf(data = fishFoodMWD::streams, aes(color="Direct")) +
    scale_color_manual(values = c("Direct" = "blue", "Indirect" = "darkred")) +
    scale_fill_manual(values = c("Direct" = "lightblue", "Indirect" = "pink", "Lateral" = "lightyellow")) +
    theme_minimal()
}

# plot_leaflet <- function() {}
#
# SCRATCH AREA
#
#plot_by_return_id <- function(id) {
#  ggplot() +
#    geom_sf(data = fishFoodMWD::watersheds |> filter(return_id == id)) +
#    geom_sf(data = left_join(fishFoodMWD::fields, fishFoodMWD::distances) |> filter(return_id == id)) +
#    geom_sf(data = fishFoodMWD::returns |> filter(return_id == id)) +
#    theme_minimal()
#}
#plot_by_return_id(9)
#
#plot_by_watershed <- function() {
#  ggplot() +
#    geom_sf(data = left_join(fishFoodMWD::fields, fishFoodMWD::distances),
#            aes(fill=totdist_mi, color=totdist_mi)) +
#    geom_sf(data = fishFoodMWD::watersheds, color="white") +
#    facet_wrap(vars(group_id)) +
#    theme_minimal()
#}
# select a field, highlight the stream, the return_id, the watershed
# select a return_id, highlight the stream, and all fields and watersheds that drain into it
