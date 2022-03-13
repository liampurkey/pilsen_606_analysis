#This script runs the analysis
library(here)

# Import packages and define functions
source(here("pgm", "prelim.R"))

# Build data --------------------
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

source(here("pgm", "build_permits.R"))

#Delete current clean data to resolve st_write append issue
unlink(here("clean_data", "*"), recursive = T, force = T)

write_csv(df_pilsen_decon_demo, here("clean_data", 'pilsen_decon_demo.csv'))
write_csv(df_sos_decon_demo, here("clean_data", 'sos_decon_demo.csv'))
write_csv(df_pilsen_construction, here("clean_data", 'pilsen_construction.csv'))
write_csv(df_sos_construction, here("clean_data", 'sos_construction.csv'))
st_write(df_pilsen_map, here("clean_data", 'pilsen_map.geojson'))
st_write(df_sos_map, here("clean_data", 'sos_map.geojson'))

# Run analysis --------------------
source(here("pgm", "analyze_permits.R"))

plot_list <- list(
  sos_decon_demo_means = gg_sos_decon_demo_means,
  sos_construction_means = gg_sos_construction_means,
  pilsen_decon_demo_means = gg_pilsen_decon_demo_means,
  pilsen_construction_means = gg_pilsen_construction_means
)

for (i in seq_along(plot_list)) {
  ggsave(filename = here("out", paste0(names(plot_list)[i], ".pdf")), plot = plot_list[[i]], w = 6, h = 4)
}
