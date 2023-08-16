#' @name plot_fields
#' @title Plot rice fields
#' @description Plot all fields. Displays the watersheds, return points, and waterways as well. Returns are distinguished as draining directly into the fish-bearing stream or via a secondary waterway.
#' @param filename File name to create PNG image on disk. Optional if saving the plot is desired.
#' @param width Plot width in `units`. If not supplied, uses the size of current graphics device.
#' @param height Plot height in `units`. If not supplied, uses the size of current graphics device.
#' @param units Units used for the width and height ("in", "cm", "mm", or "px"). Uses default `ggplot` dpi settings for resolution.
#' @md
#' @export
#' @examples
#' plot_fields()
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_fields() + ggplot2::ggtitle("Rice Fields") + ggplot2::theme_void()
#' # Save the output (or for more options, follow the function with a call to ggplot2::ggsave)
#' plot_fields(filename="temp/out.png", width=5, height=7, units="in")
plot_fields <- function(filename, width=NA, height=NA, units=NULL) {
  gg <- ggplot2::ggplot() +
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
  if(!(missing(filename))){
    ggplot2::ggsave(filename=filename, width=width, height=height, units=units)
  }
  return(gg)
}

#' @name plot_distances
#' @title Plot rice fields with flow distances
#' @description Plot all fields showing their calculated flow distances. Distance table is first joined to the fields table. Displays the watersheds, return points, and waterways on the basemap.
#' @importFrom dplyr left_join
#' @param filename File name to create PNG image on disk. Optional if saving the plot is desired.
#' @param width Plot width in `units`. If not supplied, uses the size of current graphics device.
#' @param height Plot height in `units`. If not supplied, uses the size of current graphics device.
#' @param units Units used for the width and height ("in", "cm", "mm", or "px"). Uses default `ggplot` dpi settings for resolution.
#' @param colors Color palette to use. Choose from either a character string indicating the `viridis` color map option to use (listed below), or a named vector defining a custom continuous gradient with `low` and `high` or a diverging gradient with `low`, `mid`, and `high`, e.g. `colors = c(low="red", mid="white", high="blue")`. For the diverging gradient, the average value is used as the midpoint.
#' * `magma` (or `A`)
#' * `inferno` (or `B`)
#' * `plasma` (or `C`)
#' * `viridis` (or `D`)
#' * `cividis` (or `E`)
#' * `rocket` (or `F`)
#' * `mako` (or `G`)
#' * `turbo` (or `H`)
#' @param direction If using one of the `viridis` scales for the `color` option, sets the order of colors in the scale. If 1, the default, colors are ordered from darkest to lightest. If -1, the order of colors is reversed.
#' @md
#' @export
#' @examples
#' plot_distances()
#' # Choose custom colors
#' plot_distances(colors=c(low="darkorange", mid="lightyellow", high="darkorchid4"))
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_distances() + ggplot2::ggtitle("Rice Field Distances") + ggplot2::theme_void()
plot_distances <- function(filename=NULL, width=NULL, height=NULL, units=NULL,
                           colors=NULL, direction=1) {
  df <- fishFoodMWD::fields |> dplyr::left_join(fishFoodMWD::distances)
  legend_name <- "Distance to \nfish-bearing stream \n(mi)"
  gg <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = df, ggplot2::aes(fill=totdist_mi, color=totdist_mi)) +
    ggplot2::geom_sf(data = fishFoodMWD::returns) +
    ggplot2::geom_sf(data = fishFoodMWD::canals) +
    ggplot2::geom_sf(data = fishFoodMWD::streams) +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(breaks = seq(38, 40, by=0.5)) +
    ggplot2::scale_x_continuous(breaks = seq(-122.5, -120.5, by=0.5))
  if(!(missing(filename))){
    ggplot2::ggsave(filename=filename, width=width, height=height, units=units)
  }
  if(missing(colors)){
    gg <- gg + ggplot2::scale_fill_viridis_c(aesthetics = c("colour", "fill"),
                                             option="cividis",
                                             direction=-1,
                                             name=legend_name)
  } else if (all(c("low", "mid", "high") %in% names(colors))) {
    gg <- gg + ggplot2::scale_colour_gradient2(aesthetics = c("colour", "fill"),
                                               low=colors["low"], mid=colors["mid"], high=colors["high"],
                                               midpoint = mean(df$totdist_mi),
                                               name=legend_name)
  } else if (all(c("low", "high") %in% names(colors))) {
    gg <- gg + ggplot2::scale_colour_gradient(aesthetics = c("colour", "fill"),
                                               low=colors["low"], high=colors["high"],
                                               name=legend_name)
  } else {
    gg <- gg + ggplot2::scale_fill_viridis_c(aesthetics = c("colour", "fill"),
                                             option=colors, direction=direction)
  }
  return(gg)
}

