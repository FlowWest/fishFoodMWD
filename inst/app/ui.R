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
      selectInput(
        "functions",
        "Select a function to run the calculation:",
        c(
          "calc_inv_mass" = "calc_inv_mass",
          "calc_inv_mass_ts" = "calc_inv_mass_ts"
        )
      )
    ),
    mainPanel(
      leafletOutput("fishfood_map", width = "155vh", height = "100vh")
    )
  )
)
