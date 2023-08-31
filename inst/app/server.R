function(input, output, session){

  # using a reactive ID option
  selected_point <- reactiveValues(object_id = NULL,
                                   return_point_id = NULL,
                                   group_id = NULL,
                                   long = NULL,
                                   lat = NULL)

  observeEvent(input$field_map_shape_click, {
    if (!is.null(input$field_map_shape_click$id)) {

      shinyjs::showElement(id = 'reset_guidance')

      click_type <- substr(input$field_map_shape_click$id, 1, 1)

      if(click_type == 'F') { # Fields

        val <- ff_fields_joined_gcs |>
          filter(object_id == input$field_map_shape_click$id) |>
          select(return_id, group_id)

        selected_point$object_id <- input$field_map_shape_click$id
        selected_point$group_id <- val$group_id
        selected_point$return_point_id <- val$return_id
        selected_point$long = input$field_map_shape_click$lng
        selected_point$lat = input$field_map_shape_click$lat

      } else if(click_type == 'W') { # Watersheds

        val <- ff_watersheds_gcs |>
          filter(object_id == input$field_map_shape_click$id) |>
          select(return_id, group_id)

        selected_point$object_id <- NULL
        selected_point$group_id <- val$group_id
        selected_point$return_point_id <- val$return_id
        selected_point$long = input$field_map_shape_click$lng
        selected_point$lat = input$field_map_shape_click$lat

      }
    }
  })

  observeEvent(input$field_map_marker_click, {
    if (!is.null(input$field_map_marker_click$id)) {

      shinyjs::showElement(id = 'reset_guidance')

      click_type <- substr(input$field_map_marker_click$id, 1, 1)

      if(click_type == 'R') { # Return points

        val <- ff_returns_gcs |>
          filter(object_id == input$field_map_marker_click$id) |>
          select(return_id)

        selected_point$object_id <- NULL
        selected_point$group_id <- NULL
        selected_point$return_point_id <- val$return_id
        selected_point$long = input$field_map_marker_click$lng
        selected_point$lat = input$field_map_marker_click$lat

      }
    }
  })

  reset_filters <- function() {
    shinyjs::showElement(id = 'loading')
    selected_point$object_id <- NULL
    selected_point$group_id <- NULL
    selected_point$return_point_id <- NULL
    selected_point$long <- NULL
    selected_point$lat <- NULL
    shinyjs::hideElement(id = 'reset_guidance')
  }

  observeEvent(input$field_map_click, {

    if (!is.null(selected_point)) {
      field_map_shape_click_info <- input$field_map_shape_click
      field_map_marker_click_info <- input$field_map_marker_click
      field_map_click_info <- input$field_map_click
      if (is.null(field_map_shape_click_info) & is.null(field_map_marker_click_info)) {
        #cat("shape is null and marker is null")
        reset_filters()
      } else if ( is.null(field_map_marker_click_info) &
                  (!all(unlist(field_map_shape_click_info[c('lat','lng')]) ==
                       unlist(field_map_click_info[c('lat','lng')])))
                  ) {
        #cat("marker is null and click doesn't match last shape")
        reset_filters()
      } else if ( is.null(field_map_shape_click_info) &
                  (!all(unlist(field_map_marker_click_info[c('lat','lng')]) ==
                       unlist(field_map_click_info[c('lat','lng')])))
                  ) {
        #cat("shape is null and click doesn't match last marker")
        reset_filters()
      } else if ((!all(unlist(field_map_shape_click_info[c('lat','lng')]) ==
                      unlist(field_map_click_info[c('lat','lng')]))) &
                 (!all(unlist(field_map_marker_click_info[c('lat','lng')]) ==
                      unlist(field_map_click_info[c('lat','lng')])))
        ) {
        #cat("click doesn't match last marker or shape")
        reset_filters()
      }
    }

  })

  # reset the map
  observeEvent(input$resetButton, {
    reset_filters()
    proxy <- leaflet::leafletProxy("field_map")
    proxy |>
      leaflet::fitBounds(lng1 = -122.3,
                         lat1 = 38.5,
                         lng2 = -121.3,
                         lat2 = 39.7)

  })

  output$field_map <- renderLeaflet({
    # shinyjs::showElement(id = 'loading_action')
    ff_make_leaflet() |>
      ff_layer_streams() |>
      ff_layer_canals() |>
      ff_layer_wetdry() |>
      leaflet::addLayersControl(baseGroups = c("watersheds", "wetdry", "none"),
                                                             overlayGroups = c("fields", "returns-canals-streams"),
                                                             position = "bottomleft",
                                                             options = leaflet::layersControlOptions(collapsed = FALSE)) |>
      htmlwidgets::onRender("
                              function() {
                                  $('.leaflet-control-layers-base').prepend('<label>Select a Base Layer</label>');
                                  $('.leaflet-control-layers-overlays').prepend('<label>Show/Hide Overlays</label>');
                              }
                              ")
  })

  measure_data <- eventReactive(input$runButton, {
    shinyjs::showElement(id = 'loading_radio')
    input$inv_mass

    })
  observe({
    if(input$calculationButton == "return" |
       input$calculationButton == "distance" |
       input$calculationButton == "wetdry"){
      shinyjs::showElement(id = 'loading_radio')
      proxy <- leaflet::leafletProxy("field_map")
      proxy |>
        ff_layer_returns(selected_return = selected_point$return_point_id) |>
        ff_layer_watersheds(selected_group = selected_point$group_id,
                            selected_return = selected_point$return_point_id) |>
        leaflet.extras2::addSpinner() |>
        leaflet.extras2::startSpinner() |>
        ff_layer_fields(selected_object = selected_point$object_id,
                        selected_group = selected_point$group_id,
                        selected_return = selected_point$return_point_id,
                        measure = input$calculationButton) |>
        leaflet::setView(lng = selected_point$long, lat = selected_point$lat, zoom = 11) |>
        leaflet.extras2::stopSpinner()
      shinyjs::hideElement(id = 'loading_radio')
    }else if (is.null(measure_data()) == FALSE){

      req(input$runButton)

      proxy <- leaflet::leafletProxy("field_map")
      proxy |>
        ff_layer_returns(selected_return = selected_point$return_point_id) |>
        ff_layer_watersheds(selected_group = selected_point$group_id,
                            selected_return = selected_point$return_point_id) |>
        leaflet.extras2::addSpinner() |>
        leaflet.extras2::startSpinner() |>
        ff_layer_fields(selected_object = selected_point$object_id,
                        selected_group = selected_point$group_id,
                        selected_return = selected_point$return_point_id,
                        measure = "invmass",
                        inv_mass_days = measure_data()) |>
        # leaflet::addLayersControl(overlayGroups = c("Fields", "Watersheds"), position = "topleft") |>
        leaflet::setView(lng = selected_point$long, lat = selected_point$lat, zoom = 11) |>
        leaflet.extras2::stopSpinner()
      shinyjs::hideElement(id = 'loading_radio')
    }

  })

  observeEvent(input$field_map_groups, {
    proxy <- leaflet::leafletProxy("field_map") |>
      leaflet::removeControl(layerId=c("legend_watersheds", "legend_wetdry"))
    if ("wetdry" %in% input$field_map_groups){
      proxy <- proxy |>
        leaflet::removeControl(layerId="legend_watersheds") |>
        addLegend("topright",
                  colors = c("#FFE4B5", "#66CDAA"),
                  labels = c("Dry (behind levee)","Wet (active floodplain)"),
                  title = "Production area<br />wet vs. dry sides",
                  opacity = 1,
                  layerId = "legend_wetdry",
                  group = "wetdry"
        )
    } else if ("watersheds" %in% input$field_map_groups){
      proxy <- proxy |>
        leaflet::removeControl(layerId="legend_wetdry") |>
        addLegend("topright",
                  pal = leaflet::colorFactor(palette = c("#ADD8E6", "#FFB6C1", "#FFE4B5"),
                                             levels = c("Direct", "Indirect", "Lateral")),
                  values=ff_watersheds_gcs$return_category,
                  title = "Watersheds<br />by return type",
                  opacity = 1,
                  layerId = "legend_watersheds",
                  group = "watersheds"
        )
    }else{
      proxy <- proxy |>
        leaflet::removeControl(layerId="legend_wetdry") |>
        leaflet::removeControl(layerId="legend_watersheds")
    }
  })

  downloader <- function(dataset, basename) {
    dh <- downloadHandler(
      filename = paste0(basename,".zip"),
      content = function(file) {
        if (length(Sys.glob(paste0(basename,".*"))>0)){
          file.remove(Sys.glob(paste0(basename,".*")))
        }
        if ("sf" %in% class(dataset)){
          sf::st_write(dataset, dsn=paste0(basename,".shp"), layer=basename, driver="ESRI Shapefile", overwrite_layer = T)
          readr::write_excel_csv(dataset |> sf::st_drop_geometry(), paste0(basename,".csv"))
        } else if ("data.frame" %in% class(dataset)) {
          readr::write_excel_csv(dataset, paste0(basename,".csv"))
        }
        if (file.exists(paste0("xml/",basename,".shp.xml"))){
          file.copy(paste0("xml/",basename,".shp.xml"), paste0(basename,".shp.xml"))
        }
        zip::zip(zipfile=paste0(basename,".zip"), files=Sys.glob(paste0(basename,".*")))
        file.copy(paste0(basename,".zip"), file)
        if (length(Sys.glob(paste0(basename,".*")))>0){
          file.remove(Sys.glob(paste0(basename,".*")))
        }}
    )
    return(dh)
  }

  output$download_streams <- downloader(ff_streams, "fishFoodMWD_streams")
  output$download_fields <- downloader(ff_fields, "fishFoodMWD_fields")
  output$download_watersheds <- downloader(ff_watersheds, "fishFoodMWD_watersheds")
  output$download_canals <- downloader(ff_canals, "fishFoodMWD_canals")
  output$download_returns <- downloader(ff_returns, "fishFoodMWD_returns")
  output$download_distances <- downloader(ff_distances, "fishFoodMWD_distances")
  output$download_wetdry <- downloader(ff_wetdry, "fishFoodMWD_wetdry")

}
