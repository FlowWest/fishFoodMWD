#' @title Plot fields
#' @description Plot all fields. Displays the watersheds, return points, and waterways as well. Returns are distinguished as draining directly into the fish-bearing stream or via a secondary waterway.
plot_fields <- function() {
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = fishFoodMWD::watersheds, color="white") +
    ggplot2::geom_sf(data = fishFoodMWD::fields, color="orange") +
    ggplot2::geom_sf(data = fishFoodMWD::returns, aes(color=return_direct)) +
    ggplot2::geom_sf(data = fishFoodMWD::canals, aes(color="Indirect")) +
    ggplot2::geom_sf(data = fishFoodMWD::streams, aes(color="Direct")) +
    ggplot2::scale_color_manual(values = c("Direct" = "blue", "Indirect" = "darkred")) +
    ggplot2::theme_minimal()
}

#' @title Plot distances
#' @description Plot all fields showing their calculated flow distances. Distance table is first joined to the fields table. Displays the watersheds, return points, and waterways on the basemap.
plot_distances <- function() {
  df <- dplyr::left_join(fishFoodMWD::fields, fishFoodMWD::distances)
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = df, aes(fill=totdist_mi, color=totdist_mi)) +
    ggplot2::geom_sf(data = fishFoodMWD::returns) +
    ggplot2::geom_sf(data = fishFoodMWD::canals) +
    ggplot2::geom_sf(data = fishFoodMWD::streams) +
    ggplot2::scale_fill_viridis_c(aesthetics = c("colour", "fill"), direction=-1) +
    ggplot2::theme_minimal()
}

#' @title Plot watersheds
#' @description Plot all watersheds (groups) showing their type of flow: lateral to fish-bearing stream, direct to fish-bearing stream via return point outlet, or indirect to fish-bearing stream via return point outlet and secondary canal. Displays the watersheds, return points, and waterways on the basemap.
plot_watersheds <- function() {
  df <- dplyr::left_join(fishFoodMWD::watersheds,
                         sf::st_drop_geometry(fishFoodMWD::returns)) |>
    dplyr::mutate(category = dplyr::case_when(is.na(ds_fbs_dist) ~ "Lateral",
                                              ds_fbs_dist==0 ~ "Direct",
                                              .default ~ "Indirect"))
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = df, aes(fill=category)) +
    ggplot2::geom_sf(data = fishFoodMWD::returns, aes(color=return_direct)) +
    ggplot2::geom_sf(data = fishFoodMWD::canals, aes(color="Indirect")) +
    ggplot2::geom_sf(data = fishFoodMWD::streams, aes(color="Direct")) +
    ggplot2::scale_color_manual(values = c("Direct" = "blue", "Indirect" = "darkred")) +
    ggplot2::scale_fill_manual(values = c("Direct" = "lightblue", "Indirect" = "pink", "Lateral" = "lightyellow")) +
    ggplot2::theme_minimal()
}
