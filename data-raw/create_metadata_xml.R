create_metadata_xml <- function(output_xml, title_text, summary_text, description_text, credits_text, tags, sf_df, bbox){
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
  if (!missing(description_text)) { # parse html?
    description_text_parsed <- description_text |> markdown::mark_html(template=FALSE)
    idAbs = XML::newXMLNode("idAbs", description_text_parsed, parent = dataIdInfo)
  }
  if (!missing(credits_text)) { # parse html?
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
    GeoBndBox = XML::newXMLNode("GeoBndBox", parent = geoEle)
    westBL = XML::newXMLNode("westBL", bbox_gcs["xmin"], parent = GeoBndBox)
    eastBL = XML::newXMLNode("eastBL", bbox_gcs["xmax"], parent = GeoBndBox)
    southBL = XML::newXMLNode("southBL", bbox_gcs["ymin"], parent = GeoBndBox)
    northBL = XML::newXMLNode("northBL", bbox_gcs["ymax"], parent = GeoBndBox)
    exTypeCode = XML::newXMLNode("exTypeCode", 1, parent = GeoBndBox) # 1 if "extent contains the resource
  }
  #return(doc)
  XML::saveXML(doc, file = output_xml)
}

common_tags <- c("Sacramento Valley", "rice field", "salmonid", "habitat")

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_distances.xml",
                    title_text = "Rice field distance attributes",
                    summary_text = "Results of the FlowWest analysis of flow distances to the nearest fish-bearing stream. Intended to be joined to the fields dataset.",
                    tags = c(common_tags, "distance"),
                    credits = "FlowWest",
                    )

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_fields.xml",
                    title_text = "Rice field geometries",
                    summary_text = "Polygon geometries of rice fields based on crop mapping from YYYY.",
                    tags = c(common_tags, "crops"),
                    credits = "FlowWest",
                    sf_df = fishFoodMWD::ff_fields,
)

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_watersheds.xml",
                    title_text = "Watershed polygons used to group rice fields and organize flow patterns. Based on HUC10 watersheds, but split in some cases where necessary.",
                    summary_text = "hello",
                    tags = c(common_tags, "watersheds", "huc10", "groups"),
                    credits = "FlowWest; based on USGS National Hydrography Dataset (NHD)",
                    sf_df = fishFoodMWD::ff_watersheds,
)

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_returns.xml",
                    title_text = "Return points",
                    summary_text = "Point locations of outlets for return flow from rice field drainage networks into adjacent canals or streams.",
                    tags = c(common_tags, "outlets", "outfalls", "returns", "confluence"),
                    credits = "FlowWest",
                    sf_df = fishFoodMWD::ff_returns,
)

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_streams.xml",
                    title_text = "Fish-bearing streams",
                    summary_text = "Supplementary geometry layer containing the fish-bearing streams. Used to calculate flow distances.",
                    tags = c(common_tags, "flowlines", "streams", "rivers", "rearing"),
                    credits = "FlowWest; modified from CVPIA rearing habitat",
                    sf_df = fishFoodMWD::ff_streams,
)

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_canals.xml",
                    title_text = "Secondary canals",
                    summary_text = "Non-fish-bearing streams and canals that connect indirect return points to fish-bearing streams. Used to calculate flow distances.",
                    tags = c(common_tags, "flowlines", "streams", "canals"),
                    credits = "FlowWest",
                    sf_df = fishFoodMWD::ff_canals,
)

create_metadata_xml(output_xml = "data-raw/xml/fishFoodMWD_wetdry.xml",
                    title_text = "Sacramento Valley wet and dry areas",
                    summary_text = "polygons identifying which parts of the Sacramento Valley are behind levees (dry) or directly exposed to rivers or floodways (wet).",
                    tags = c(common_tags, "levee", "drainage", "reclamation", "floodplain"),
                    credits = "FlowWest; compiled from data from Ducks Unlimited and others",
                    sf_df = fishFoodMWD::ff_wetdry,
)
