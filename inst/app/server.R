function(input, output, session){
  county_pal <- colorFactor(palette = "viridis", domain = fields_watersheds$county)
  ret_pal <- colorFactor(palette = c("orange", "turquoise"), domain = fields_returns$return_direct, na.color = "#808080")
  dist_pal <- colorNumeric(palette = "Blues", domain = fields_distances$totdist_mi)

  output$field_map <- renderLeaflet({
    base <- ff_make_leaflet(sf::st_bbox(ff_fields_gcs))

    base |>
      ff_layer_fields()
  })
}
