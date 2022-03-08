library(tidyverse)
library(lubridate)
library(readxl)
library(readr)
library(sf)
library(spData)
library(tmap)
library(here)

#Functions for project
plot_theme <- function() {
  
  # Generate the colors for the chart procedurally with RColorBrewer
  palette <- brewer.pal("Greys", n=9)
  color.background = "white"
  color.grid.major = palette[3]
  color.axis.text = palette[6]
  color.axis.title = palette[7]
  color.title = palette[9]
  
  # Begin construction of chart
  theme_bw(base_size=9) +
    
    # Set the entire chart region to a light gray color
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    
    # Format the grid
    theme(panel.grid.major.y=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.major.x=element_blank()) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    
    # Format the legend, but hide by default
    theme(legend.position="none") +
    theme(legend.background = element_rect(fill=color.background)) +
    theme(legend.text = element_text(size=9,color=color.axis.title)) +
    
    # Set title and axis labels, and format these and tick marks
    theme(plot.title=element_text(color=color.title, size=11, vjust=1.25)) +
    theme(axis.text.x=element_text(size=10,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=10,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=10,color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(size=10,color=color.axis.title, vjust=1.25)) +
    
    # Plot margins
    theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm"))
}

drop_units <- function(x) {
  class(x) <- setdiff(class(x), "units")
  attr(x, "units") <- NULL
  return(x)
}

build_analysis_nhoods <- function(df_zoning, df_boundaries, df_control_nhoods, zoning_codes, nhood_name) {
  
  df_zoning_filtered <- df_zoning %>%
    filter(ZONE_CLASS %in% zoning_codes) %>%
    st_make_valid()
    
  df_treatment <- df_zoning_filtered %>%
    st_intersection(df_boundaries) %>%
    transmute(neighborhood = nhood_name)
  
  df_control <- df_zoning_filtered %>%
    st_intersection(df_control_nhoods %>% st_make_valid()) %>%
    transmute(neighborhood = name)
  
  df_analysis_nhoods = bind_rows(df_treatment, df_control) 
    
  df_nhood_areas = df_analysis_nhoods %>%
    mutate(area = drop_units(st_area(.)) / 27878400) %>%
    st_drop_geometry() %>%
    group_by(neighborhood) %>%
    summarize(area = sum(area))
  
  df_nhoods_map <- df_control_nhoods %>%
    transmute(neighborhood = name,
              geometry) %>%
    bind_rows(df_boundaries %>% transmute(neighborhood = nhood_name, geometry))
  
  return(list('df_analysis_nhoods' = df_analysis_nhoods, 'df_nhood_areas' = df_nhood_areas, 'df_nhoods_map' = df_nhoods_map))
  
}