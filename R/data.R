#' @name ff_returns
#' @title Return points
#' @description This `sf` dataset contains the point locations of outlets for return flow from rice field drainage networks into adjacent canals or streams.
#' @details
#' This dataset contains a combination of pump export locations and apparent watershed drainage network points. Pump export locations were obtained from multiple sources, including, reclamation districts, irrigation and drainage districts, and Trout Unlimited. The remainder of the locations were digitized by FlowWest using a combination of aerial imagery, drainage network and watershed information, and professional judgement.
#' * `return_id` = the unique identifier of the return point
#' * `return_name` = the name of the return for identification
#' * `return_direct` = "Direct" if directly connected to a salmonid rearing stream, else "Indirect"
#' * `water_sup` = the apparent water supply of the return
#' * `ds_return_id` = for Indirect returns, the `return_id` of the downstream return that this return flows into, else the identifier of this same return if it directly flows into a salmonid rearing stream. (i.e., if the return is on a salmonid rearing stream, the `return_id` and `ds_return_id` will be identical. If the point of return is in a canal or secondary drainage, upstream of salmonid rearing stream, this number will identify the location at which this secondary drainage enters a fish bearing stream.)
#' * `ds_fbs_dist` = for Indirect returns, the distance from this return to the downstream return to a salmonid rearing stream, else zero
#' * `ds_fbs_name` = name of the salmonid rearing stream that the return drains directly or indirectly into
#' @md
#' @source [Bethany Hackenjos](mailto:bhackenjos@flowwest.com), [Aidan Kelleher](mailto:akelleher@flowwest.com), [Skyler Lewis](mailto:slewis@flowwest.com), FlowWest, 2023.
#' @examples
#' head(ff_returns)
#'
#' plot(ff_returns$geometry)
"ff_returns"
#'
#' @name ff_watersheds
#' @title Watersheds
#' @description This `sf` dataset contains watershed polygons used to group rice fields and organize flow patterns. Based on HUC10 watersheds, but split in some cases where necessary.
#' @details
#' * `group_id` = the unique identifier of the watershed group, which is based on the HUC10
#' * `return_id` = the corresponding unique identifier of the return point, used to join to the `returns` dataset. For watersheds with a `return_id` of zero, fields are assumed to flow laterally into the nearest major stream rather than via the return point.
#' * `huc10` = the original HUC10 identifier from the NHD dataset
#' * `watershed_name` = the original HUC10 common name from the NHD dataset
#' @md
#' @source Developed by [Bethany Hackenjos](mailto:bhackenjos@flowwest.com), FlowWest, 2023, based on USGS NHD/Watershed Boundary Dataset.
#' @examples
#' head(ff_watersheds)
#'
#' plot(ff_watersheds$geometry)
"ff_watersheds"
#'
#' @name ff_fields
#' @title Rice field geometries
#' @description This `sf` dataset contains polygon geometries of rice fields based on DWR i15 crop mapping from 2019.
#' @details
#' * `unique_id` = the unique identifier of the rice field as defined in the original CNRA dataset
#' * `group_id` = the unique identifier of the watershed group, obtained via spatial join, used to join to the `watersheds` dataset
#' * `county` = common name of the county in which th erice field is located
#' * `elev_grp` = an elevation interval
#' * `area_ac` = area of the rice field polygon calculated in acres
#' * `volume_af` = inundated volume of the rice field assuming 5 inches of water
#' @md
#' @source Developed by [Bethany Hackenjos](mailto:bhackenjos@flowwest.com), [Aidan Kelleher](mailto:akelleher@flowwest.com), [Skyler Lewis](mailto:slewis@flowwest.com), FlowWest, 2023, based on California Department of Water Resources & Land IQ [i15 Crop Mapping 2019](https://gis.data.ca.gov/datasets/363c00277ad74c4ba4f64238edc5430c_0)
#' @examples
#' head(ff_fields)
#'
#' plot(ff_fields$geometry)
"ff_fields"
#'
#' @name ff_distances
#' @title Rice field distance attributes
#' @description A data frame containing the results of the FlowWest analysis of flow distances to the nearest salmonid rearing stream. Intended to be joined to the `fields` dataset.
#' @details
#' * `unique_id` = the unique identifier of the rice field as defined in the original CNRA dataset
#' * `return_id` = the return point from the `returns` dataset used in the distance calculation for this rice field, as determined based on watershed in which the field is located.  For watersheds with a `return_id` of zero, fields are assumed to flow laterally into the nearest major stream rather than via the return point
#' * `ds_fbs_dist` = for fields flowing into "Indirect" return points, this is the downstream flow distance from the return point to the nearest salmonid rearing stream, else zero
#' * `return_dis` = linear distance from the centroid of the rice field to the return point (or laterally to the nearest salmonid rearing stream)
#' * `return_rec` = rectangular grid distance from the centroid of the rice field to the return point (or laterally to the nearest salmonid rearing stream)
#' * `totdist_ft` = total distance from the rice field to the nearest salmonid rearing stream, calculated via `ds_fbs_dist` + `return_dis` using linear distances
#' * `totrect_ft` = total distance from the rice field to the nearest salmonid rearing stream, calculated via `ds_fbs_dist` + `return_rec` using rectangular grid distances
#' * `totdist_mi` = `totdist_ft` converted to miles
#' * `totrect_mi` = `totrect_ft` converted to miles
#' * `wet_dry` =  of the rice field as on theidentifier wet or dry side of the levee
#' @md
#' @source [Skyler Lewis](mailto:slewis@flowwest.com), [Bethany Hackenjos](mailto:bhackenjos@flowwest.com), FlowWest, 2023.
#' @importClassesFrom tibble tbl_df
#' @examples
#' head(ff_distances)
"ff_distances"
#'
#' @name ff_streams
#' @title Salmonid rearing streams
#' @description Supplementary `sf` geometry layer containing the salmonid rearing streams used to calculate flow distances
#' @source FlowWest; modified from CVPIA rearing habitat
#' @examples
#' head(ff_streams)
#'
#' plot(ff_streams$geometry)
"ff_streams"
#'
#' @name ff_canals
#' @title Canals connecting indirect return points to salmonid rearing streams
#' @description Supplementary `sf` geometry layer containing the non-salmonid rearing streams and canals used to calculate the flow distances from indirect return points to their nearest salmonid rearing stream (in the `ds_fbs_dist` attribute of `returns`)
#' @source FlowWest; modified from USGS National Hydrography Dataset
#' @examples
#' head(ff_canals)
#'
#' plot(ff_canals$geometry)
"ff_canals"

