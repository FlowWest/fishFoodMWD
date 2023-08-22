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
#' ff_make_leaflet(bbox)
#'
#' # create the leaflet map for a Shiny app
#' if(FALSE){
#'   output$mainMap <- leaflet::renderLeaflet({
#'     ff_make_leaflet(bbox)
#'   })
#' }
#'
ff_make_leaflet <- function(bbox=c(xmin=-122.3, ymin=38.5, xmax=-121.3, ymax=39.7)) {
  m <- leaflet::leaflet() |>
    leaflet::addMapPane("Basemap", zIndex = 400) |>
    leaflet::addMapPane("Watersheds", zIndex = 450) |>
    leaflet::addMapPane("Fields", zIndex = 460) |>
    leaflet::addMapPane("Flowlines", zIndex = 470) |>
    leaflet::addMapPane("Returns", zIndex = 480) |>
    leaflet::addProviderTiles(leaflet::providers$Stamen.Terrain,
                              options = leaflet::providerTileOptions(noWrap = TRUE,
                                                                     opacity = 0.5,
                                                                     pane = "Basemap")) |>
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
#' m <- ff_make_leaflet()
#' m |> ff_layer_streams(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_streams(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_streams"
#' if(FALSE){
#'   shiny::observe({
#'     proxy <- leaflet::leafletProxy("mainMap")
#'     proxy |> ff_layer_streams(show = input$show_streams)
#'   })
#' }
ff_layer_streams <- function(m, show = TRUE) {
  if(show) {
    m |> leaflet::addPolylines(data = ff_streams_gcs,
                      layerId = ~object_id,
                      label = ~lapply(paste0("<strong>",stream_name,"</strong><br />Fish-bearing stream"), htmltools::HTML),
                      color = "#00688b",
                      opacity = 1,
                      weight = 2,
                      options = leaflet::pathOptions(pane = "Flowlines"),
                      highlightOptions = leaflet::highlightOptions(color = "#FDD20E",
                                                                   weight = 3,
                                                                   bringToFront = TRUE)
    )
  } else {
    m |> leaflet::removeShape(ff_streams_gcs$object_id)
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
#' m <- ff_make_leaflet()
#' m |> ff_layer_canals(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_canals(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_canals"
#' if(FALSE){
#'   shiny::observe({
#'     proxy <- leaflet::leafletProxy("mainMap")
#'     proxy |> ff_layer_canals(show = input$show_canals)
#'   })
#' }
ff_layer_canals <- function(m, show = TRUE) {
  if(show) {
    m |> leaflet::addPolylines(data = ff_canals_gcs,
                      layerId = ~object_id,
                      label = ~lapply(paste0("<strong>",canal_name,"</strong><br />Secondary canal"), htmltools::HTML),
                      color = "#8b1a1a",
                      opacity = 1,
                      weight = 2,
                      options = leaflet::pathOptions(pane = "Flowlines"),
                      highlightOptions = leaflet::highlightOptions(color = "#FDD20E",
                                                                   weight = 3,
                                                                   bringToFront = TRUE)
    )
  } else {
    m |> leaflet::removeShape(ff_canals_gcs$object_id)
  }
}

#' @name ff_layer_returns
#' @title Show or hide leaflet returns layer
#' @description
#' Function to toggle the returns layer on an existing leaflet map.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @param selected_return The `return_id` of a return point to filter to, if desired.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m <- ff_make_leaflet()
#' m |> ff_layer_returns(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_returns(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_returns"
#' if(FALSE){
#'   shiny::observe({
#'     proxy <- leaflet::leafletProxy("mainMap")
#'     proxy |> ff_layer_returns(show = input$show_returns)
#'   })
#' }
#'
ff_layer_returns <- function(m, show = TRUE, selected_return=NULL) {
  if(show) {
    pal <- leaflet::colorFactor(palette = c("#00688b", "#8b1a1a"),
                                levels = c("Direct", "Indirect"))
    if(!is.null(selected_return)) {
      df <- ff_returns_gcs |> dplyr::filter(return_id == {{selected_return}})
    } else {
      df <- ff_returns_gcs
    }
    m |> leaflet::removeMarker(ff_returns_gcs$object_id) |>
      leaflet::addCircleMarkers(data = df,
                                layerId = ~object_id,
                                label = ~lapply(paste0("<strong>Return point ",return_id,": ",return_name,"</strong><br />",return_direct," return to ",ds_fbs_name), htmltools::HTML),
                                color = ~pal(return_direct),
                                radius = 4,
                                fillOpacity = 1,
                                stroke = FALSE,
                                options = leaflet::pathOptions(pane = "Returns")
                          )
  } else {
    m |> leaflet::removeMarker(ff_returns_gcs$object_id)
  }
}

#' @name ff_layer_watersheds
#' @title Show or hide leaflet watersheds layer
#' @description
#' Function to toggle the watersheds layer on an existing leaflet map.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @param selected_return The `return_id` of a return point to filter to, if desired.
#' @param selected_group The `group_id` of a watershed to filter to, if desired.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m <- ff_make_leaflet()
#' m |> ff_layer_watersheds(show = TRUE)
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_watersheds(show = FALSE)
#'
#' # use as part of a Shiny app with map "mainMap" and a boolean selector "show_canals"
#' if(FALSE){
#'   shiny::observe({
#'     proxy <- leaflet::leafletProxy("mainMap")
#'     proxy |> ff_layer_watersheds(show = input$show_watersheds)
#'   })
#' }
#'
ff_layer_watersheds <- function(m, show = TRUE, selected_return=NULL, selected_group=NULL) {
  if(show) {
    pal <- leaflet::colorFactor(palette = c("#ADD8E6", "#FFB6C1", "#FFE4B5"),
                                levels = c("Direct", "Indirect", "Lateral"))
    if(!is.null(selected_group)) {
      df <- ff_watersheds_gcs |> dplyr::filter(group_id == {{selected_group}})
    } else if(!is.null(selected_return)) {
      df <- ff_watersheds_gcs |> dplyr::filter(return_id == {{selected_return}})
    } else {
      df <- ff_watersheds_gcs
    }
    m |> leaflet::removeShape(ff_watersheds_gcs$object_id) |>
      leaflet::addPolygons(data = df,
                           layerId = ~object_id,
                           label = ~lapply(paste0("<strong>",watershed_name," Watershed</strong><br />",return_category," return to fish-bearing stream"), htmltools::HTML),
                           color = "white",
                           fillColor = ~pal(return_category),
                           weight = 1,
                           fillOpacity = 0.5,
                           options = leaflet::pathOptions(pane = "Watersheds"),
                           highlightOptions = leaflet::highlightOptions(color = "#FDD20E",
                                                                        weight = 3,
                                                                        bringToFront = FALSE)
                           )
  } else {
    m |> leaflet::removeShape(ff_watersheds_gcs$object_id)
  }
}

#' @name ff_layer_fields
#' @title Show or hide leaflet fields layer
#' @description
#' Function to toggle the rice fields layer on an existing leaflet map, and to select which attributes to use to define the symbology of the fields.
#' @param m An initialized `leaflet` map object or `leafletProxy` object.
#' @param show A boolean value indicating whether the function call will be adding the layer to the map (`TRUE`) or removing the layer from the map (`FALSE`). Designed to be changed via `shiny` checkbox input by calling the function inside an observer.
#' @param measure A string indicating the measure to show. Choose from `return` to color by return type, or `distances` to color by distances. FUTURE EDITS: ADD OPTIONS TO COLOR BY VOLUME, INVERTEBRATE MASS PRODUCTION, WET/DRY, ETC.
#' @param selected_return The `return_id` of a return point to filter to, if desired.
#' @param selected_group The `group_id` of a watershed to filter to, if desired.
#' @param selected_object The `object_id` of a single field to filter to, if desired. Used internally.
#' @md
#' @export
#' @examples
#' # show the layer on a leaflet map object ("m")
#' m <- ff_make_leaflet()
#' m |> ff_layer_fields(show = TRUE)
#'
#' # show the layer on a leaflet map object ("m") specifying the distances measure
#' m |> ff_layer_fields(show = TRUE, measure = "distances")
#'
#' # hide the layer on a leaflet map object ("m")
#' m |> ff_layer_fields(show = FALSE)
#'
#' # use as part of a Shiny app with a boolean selector "show_fields" and dropdown selector "measure_fields"
#' if(FALSE){
#'   shiny::observe({
#'     proxy <- leaflet::leafletProxy("mainMap")
#'     proxy |> ff_layer_fields(show = input$show_fields,
#'                              measure = input$measure_fields)
#'   })
#' }
#'
ff_layer_fields <- function(m, show = TRUE, measure="return", selected_return=NULL, selected_group=NULL, selected_object=NULL) {
  if(show) {
    if(!is.null(selected_object)) {
      df <- ff_fields_joined_gcs |> dplyr::filter(object_id == {{selected_object}})
    } else if(!is.null(selected_group)) {
      df <- ff_fields_joined_gcs |> dplyr::filter(group_id == {{selected_group}})
    } else if(!is.null(selected_return)) {
      df <- ff_fields_joined_gcs |> dplyr::filter(return_id == {{selected_return}})
    } else {
      df <- ff_fields_joined_gcs
    }
    if(measure=="return"){
      pal <- leaflet::colorFactor(palette = c("#57A0B9", "#C5686E", "#D9B679"),
                                  levels = c("Direct", "Indirect", "Lateral"))
      m |> leaflet::removeShape(ff_fields_joined_gcs$object_id) |>
           leaflet::addPolygons(data = df,
                       layerId = ~object_id,
                       label = ~lapply(paste0("<strong>",round(area_ac,1),"-acre rice field</strong><br />",
                                              return_category," return to ",fbs_name," = ",round(totdist_mi,1)," mi"),
                                       htmltools::HTML),
                       weight = 0,
                       color = "white",
                       fillColor = ~pal(return_category),
                       fillOpacity = 1,
                       options = leaflet::pathOptions(pane = "Fields"),
                       highlightOptions = leaflet::highlightOptions(fillColor = "#FDD20E",
                                                                    bringToFront = TRUE)
                       )
    } else if(measure=="distance"){
      pal <- leaflet::colorNumeric(palette = "Blues",
                                   domain = ff_fields_joined_gcs$totdist_mi)
      m |> leaflet::removeShape(ff_fields_joined_gcs$object_id) |>
           leaflet::addPolygons(data = df,
                       layerId = ~object_id,
                       label = ~lapply(paste0(return_category," return to ",fbs_name," = ",round(totdist_mi,1)," mi"),
                                       htmltools::HTML),
                       weight = 0,
                       fillColor = ~pal(totdist_mi),
                       fillOpacity = 1,
                       options = leaflet::pathOptions(pane = "Fields"),
                       highlightOptions = leaflet::highlightOptions(fillColor = "#FDD20E",
                                                                    bringToFront = TRUE)
      )
}
  } else {
    m |> leaflet::removeShape(ff_fields_joined_gcs$object_id)
  }
}

#' @name ff_map_watersheds
#' @title Interactive map of watersheds
#' @description
#' Creates an interactive leaflet map showing the rice fields with watersheds return types.
#' @param return (optional) A specific `return_id` for a return point to map.
#' @md
#' @export
#' @examples
#' ff_map_watersheds()
#'
#' ff_map_watersheds(return = 9)
ff_map_watersheds <- function(selected_return) {
  if (!missing(selected_return)){
    bbox <- sf::st_bbox(ff_fields_joined_gcs |> filter(return_id == {{selected_return}}))
    m <- ff_make_leaflet(bbox) |>
      ff_layer_streams() |>
      ff_layer_canals() |>
      ff_layer_returns(selected_return=selected_return) |>
      ff_layer_watersheds(selected_return=selected_return) |>
      ff_layer_fields(measure="return", selected_return=selected_return)
  } else {
    m <- ff_make_leaflet() |>
      ff_layer_streams() |>
      ff_layer_canals() |>
      ff_layer_returns() |>
      ff_layer_watersheds() |>
      ff_layer_fields(measure="return")
  }
  return(m)
  }

#' @name ff_map_distances
#' @title Interactive map of watersheds
#' @description
#' Creates an interactive leaflet map showing the rice fields with watersheds return types.
#' @param selected_return (optional) A specific `return_id` for a return point to map.
#' @md
#' @export
#' @examples
#' ff_map_distances()
#' ff_map_distances(selected_return = 9)
ff_map_distances <- function(selected_return) {
  if (!missing(selected_return)){
    bbox <- sf::st_bbox(ff_fields_joined_gcs |> filter(return_id == {{selected_return}}))
    m <- ff_make_leaflet(bbox) |>
      ff_layer_streams() |>
      ff_layer_canals() |>
      ff_layer_returns(selected_return=selected_return) |>
      ff_layer_fields(measure="distance", selected_return=selected_return)
  } else {
    m <- ff_make_leaflet() |>
      ff_layer_streams() |>
      ff_layer_canals() |>
      ff_layer_returns() |>
      ff_layer_fields(measure="distance")
  }
  return(m)
}

