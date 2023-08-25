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
        "Select rice field attribute to display:",
        c("Return Type" = "return",
          "Distance" = "distance",
          "Wet/Dry" = "wetdry",
          "Invertebrate Mass Days" = "invmass"
          )
      ),
      conditionalPanel(
        condition = "input.calculationButton == 'invmass'",
        numericInput(
          "inv_mass",
          "Input the number of days to calculate the invertebrate mass production:",
          1,
          min = 1,
          max = 100),
      br(),
      actionButton('runButton' ,'Update Map'),
      ),
      br(),
      br(),
      actionButton(
        "resetButton",
        "Reset Map",
      ),
      div(id = 'filter_guidance', p("Click a watershed, return point, or rice field to filter.")),
      div(id = 'reset_guidance', p("Click the map background to reset all filters."), style = "display: none;"),
      div(id = 'loading_radio', p("Loading data, please wait..."), style = "display: none;"),
    ),
    mainPanel(
      width = 10, # main width plus sidebar width should add to 12
      shinyjs::useShinyjs(),  # Initialize shinyjs
      shinycssloaders::withSpinner(leafletOutput("field_map"))
    )
  )
)