#' @name ff_wetdry
#' @title Sacramento Valley wet and dry areas
#' @description This `sf` dataset contains polygons identifying which parts of the Sacramento Valley, within the project area, are behind levees ("dry") or directly exposed to rivers or floodways ("wet")
#' @details
#' * `wet_dry` = identifier of the enclosed area as "wet" or "dry"
#' * `area_name` = name given to the area defined by the polygon
#' * `source` = source of the polygon and determination of hydrology (wet or dry)
#' @md
#' @source [Aidan Kelleher](mailto:akelleher@flowwest.com), [Bethany Hackenjos](mailto:bhackenjos@flowwest.com), FlowWest, 2023, compiled from data from Ducks Unlimited and others.
#' @examples
#' head(ff_wetdry)
#'
#' plot(ff_wetdry)
"ff_wetdry"

#' @name ff_aoi
#' @title Project boundary
#' @description This `sf` dataset contains a polygon defining the project for this analysis. Covers 7 Counties:  Butte, Colusa, Glenn, Placer, Sutter, Yolo, and Yuba.
#' @details
#' * West boundary determined by Tehema canal from the top of Glenn county border until Yolo County border.
#' * South boundary follows Yolo County until its intersection of Placer County and follows rice fields until the intersection of Yuba and Placer County at the Camp Far West Reservoir.
#' * East boundary follows the Yuba County border until it intersects with the Yuba River, then follows the rice fields until Highway 99. Following highway 99 until it reaches the top of Butte County Boundary.
#' * North boundary begins at the intersection of Tehema Canal and Glenn County Boundary, following the boundary right until it intersects Butte County Boundary. Following Butte County Boundary north until the intersection of highway 99.
#'
#' @md
#' @source [Aidan Kelleher](mailto:akelleher@flowwest.com), [Bethany Hackenjos](mailto:bhackenjos@flowwest.com), FlowWest, 2023.
#' @examples
#' head(ff_aoi)
#'
#' plot(ff_aoi)
"ff_aoi"
