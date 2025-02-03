#' Prepare NRI data
#' 
#' @description
#' This function prepares NRI non-federal forest data which was downloaded from
#' https://publicdashboards.dl.usda.gov/t/FPAC_PUB/views/RCADVLandUseDownloadNRI20171/LandUseDownload
#' Data was downloaded as a CSV with the following parameters:
#  Area: (All)
#  Land Type: Forest Land, Non-Federal
#  Year: (All)
#  Prime Farmland: Total
#  Land Detail: Hide
#  Irrigation Detail: Hide
#' 
#' @return This function does not return anything to the environment, but saves a new CSV to disk
#' in derived-data which is then uploaded to Google Drive where most of the other data live

prep_nri <- function() {
  # Read in the downloaded CSV
  dat <- read.csv(here::here("data", "raw-data", "nri_grazed_nongrazed_nonfederal_forest.csv"), 
                  header = T, fileEncoding = "UTF-16LE", sep = '\t', stringsAsFactors = F)
  
  # Check to see if any values are not significantly different from zero
  # summary(dat$X.1.if.estimate.significant.from.zero)   # All values are 1 indicating significant non-zero
  
  # Subset columns
  dat <- dat[, c("Area", "Detail", "Year", "Estimate")]
  
  # Remove Hawaii
  dat <- dat[dat$Area != 'Hawaii', ]
  
  # Change state names to abbreviations
  dat$state <- dplyr::case_match(dat$Area,
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
  
  # Reformat estimate from millions of acres to acres
  dat$acres <- dat$Estimate * 1000000
  
  # Reduce columns again
  dat <- dat[, c('state', 'Detail', 'Year', 'acres')]
  
  # Calculate total non-federal forest from 'grazed' and 'not grazed' categories
  # Cast from long to wide -- want to get grazed and non-grazed as separate columns
  datw <- reshape2::dcast(dat, state+Year~Detail)
  
  # Calculate total non-federal forest (grazed + non-grazed)
  datw$totalf <- datw$Grazed + datw$`Not Grazed`
  
  # Rename columns
  colnames(datw) <- c('state', 'year', 'grazed', 'notgrazed', 'total')
  
  # Reshape to match format of other CSVs
  dat.final <- reshape2::melt(datw, id.vars = c('state', 'year'))
  colnames(dat.final) <- c('state', 'year', 'forest_type', 'acres')
  dat.final2 <- reshape2::dcast(dat.final, state+forest_type~year)
  
  # Save as CSV, which is then uploaded to Google Drive to be incorporated with the rest of the data (except FIA)
  write.csv(dat.final2, here::here("data", "derived-data", "nri_grazed_notgrazed_total_forest_acres.csv"), row.names = F)
  print('Saved prepared NRI data to derived-data folder')
}