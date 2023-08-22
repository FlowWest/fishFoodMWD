function(input, output, session){
  county_pal <- colorFactor(palette = "viridis", domain = fields_watersheds$county)
  ret_pal <- colorFactor(palette = c("orange", "turquoise"), domain = fields_returns$return_direct, na.color = "#808080")
  dist_pal <- colorNumeric(palette = "Blues", domain = fields_distances$totdist_mi)


  # using a rective ID option
  selected_point <- reactiveVal()

  observeEvent(input$field_map_shape_click, {
    if (!is.null(input$field_map_shape_click$id)) {
      selected_point(input$field_map_shape_click$id)
    }
  })

  # reset the map
  observeEvent(input$resetButton, {
    selected_point(NULL)
  })

  output$field_map <- renderLeaflet({
    ff_make_leaflet(sf::st_bbox(ff_fields_gcs)) |>
      ff_layer_fields()
  })

  observe({
    proxy <- leaflet::leafletProxy("field_map")

    if (!is.null(input$field_map_shape_click$id)) {
      cat("map marker was clicked\n")
      cat("click has id: ", input$field_map_shape_click$id, "\n")
      proxy |>
        ff_layer_fields(return = input$field_map_shape_click$id)
    } else {
      proxy |>
        ff_layer_fields()
    }
  })
}
