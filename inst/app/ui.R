map_tab_ui <- tabPanel(title= "Map")

shinyUI(
  navbarPage(
    tags$style('body {font-family: Inter;}'),
    title = "fishFood MWD Dashboard",
    id = "tabs",
    collapsible = TRUE,
    tabPanel("Map"),
    sidebarPanel(
      width = 2,
      actionButton(
        "resetButton",
        "Reset",
      ),
    ),
    mainPanel(
      shinycssloaders::withSpinner(leafletOutput("field_map", width = "155vh", height = "100vh"))
    )
  )
)

