#' @name calc_inv_mass
#' @title Calculate invertebrate mass
#' @description Calculates invertebrate mass (grams) based on field acreage. Requires input of the fields data frame with area_ac attribute. Returns the data frame with additional columns for calculated values. Can be chained with pipes.
#' @importFrom tidyverse
#' @importFrom sf
calc_inv_mass <- function(df, day) {
  df |>
    mutate(area_m2 = area_ac / 4047,
           daily_prod_g = area_m2 * 0.186,
           total_prod_g = daily_prod_g * day)
}

#' @name calc_inv_mass_ts
#' @title Calculate invertebrate mass time series
#' @description A wrapper for calc_inv_mass that runs the calculation for a series of elapsed days from 1 to ndays. Returns a data frame with total invertebrate mass (grams) by field unique_id and day.
#' @importFrom tidyverse
#' @importFrom sf
calc_inv_mass_ts <- function(df, ndays) {
  as_tibble_col(seq(1, ndays), column_name = "day") |>
    mutate(result = map(day,
                        function(x){
                          calc_inv_mass(
                            st_drop_geometry(df), x) |>
                            select(unique_id, total_prod_g)
                          }
                        )) |>
    unnest(cols = c(result))
}
