map_tab_ui <- tabPanel(title= "Map")

shinyUI(
  navbarPage(
    tags$style('body {font-family: Inter;}'),
    title = "fishFood MWD Dashboard",
    id = "tabs",
    collapsible = TRUE,
    tabPanel("Map"),
    sidebarPanel(
      width = 3,
      radioButtons(
        "field",
        "Click on Fields to access information about a rice field's return:",
        c(
          "Fields" = "fields"
        )
      ),
      selectInput(
        "joint_by",
        "Select rice field's associated information:",
        c(
          "Watersheds" = "Watersheds",
          'Returns' = "Returns",
          'Distances' = "Distances"
        )
    )
    ),
    mainPanel(
      leafletOutput("field_map", width = "155vh", height = "100vh")
    )
  )
)

