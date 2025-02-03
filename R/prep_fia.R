#' Prepare FIA data
#' 
#' @description
#'  Adds a CONUS value to FIA data sent by Luca
#'  
#'  @param fia_csv Path to the FIA CSV from Luca
#'  located in data/raw-data directory
#'  
#'  @return This function returns the preprocessed
#'  FIA data as a dataframe

prep_fia <- function(fia_csv){
  # Read in data and match columns to tables on Drive
  fia <- read.csv(fia_csv, stringsAsFactors = F)
  fia <- fia[, -1]                  # Drop the column of row numbers
  colnames(fia)[1] <- 'state'       # Match case with other tables
  
  # Calculate CONUS estimates where possible (2011-2019)
  conus_fia <- fia[, -1]    # Make a copy of FIA df without the state field -- don't need for aggregation
  conus_fia <- stats::aggregate(. ~ dataset_id, conus_fia, sum, na.action = na.pass)
  
  # Add state = CONUS and append back to the main FIA df
  conus_fia$state <- 'CONUS'
  fia <- dplyr::bind_rows(fia, conus_fia)
  
  # Return DF
  return(fia)
}