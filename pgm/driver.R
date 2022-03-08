#This script runs the analysis
build_data <- TRUE

source(here("pgm", "prelim.R"))

if (isTRUE(build_data)) {
  
  df_permits <- read_csv(here("raw_data", "building_permits.csv"))
  
  gis_data = list(
    df_zoning = "Zoning_asof_17DEC2021/Zoning_asof_17DEC2021.shp",
    df_nhoods = "chicago_neighborhoods.geojson",
    df_606_boundaries = "boundaries_606.kml",
    df_pilsen_boundaries = "boundaries_pilsen.kml"
  )
  
  for (i in seq_along(gis_data)) {
    assign(names(gis_data)[i], st_read(here("raw_data", gis_data[[i]])) %>%
             st_transform(crs = 3435))
  }
  
  source(here("pgm", "build_nhood_permits.R"))
  
} else {
  
  #df_analysis <- read_csv(here("clean_data", "nhood_permits.csv"))
  
}