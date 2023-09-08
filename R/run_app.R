#' @title Launch App
#' @description `run_app()` launches a shiny application that allows the user to
#' enter data to the run riceflows4ff functions.
#' @details The riceflows4ff application can be run when the user has a dataset that they want to visualize.
#' @examples
#' \dontrun{
#' riceflows4ff::run_app()
#' }
#' @md
#' @export
run_app <- function() {
  appDir <- system.file("app", package = "riceflows4ff")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `riceflows4ff`.", call. = FALSE)
  }
  shiny::runApp(appDir, display.mode = "normal")
}
