#' @name calc_inv_mass
#' @title Calculate invertebrate mass
#' @description Calculates invertebrate mass (grams) based on field acreage. Requires input of the fields data frame with area_ac attribute. Returns the data frame with additional columns for calculated values. Can be chained with pipes.
#' @param df An `sf` dataset, such as the provided dataframe `fields`, which includes an attribute area_ac containing the field area in acres. Also works with an ordinary data.frame or tibble.
#' @param day The day number for which to calculate the invertebrate mass.
#' @importClassesFrom sf sf
#' @export
#' @examples
#' # calculate the invertebrate mass after 14 days for each field
#' fields |> head(1) |> calc_inv_mass(14)
#' @md
calc_inv_mass <- function(df, day) {
  df$area_m2 = df$area_ac / 4047
  df$daily_prod_g = df$area_m2 * 0.186
  df$total_prod_g = df$daily_prod_g * day
  return(df)
}

#' @name calc_inv_mass_ts
#' @title Calculate invertebrate mass time series
#' @description A wrapper for `calc_inv_mass` that runs the calculation for a series of elapsed days from 1 to `ndays`. Returns a data frame with total invertebrate mass (grams) by field `unique_id` and `day`.
#' @param df An `sf` dataset, such as the provided dataframe `fields`, which includes an attribute area_ac containing the field area in acres. Also works with an ordinary data.frame or tibble.
#' @param ndays The total number of days over which to conduct the mass calculation. A sequence of days from 1 to `ndays` is fed into the `day` parameter of the `calc_inv_mass` function.
#' @importClassesFrom sf sf
#' @export
#' @examples
#' # calculate the invertebrate mass time series
#' fields |> calc_inv_mass_ts(14)
#'
#' # calculate the invertebrate mass time series for a particular field
#' fields |> dplyr::filter(unique_id=="1103539") |> calc_inv_mass_ts(14)
#' @md
calc_inv_mass_ts <- function(df, ndays) {
  tibble::as_tibble_col(seq(1, ndays), column_name = "day") |>
    dplyr::mutate(result = purrr::map(day,
                        function(x){
                          calc_inv_mass(
                            sf::st_drop_geometry(df), x) |>
                            dplyr::select(unique_id, total_prod_g)
                          }
                        )) |>
    tidyr::unnest(cols = c(result))
}
