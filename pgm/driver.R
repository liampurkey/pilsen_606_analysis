#This script runs the analysis
library(here)
build_data <- TRUE

source(here("pgm", "prelim.R"))

if (isTRUE(build_data)) {
  
  df_permits <- read_csv(here("raw_data", "building_permits.csv"))
  
  gis_data_list = list(
    df_zoning = "Zoning_asof_17DEC2021/Zoning_asof_17DEC2021.shp",
    df_nhoods = "chicago_neighborhoods.geojson",
    df_sos_boundaries = "boundaries_sos.kml",
    df_pilsen_boundaries = "boundaries_pilsen.kml"
  )
  
  for (i in seq_along(gis_data_list)) {
    assign(names(gis_data_list)[i], st_read(here("raw_data", gis_data_list[[i]])) %>%
             st_transform(crs = 3435))
  }
  
  source(here("pgm", "build_nhood_permits.R"))
  
  #Delete current clean data to resolve st_write append issue
  unlink(here("clean_data", "*"), recursive = T, force = T)
  
  write_csv(df_pilsen_analysis, here("clean_data", 'pilsen_analysis.csv'))
  write_csv(df_sos_analysis, here("clean_data", 'sos_analysis.csv'))
  st_write(df_pilsen_map, here("clean_data", 'pilsen_map.geojson'))
  st_write(df_sos_map, here("clean_data", 'sos_map.geojson'))
  
} else {
  
  #df_analysis <- read_csv(here("clean_data", "nhood_permits.csv"))
  
}
