#' Create base data
#' 
#' @description
#' This function creates the data that is the basis of all the figures
#' and statistical analyses done for the forest comparison project.
#' It reads in data from Google Drive (or disk, you can comment out lines
#' you don't want), renames columns, and does a few other minor data
#' cleaning tasks to prepare for analysis.
#' 
#' @param from_drive Should the merged data be read from Google Drive?
#' If FALSE, it will be read in from disk (saved in combine_data()).
#' 
#' @return This function returns a dataframe of the forest dataset area
#' estimates. 

create_base_data <- function(from_drive = c(TRUE, FALSE)){
  if (from_drive == TRUE) {
    id <- "1PFjCG1xa--od_SDRpytgm32n1hQmoEgy"  # google file ID for lower48_v5-1_20240904.csv
    df <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id),
                   stringsAsFactors = FALSE)
  } else {
    df <- read.csv(here::here("data", "derived-data", "lower48_v5-1_20240904.csv"),
                   stringsAsFactors = F)
  }
  
  # Remove X from in front of year column names -- this is critical for coercing from factor
  # to numeric after melting to long format
  # NOTE: R always adds the X to numeric column names when reading in CSV, so this always needs to be run!
  colnames(df) <- c('dataset_id', 'state', '1985', '1986', '1987', '1988', '1989', '1990', '1991', '1992',
                    '1993', '1994', '1995', '1996', '1997', '1998', '1999', '2000', '2001', '2002', '2003',
                    '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014',
                    '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022')
  
  # Remove NRI_grazed and NRI_notgrazed
  df <- df[df$dataset_id != 'NRI_grazed' & df$dataset_id != 'NRI_notgrazed', ]
  
  # Set any FIA data prior to 2000 to NA -- only pre-2000 data is 1997, 1998, and 1999
  df[df$dataset_id %in% c('FIA_forest', 'FIA_timberland'), '1997'] <- NA
  df[df$dataset_id %in% c('FIA_forest', 'FIA_timberland'), '1998'] <- NA
  df[df$dataset_id %in% c('FIA_forest', 'FIA_timberland'), '1999'] <- NA
  
  # Update dataset names to make them more intuitive for plotting
  df[df$dataset_id == 'NRI_total', 'dataset_id'] <- 'NRI_nonfederal_forest'
  df[df$dataset_id == 'EPA_forested', 'dataset_id'] <- 'EPA_forest'
  
  return(df)
}
