# map_tab_ui <- tabPanel(title= "Map")

shinyUI(
  navbarPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    title = "fishFood MWD Dashboard",
    id = "tabs",
    collapsible = TRUE,
    tabPanel("Map"),
    sidebarPanel(
      width = 2,
      tags$h2("Map Controls"),
      br(),
      br(),
      radioButtons(
        "calculationButton",
        "Check calculation of interest:",
        c("Return" = "return",
          "Distance" = "distance",
          "Invertebrate Mass Days" = "invmass"
          )
      ),
      conditionalPanel(
        condition = "input.calculationButton == 'invmass'",
        numericInput(
          "invmass",
          "Input the number of days to calculate the invertebrate mass production:",
          1,
          min = 1,
          max = 100)
      ),
      br(),
      actionButton('runButton' ,'Submit Calculation'),
      br(),
      br(),
      actionButton(
        "resetButton",
        "Reset Map",
      ),
      div(id = 'loading_radio', p("Loading data, please wait..."), style = "display: none;"),
      # div(id = 'loading_action', p("Loading data, please wait..."), style = "display: none;"),  # Hidden by default
    ),
    mainPanel(
      width = 10, # main width plus sidebar width should add to 12
      shinyjs::useShinyjs(),  # Initialize shinyjs
      shinycssloaders::withSpinner(leafletOutput("field_map"))
    )
  )
)

