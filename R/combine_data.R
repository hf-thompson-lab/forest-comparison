#' Combine and save all data
#' 
#' @description
#' This function retrieves and combines all CSVs stored
#' on Google Drive. It replaces the existing EPA and FIA
#' data with updated data from those sources and saves the
#' result as a new CSV and optionally uploads it back to Google Drive.
#' 
#' @param epa Dataframe of preprocessed updated EPA data
#' returned by prep_epa()
#' 
#' @param fia Dataframe of preprocessed updated FIA data
#' returned by prep_fia()
#' 
#' @param upload Should the function upload the result to
#' Google Drive? It is recommended this parameter be set to
#' FALSE unless the user wants to recreate a file directory
#' in the same structure as the one used by the authors.
#' Setting this parameter as FALSE also accesses googledrive
#' in an unauthenticated state (i.e., you don't need to log in
#' or give permissions to your account).
#' 
#' @return This function does not return any R object.

combine_data <- function(epa, fia, upload = c(TRUE, FALSE)) {
  # Name of folder on Google Drive that contains CSVs to merge
  csv_folder <- 'v5-1_merged'
  
  # Path to write merged CSVs to (on disk)
  out_path <- paste0(here::here(), '/data/derived-data/')
  
  # File name of merged CSV to create
  out_fn <- 'lower48_v5-1_20240904.csv'
  
  ### GET ALL DATA FROM GOOGLE DRIVE ####
  # Suspend authorization so no log in required
  # If upload = TRUE then 
  if (upload == FALSE){
    googledrive::drive_deauth()
    googledrive::drive_user()
  }
  
  # Get CSVs in Forest-Product-Comparison/datasets/csv_folder directory
  # Note: Using the link allows someone not logged into Google to access files, whereas
  # using a text path to the folder produced an error
  files <- googledrive::drive_ls(path = "https://drive.google.com/drive/u/0/folders/1U_VfSVFpdLIgk4dnqr5TIHQzshm0EZou", type = "csv")
  
  # Create list of dataframes with CSV data
  file_ids <- files$id                    # retrieve Google File IDs
  csv_dfs <- vector('list', nrow(files))  # initialize empty list as long as # of CSVs
  
  # Populate csv_dfs list by reading all CSVs in the folder by ID
  i <- 1
  for (id in file_ids) {
    csv_dfs[[i]] <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id))
    i <- i + 1
  }
  
  #### COMBINE ALL GOOGLE DRIVE DATA ####
  # Merge list contents into one dataframe
  out_df <- dplyr::bind_rows(csv_dfs)
  
  # Set state to CONUS where it is currently NA
  # This table did not have a state column
  out_df[is.na(out_df$state), 'state'] <- 'CONUS'
  
  #### REPLACE EXISTING FIA DATA ####
  # Replace FIA rows with new FIA data from Luca
  `%!in%` <- Negate(`%in%`)     # Create 'not in' operator
  fia_datasets <- c('FIA_forest', 'FIA_timberland', 'FIA_forest_upper', 'FIA_forest_lower', 'FIA_timberland_upper', 'FIA_timberland_lower')
  out_df <- out_df[out_df$dataset_id %!in% fia_datasets, ]   # Keep only non-FIA rows
  
  out_df <- dplyr::bind_rows(out_df, fia)
  
  #### REPLACE EXISTING EPA DATA ####
  # Replace EPA rows with updated EPA data from Walters et al 2023
  out_df <- out_df[out_df$dataset_id != 'EPA_forested', ]   # Remove existing EPA rows from out_df
  out_df <- dplyr::bind_rows(out_df, epa)
  
  #### SAVE RESULT AND UPLOAD TO GOOGLE DRIVE ####
  # Save CSV to disk
  merged_csv <- paste0(out_path, out_fn)
  write.csv(out_df, merged_csv, row.names = F)
  print("Saved merged CSV to derived-data folder")
  
  # Upload to drive -- note that this CANNOT be used when in an unauthenticated state
  if (upload == TRUE) {
    googledrive::drive_upload(media = merged_csv, path = 'Forest-Product-Comparison/datasets/lower48/')
  }
}