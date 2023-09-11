create_metadata_xml <- function(output_xml, title_text, summary_text, description_text, credits_text, fields_list, tags, sf_df, bbox){
  doc = XML::newXMLDoc()
  root = XML::newXMLNode("metadata", doc = doc) #, attrs=c("xml:lang" = "en"))
  dataIdInfo = XML::newXMLNode("dataIdInfo", parent = root)
  if (!missing(summary_text)){
    idPurp = XML::newXMLNode("idPurp", summary_text, parent = dataIdInfo)
  }
  if (!missing(title_text)){
    idCitation = XML::newXMLNode("idCitation", parent = dataIdInfo)
    resTitle = XML::newXMLNode("resTitle", title_text, parent = idCitation)
  }
  if (!missing(tags)) {
    searchKeys = XML::newXMLNode("searchKeys", parent = dataIdInfo)
    for (i in 1:length(tags)){
      keyword = XML::newXMLNode("keyword", tags[i], parent = searchKeys)
    }
  }
  if (!missing(description_text) | !missing(fields_list)) {
    if (!missing(description_text)){
      description_text_parsed <- description_text |> markdown::mark_html(template=FALSE)
    } else {
      description_text_parsed <- ""
    }
    if (!missing(fields_list)){
      fields_list_parsed <- paste0("<p><b>Fields:</b></p>","<ul>",
                                   paste0("<li><b>",names(fields_list),"</b> =",fields_list,"</li>",collapse=""),
                                   "</ul>",collapse="")
    } else {
      fields_list_parsed <- ""
    }
    idAbs = XML::newXMLNode("idAbs", paste0(description_text_parsed,fields_list_parsed,collapse=""), parent = dataIdInfo)
  }
  if (!missing(credits_text)) {
    idCredit = XML::newXMLNode("idCredit", credits_text, parent = dataIdInfo)
  }
  if (!missing(sf_df)) {
    if ("sf" %in% class(sf_df)) {
      bbox_gcs <- sf_df |> sf::st_transform("+proj=longlat +datum=WGS84") |> sf::st_bbox()
    }
  } else
  if (!missing(bbox)) {
    if (c("xmin", "xmax", "ymin", "ymax") %in% names(bbox)) {
      bbox_gcs <- bbox[c("xmin", "xmax", "ymin", "ymax")]
    }
  } else {
    bbox_gcs <- NULL
  }
  if (!is.null(bbox_gcs)) {
    dataExt = XML::newXMLNode("dataExt", parent = dataIdInfo)
    geoEle = XML::newXMLNode("geoEle", parent = dataExt)
    GeoBndBox = XML::newXMLNode("GeoBndBox", parent = geoEle, attrs=c("esriExtentType" = "search"))
    exTypeCode = XML::newXMLNode("exTypeCode", 1, parent = GeoBndBox) # 1 if "extent contains the resource
    westBL = XML::newXMLNode("westBL", bbox_gcs["xmin"], parent = GeoBndBox)
    eastBL = XML::newXMLNode("eastBL", bbox_gcs["xmax"], parent = GeoBndBox)
    northBL = XML::newXMLNode("northBL", bbox_gcs["ymax"], parent = GeoBndBox)
    southBL = XML::newXMLNode("southBL", bbox_gcs["ymin"], parent = GeoBndBox)
  }
  #return(doc)
  XML::saveXML(doc, file = output_xml)
}


###################
# CREATE METADATA #
###################

common_tags <- c("Sacramento Valley", "rice field", "salmonid", "habitat")

# RETURNS
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_returns.shp.xml",
                    title_text = "Return points",
                    summary_text = "Point locations of outlets for return flow from rice field drainage networks into adjacent canals or streams.",
                    tags = c(common_tags, "outlets", "outfalls", "returns", "confluence"),
                    description_text = "This dataset contains a combination of pump export locations and apparent watershed drainage network points. Pump export locations were obtained from multiple sources, including, reclamation districts, irrigation and drainage districts, and Trout Unlimited. The remainder of the locations were digitized by FlowWest using a combination of aerial imagery, drainage network and watershed information, and professional judgement.",
                    fields_list = c(
                      "return_id" = "the unique identifier of the return point",
                      "return_name" = "the name of the return",
                      "return_direct" = "'Direct' if directly connected to a salmonid rearing stream, else 'Indirect'",
                      "water_sup" = "the apparent water supply of the return",
                      "ds_return_id" = "for Indirect returns, the `return_id` of the downstream return that this return flows into, else the identifier of this same return if it directly flows into a salmonid rearing stream (i.e., if the return is on a salmonid rearing stream, the `return_id` and `ds_return_id` will be identical. If the point of return is in a canal or secondary drainage, upstream of salmonid rearing stream, this number will identify the location at which this secondary drainage enters a fish bearing stream.)",
                      "ds_fbs_dist" = "for Indirect returns, the distance from this return to the downstream return to a salmonid rearing stream, else zero",
                      "ds_fbs_name" = "name of the salmonid rearing stream that the return drains directly or indirectly into"
                    ),
                    credits = "Aidan Kelleher [akelleher@flowwest.com], Bethany Hackenjos [bhackenjos@flowwest.com], Skyler Lewis [slewis@flowwest.com], FlowWest, 2023",
                    sf_df = riceflows4ff::ff_returns,
)

