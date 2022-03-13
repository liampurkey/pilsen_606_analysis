#This script builds the analysis data from city of chicago building permits data

#Clean permits
df_permits_clean <- df_permits %>%
  filter(!is.na(LOCATION)) %>%
  transmute(permit_type = PERMIT_TYPE,
            issue_date = as_date(ISSUE_DATE, format = "%m/%d/%Y"), 
            year = as.numeric(year(as.period(interval(start = as_date("01/27/2006", format = "%m/%d/%Y"), end = issue_date)))) + 2006,
            description = WORK_DESCRIPTION,
            latitude = LATITUDE,
            longitude = LONGITUDE) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 3435) %>%
  filter(year < 2022)

df_decon_demo_permits <- df_permits_clean %>%
  filter(grepl("deconvert|deconversion", description, ignore.case = TRUE),
         grepl('renovation/alteration', permit_type, ignore.case = TRUE)) %>%
  bind_rows(df_permits_clean %>%
              filter(grepl("wreck and remove", description, ignore.case = TRUE),
                     grepl('wrecking/demolition', permit_type, ignore.case = TRUE)))

df_constuction_permits <- df_permits_clean %>%
  filter(grepl("new construction", permit_type, ignore.case = TRUE)) 

#Drop pilsen and 606 areas from chicago neighborhood data
df_control_nhoods <- df_nhoods %>%
  st_make_valid() %>%
  st_difference(df_pilsen_boundaries) %>%
  st_difference(df_sos_boundaries)
  
#Construct Pilsen data
pilsen_nhood_data <- build_analysis_nhoods(df_zoning = df_zoning, df_boundaries = df_pilsen_boundaries, df_control_nhoods = df_control_nhoods, 
                                       zoning_codes = c("RT-4", "RM-4.5", "RM-5", "RM-5.5", "RM6", "RM-6.5"), nhood_name = 'pilsen')

df_pilsen_nhoods <- pilsen_nhood_data$df_analysis_nhoods
  
df_pilsen_decon_demo <- df_decon_demo_permits %>%
  st_intersection(df_pilsen_nhoods) %>%
  st_drop_geometry() %>%
  group_by(neighborhood, year) %>%
  summarize(n_permits = n()) %>%
  ungroup() %>%
  complete(neighborhood, year, fill = list(n_permits = 0)) %>%
  inner_join(pilsen_nhood_data$df_nhood_areas, by = 'neighborhood') %>%
  mutate(permits_per_sm = n_permits / area) %>%
  select(-area) %>%
  mutate(treatment = if_else(neighborhood == 'pilsen', 1, 0))

df_pilsen_construction <- df_constuction_permits %>%
  st_intersection(df_pilsen_nhoods) %>%
  st_drop_geometry() %>%
  group_by(neighborhood, year) %>%
  summarize(n_permits = n()) %>%
  ungroup() %>%
  complete(neighborhood, year, fill = list(n_permits = 0)) %>%
  inner_join(pilsen_nhood_data$df_nhood_areas, by = 'neighborhood') %>%
  mutate(permits_per_sm = n_permits / area) %>%
  select(-area) %>%
  mutate(treatment = if_else(neighborhood == 'pilsen', 1, 0))

df_pilsen_map <- pilsen_nhood_data$df_nhoods_map

#Construct 606 data
sos_nhood_data <- build_analysis_nhoods(df_zoning = df_zoning, df_boundaries = df_sos_boundaries, df_control_nhoods = df_control_nhoods, 
                                    zoning_codes = c("RS-3", "RS3.5"), nhood_name = 'sos')

df_sos_nhoods <- sos_nhood_data$df_analysis_nhoods

df_sos_decon_demo <- df_decon_demo_permits %>%
  st_intersection(df_sos_nhoods) %>%
  st_drop_geometry() %>%
  group_by(neighborhood, year) %>%
  summarize(n_permits = n()) %>%
  ungroup() %>%
  complete(neighborhood, year, fill = list(n_permits = 0)) %>%
  inner_join(sos_nhood_data$df_nhood_areas, by = 'neighborhood') %>%
  mutate(permits_per_sm = n_permits / area) %>%
  select(-area) %>%
  mutate(treatment = if_else(neighborhood == 'sos', 1, 0))

df_sos_construction <- df_constuction_permits %>%
  st_intersection(df_sos_nhoods) %>%
  st_drop_geometry() %>%
  group_by(neighborhood, year) %>%
  summarize(n_permits = n()) %>%
  ungroup() %>%
  complete(neighborhood, year, fill = list(n_permits = 0)) %>%
  inner_join(sos_nhood_data$df_nhood_areas, by = 'neighborhood') %>%
  mutate(permits_per_sm = n_permits / area) %>%
  select(-area) %>%
  mutate(treatment = if_else(neighborhood == 'sos', 1, 0))

df_sos_map <- sos_nhood_data$df_nhoods_map





