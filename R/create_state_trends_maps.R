#' Create state trends maps
#' 
#' @description
#' This function creates and saves the multi-panel
#' state trends maps (Figure 3).
#' 
#' @param pct_df Dataframe of percent forest
#' from 2000-2019 returned by calc_percent_forest().
#' 
#' @param trend_df Dataframe summarizing linear trend
#' results returned by calc_lm()
#' 
#' @return The function does not return an object but
#' saves a PNG of the resulting figure to disk.

create_state_trends_maps <- function(pct_df, trend_df) {
  # Legend labels - dropping the symbols used in Fig 1 to indicate trend significance
  leg_labels <- c('DW_trees_annual_mode' = 'DW Trees (annual)', 'DW_trees_gs_mode' = 'DW Trees (growing season)',
                  'DW_trees_prob_10' = "DW Trees (10% prob.)", 'DW_trees_prob_25' = "DW Trees (25% prob.)",
                  'DW_trees_prob_50' = "DW Trees (50% prob.)", 'EPA_forest' = 'EPA Forest', 
                  "ESA_trees" = "ESA WorldCover Trees",
                  "ESRI_2020_trees" = "ESRI Trees (2020)", "ESRI_annual_trees" = "ESRI Trees (annual)", 
                  "FIA_forest" = "FIA Forest",
                  "FIA_timberland" = "FIA Timberland", 'Hansen_GFC' = "Hansen Global Forest Cover", 
                  "LCMAP_trees" = "LCMAP Trees",
                  "LCMAP_trees_woodywet" = "LCMAP Trees, Woody wetlands", "LCMS_forest" = "LCMS Forest", 
                  "LCMS_trees" = "LCMS Trees",
                  "LCMS_trees_shrubs_mix" = "LCMS Trees, Shrubs", 
                  "LCMS_all_trees_mixes" = "LCMS Trees, Shrubs, Barren",
                  "MODIS_1_IGBP" = "MODIS 1 (IGBP)", "MODIS_2_UMD" = "MODIS 2 (UMD)", 
                  "MODIS_3_LAI" = "MODIS 3 (LAI)", "MODIS_4_BGC" = "MODIS 4 (BGC)",
                  "MODIS_5_PFT" = "MODIS 5 (PFT)", "NLCD_canopy_10" = "NLCD TCC (10%)", 
                  "NLCD_canopy_20" = "NLCD TCC (20%)",
                  "NLCD_canopy_60" = "NLCD TCC (60%)", "NLCD_canopy_80" = "NLCD TCC (80%)",
                  "NLCD_canopy_perc" = "NLCD Percent TCC", "NLCD_forest" = "NLCD Forest", 
                  "NLCD_forest_woodywet" = "NLCD Forest, Woody wetlands",
                  'NRI_nonfederal_forest' = 'NRI Forest (non-federal)', 'MODIS_1_2_3' = 'MODIS 1, 2 & 3')
  
  # Clean up the trend significance labels
  trend_df$trend <- ifelse(trend_df$trend == 'decrease', 'Decrease',
                                  ifelse(trend_df$trend == 'increase', 'Increase',
                                         ifelse(trend_df$trend == 'not sig', 'Not significant', NA)))

  # Drop CONUS
  trend_df_no_conus <- trend_df[trend_df$state != 'CONUS', ]
  
  # Retrive the number of observation used per dataset from pct_df
  # which is the basis for this analysis/figure
  # For all datasets except FIA, states have the same number of obs per dataset
  n_obs <- pct_df[pct_df$dataset_id != 'FIA_forest' & pct_df$dataset_id != 'FIA_timberland', ]  # Drop FIA rows
  n_obs <- n_obs[n_obs$state == 'CONUS', -2]   # Since n is same for all states, just use CONUS & drop state col
  
  # Melt to long
  n_obs <- reshape2::melt(n_obs, id.vars = 'dataset_id')
  colnames(n_obs) <- c('dataset_id', 'year', 'sq_km')
  
  # Remove rows where sq_km is NA
  n_obs <- n_obs[!is.na(n_obs$sq_km), ]
  
  # Summarize to get number of observation per dataset
  n_obs <- n_obs %>%
    dplyr::group_by(dataset_id) %>%
    dplyr::summarise(n = dplyr::n())
  
  # Convert n to character
  n_obs$n <- as.character(n_obs$n)
  
  # FIA needs to be handled differently
  # because the label is much longer than those of other datasets
  # So we use a separate dataframe that points reader to Table S2
  n_obs_fia <- data.frame(dataset_id = c('FIA_forest', 'FIA_timberland'),
                          n = rep('See Table S1', times = 2),
                          stringsAsFactors = F)
  
  # Formatting the multipanel state trend figure for publication
  # Position values for geom_text based on axis range:
  # https://stackoverflow.com/questions/7705345/how-can-i-extract-plot-axes-ranges-for-a-ggplot2-object
  inc.dec2 <- usmap::plot_usmap(regions = 'states', exclude = c('AK', 'HI', 'DC'), 
                         data = trend_df_no_conus, values = 'trend') +
    scale_fill_manual(values = c('Increase' = '#4daf4a', 'Decrease' = '#a65628', 'Not significant' = 'white'), 
                      name = 'Trend: ') +
    facet_wrap(~ dataset_id, ncol = 3, labeller = labeller(dataset_id = leg_labels)) + 
    geom_text(x = -1900000, y = -1950000, aes(label = n), data = n_obs, size = 2.8) +
    geom_text(x = -1300000, y = -1950000, aes(label = n), data = n_obs_fia, size = 2.2) +
    theme_bw() + 
    theme(legend.position = 'top',
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          plot.title = element_text(size = 12),
          plot.subtitle = element_text(size = 10),
          legend.title = element_text(size = 10),
          legend.text = element_text(size = 9),
          strip.text = element_text(size = 8),
          plot.margin = unit(c(0, 0, 0, 0), 'cm')) +
    ggtitle('Linear trend in percent forest/tree area, 2000-2019')
  ggsave(here::here("figures", "state_trends_2000-2019_fig3.png"), 
         inc.dec2, width = 6.5, height = 9)
  print("Saved Figure 3 (state trends maps)")
}