# WATERSHEDS
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_watersheds.shp.xml",
                    title_text = "Watershed Groups",
                    summary_text = "Watershed polygons used to group rice fields and organize flow patterns. Based on HUC10 watersheds, but split in some cases where necessary.",
                    description_text = "Dataset started with HUC 10 shapefile from USGS, and split in locations as necessary to more accurately define distances to the nearest outfall return location or distance to nearest salmon rearing stream.",
                    fields_list = c(
                      "group_id" = "the unique identifier of the watershed group, which is based on the HUC10",
                      "return_id" = "the corresponding unique identifier of the return point, used to join to the `returns` dataset. For watersheds with a `return_id` of zero, fields are assumed to flow laterally into the nearest major stream rather than via the return point.",
                      "huc10" = "the original HUC10 identifier from the NHD dataset",
                      "watershed_name" = "the original HUC10 common name from the NHD dataset"
                    ),
                    tags = c(common_tags, "watersheds", "huc10", "groups"),
                    credits = "Bethany Hackenjos [bhackenjos@flowwest.com], FlowWest, 2023",
                    sf_df = riceflows4ff::ff_watersheds,
)

# FIELDS
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_fields.shp.xml",
                    title_text = "Rice field geometries",
                    summary_text = "Polygon geometries of rice fields based on DWR i15 crop mapping from 2019.",
                    description_text = paste(sep="\n",
                                             "Creating a spatial database of Sacramento Valley rice field drainage system conveyance characteristics and operations. This dataset shows all rice fields mapped as of 2019, categorized by watershed and elevation. Starting with the LandIQ 2019 crop mapping, the following steps were taken to create the file. Datasets used mentioned in the credits below.",
                                             "1. Filter out agriculture fields by MAIN-CROP = R1 (Rice)",
                                             "2. Crop dataset to only include fields within our project boundary.",
                                             "3. Create point feature using 'feature to point' geoprocessing tool, converting all rice fields into a point at the center of the polygon (centroid).",
                                             "4. Use 'Extract Values to Points' geoprocessing tool to assign an elevation value from the DEM raster to each rice field point feature.",
                                             "5. Spatial Join the rice field point feature dataset to the polygon features. Creating an elevation attribute for each rice field polygon.",
                                             "6. Group rice fields into elevation intervals of 10 ft. 0-10,10-20, 20-30...etc. (elev_grp)",
                                             "7. Apply HUC10 codes and watershed names to rice field polygons based on location. If fields were located in multiple watersheds, the centroid of the polygon was used to determine which watershed it belonged to. (HUC10, NAME)",
                                             "Elevation Units - ft",
                                             "Vertical Datum - North American Vertical Datum 1988"),
                    fields_list = c(
                      "unique_id" = "the unique identifier of the rice field as defined in the original CNRA dataset",
                      "group_id" = "the unique identifier of the watershed group, obtained via spatial join, used to join to the `watersheds` dataset",
                      "county" = "common name of the county in which th erice field is located",
                      "area_ac" = "area of the rice field polygon calculated in acres",
                      "volume_af" = "inundated volume of the rice field assuming 5 inches of water"
                    ),
                    tags = c(common_tags, "crops"),
                    credits = paste(sep="\n",
                                    "Aidan Kelleher [akelleher@flowwest.com], Bethany Hackenjos [bhackenjos@flowwest.com], FlowWest, 2023",
                                    "Original Datasets:",
                                    "i15 Crop Mapping dataset (2019) https://gis.data.ca.gov/datasets/363c00277ad74c4ba4f64238edc5430c_0/about (Land IQ was contracted by DWR to develop a comprehensive and accurate spatial land use database for the 2019 water year).",
                                    "HUC 10 watersheds via USGS Watershed Boundary Dataset https://www.usgs.gov/national-hydrography/access-national-hydrography-products",
                                    "CA DEM via USGS 1 arc-second Digital Elevation Model https://portal.opentopography.org/datasetMetadata?otCollectionID=OT.012021.4269.2")
                    ,
                    sf_df = riceflows4ff::ff_fields,
)