#' @name plot_watersheds
#' @title Plot watersheds by flow type
#' @description Plot all watersheds (groups) showing their type of flow: lateral to fish-bearing stream, direct to fish-bearing stream via return point outlet, or indirect to fish-bearing stream via return point outlet and secondary canal. Displays the watersheds, return points, and waterways on the basemap.
#' @importFrom dplyr mutate
#' @param filename File name to create PNG image on disk. Optional if saving the plot is desired.
#' @param width Plot width in `units`. If not supplied, uses the size of current graphics device.
#' @param height Plot height in `units`. If not supplied, uses the size of current graphics device.
#' @param units Units used for the width and height ("in", "cm", "mm", or "px"). Uses default `ggplot` dpi settings for resolution.
#' @md
#' @export
#' @examples
#' plot_watersheds()
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_watersheds() + ggplot2::ggtitle("Watersheds") + ggplot2::theme_void()
plot_watersheds <- function(filename, width=NA, height=NA, units=NULL) {
  df <- fishFoodMWD::watersheds |> dplyr::left_join(sf::st_drop_geometry(fishFoodMWD::returns)) |>
    dplyr::mutate(category = dplyr::case_when(is.na(ds_fbs_dist) ~ "Lateral",
                                       ds_fbs_dist==0 ~ "Direct",
                                       TRUE ~ "Indirect"))
  gg <- ggplot2::ggplot() +
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
  if(!(missing(filename))){
    ggplot2::ggsave(filename=filename, width=width, height=height, units=units)
  }
  return(gg)
}

