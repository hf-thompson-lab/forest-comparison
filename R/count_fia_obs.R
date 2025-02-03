#' Count FIA observations by state
#' 
#' @description
#' This function counts the number of FIA observations in each state
#' from 2000-2019, the period used for trend analysis. It saves a CSV
#' which is Table S2 in the manuscript.
#' 
#' @param data The percent forest dataframe returned by calc_percent_forest()
#' 
#' @return Returns the number of FIA observations by state as a dataframe.

# Input = pct_df (returned by calc_percent_forest.R)
count_fia_obs <- function(data){
  # For FIA, we need to do each state separately because states have different remeasurement periods
  # Since FIA_forest and FIA_timberland share same underlying data, we only need to use one
  # This data will be in a supplemental table in the manuscript
  n_obs_fia <- data[data$dataset_id == 'FIA_forest', ]
  n_obs_fia <- reshape2::melt(n_obs_fia, id.vars = c('dataset_id', 'state'))
  colnames(n_obs_fia) <- c('dataset_id', 'state', 'year', 'sq_km')
  n_obs_fia <- n_obs_fia[!is.na(n_obs_fia$sq_km), ]
  n_obs_fia <- n_obs_fia %>%
    dplyr::group_by(dataset_id, state) %>%
    dplyr::summarise(n = dplyr::n())
  
  # Save the result so it can be added to manuscript as Table S2
  write.csv(n_obs_fia, here::here("data", "derived-data", "n_obs_fia.csv"), row.names = F)
  print("Saved number of FIA observations (Table S2)")
}
