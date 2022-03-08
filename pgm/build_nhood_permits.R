#This script builds the analysis data from city of chicago building permits data

df_deconversions <- df_permits %>%
  filter(!is.na(LOCATION)) %>%
  transmute(permit_type = PERMIT_TYPE,
            issue_date = as_date(ISSUE_DATE, format = "%m/%d/%Y"), 
            year = year(as.period(interval(start = as_date("01/27/2006", format = "%m/%d/%Y"), end = issue_date))) + 2006,
            description = WORK_DESCRIPTION,
            latitude = LATITUDE,
            longitude = LONGITUDE) %>%
  filter(grepl("deconvert|deconversion", description, ignore.case = TRUE),
         year < 2022) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 3435)

#Construct Pilsen data
pilsen_nhoods <- build_analysis_nhoods(df_zoning = df_zoning, df_boundaries = df_pilsen_boundaries, df_nhoods = df_nhoods, 
                                       zoning_codes = c("RT-4", "RM-4.5", "RM-5", "RM-5.5", "RM6", "RM-6.5"), nhood_name = 'pilsen')

df_pilsen_nhoods <- pilsen_nhoods$df_analysis_nhoods
  
df_pilsen_analysis <- df_deconversions %>%
  st_intersection(df_pilsen_nhoods) %>%
  st_drop_geometry() %>%
  group_by(neighborhood, year) %>%
  summarize(n_permits = n()) %>%
  ungroup() %>%
  complete(neighborhood, year, fill = list(n_permits = 0))

df_pilsen_map <- pilsen_nhoods$df_map

#Construct 606 data
sos_nhoods <- build_analysis_nhoods(df_zoning = df_zoning, df_boundaries = df_606_boundaries, df_nhoods = df_nhoods, 
                                    zoning_codes = c("RS-3", "RS3.5"), nhood_name = '606')

df_sos_nhoods <-sos_nhoods$df_analysis_nhoods

df_sos_analysis <- df_deconversions %>%
  st_intersection(df_sos_nhoods) %>%
  st_drop_geometry() %>%
  group_by(neighborhood, year) %>%
  summarize(n_permits = n()) %>%
  ungroup() %>%
  complete(neighborhood, year, fill = list(n_permits = 0))

df_sos_map <- sos_nhoods$df_map