#' @name plot_inv_mass
#' @title Plot rice fields with invertebrate mass production
#' @description Plot all fields showing their calculated invertebrate mass production (based on acreage). The `calc_inv_mass` function is first run on the `fields` dataset using the defined number of days. Displays the watersheds, return points, and waterways on the basemap.
#' @param day The day number for which to calculate the invertebrate mass. Defaults to one day.
#' @param filename File name to create PNG image on disk. Optional if saving the plot is desired.
#' @param width Plot width in `units`. If not supplied, uses the size of current graphics device.
#' @param height Plot height in `units`. If not supplied, uses the size of current graphics device.
#' @param units Units used for the width and height ("in", "cm", "mm", or "px"). Uses default `ggplot` dpi settings for resolution.
#' @param colors Color palette to use. Choose from either a character string indicating the `viridis` color map option to use (listed below), or a named vector defining a custom continuous gradient with `low` and `high` or a diverging gradient with `low`, `mid`, and `high`, e.g. `colors = c(low="red", mid="white", high="blue")`. For the diverging gradient, the average value is used as the midpoint.
#' * `magma` (or `A`)
#' * `inferno` (or `B`)
#' * `plasma` (or `C`)
#' * `viridis` (or `D`)
#' * `cividis` (or `E`)
#' * `rocket` (or `F`)
#' * `mako` (or `G`)
#' * `turbo` (or `H`)
#' @param direction If using one of the `viridis` scales for the `color` option, sets the order of colors in the scale. If 1, the default, colors are ordered from darkest to lightest. If -1, the order of colors is reversed.
#' @md
#' @export
#' @examples
#' plot_inv_mass(14)
#' # Choose custom colors
#' plot_inv_mass(14, colors=c(low="darkorange", mid="lightyellow", high="darkorchid4"))
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_inv_mass(14) + ggplot2::ggtitle("Rice Field Distances") + ggplot2::theme_void()
plot_inv_mass <- function(day=1, filename=NULL, width=NULL, height=NULL, units=NULL,
                           colors=NULL, direction=1) {
  df <- fishFoodMWD::fields |> calc_inv_mass(day)
  legend_name <- paste0("Total ",day,"-day \ninvertebrate mass \nproduction (kg)")
  gg <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = df, ggplot2::aes(fill=total_prod_kg, color=total_prod_kg)) +
    ggplot2::geom_sf(data = fishFoodMWD::returns) +
    ggplot2::geom_sf(data = fishFoodMWD::canals) +
    ggplot2::geom_sf(data = fishFoodMWD::streams) +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(breaks = seq(38, 40, by=0.5)) +
    ggplot2::scale_x_continuous(breaks = seq(-122.5, -120.5, by=0.5))
  if(!(missing(filename))){
    ggplot2::ggsave(filename=filename, width=width, height=height, units=units)
  }
  if(missing(colors)){
    gg <- gg + ggplot2::scale_fill_viridis_c(aesthetics = c("colour", "fill"),
                                             option="cividis",
                                             direction=-1,
                                             name=legend_name)
  } else if (all(c("low", "mid", "high") %in% names(colors))) {
    gg <- gg + ggplot2::scale_colour_gradient2(aesthetics = c("colour", "fill"),
                                               low=colors["low"], mid=colors["mid"], high=colors["high"],
                                               midpoint = mean(df$total_prod_kg),
                                               name=legend_name)
  } else if (all(c("low", "high") %in% names(colors))) {
    gg <- gg + ggplot2::scale_colour_gradient(aesthetics = c("colour", "fill"),
                                              low=colors["low"], high=colors["high"],
                                              name=legend_name)
  } else {
    gg <- gg + ggplot2::scale_fill_viridis_c(aesthetics = c("colour", "fill"),
                                             option=colors, direction=direction)
  }
  return(gg)
}

#' @name plot_wetdry
#' @title Plot wet/dry sides
#' @description Plot all fields. Displays the watersheds, return points, and waterways as well. Returns are distinguished as draining directly into the fish-bearing stream or via a secondary waterway.
#' @param filename File name to create PNG image on disk. Optional if saving the plot is desired.
#' @param width Plot width in `units`. If not supplied, uses the size of current graphics device.
#' @param height Plot height in `units`. If not supplied, uses the size of current graphics device.
#' @param units Units used for the width and height ("in", "cm", "mm", or "px"). Uses default `ggplot` dpi settings for resolution.
#' @md
#' @export
#' @examples
#' plot_wetdry()
#' # Returns a ggplot object that can be chained to additional ggplot functions
#' plot_wetdry() + ggplot2::ggtitle("Wet/Dry Sides") + ggplot2::theme_void()
#' # Save the output (or for more options, follow the function with a call to ggplot2::ggsave)
#' plot_wetdry(filename="temp/out.png", width=5, height=7, units="in")
plot_wetdry <- function(filename, width=NA, height=NA, units=NULL) {
  df <- fishFoodMWD::fields |> dplyr::left_join(fishFoodMWD::distances)
  gg <- ggplot2::ggplot() +
    ggplot2::geom_sf(data=wetdry, ggplot2::aes(fill=wet_dry), alpha=0.5, color=NA) +
    ggplot2::geom_sf(data=df, ggplot2::aes(fill=wet_dry, color=wet_dry)) +
    ggplot2::geom_sf(data=streams) +     ggplot2::geom_sf(data=canals) +
    ggplot2::scale_fill_manual(values=c("Dry"="moccasin", "Wet"="mediumaquamarine"),
                      aesthetics=c("fill","color"), name="Wet vs Dry \n(rice fields shaded)") +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(breaks = seq(38, 40, by=0.5)) +
    ggplot2::scale_x_continuous(breaks = seq(-122.5, -120.5, by=0.5))
  if(!(missing(filename))){
    ggplot2::ggsave(filename=filename, width=width, height=height, units=units)
  }
  return(gg)
}
