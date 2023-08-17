add_polygons <- function(map, data, color fill_color, fill_opacity=0.4, bring_to_front=TRUE, popup, layer="underlay"){
  leaflet::addPolygons(
    map = map,
    data = data,
    weight = 3,
    opacity = 1,
    dashArray = "6",
    fillColor = fill_color,
    color = color,
    fillOpacity = fill_opacity,
    highlightOptions = highlightOptions(
      weight = 3,
      color = "#FDD20E",
      dashArray = "",
      fillOpacity = fill_opacity,
      bringToFront = bring_to_front
    ),
    popup = popup,
    # label = label,
    labelOptions = labelOptions(
      textsize = "11px"
    ),
    options = pathOptions(pane = layer)
  )

}
