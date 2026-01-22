## v-dem dataset, summarizing by country up to end of WWII

polyarchy_pre1945 <- vdem %>%
  rename(country = country_name) %>%
  filter(year < 1945) %>%
  group_by(country_id, country) %>%
  summarize(
    polyarchy = mean(v2x_polyarchy, na.rm = TRUE),
    gdp_pc = mean(e_gdppc, na.rm = TRUE), 
    region = max(e_regionpol_6C, na.rm = TRUE)
  ) %>%
  mutate(
    region = recode(region, `1` = "Eastern Europe", 
                    `2` = "Latin America", 
                    `3` = "Middle East", 
                    `4` = "Africa", 
                    `5` = "The West", 
                    `6` = "Asia")
  )

# v-dem dataset, summarizing by country for post-WWII period

polyarchy_postwar <- vdem %>%
  rename(country = country_name) %>%
  filter(year >= 1945) %>%
  group_by(country_id, country) %>%
  summarize(
    polyarchy = mean(v2x_polyarchy, na.rm = TRUE),
    gdp_pc = mean(e_gdppc, na.rm = TRUE), 
    region = max(e_regionpol_6C, na.rm = TRUE)
  ) %>%
  mutate(
    region = recode(region, `1` = "Eastern Europe", 
                    `2` = "Latin America", 
                    `3` = "Middle East", 
                    `4` = "Africa", 
                    `5` = "The West", 
                    `6` = "Asia")
  )

## v-dem dataset, summarizing by year with codings for different time periods

polyarchy_annual <- vdem %>%
  group_by(year) %>%
  summarize(
    polyarchy = mean(v2x_polyarchy, na.rm = TRUE),
    gdp_pc = mean(e_gdppc, na.rm = TRUE)
  ) %>%
  mutate(
    wave = case_when(year <= 1827 ~ "pre 1st wave",
                     year > 1827 & year <= 1926 ~ "1st wave", 
                     year > 1926 & year <= 1945 ~ "1st rev. wave",
                     year > 1945 & year <= 1962 ~ "2nd wave", 
                     year > 1962 & year <= 1973 ~ "2nd rev. wave", 
                     year > 1973 & year <= 2010 ~ "3rd wave", 
                     year > 2010 ~ "3rd rev. wave") %>%
      factor(levels = c("pre 1st wave", "1st wave", "1st rev. wave",
                        "2nd wave", "2nd rev. wave", "3rd wave", "3rd rev. wave"))
  ) %>%
  drop_na()

## most democratic countries by polyarchy (latest year)

latest_vdem_year <- max(vdem$year, na.rm = TRUE)

polyarchy_latest <- vdem %>%
  rename(country = country_name) %>%
  filter(year == latest_vdem_year) %>%
  select(country, polyarchy = v2x_polyarchy) %>%
  drop_na(polyarchy)

polyarchy_top15 <- polyarchy_latest %>%
  slice_max(order_by = polyarchy, n = 15)

## largest economies by GDP and GDP per capita (latest available)

latest_wdi_year <- as.integer(format(Sys.Date(), "%Y"))

gdp = WDI(indicator = "NY.GDP.MKTP.KD", country = "all",
          start = 2010, end = latest_wdi_year, extra = TRUE)

