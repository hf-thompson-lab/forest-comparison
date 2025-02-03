#' Prepare Land Areas
#' 
#' @description
#' Prepares land area data for total land area and federal land area.
#' Prior to running this script, federal land area was calculated by state
#' using USGS PAD-US v3.0. Steps to create that data are documented in 
#' analyses/calc_fed_area_by_state.py
#' State land area is based on the 2010 US Census data downloaded from
#' https://www.census.gov/geographies/reference-files/2010/geo/state-area.html 
#' and saved as a CSV.
#' 
#' This function creates and saves a CSV of total, federal, and non-federal 
#' land area by state for the 48 contiguous US states and returns this table
#' 
#' @return This function does not return any objects.

prep_land_areas <- function() {
  # Input datasets
  state_area <- readxl::read_xlsx(here::here("data", "raw-data", "census_state_area_measurements_2010.xlsx"))
  federal_land_area <- foreign::read.dbf(here::here("data", "derived-data", "padus3_fed_area_by_state.dbf"), as.is = T)    # units = sq m
  
  #### FEDERAL LAND AREA ####
  # Convert sq m to sq km
  federal_land_area$fed_land_sq_km <- federal_land_area$FED / 1000000
  
  # Recode state names to abbreviations
  federal_land_area$State <- dplyr::case_match(federal_land_area$NAME,
                                               'Alabama' ~ 'AL',
                                               'Arizona' ~ 'AZ',
                                               'Arkansas' ~ 'AR',
                                               'California' ~ 'CA',
                                               'Colorado' ~ 'CO',
                                               'Connecticut' ~ 'CT',
                                               'Delaware' ~ 'DE',
                                               'Florida' ~ 'FL',
                                               'Georgia' ~ 'GA',
                                               'Idaho' ~ 'ID',
                                               'Illinois' ~ 'IL',
                                               'Indiana' ~ 'IN',
                                               'Iowa' ~ 'IA',
                                               'Kansas' ~ 'KS',
                                               'Kentucky' ~ 'KY',
                                               'Louisiana' ~ 'LA',
                                               'Maine' ~ 'ME',
                                               'Maryland' ~ 'MD',
                                               'Massachusetts' ~ 'MA',
                                               'Michigan' ~ 'MI',
                                               'Minnesota' ~ 'MN',
                                               'Mississippi' ~ 'MS',
                                               'Missouri' ~ 'MO',
                                               'Montana' ~ 'MT',
                                               'Nebraska' ~ 'NE',
                                               'Nevada' ~ 'NV',
                                               'New Hampshire' ~ 'NH',
                                               'New Jersey' ~ 'NJ',
                                               'New Mexico' ~ 'NM',
                                               'New York' ~ 'NY',
                                               'North Carolina' ~ 'NC',
                                               'North Dakota' ~ 'ND',
                                               'Ohio' ~ 'OH',
                                               'Oklahoma' ~ 'OK',
                                               'Oregon' ~ 'OR',
                                               'Pennsylvania' ~ 'PA',
                                               'Rhode Island' ~ 'RI',
                                               'South Carolina' ~ 'SC',
                                               'South Dakota' ~ 'SD',
                                               'Tennessee' ~ 'TN',
                                               'Texas' ~ 'TX',
                                               'Utah' ~ 'UT',
                                               'Vermont' ~ 'VT',
                                               'Virginia' ~ 'VA',
                                               'Washington' ~ 'WA',
                                               'West Virginia' ~ 'WV',
                                               'Wisconsin' ~ 'WI',
                                               'Wyoming' ~ 'WY')
  
  # Keep only needed columns and rows - get rid of Alaska, etc.
  federal_land_area <- federal_land_area[!is.na(federal_land_area$State), c('State', 'fed_land_sq_km')]
  
  # Sum columns to calculate land area of CONUS
  federal_land_area[nrow(federal_land_area)+1, ] <- list('CONUS', sum(federal_land_area$fed_land_sq_km))
  
  
  #### STATE LAND AREA ####
  # Recode full state names to abbreviations
  state_area$State <- dplyr::case_match(state_area$State,
                                        'Alabama' ~ 'AL',
                                        'Arizona' ~ 'AZ',
                                        'Arkansas' ~ 'AR',
                                        'California' ~ 'CA',
                                        'Colorado' ~ 'CO',
                                        'Connecticut' ~ 'CT',
                                        'Delaware' ~ 'DE',
                                        'Florida' ~ 'FL',
                                        'Georgia' ~ 'GA',
                                        'Idaho' ~ 'ID',
                                        'Illinois' ~ 'IL',
                                        'Indiana' ~ 'IN',
                                        'Iowa' ~ 'IA',
                                        'Kansas' ~ 'KS',
                                        'Kentucky' ~ 'KY',
                                        'Louisiana' ~ 'LA',
                                        'Maine' ~ 'ME',
                                        'Maryland' ~ 'MD',
                                        'Massachusetts' ~ 'MA',
                                        'Michigan' ~ 'MI',
                                        'Minnesota' ~ 'MN',
                                        'Mississippi' ~ 'MS',
                                        'Missouri' ~ 'MO',
                                        'Montana' ~ 'MT',
                                        'Nebraska' ~ 'NE',
                                        'Nevada' ~ 'NV',
                                        'New Hampshire' ~ 'NH',
                                        'New Jersey' ~ 'NJ',
                                        'New Mexico' ~ 'NM',
                                        'New York' ~ 'NY',
                                        'North Carolina' ~ 'NC',
                                        'North Dakota' ~ 'ND',
                                        'Ohio' ~ 'OH',
                                        'Oklahoma' ~ 'OK',
                                        'Oregon' ~ 'OR',
                                        'Pennsylvania' ~ 'PA',
                                        'Rhode Island' ~ 'RI',
                                        'South Carolina' ~ 'SC',
                                        'South Dakota' ~ 'SD',
                                        'Tennessee' ~ 'TN',
                                        'Texas' ~ 'TX',
                                        'Utah' ~ 'UT',
                                        'Vermont' ~ 'VT',
                                        'Virginia' ~ 'VA',
                                        'Washington' ~ 'WA',
                                        'West Virginia' ~ 'WV',
                                        'Wisconsin' ~ 'WI',
                                        'Wyoming' ~ 'WY')
  
  # Keep only needed columns and rows - get rid of Alaska, etc.
  state_area <- state_area[!is.na(state_area$State), c('State', 'land_sq_km')]
  
  # Sum columns to calculate land area of CONUS
  state_area[nrow(state_area)+1, ] <- list('CONUS', sum(state_area$land_sq_km))
  
  
  #### COMBINE AND CALCULATE NON-FEDERAL LAND AREA ####
  # Combine and subtract federal area from land area to get non-federal land area (for NRI datasets)
  land_areas <- dplyr::left_join(state_area, federal_land_area, by = 'State')
  land_areas$non_fed_land_sq_km <- land_areas$land_sq_km - land_areas$fed_land_sq_km
  
  # Save table to disk
  write.csv(land_areas, here::here("data", "derived-data", "land_areas.csv"), row.names = F)
}