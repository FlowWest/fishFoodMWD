function(input, output, session){

  output$field_map <- renderLeaflet({
      leaflet() |>
        addProviderTiles(providers$Esri.WorldImagery,
                         options = providerTileOptions(noWrap = TRUE)) |>
        addMapPane("overlay", zIndex = 420) |>
        addMapPane('underlay', zIndex = 410) |>
        # setView(lng = -121.313718,
        #         lat = 38.425859,
        #         zoom = 8) |>
        setView(lng = -121.513718,
                lat = 39.125859,
                zoom = 10) |>
        addPolygons(
          data = fields_watersheds,
          fillOpacity = .2,
          fillColor = ~watershed_name,
          # fillColor = "#28b62c",
          opacity = 0.5,
          dashArray = "3",
          group = "default_fields",
          popup = as.character(paste(
            "County:", fishFoodMWD::ff_fields_gcs$county,
            "<br>",
            "Area in acres:", fishFoodMWD::ff_fields_gcs$area_ac,
            "<br>",
            "Inundated volume of the rice field:", fishFoodMWD::ff_fields_gcs$volume_af)),
          label = "FIELDS",
          highlightOptions = highlightOptions(
            weight = 3,
            color = "#FDD20E",
            dashArray = "",
            fillOpacity = 1,
            bringToFront = TRUE
          ),
          layerId = ~unique_id
        )
      })
    selectedID <- reactiveValues(id = NULL)
    observeEvent(input$field_map_shape_click, {
      selectedID$id <- input$field_map_shape_click$id
      if(is.null(input$field_map_shape_click$id)){
        return (NULL)
      }
    })

    selected_field <- reactive({
      req(selectedID$id)
      fishFoodMWD::ff_fields_gcs |>
        filter(unique_id == selectedID$id)
    })

    observeEvent(selected_field(), {
      print(selected_field())
      leafletProxy("field_map") %>%
        clearGroup("default_fields")%>%
        addPolygons(
          data = selected_field(),
          fillOpacity = .8,
          weight = 2,
          color = "#2e2e2e",
          fillColor = "#28b62c",
          opacity = 1,
          group = "selected_field"
        )
    })
    observeEvent(input$resetButton,{
      req(selectedID$id)
      selectedID$id <- NULL
      leafletProxy("field_map") %>%
        clearGroup("selected_field")%>%
        addPolygons(
          data = fishFoodMWD::ff_fields_gcs,
          fillOpacity = .8,
          weight = 2,
          color = "#2e2e2e",
          fillColor = "#28b62c",
          opacity = 1,
          group = "default_fields",
          layerId = ~unique_id
        )
    })
}
