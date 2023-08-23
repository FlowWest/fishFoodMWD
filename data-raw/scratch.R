geom <- st_coordinates(ff_fields_gcs$geometry)
fields_watersheds <- ff_fields_gcs |>
  left_join(st_drop_geometry(ff_watersheds_gcs), by="group_id")

fields_returns <- fields_watersheds |>
  left_join(st_drop_geometry(ff_returns), by="return_id")
fields_distances <- fields_watersheds |>
  left_join(ff_distances, by="unique_id")

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
    fillColor = ~county_pal(county),
    # fillColor = "#28b62c",
    fillOpacity = 1,
    weight = 2,
    color = "#2e2e2e",
    # fillColor = "#28b62c",
    opacity = 1,
    dashArray = "3",
    group = "default_fields",
    label = as.character(paste(
      "County:", fields_watersheds$county)),
    # 0           "Area in acres:", fields_watersheds$area_ac,
    # "Inundated volume of the rice field:", fields_watersheds$volume_af)),
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#FDD20E",
      dashArray = "",
      fillOpacity = 1,
      fillColor = "#FDD20E",
      bringToFront = TRUE
    ),
    layerId = ~unique_id
  ) |>
  addPolylines(
    data = ff_canals_gcs,
    weight = 1.5,
    color = "orange",
    group = "canals",
    label = "Secondary canals"

  ) |>
  addPolylines(
    data = ff_streams_gcs,
    weight = 1.5,
    color = "turquoise",
    group = "streams",
    label = "Fish bearing streams"
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
  fields_watersheds |>
    filter(unique_id == selectedID$id)
})
selected_watershed <- reactive({
  req(selected_field)
  fields_returns |>
    filter(watershed_name == selected_field()$watershed_name)
})
selected_dist <- reactive({
  req(selected_field)
  fields_distances |>
    filter(watershed_name == selected_field()$watershed_name)
})

observeEvent(selected_field(), {
  print(selected_field())
  leafletProxy("field_map") %>%
    clearGroup("default_fields")%>%
    addPolygons(
      data = selected_field(),
      fillOpacity = 1,
      weight = 3,
      color = "#FFA500",
      # fillColor = ~groupColors(watershed_name),
      fillColor = "#FFA500",
      opacity = 1,
      group = "selected_field",
      popup = as.character(paste(
        "County:", fields_watersheds$county,
        "<br>",
        "Area in acres:", fields_watersheds$area_ac,
        "<br>",
        "Inundated volume of the rice field:", fields_watersheds$volume_af))
    ) |>
    addPolygons(
      data = selected_watershed(),
      fillOpacity = .5,
      weight = 1,
      color = ~ret_pal(return_direct),
      # fillColor = "#ADD8E6",
      fillColor = ~ret_pal(return_direct),
      opacity = 1,
      group = "selected_watershed",
      label = as.character(selected_watershed()$watershed_name),
      popup = as.character(paste(
        "County:", selected_watershed()$county,
        "<br>",
        "Area in acres:", selected_watershed()$area_ac,
        "<br>",
        "Inundated volume of the rice field:", selected_watershed()$volume_af,
        "<br>",
        "Return Direct:", selected_watershed()$return_direct))
    ) |>
    addPolygons(
      data = selected_dist(),
      fillOpacity = .5,
      weight = 1,
      color = ~dist_pal(totdist_mi),
      # fillColor = "#ADD8E6",
      fillColor = ~dist_pal(totdist_mi),
      opacity = 1,
      group = "selected_total_dist",
      label = as.character(selected_dist()$watershed_name),
      popup = as.character(paste(
        "County:", selected_dist()$county,
        "<br>",
        "Area in acres:", selected_dist()$area_ac,
        "<br>",
        "Inundated volume of the rice field:", selected_dist()$volume_af,
        "<br>",
        "Total Distance:", selected_dist()$totdist_mi))
    ) |>
    addLegend(
      data = selected_watershed(),
      "bottomright",
      pal = ret_pal,
      values = ~return_direct,
      title = "Return Direct",
      opacity = 1,
      group = "ret_legend"
    ) |>
    addLegend(
      data = selected_dist(),
      "bottomleft",
      pal = dist_pal,
      values = ~totdist_mi,
      title = "Total Distance",
      opacity = 1,
      group = "dist_legend"
    ) |>
    addLayersControl(
      overlayGroups = c("selected_field", "selected_watershed", "selected_total_dist"),
      options = layersControlOptions(collapsed = FALSE)
    )
})
observeEvent(input$resetButton,{
  req(selectedID$id)
  selectedID$id <- NULL
  print("Clearing")
  leafletProxy("field_map") %>%
    # clearControls() |>
    clearGroup(c("selected_watershed", "selected_field", "selected_total_dist")) |>
    addPolygons(
      data = fields_watersheds,
      fillOpacity = .8,
      weight = 2,
      color = "#2e2e2e",
      fillColor = ~county_pal(county),
      # fillColor = "#28b62c",
      opacity = 1,
      group = "default_fields",
      layerId = ~unique_id,
      label = as.character(paste(
        "County:", fields_watersheds$county))
      # "Area in acres:", fields_watersheds$area_ac,
      # "<br>",
      # "Inundated volume of the rice field:", fields_watersheds$volume_af)),
    )
