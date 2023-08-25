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
      ff_layer_canals()
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
        leaflet::addLayersControl(overlayGroups = c("watersheds", "fields"), position = "topleft") |>
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
}