biggest <- gdp %>%
  select(country, region, year, gdp = NY.GDP.MKTP.KD) %>%
  filter(region != "Aggregates") %>%
  group_by(country, region) %>%
  slice_max(order_by = year, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  slice_max(order_by = gdp, n = 15)

## largest economies by GDP in PPP (latest available)

gdp_ppp = WDI(indicator = "NY.GDP.MKTP.PP.KD", country = "all",
              start = 2010, end = latest_wdi_year, extra = TRUE)

biggest_ppp <- gdp_ppp %>%
  select(country, region, year, gdp_ppp = NY.GDP.MKTP.PP.KD) %>%
  filter(region != "Aggregates") %>%
  group_by(country, region) %>%
  slice_max(order_by = year, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  slice_max(order_by = gdp_ppp, n = 15)

## wealthiest countries by GDP per capita (PPP, latest available)

gdp_pc_ppp = WDI(indicator = "NY.GDP.PCAP.PP.KD", country = "all",
                 start = 2010, end = latest_wdi_year, extra = TRUE)

wealthiest_pc_ppp <- gdp_pc_ppp %>%
  select(country, region, year, gdp_pc_ppp = NY.GDP.PCAP.PP.KD) %>%
  filter(region != "Aggregates") %>%
  group_by(country, region) %>%
  slice_max(order_by = year, n = 1, with_ties = FALSE) %>%
  ungroup() %>%
  slice_max(order_by = gdp_pc_ppp, n = 15)

## wealth and democracy plot 1

modernization <- ggplot(polyarchy_pre1945, aes(x = gdp_pc, y = polyarchy)) + 
  geom_point() + 
  geom_smooth(method = "lm", size = 1) + 
  scale_x_log10(labels = scales::label_dollar(suffix = "k")) +
  aes(label = country) + # need so ggplot retains label for plotly
  labs(x= "GDP Per Capita", y = "Polyarchy Score",
       title = "Wealth and democracy, 1789 - 1945")

modernization_plot1 <- ggplotly(modernization, tooltip = c("country", "polyarchy")) %>%
  # adjust size 
  layout(
    height = 400,
    width = 900  # Adjust width to better fit your slide
  ) %>%
  # add source
  layout(annotations = list(text = "Source: The V-Dem Institute, Varities of Democracy Dataset",  
                            font = list(size = 10), showarrow = FALSE,
                            xref = 'paper', x = 1, xanchor = 'right', xshift = 0,
                            yref = 'paper', y = -.1, yanchor = 'auto', yshift = 0)) %>%
  # add web address
  layout(annotations = list(text = "www.psc2339.com", 
                            font = list(size = 10, color = 'grey'), showarrow = FALSE,
                            xref = 'paper', x = .5, xanchor = 'center', xshift = 0,
                            yref = 'paper', y = 1, yanchor = 'top', yshift = 0)) %>%
  # edit tooltip
  style(hoverinfo="skip", traces = 2) %>%
  style(hoverinfo="skip", traces = 3)

## wealth and democracy plot 2

modernization2 <- ggplot(polyarchy_postwar, aes(x = gdp_pc, y = polyarchy)) + 
  geom_point() + 
  geom_smooth(method = "lm", size = 1) + 
  scale_x_log10(labels = scales::label_dollar(suffix = "k")) +
  aes(label = country) +
  labs(x= "GDP Per Capita", y = "Polyarchy Score",
       title = "Wealth and democracy after WWII")

modernization_plot2 <- ggplotly(modernization, tooltip = c("country", "polyarchy")) %>% 
  # adjust size 
  layout(
    height = 400,
    width = 900  # Adjust width to better fit your slide
  ) %>%
  # add source
  layout(annotations = list(text = "Source: The V-Dem Institute, Varities of Democracy Dataset",  
                            font = list(size = 10), showarrow = FALSE,
                            xref = 'paper', x = 1, xanchor = 'right', xshift = 0,
                            yref = 'paper', y = -.1, yanchor = 'auto', yshift = 0)) %>%
  # add web address
  layout(annotations = list(text = "www.psc2339.com", 
                            font = list(size = 10, color = 'grey'), showarrow = FALSE,
                            xref = 'paper', x = .5, xanchor = 'center', xshift = 0,
                            yref = 'paper', y = 1, yanchor = 'top', yshift = 0)) %>%
  # edit tooltip
  style(hoverinfo="skip", traces = 2) %>%
  style(hoverinfo="skip", traces = 3)

## Democracy and development by region

region_plot <- ggplot(polyarchy_postwar, aes(x = gdp_pc, y = polyarchy)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE, size = .75) + 
  facet_wrap(~ region) + 
  scale_x_log10() +
  aes(label = country) + # need to retain label to give to plotly
  #geom_text(hjust = 0, nudge_x = .2, size = 1.5, aes(label = country_name)) +
  labs(x= "GDP Per Capita", y = "Polyarchy Score",
       title = "Wealth and democracy by region after WWII")

modernization_by_region <- ggplotly(region_plot, tooltip = c("country", "polyarchy")) %>% 
  # adjust size 
  layout(
    height = 400,
    width = 900  # Adjust width to better fit your slide
  ) %>%
  # add source
  layout(annotations = list(text = "Source: The V-Dem Institute, Varities of Democracy Dataset",  
                            font = list(size = 10), showarrow = FALSE,
                            xref = 'paper', x = 1, xanchor = 'right', xshift = 0,
                            yref = 'paper', y = -.1, yanchor = 'auto', yshift = 0)) %>%
  # add web address
  layout(annotations = list(text = "www.psc2339.com", 
                            font = list(size = 10, color = 'grey'), showarrow = FALSE,
                            xref = 'paper', x = .5, xanchor = 'center', xshift = 0,
                            yref = 'paper', y = 1, yanchor = 'top', yshift = 0))

## Democracy and development over time

time_plot <- ggplot(polyarchy_annual, aes(x = gdp_pc, y = polyarchy)) + 
  geom_point(aes(color = wave)) + 
  geom_smooth(method = "lm", se = FALSE, size = .75) + 
  scale_x_log10() +
  aes(label = year) +
  labs(x= "GDP Per Capita", y = "Polyarchy Score",
       title = "Democracy, development and Huntington's three waves") +
  scale_color_discrete(name = "Wave")

modernization_over_time <- ggplotly(time_plot, tooltip = c("year", "polyarchy")) %>%   
  # adjust size 
  layout(
    height = 400,
    width = 900  # Adjust width to better fit your slide
  ) %>%
  # add source
  layout(annotations = list(text = "Source: The V-Dem Institute, Varities of Democracy Dataset",  
                            font = list(size = 10), showarrow = FALSE,
                            xref = 'paper', x = 1, xanchor = 'right', xshift = 100,
                            yref = 'paper', y = -.1, yanchor = 'auto', yshift = 0)) %>%
  # add web address
  layout(annotations = list(text = "www.psc2339.com", 
                            font = list(size = 10, color = 'grey'), showarrow = FALSE,
                            xref = 'paper', x = .5, xanchor = 'center', xshift = 0,
                            yref = 'paper', y = 1, yanchor = 'top', yshift = 0))
