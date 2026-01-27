## lecture-3.1.R - helper file for democratic backsliding lecture
## Data wrangling for regime type trends and top 10 autocratizing countries

# Get the latest year in the V-Dem data
latest_vdem_year <- max(vdem$year, na.rm = TRUE)

# Calculate the time period for autocratization analysis
# Using 2010 as the inflection point (peak of Third Wave / start of democratic recession)
start_year <- 2010

## Regime type trends data (1975 - present)

regime_type <- vdem |>
  filter(year >= 1975) |>
  select(country = country_name, year, regime_type = v2x_regime) |>
  mutate(
    closed = if_else(regime_type == 0, 1, 0),
    electoral_a = if_else(regime_type == 1, 1, 0),
    electoral_d = if_else(regime_type == 2, 1, 0),
    lib_dem = if_else(regime_type == 3, 1, 0),
    num_ctrs = n_distinct(country)
  )

pct_regimes <- regime_type |>
  group_by(year, regime_type) |>
  summarize(n = n(), .groups = "drop") |>
  mutate(percent = 100 * (n / sum(n))) |>
  select(!n) |>
  arrange(regime_type) |>
  mutate(regime_type = recode(regime_type,
                              `0` = "closed",
                              `1` = "electoral_auth",
                              `2` = "electoral_dem",
                              `3` = "liberal_dem")) |>
  drop_na()

## Top 10 autocratizing countries (based on change in liberal democracy index)

# Helper function to get regime type label
get_regime_label <- function(regime_code) {
  case_when(
    regime_code == 0 ~ "Closed Autocracy",
    regime_code == 1 ~ "Electoral Autocracy",
    regime_code == 2 ~ "Electoral Democracy",
    regime_code == 3 ~ "Liberal Democracy",
    TRUE ~ NA_character_
  )
}

# Get data for start year (start_year)
start_year_data <- vdem |>
  filter(year == start_year) |>
  select(
    country = country_name,
    ldi_start = v2x_libdem,
    regime_start = v2x_regime
  ) |>
  mutate(regime_start_label = get_regime_label(regime_start))

# Get data for end year (latest)
end_year_data <- vdem |>
  filter(year == latest_vdem_year) |>
  select(
    country = country_name,
    ldi_end = v2x_libdem,
    regime_end = v2x_regime
  ) |>
  mutate(regime_end_label = get_regime_label(regime_end))

# Calculate change and get top 10 autocratizing countries
top10_autocratizing <- start_year_data |>
  inner_join(end_year_data, by = "country") |>
  mutate(change = ldi_end - ldi_start) |>
  drop_na(change) |>
  slice_min(order_by = change, n = 10) |>
  select(
    Country = country,
    Change = change,
    `LDI Start` = ldi_start,
    `LDI End` = ldi_end,
    `Regime Start` = regime_start_label,
    `Regime End` = regime_end_label
  )
