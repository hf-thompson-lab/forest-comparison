#' Create data for pie charts
#' 
#' @description
#' Creates the data underlying Figure 5
#' pie charts. Saves two CSVs summarizing number
#' of increasing, decreasing, and insignificant
#' trends -- one for lower 48 states and one for CONUS.
#' 
#' @param trend_df Dataframe of linear trend results
#' returned by calc_lm()
#' 
#' @return This function does not return any objects
#' but saves two CSVs to disk in the results folder.

create_pie_chart_data <- function(trend_df) {
  # Datasets used for trend analysis
  products <- c('EPA_forest', 'FIA_forest', 'FIA_timberland', 'Hansen_GFC',
                'LCMAP_trees', 'LCMAP_trees_woodywet',
                'LCMS_forest', 'LCMS_all_trees_mixes', 'LCMS_trees', 'LCMS_trees_shrubs_mix', 
                'MODIS_1_IGBP', 'MODIS_2_UMD', 'MODIS_3_LAI', 'MODIS_4_BGC', 'MODIS_5_PFT',
                'NLCD_forest', 'NLCD_forest_woodywet', 'NRI_nonfederal_forest')
  states <- unique(trend_df$state)
  
  # Number of increase / decrease by state
  state_count_df <- data.frame('state' = character(0),
                               'n_increase' = numeric(0),
                               'n_decrease' = numeric(0),
                               'diff' = numeric(0),
                               'n_notsig' = numeric(0),
                               stringsAsFactors = FALSE)
  c <- 1
  for (s in states){
    ss <- trend_df[trend_df$state == s, ]
    gains <- nrow(ss[ss$trend == 'increase', ])
    losses <- nrow(ss[ss$trend == 'decrease', ])
    diff <- gains - losses
    notsig <- nrow(ss[ss$trend == 'not sig', ])
    
    state_count_df[c, 'state'] <- s
    state_count_df[c, 'n_increase'] <- gains
    state_count_df[c, 'n_decrease'] <- losses
    state_count_df[c, 'diff'] <- diff
    state_count_df[c, 'n_notsig'] <- notsig
    c <- c + 1
  }
  
  # Tables of counts of sig/insig trends by state/CONUS for use in Figure 5 (pie charts on map)
  # Save a version of just the lower 48 (main map) and one of just CONUS (inset map)
  write.csv(state_count_df[state_count_df$state != 'CONUS', -4],
            here::here("results", "state_trend_counts_20240904.csv"),  
            row.names = F)
  write.csv(state_count_df[state_count_df$state == 'CONUS', -4], 
            here::here("results", "conus_trend_counts_20240904.csv"), 
            row.names = F)
  print("Saved data for Figure 5 pie charts")
}
