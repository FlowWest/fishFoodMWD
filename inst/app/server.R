function(input, output, session){
  county_pal <- colorFactor(palette = "viridis", domain = fields_watersheds$county)
  ret_pal <- colorFactor(palette = c("orange", "turquoise"), domain = fields_returns$return_direct, na.color = "#808080")
  dist_pal <- colorNumeric(palette = "Blues", domain = fields_distances$totdist_mi)


  # using a rective ID option
  selected_point <- reactiveValues(object_id = NULL, return_point_id = NULL, group_id = NULL)

  observeEvent(input$field_map_shape_click, {
    if (!is.null(input$field_map_shape_click$id)) {
      val <- ff_fields_joined_gcs |>
        filter(object_id == input$field_map_shape_click$id) |>
        select(return_id, group_id)

      selected_point$object_id <- input$field_map_shape_click$id
      selected_point$group_id <- val$group_id
      selected_point$return_point_id <- val$return_id

      cat(unlist(selected_point$return_point_id))
      cat(unlist(selected_point$object_id))
      cat(unlist(selected_point$group_id))
    }
  })

  # reset the map
  observeEvent(input$resetButton, {
    selected_point$object_id <- NULL
    selected_point$group_id <- NULL
    selected_point$return_point_id <- NULL
  })

  output$field_map <- renderLeaflet({
    ff_make_leaflet(sf::st_bbox(ff_fields_gcs)) |>
      ff_layer_streams() |>
      ff_layer_canals()
  })

  observe({
    proxy <- leaflet::leafletProxy("field_map")

      proxy |>
        ff_layer_fields(selected_object = selected_point$object_id) |>
        ff_layer_returns(selected_return = selected_point$return_point_id) |>
        ff_layer_watersheds(selected_group = selected_point$group_id)
  })
}
