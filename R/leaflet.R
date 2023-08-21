#' @name ff_make_leaflet
#' @title Create leaflet map object
#' @description
#' Initialize a leaflet map object with the desired basemap and settings.
#' @param bbox A named vector defining the initial map extent via minimum and maximum lat/lon coordinates in the format `c(xmin=_, ymin=_, xmax=_, ymax=_)`
#' @md
#' @export
#' @examples
#' # create and display leaflet object with a specified bounding box
#' bbox <- sf::st_bbox(ff_fields_gcs)
#' m <- ff_make_leaflet(bbox)
#' m
#'
#' # create the leaflet map for a Shiny app
#' output$mainMap <- leaflet::renderLeaflet({
#'   ff_make_leaflet(bbox)
#' })
#'
ff_make_leaflet <- function(bbox) {
  m <- leaflet::leaflet() |>
    leaflet::addProviderTiles(leaflet::providers$Stamen.Terrain,
                     options = leaflet::providerTileOptions(noWrap = TRUE,
                                                   opacity = 0.5)) |>
    leaflet::fitBounds(lng1 = bbox[["xmin"]],
                       lat1 = bbox[["ymin"]],
                       lng2 = bbox[["xmax"]],
                       lat2 = bbox[["ymax"]])
  return(m)
}

#' @name ff_layer_streams
#' @title Show or hide leaflet streams layer
#' @description
#' Function to toggle the streams layer on an existing leaflet map.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m |> ff_layer_streams(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_streams(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_streams"
#' observe({
#'   proxy <- leaflet::leafletProxy("mainMap")
#'   proxy |> ff_leaflet_streams(show = input$show_streams)
#' })
#'
ff_layer_streams <- function(m, show = TRUE) {
  object_ids <- paste0("stream_",seq(1,nrow(ff_streams_gcs)))
  if(show) {
    m |> leaflet::addPolylines(data = ff_streams_gcs,
                      layerId = object_ids,
                      popup = ~stream_name,
                      color = "#00688b",
                      opacity = 1,
                      weight = 2,
    )
  } else {
    m |> leaflet::removeShape(object_ids)
  }
  }

#' @name ff_layer_canals
#' @title Show or hide leaflet canals layer
#' @description
#' Function to toggle the canals layer on an existing leaflet map.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m |> ff_layer_canals(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_canals(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_canals"
#' observe({
#'   proxy <- leaflet::leafletProxy("mainMap")
#'   proxy |> ff_layer_canals(show = input$show_canals)
#' })
#'
ff_layer_canals <- function(m, show = TRUE) {
  object_ids <- paste0("canal_",seq(1,nrow(ff_canals_gcs)))
  if(show) {
    m |> leaflet::addPolylines(data = ff_canals_gcs,
                      layerId = object_ids,
                      popup = ~canal_name,
                      color = "#8b1a1a",
                      opacity = 1,
                      weight = 2,
    )
  } else {
    m |> leaflet::removeShape(object_ids)
  }
}

#' @name ff_layer_returns
#' @title Show or hide leaflet returns layer
#' @description
#' Function to toggle the returns layer on an existing leaflet map.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m |> ff_layer_returns(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_returns(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_returns"
#' observe({
#'   proxy <- leaflet::leafletProxy("mainMap")
#'   proxy |> ff_layer_returns(show = input$show_returns)
#' })
#'
ff_layer_returns <- function(m, show = TRUE) {
  object_ids <- paste0("return_",seq(1,nrow(ff_returns_gcs)))
  if(show) {
    pal <- leaflet::colorFactor(palette = c("#00688b", "#8b1a1a"),
                                levels = c("Direct", "Indirect"))
    m |> leaflet::addCircleMarkers(data = ff_returns_gcs,
                          layerId = object_ids,
                          popup = ~paste0(return_id,"<br>",return_direct),
                          color = ~pal(return_direct),
                          radius = 4,
                          fillOpacity = 1,
                          stroke = FALSE,
                          )
  } else {
    m |> leaflet::removeShape(object_ids)
  }
}

