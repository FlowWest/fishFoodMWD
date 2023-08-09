#' @title Plot fields
#' @description Plot all fields. Display the watersheds, return points, and waterways on the basemap. Returns are distinguished as draining directly into the fish-bearing stream or via a seocndary waterway.
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
plot_distances <- function() {
  df <- left_join(fishFoodMWD::fields, fishFoodMWD::distances)
  ggplot() +
    geom_sf(data = df, aes(fill=totdist_mi, color=totdist_mi)) +
    geom_sf(data = fishFoodMWD::returns) +
    geom_sf(data = fishFoodMWD::canals) +
    geom_sf(data = fishFoodMWD::streams) +
    scale_fill_viridis_c(aesthetics = c("colour", "fill"), direction=-1) +
    theme_minimal()
}

#' @title Plot watersheds
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