# DISTANCES
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_distances.csv.xml",
                    title_text = "Rice field distance attributes",
                    summary_text = "Results of the FlowWest analysis of flow distances to the nearest fish-bearing stream. Intended to be joined to the fields dataset.",
                    fields_list = c(
                      "unique_id" = "the unique identifier of the rice field as defined in the original CNRA dataset",
                      "return_id" = "the return point from the `returns` dataset used in the distance calculation for this rice field, as determined based on watershed in which the field is located.  For watersheds with a `return_id` of zero, fields are assumed to flow laterally into the nearest major stream rather than via the return point",
                      "ds_fbs_dist" = "for fields flowing into 'Indirect' return points, this is the downstream flow distance from the return point to the nearest fish-bearing stream, else zero",
                      "return_dis" = "linear distance from the centroid of the rice field to the return point (or laterally to the nearest fish-bearing stream)",
                      "return_rec" = "rectangular grid distance from the centroid of the rice field to the return point (or laterally to the nearest fish-bearing stream)",
                      "totdist_ft" = "total distance from the rice field to the nearest fish-bearing stream, calculated via `ds_fbs_dist` + `return_dis` using linear distances",
                      "totrect_ft" = "total distance from the rice field to the nearest fish-bearing stream, calculated via `ds_fbs_dist` + `return_rec` using rectangular grid distances",
                      "totdist_mi" = "`totdist_ft` converted to miles",
                      "totrect_ft" = "`totrect_ft` converted to miles",
                      "wet_dry" = "identifier of the rice field as on the wet or dry side of the levee"
                      ),
                    tags = c(common_tags, "distance"),
                    credits = "Skyler Lewis [slewis@flowwest.com], Bethany Hackenjos [bhackenjos@flowwest.com], FlowWest, 2023"
                    )

# STREAMS
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_streams.shp.xml",
                    title_text = "Fish-bearing streams",
                    summary_text = "Supplementary geometry layer containing the fish-bearing streams. Used to calculate flow distances.",
                    tags = c(common_tags, "flowlines", "streams", "rivers", "rearing"),
                    credits = "FlowWest; modified from CVPIA rearing habitat",
                    sf_df = riceflows4ff::ff_streams,
)

# CANALS
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_canals.shp.xml",
                    title_text = "Secondary canals",
                    summary_text = "Non-fish-bearing streams and canals that connect indirect return points to fish-bearing streams. Used to calculate flow distances. ",
                    tags = c(common_tags, "flowlines", "streams", "canals"),
                    credits = "FlowWest; modified from USGS NHD",
                    sf_df = riceflows4ff::ff_canals,
)

# WETDRY
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_wetdry.shp.xml",
                    title_text = "Sacramento Valley wet and dry areas",
                    summary_text = "Polygons identifying which parts of the Sacramento Valley, within the project area, are behind levees (dry) or directly exposed to rivers or floodways (wet).",
                    description_text = paste(sep="\n",
                                             "Identification and prioritization of rice fields.",
                                             "* Dry side is separated from fish bearing stream by levees.",
                                             "* Wet side is connected to the fish bearing stream via floodplain activation.",
                                             "Note:  Areas outside of the project boundary and areas where rice fields are not present may not be defined accurately. Areas north of Stony Creek coarsely defined as 'Dry' for the purposes of this study."
                    ),
                    fields_list = c("wet_dry" = "identification of polygon as being on the wet-side or dry-side of a fish bearing stream",
                                    "area_name" = "name given to the area defined by the polygon",
                                    "source" = "source of the polygon and determination of hydrology (wet or dry)"
                                    ),
                    tags = c(common_tags, "levee", "drainage", "reclamation", "floodplain"),
                    credits = "Aidan Kelleher [akelleher@flowwest.com], Bethany Hackenjos [bhackenjos@flowwest.com], FlowWest, 2023",
                    sf_df = riceflows4ff::ff_wetdry,
)

# AOI
create_metadata_xml(output_xml = "inst/app/xml/riceflows4ff_aoi.shp.xml",
                    title_text = "Rice field drainage project boundary",
                    summary_text = "The project boundary for this analysis. Covers 7 Counties:  Butte, Colusa, Glenn, Placer, Sutter, Yolo, and Yuba.",
                    description_text = paste(sep="\n",
                    "* West boundary determined by Tehema canal from the top of Glenn county border until Yolo County border.",
                    "* South boundary follows Yolo County until its intersection of Placer County and follows rice fields until the intersection of Yuba and Placer County at the Camp Far West Reservoir.",
                    "* East boundary follows the Yuba County border until it intersects with the Yuba River, then follows the rice fields until Highway 99. Following highway 99 until it reaches the top of Butte County Boundary.",
                    "* North boundary begins at the intersection of Tehema Canal and Glenn County Boundary, following the boundary right until it intersects Butte County Boundary. Following Butte County Boundary north until the intersection of highway 99."),
                    tags = c(common_tags, "levee", "drainage", "reclamation", "floodplain", "boundary"),
                    credits = "Aidan Kelleher [akelleher@flowwest.com], Bethany Hackenjos [bhackenjos@flowwest.com], FlowWest, 2023",
                    sf_df = riceflows4ff::ff_aoi,
)
