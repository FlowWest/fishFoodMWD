#' @title Launch App
#' @description `run_app()` launches a shiny application that allows the user to
#' enter data to the run fishFoodMWD functions.
#' @details the fishFoodMWD application can be run when the user has a dataset that they want to visualize.
#' @examples
#' fishFoodMWD::run_app()
#' @md
#' @export
run_app <- function() {
  appDir <- system.file("app", package = "fishFoodMWD")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `fishFoodMWD`.", call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal")
}
