map_tab_ui <- tabPanel(title= "Map")

shinyUI(
  navbarPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
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
      width = 10, # main width plus sidebar width should add to 12
      leafletOutput("field_map"),
      shinyjs::useShinyjs(),  # Initialize shinyjs
      div(id = 'loading', p("Loading data, please wait..."), style = "display: none;")  # Hidden by default
    ),
    mainPanel(
      width = 10, # main width plus sidebar width should add to 12
      shinycssloaders::withSpinner(leafletOutput("field_map"))
    )
  )
)

