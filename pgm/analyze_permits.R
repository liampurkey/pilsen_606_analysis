#This script analyzes permits

# Descriptive analysis --------------------

## Create raw treatment vs control time-series plots --------------------

### Logan Square --------------------
df_sos_decon_demo_means <- df_sos_decon_demo %>%
  group_by(treatment, year) %>%
  summarize(n_permits = mean(n_permits)) %>%
  ungroup()

gg_sos_decon_demo_means <- df_sos_decon_demo_means %>%
  mutate(Neighborhood = if_else(treatment == 1, "606 area", "Control neighborhoods"),
         Neighborhood = fct_relevel(as.factor(Neighborhood), c("606 area", "Control neighborhoods"))) %>%
  ggplot(aes(x = year, y = n_permits, group = treatment, color = Neighborhood, shape = Neighborhood)) +
  geom_vline(xintercept = 2020) + geom_line() + geom_point() + 
  plot_theme() + tc_colors + year_scale + 
  ylim(c(0, 40)) +
  labs(x = 'Year', y = '', subtitle = 'Number of deconversion and demolition permits') +
  theme(legend.position = c(0.175, .85))
  
df_sos_construction_means <- df_sos_construction %>%
  group_by(treatment, year) %>%
  summarize(n_permits = mean(n_permits)) %>%
  ungroup()

gg_sos_construction_means <- df_sos_construction_means %>%
  mutate(Neighborhood = if_else(treatment == 1, "606 area", "Control neighborhoods"),
         Neighborhood = fct_relevel(as.factor(Neighborhood), c("606 area", "Control neighborhoods"))) %>%
  ggplot(aes(x = year, y = n_permits, group = treatment, color = Neighborhood, shape = Neighborhood)) +
  geom_vline(xintercept = 2020) + geom_line() + geom_point() + 
  plot_theme() + tc_colors + year_scale + 
  ylim(c(0, 50)) +
  labs(x = 'Year', y = '', subtitle = 'Number of new construction permits') +
  theme(legend.position = c(0.25, .85))

### Pilsen --------------------
df_pilsen_decon_demo_means <- df_pilsen_decon_demo %>%
  group_by(treatment, year) %>%
  summarize(n_permits = mean(n_permits)) %>%
  ungroup()

gg_pilsen_decon_demo_means <- df_pilsen_decon_demo_means %>%
  mutate(Neighborhood = if_else(treatment == 1, "Pilsen", "Control neighborhoods"),
         Neighborhood = fct_relevel(as.factor(Neighborhood), c("Pilsen", "Control neighborhoods"))) %>%
  ggplot(aes(x = year, y = n_permits, group = treatment, color = Neighborhood, shape = Neighborhood)) +
  geom_vline(xintercept = 2020) + geom_line() + geom_point() + 
  plot_theme() + tc_colors + year_scale + 
  ylim(c(0, 15)) +
  labs(x = 'Year', y = '', subtitle = 'Number of deconversion and demolition permits') +
  theme(legend.position = c(0.175, .85))

df_pilsen_construction_means <- df_pilsen_construction %>%
  group_by(treatment, year) %>%
  summarize(n_permits = mean(n_permits)) %>%
  ungroup()

gg_pilsen_construction_means <- df_pilsen_construction_means %>%
  mutate(Neighborhood = if_else(treatment == 1, "Pilsen", "Control neighborhoods"),
         Neighborhood = fct_relevel(as.factor(Neighborhood), c("Pilsen", "Control neighborhoods"))) %>%
  ggplot(aes(x = year, y = n_permits, group = treatment, color = Neighborhood, shape = Neighborhood)) +
  geom_vline(xintercept = 2020) + geom_line() + geom_point() + 
  plot_theme() + tc_colors + year_scale + 
  ylim(c(0, 20)) +
  labs(x = 'Year', y = '', subtitle = 'Number of new construction permits') +
  theme(legend.position = c(0.175, .85))