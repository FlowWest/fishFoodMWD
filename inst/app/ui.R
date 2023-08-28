# map_tab_ui <- tabPanel(title= "Map")

shinyUI(
  navbarPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    title = "fishFood MWD Dashboard",
    id = "tabs",
    collapsible = TRUE,
    tabPanel("Map"),
    sidebarPanel(
      width = 3,
      tags$h2("Map Controls"),
      div(id = 'mapControls',
          radioButtons(
            "calculationButton",
            "Select rice field attribute to display:",
            c("Return Type" = "return",
              "Distance" = "distance",
              "Wet/Dry" = "wetdry",
              "Invertebrate Mass Days" = "invmass"
            )
          ),
          conditionalPanel(id = "invmassControlPanel",
            condition = "input.calculationButton == 'invmass'",
            numericInput(
              "inv_mass",
              "Input the number of days to calculate the invertebrate mass production:",
              1,
              min = 1,
              max = 100),
            actionButton('runButton' ,'Update Map')),
      ),
      div(id = 'filter_guidance', "Click a watershed, return point, or rice field to filter.", class="sidebar-message"),
      actionButton("resetButton", "Reset Map"),
      div(id = 'reset_guidance', "Click the map background to reset all filters.", style = "display: none;", class="sidebar-message"),
      div(id = 'loading_radio', "Loading data, please wait...", style = "display: none;", class="sidebar-message"),
    ),
    mainPanel(
      width = 9, # main width plus sidebar width should add to 12
      shinyjs::useShinyjs(),  # Initialize shinyjs
      shinycssloaders::withSpinner(leafletOutput("field_map"))
    )
  )
)

