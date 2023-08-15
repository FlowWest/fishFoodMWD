function(input, output, session){
  output$fishfood_map <- renderLeaflet({
    if (input$functions == "calc_inv_mass"){
      fishfood_map <- leaflet() |>
        addProviderTiles(providers$Esri.WorldImagery,
                         options = providerTileOptions(noWrap = TRUE)) |>
        addMapPane("overlay", zIndex = 420) |>
        addMapPane('underlay', zIndex = 410) |>
        setView(lng = -121.313718,
                lat = 38.425859,
                zoom = 8)
    }
  })
}
