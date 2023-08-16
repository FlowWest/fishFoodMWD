#' @name returns
#' @title Return points
#' @description This `sf` dataset contains the point locations of outlets for return flow from rice field drainage networks into adjacent canals or streams.
#' @details
#' * `return_id` = the unique identifier of the return point
#' * `return_name` = the name of the return
#' * `return_direct` = "Direct" if directly connected to a fish-bearing stream, else "Indirect"
#' * `ds_fbs_dist` = for Indirect returns, the distance to the downstream return to a fish-bearing stream, else zero
#' * `ds_return_id` = for Indirect returns, the `return_id` of the downstream return that this return flows into, else the identifier of this same return if it directly flows into a fish-bearing stream
#' * `ds_fbs_name` = name of the fish-bearing stream that the return drains directly or indirectly into
#' @md
#' @source FlowWest
#' @examples
#' head(returns)
#'
#' plot(returns$geometry)
"returns"
#'
#' @name watersheds
#' @title Watersheds
#' @description This `sf` dataset contains watershed polygons used to group rice fields and organize flow patterns. Based on HUC10 watersheds, but split in some cases where necessary.
#' @details
#' * `group_id` = the unique identifier of the watershed group, which is based on the HUC10
#' * `return_id` = the corresponding unique identifier of the return point, used to join to the `returns` dataset. For watersheds with a `return_id` of zero, fields are assumed to flow laterally into the nearest major stream rather than via the return point.
#' * `huc10` = the original HUC10 identifier from the NHD dataset
#' * `watershed_name` = the original HUC10 common name from the NHD dataset
#' @md
#' @source NHD; FlowWest
#' @examples
#' head(watersheds)
#'
#' plot(watersheds$geometry)
"watersheds"
#'
#' @name fields
#' @title Rice field geometries
#' @description This `sf` dataset contains polygon geometries of rice fields based on crop mapping from YYYY.
#' @details
#' * `unique_id` = the unique identifier of the rice field as defined in the original CNRA dataset
#' * `group_id` = the unique identifier of the watershed group, obtained via spatial join, used to join to the `watersheds` dataset
#' * `county` = common name of the county in which th erice field is located
#' * `area_ac` = area of the rice field polygon calculated in acres
#' * `volume_af` = inundated volume of the rice field assuming 5 inches of water
#' @md
#' @source California Department of Water Resources Land Use Program - i15 Crop Mapping YYYY; FlowWest
#' @examples
#' head(fields)
#'
#' plot(fields$geometry)
"fields"
#'
#' @name distances
#' @title Rice field distance attributes
#' @description A data frame containing the results of the FlowWest analysis of flow distances to the nearest fish-bearing stream. Intended to be joined to the `fields` dataset.
#' @details
#' * `unique_id` = the unique identifier of the rice field as defined in the original CNRA dataset
#' * `return_id` = the return point from the `returns` dataset used in the distance calculation for this rice field, as determined based on watershed in which the field is located.  For watersheds with a `return_id` of zero, fields are assumed to flow laterally into the nearest major stream rather than via the return point
#' * `ds_fbs_dist` = for fields flowing into "Indirect" return points, this is the downstream flow distance from the return point to the nearest fish-bearing stream, else zero
#' * `return_dis` = linear distance from the centroid of the rice field to the return point (or laterally to the nearest fish-bearing stream)
#' * `return_rec` = rectangular grid distance from the centroid of the rice field to the return point (or laterally to the nearest fish-bearing stream)
#' * `totdist_ft` = total distance from the rice field to the nearest fish-bearing stream, calculated via `ds_fbs_dist` + `return_dis` using linear distances
#' * `totrect_ft` = total distance from the rice field to the nearest fish-bearing stream, calculated via `ds_fbs_dist` + `return_rec` using rectangular grid distances
#' * `totdist_mi` = `totdist_ft` converted to miles
#' * `totrect_mi` = `totrect_ft` converted to miles
#' * `wet_dry` = identifier of the rice field as on the wet or dry side of the levee
#' @md
#' @source FlowWest
#' @importClassesFrom tibble tbl_df
#' @examples
#' head(distances)
"distances"
#'
#' @name streams
#' @title Fish-bearing streams
#' @description Supplementary `sf` geometry layer containing the fish-bearing streams used to calculate flow distances
#' @source Modified from CVPIA rearing habitat
#' @examples
#' head(streams)
#'
#' plot(streams$geometry)
"streams"
#'
#' @name canals
#' @title Canals connecting indirect return points to fish-bearing streams
#' @description Supplementary `sf` geometry layer containing the non-fish-bearing streams and canals used to calculate the flow distances from indirect return points to their nearest fish-bearing stream (in the `ds_fbs_dist` attribute of `returns`)
#' @source NHD; FlowWest
#' @examples
#' head(canals)
#'
#' plot(canals$geometry)
"canals"

#' @name wetdry
#' @title Sacramento Valley wet and dry areas
#' @description This `sf` dataset contains polygons identifying which parts of the Sacramento Valley are behind levees ("dry") or directly exposed to rivers or floodways ("wet")
#' @details
#' * `wet_dry` = identifier of the enclosed area as "wet" or "dry"
#' @md
#' @source compiled from data from Ducks Unlimited and others
#' @examples
#' head(wetdry)
#'
#' plot(wetdry)
"wetdry"
