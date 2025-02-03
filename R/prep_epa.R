#' Prepare EPA GHG Inventory Data
#' 
#' @description
#' Takes EPA GHG Inventory data (Walters et al., 2023)
#' downloaded from https://doi.org/10.2737/RDS-2023-0020
#' and prepares it in a format compatible with other forest
#' datasets for comparison (e.g., adding value for CONUS).
#' 
#' @param epa_csv Path to CSV of Walters et al 2023 EPA GHG data
#' 
#' @return This function returns the preprocessed EPA data
#' as a dataframe

prep_epa <- function(epa_csv){
  # Read in data
  epa <- read.csv(epa_csv, stringsAsFactors = F)
  
  # Clean the data to get forested land area in similar format to other data
  colnames(epa)[2] <- 'LU'  # Rename the second column which has a super long name
  epa <- epa[epa$LU == 'Total Forest Land', ]  # Keep only the rows where LU = Total Forest Land
  epa <- epa[epa$State != 'Alaska', -2]  # Drop Alaska and the LU column (no longer needed)
  colnames(epa)[1] <- 'state'  # Set State column to lowercase to match other data
  epa$state <- dplyr::case_match(epa$state,
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
  
  # Calculate CONUS estimates based on state data
  conus_epa <- epa[, -1]  # Drop the state column in new conus df
  conus_epa <- as.data.frame(colSums(conus_epa))  # Aggregate by columns (years)
  conus_epa$year <- row.names(conus_epa)   # Years are in the row names -- make this a new column
  conus_epa$dataset_id <- 'EPA Forest'   # And add a dataset name to use as value.var in dcast
  colnames(conus_epa)[1] <- 'LU'
  conus_epa <- reshape2::dcast(conus_epa, dataset_id ~ year, value.var = 'LU', id.vars = 'dataset_id')
  conus_epa$state <- 'CONUS'
  
  # Combine the CONUS rows with the state rows
  epa <- dplyr::bind_rows(epa, conus_epa)
  epa$dataset_id <- 'EPA_forested'   # Set dataset_id for all rows
  
  # According to metadata, this data is in thousands of hectares
  # We need to convert it to sq km to match data on Google Drive
  # For my sanity, we'll convert from thousands of hectares to hectares
  # and then from hectares to sq km
  epa_ha <- epa %>%
    dplyr::mutate_if(is.numeric, ~ . * 1000)
  epa_sq_km <- epa_ha %>%
    dplyr::mutate_if(is.numeric, ~ . / 100)
  
  # Return the preprocessed EPA data
  return(epa_sq_km)
}