#' @name ff_layer_watersheds
#' @title Show or hide leaflet watersheds layer
#' @description
#' Function to toggle the watersheds layer on an existing leaflet map.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m |> ff_layer_watersheds(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_watersheds(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_canals"
#' observe({
#'   proxy <- leaflet::leafletProxy("mainMap")
#'   proxy |> ff_layer_watersheds(show = input$show_watersheds)
#' })
#'
ff_layer_watersheds <- function(m, show = TRUE) {
  df <- ff_watersheds_gcs |>
    dplyr::left_join(sf::st_drop_geometry(ff_returns)) |>
    dplyr::mutate(return_direct = dplyr::case_when(return_direct %in% c("Direct", "Indirect") ~ return_direct, TRUE ~ "Lateral"))
  pal <- leaflet::colorFactor(palette = c("lightblue", "lightpink", "moccasin"),
                              levels = c("Direct", "Indirect", "Lateral"))
  object_ids <- paste0("watershed_",seq(1,nrow(df)))
  if(show) {
    m |> leaflet::addPolygons(data = df,
                              layerId = object_ids,
                              popup = ~watershed_name,
                              color = "white",
                              fillColor = ~pal(return_direct),
                              weight = 1,
                              fillOpacity = 0.5,
                              )
  } else {
    m |> leaflet::removeShape(object_ids)
  }
}

#' @name ff_layer_fields
#' @title Show or hide leaflet fields layer
#' @description
#' Function to toggle the rice fields layer on an existing leaflet map, and to select which attributes to use to define the symbology of the fields.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @param measure A string indicating the measure to show. Choose from `return` to color by return type, or `distances` to color by distances. FUTURE EDITS: ADD OPTIONS TO COLOR BY VOLUME, INVERTEBRATE MASS PRODUCTION, WET/DRY, ETC.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m |> ff_layer_fields(show = TRUE)
#'
#' # show the layer on a leaflet map object ("m") specifying the distances measure
#' m |> ff_layer_fields(show = TRUE, measure = "distances")
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_fields(show = FALSE)
#'
#' # use as part of a Shiny app with a boolean selector "show_fields" and dropdown selector "measure_fields"
#' observe({
#'   proxy <- leaflet::leafletProxy("mainMap")
#'   proxy |> ff_layer_fields(show = input$show_fields,
#'                            measure = input$measure_fields)
#' })
#'
ff_layer_fields <- function(m, show = TRUE, measure="return") {
  object_ids <- paste0("field_",seq(1,nrow(ff_fields_joined_gcs)))
  if(show) {
    if(measure=="return"){
      pal <- leaflet::colorFactor(palette = c("lightblue", "lightpink", "moccasin"),
                                  levels = c("Direct", "Indirect", "Lateral"))
      m |> leaflet::removeShape(object_ids) |>
           leaflet::addPolygons(data = ff_fields_joined_gcs,
                       layerId = object_ids,
                       popup = ~paste0(return_direct," return to ",fbs_name," = ",round(totdist_mi,1)," mi"),
                       weight = 0,
                       fillColor = ~pal(return_direct),
                       fillOpacity = 1,
      )
    } else if(measure=="distance"){
      pal <- leaflet::colorNumeric(palette = "Blues",
                                   domain = ff_fields_joined_gcs$totdist_mi)
      m |> leaflet::removeShape(object_ids) |>
           leaflet::addPolygons(data = ff_fields_joined_gcs,
                       layerId = object_ids,
                       popup = ~paste0(return_direct," return to ",fbs_name," = ",round(totdist_mi,1)," mi"),
                       weight = 0,
                       fillColor = ~pal(totdist_mi),
                       fillOpacity = 1,
      )
    }
  } else {
    m |> leaflet::removeShape(object_ids)
  }
}
