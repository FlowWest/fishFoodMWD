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
        data = fishFoodMWD::ff_fields_gcs,
        fillOpacity = .8,
        color = "#FBFAA2",
        fillColor = "#28b62c",
        opacity = 1,
        dashArray = "6",
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
        )
      )
    })
  selected_field <- reactive({
    p <- input$field_map_shape_click
    # print(p)
    pnt <- tibble(y=p$lat, x=p$lng) |>
      st_as_sf(coords=c('x', 'y'), crs=st_crs(fishFoodMWD::ff_fields_gcs))
    field_row_index <- st_within(pnt, fishFoodMWD::ff_fields_gcs)[[1]]

    fishFoodMWD::ff_fields_gcs[field_row_index, ]
  })


  observeEvent(input$field_map_shape_click, {
    p <- input$field_map_shape_click
    print(p)
    print(selected_field())
    # pnt <- tibble(y=p$lat, x=p$lng) |>
      # st_as_sf(coords=c('x', 'y'), crs=st_crs(fishFoodMWD::ff_fields_gcs))
    # field_id <- st_within(pnt, fishFoodMWD::ff_fields_gcs)[[1]]

    leafletProxy("field_map") %>%
      clearGroup("default_fields")%>%
      clearGroup('selected_field') %>%
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
}
