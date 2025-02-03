#' Calculate percent forest
#' 
#' @description
#' Calculates percent forest (as a percent of land area) for the lower
#' 48 states and CONUS each year from 2000-2019. The result is used
#' as the input for linear models.
#' 
#' @param df The dataframe of forest area estimates returned by
#' create_base_data()
#' 
#' @return This function returns a dataframe with the percent forest
#' estimates over the time series.

calc_percent_forest <- function(df) {
  #### CREATE PERCENT FOREST AREA FOR ALL STATES ####
  # Keep only products that have sufficient data for trend analysis
  # EPA: 1990-2019
  # FIA: Varies by state, but all have complete data 2011-2019, and most have data going back to the early 2000s
  # Hansen: 2000-2021
  # LCMAP: 1985-2021
  # LCMS: 1985-2022
  # MODIS: 2001-2021
  # NLCD: 2001-2021
  # NRI: 1987-2017
  products <- c('EPA_forest', 'FIA_forest', 'FIA_timberland', 'Hansen_GFC',
                'LCMAP_trees', 'LCMAP_trees_woodywet',
                'LCMS_forest', 'LCMS_all_trees_mixes', 'LCMS_trees', 'LCMS_trees_shrubs_mix', 
                'MODIS_1_IGBP', 'MODIS_2_UMD', 'MODIS_3_LAI', 'MODIS_4_BGC', 'MODIS_5_PFT',
                'NLCD_forest', 'NLCD_forest_woodywet', 'NRI_nonfederal_forest')
  
  # Subset df to just products used for trend analysis
  df3 <- df[df$dataset_id %in% products, ]
  
  # States to loop through
  states <- unique(df3$state)
  
  # Keep only 2000-2019
  keep.years <- c('2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008',
                  '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017',
                  '2018', '2019')
  df3 <- df3[, c('dataset_id', 'state', keep.years)]
  years <- colnames(df3)[-c(1, 2)] 
  
  # Land areas for calculating % forest
  land_areas <- read.csv(here::here("data", "derived-data", "land_areas.csv"), stringsAsFactors = F)
  
  # Calculate % forest for each year and state using land area in sq km
  # For Fig 1, only calculated % forest for CONUS... if i was smart, I would have made
  # all this data at the same time and subset it for different figures...
  # pretty sure I copied and pasted what could I could though!
  pct_df <- data.frame('dataset_id' = character(),
                       'state' = character(),
                       stringsAsFactors = FALSE)
  
  c <- 1   # Counter for inserting new rows
  for (s in states){
    for (p in products) {
      pct_df[c, 'state'] <- s
      pct_df[c, 'dataset_id'] <- p
      # If not NRI, use state land area
      if (substr(p, 1, 3) != 'NRI'){
        for (year in years){
          pct_forest <- df3[df3$state == s & df3$dataset_id == p, year] / land_areas[land_areas$State == s, 'land_sq_km'] * 100
          pct_df[c, year] <- pct_forest
        }
        # If dataset is NRI, use non-federal land area
      } else if (substr(p, 1, 3) == 'NRI'){
        for (year in years) {
          pct_forest <- df3[df3$state == s & df3$dataset_id == p, year] / land_areas[land_areas$State == s, 'non_fed_land_sq_km'] * 100
          pct_df[c, year] <- pct_forest
        }
      }
      c <- c + 1   # Increment counter to write next row
    }
  }
  return(pct_df)
}