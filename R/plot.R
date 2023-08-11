#' @name plot_fields
#' @title Plot rice fields
#' @description Plot all fields. Displays the watersheds, return points, and waterways as well. Returns are distinguished as draining directly into the fish-bearing stream or via a secondary waterway.
#' @importClassesFrom sf sf
#' @export
#' @examples
#' plot_fields()
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_fields() + ggplot2::ggtitle("Rice Fields") + ggplot2::theme_void()
plot_fields <- function() {
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = fishFoodMWD::watersheds, color="white", fill="antiquewhite1") +
    ggplot2::geom_sf(data = fishFoodMWD::fields, color="goldenrod1") +
    ggplot2::geom_sf(data = fishFoodMWD::returns, ggplot2::aes(color=return_direct)) +
    ggplot2::geom_sf(data = fishFoodMWD::canals, ggplot2::aes(color="Indirect")) +
    ggplot2::geom_sf(data = fishFoodMWD::streams, ggplot2::aes(color="Direct")) +
    ggplot2::scale_color_manual(values = c("Direct" = "deepskyblue4", "Indirect" = "firebrick4"),
                                name="Return to \nfish-bearing stream") +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(breaks = seq(38, 40, by=0.5)) +
    ggplot2::scale_x_continuous(breaks = seq(-122.5, -120.5, by=0.5))
}

#' @name plot_distances
#' @title Plot rice fields with flow distances
#' @description Plot all fields showing their calculated flow distances. Distance table is first joined to the fields table. Displays the watersheds, return points, and waterways on the basemap.
#' @importClassesFrom sf sf
#' @importFrom dplyr left_join
#' @importMethodsFrom sf left_join.sf
#' @export
#' @examples
#' plot_distances()
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_distances() + ggplot2::ggtitle("Rice Field Distances") + ggplot2::theme_void()
plot_distances <- function() {
  df <- fishFoodMWD::fields |> dplyr::left_join(fishFoodMWD::distances)
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = df, ggplot2::aes(fill=totdist_mi, color=totdist_mi)) +
    ggplot2::geom_sf(data = fishFoodMWD::returns) +
    ggplot2::geom_sf(data = fishFoodMWD::canals) +
    ggplot2::geom_sf(data = fishFoodMWD::streams) +
    ggplot2::scale_fill_viridis_c(aesthetics = c("colour", "fill"),
                                  option="cividis",
                                  direction=-1,
                                  name="Distance to \nfish-bearing stream \n(mi)") +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(breaks = seq(38, 40, by=0.5)) +
    ggplot2::scale_x_continuous(breaks = seq(-122.5, -120.5, by=0.5))
}

#' @name plot_watersheds
#' @title Plot watersheds by flow type
#' @description Plot all watersheds (groups) showing their type of flow: lateral to fish-bearing stream, direct to fish-bearing stream via return point outlet, or indirect to fish-bearing stream via return point outlet and secondary canal. Displays the watersheds, return points, and waterways on the basemap.
#' @importClassesFrom sf sf
#' @importFrom dplyr mutate
#' @importMethodsFrom sf mutate.sf
#' @export
#' @examples
#' plot_distances()
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_distances() + ggplot2::ggtitle("Watersheds") + ggplot2::theme_void()
plot_watersheds <- function() {
  df <- fishFoodMWD::watersheds |> dplyr::left_join(sf::st_drop_geometry(fishFoodMWD::returns)) |>
    dplyr::mutate(category = case_when(is.na(ds_fbs_dist) ~ "Lateral",
                                       ds_fbs_dist==0 ~ "Direct",
                                       TRUE ~ "Indirect"))
  ggplot2::ggplot() +
    ggplot2::geom_sf(data = df, ggplot2::aes(fill=category), color="white") +
    ggplot2::geom_sf(data = fishFoodMWD::returns, ggplot2::aes(color=return_direct)) +
    ggplot2::geom_sf(data = fishFoodMWD::canals, ggplot2::aes(color="Indirect")) +
    ggplot2::geom_sf(data = fishFoodMWD::streams, ggplot2::aes(color="Direct")) +
    ggplot2::scale_color_manual(values = c("Direct" = "deepskyblue4", "Indirect" = "firebrick4"),
                                name="Return to \nfish-bearing stream") +
    ggplot2::scale_fill_manual(values = c("Direct" = "lightblue", "Indirect" = "lightpink", "Lateral" = "moccasin"),
                               name="Watershed flow type") +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(breaks = seq(38, 40, by=0.5)) +
    ggplot2::scale_x_continuous(breaks = seq(-122.5, -120.5, by=0.5))
}
