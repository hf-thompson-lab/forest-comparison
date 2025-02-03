#' Create CONUS line charts (Figs 1, S1, S2)
#' 
#' @description
#' This function produces the three CONUS line charts in the project
#' Figure 1 (combined sq km & percent, excludes NRI), Figure S1
#' (sq km, includes NRI), and Figure S2 (percent, includes NRI).
#' Because NRI has a different denominator for land area (non-federal)
#' it cannot be in the combined area & percent line chart.
#' Legends in these figures have significance for datasets included in
#' trend analysis taken from the CSV saved in calc_lm.R.
#' 
#' @param df Dataframe of forest area estimates returned by
#' create_base_data()

#' 
#' @return This function does not return anything - it just prints
#' messages stating the figures have been saved to the figures folder.

create_line_charts <- function(df){
  ######## VARIABLES USED BY ALL 3 LINE CHARTS - FIG 1, S1, S2 ########
  # The line chart legend is manually constructed in order to combine the colors and shapes into a single legend
  # Order of dataset_id levels, colors, and shapes is VERY IMPORTANT and must match
  # If these are not in the same order, the legend will draw incorrectly but not produce any error!!!
  # 'levs', colors, and 'leg.shps' are written 3 per line to help with making sure these 3 variables are in the same order
  #
  # Reference for combining legends: https://stackoverflow.com/questions/37140266/how-to-merge-color-line-style-and-shape-legends-in-ggplot 
  
  # Factor levels for dataset_id -- this controls the order of the legend
  levs <- c('DW_trees_annual_mode', 'DW_trees_gs_mode', 'DW_trees_prob_10',
            'DW_trees_prob_25', 'DW_trees_prob_50', 'EPA_forest',
            'ESA_trees', 'ESRI_2020_trees', 'ESRI_annual_trees',
            'FIA_forest', 'FIA_timberland', 'Hansen_GFC',
            'LCMAP_trees', 'LCMAP_trees_woodywet', 'LCMS_forest', 
            'LCMS_trees', 'LCMS_trees_shrubs_mix', 'LCMS_all_trees_mixes', 
            'MODIS_1_IGBP', 'MODIS_2_UMD', 'MODIS_3_LAI', 
            'MODIS_4_BGC', 'MODIS_5_PFT', 'NLCD_canopy_10', 
            'NLCD_canopy_20', 'NLCD_canopy_60', 'NLCD_canopy_80', 
            'NLCD_canopy_perc', 'NLCD_forest', 'NLCD_forest_woodywet', 
            'NRI_nonfederal_forest')
  
  # Light mode colors
  light_colors <- c('DW_trees_annual_mode' = '#b73df4', 'DW_trees_gs_mode' = '#dea1fc','DW_trees_prob_10' = '#6000c1',
                    'DW_trees_prob_25' = '#9651db', 'DW_trees_prob_50' = '#ca9af9', 'EPA_forest' = '#000000',
                    'ESA_trees' = '#f79711', 'ESRI_2020_trees' = '#5bc10d', 'ESRI_annual_trees' = '#a0e070',
                    'FIA_forest' = '#666666', 'FIA_timberland' = '#b7b7b7', 'Hansen_GFC' = '#fc99c3', 
                    'LCMAP_trees' = '#b7407b', 'LCMAP_trees_woodywet' = '#c6749f', 'LCMS_forest' = '#0e6e5c', 
                    'LCMS_trees' = '#38761d', 'LCMS_trees_shrubs_mix' = '#6aa84f', 'LCMS_all_trees_mixes' = '#274e13', 
                    'MODIS_1_IGBP' = '#073763', 'MODIS_2_UMD' = '#0b5394', 'MODIS_3_LAI' = '#3d85c6', 
                    'MODIS_4_BGC' = '#6fa8dc', 'MODIS_5_PFT' = '#9fc5e8', 'NLCD_canopy_10' = '#a61c00', 
                    'NLCD_canopy_20' = '#cc4125', 'NLCD_canopy_60' = '#dd7e6b', 'NLCD_canopy_80' = '#e6b8af', 
                    'NLCD_canopy_perc' = '#7f0000', 'NLCD_forest' = '#e81414', 'NLCD_forest_woodywet' = '#cc0000', 
                    'NRI_nonfederal_forest' = '#39bfa9')
  
  # Dark mode colors
  dark_colors <- c('DW_trees_annual_mode' = '#a65fed', 'DW_trees_gs_mode' = '#cf9fff','DW_trees_prob_10' = '#5a750f',
                   'DW_trees_prob_25' = '#95b04c', 'DW_trees_prob_50' = '#c1d48e', 'EPA_forest' = '#ffffff',
                   'ESA_trees' = '#7a5aa4', 'ESRI_2020_trees' = '#b76b1b', 'ESRI_annual_trees' = '#f5aa07',
                   'FIA_forest' = '#666666', 'FIA_timberland' = '#b7b7b7', 'Hansen_GFC' = '#f1c232', 
                   'LCMAP_trees' = '#b7407b', 'LCMAP_trees_woodywet' = '#c6749f', 'LCMS_forest' = '#0e6e5c', 
                   'LCMS_trees' = '#38761d', 'LCMS_trees_shrubs_mix' = '#6aa84f', 'LCMS_all_trees_mixes' = '#274e13', 
                   'MODIS_1_IGBP' = '#073763', 'MODIS_2_UMD' = '#0b5394', 'MODIS_3_LAI' = '#3d85c6', 
                   'MODIS_4_BGC' = '#6fa8dc', 'MODIS_5_PFT' = '#9fc5e8', 'NLCD_canopy_10' = '#a61c00', 
                   'NLCD_canopy_20' = '#cc4125', 'NLCD_canopy_60' = '#dd7e6b', 'NLCD_canopy_80' = '#e6b8af', 
                   'NLCD_canopy_perc' = '#7f0000', 'NLCD_forest' = '#e81414', 'NLCD_forest_woodywet' = '#cc0000', 
                   'NRI_nonfederal_forest' = '#fc03d3')
  
  # Symbols following some dataset names are from the trend analysis portion. + significant increase, - significant decrease, ~ insignificant
  # Trend significance (2000-2019) is calculated in the calc_lm() function and saved in results/conus_and_state_trends_by_dataset_20240904.csv
  leg_labels <- c('DW_trees_annual_mode' = 'DW Trees (annual)', 'DW_trees_gs_mode' = 'DW Trees (growing season)',
                  'DW_trees_prob_10' = "DW Trees (10% prob.)", 'DW_trees_prob_25' = "DW Trees (25% prob.)",
                  'DW_trees_prob_50' = "DW Trees (50% prob.)", 'EPA_forest' = 'EPA Forest -', "ESA_trees" = "ESA WorldCover Trees",
                  "ESRI_2020_trees" = "ESRI Trees (2020)", "ESRI_annual_trees" = "ESRI Trees (annual)", "FIA_forest" = "FIA Forest -",
                  "FIA_timberland" = "FIA Timberland -", 'Hansen_GFC' = "Hansen Global Forest Cover -", "LCMAP_trees" = "LCMAP Trees -",
                  "LCMAP_trees_woodywet" = "LCMAP Trees, Woody wetlands -", "LCMS_forest" = "LCMS Forest +", "LCMS_trees" = "LCMS Trees ~",
                  "LCMS_trees_shrubs_mix" = "LCMS Trees, Shrubs ~", "LCMS_all_trees_mixes" = "LCMS Trees, Shrubs, Barren +",
                  "MODIS_1_IGBP" = "MODIS 1 (IGBP) ~", "MODIS_2_UMD" = "MODIS 2 (UMD) ~", "MODIS_3_LAI" = "MODIS 3 (LAI) ~", 
                  "MODIS_4_BGC" = "MODIS 4 (BGC) -",
                  "MODIS_5_PFT" = "MODIS 5 (PFT) -", "NLCD_canopy_10" = "NLCD TCC (10%)", "NLCD_canopy_20" = "NLCD TCC (20%)",
                  "NLCD_canopy_60" = "NLCD TCC (60%)", "NLCD_canopy_80" = "NLCD TCC (80%)",
                  "NLCD_canopy_perc" = "NLCD Percent TCC", "NLCD_forest" = "NLCD Forest -", 
                  "NLCD_forest_woodywet" = "NLCD Forest, Woody wetlands -",
                  'NRI_nonfederal_forest' = 'NRI Forest (non-federal) ~')
  
  # Point shapes coded with the same number code R uses to assign shape
  # This vector must match the leg.shps vector below! This vector
  # is for the points on the graph, the other is for the legend
  pt_shps <- c('DW_trees_annual_mode' = 16, 'DW_trees_gs_mode' = 16,'DW_trees_prob_10' = 17,
               'DW_trees_prob_25' = 17, 'DW_trees_prob_50' = 17, 'EPA_forest' = 17,
               'ESA_trees' = 15, 'ESRI_2020_trees' = 17, 'ESRI_annual_trees' = 17,
               'FIA_forest' = 15, 'FIA_timberland' = 15, 'Hansen_GFC' = 6, 
               'LCMAP_trees' = 15, 'LCMAP_trees_woodywet' = 16, 'LCMS_forest' = 15, 
               'LCMS_trees' = 16, 'LCMS_trees_shrubs_mix' = 16, 'LCMS_all_trees_mixes' = 16, 
               'MODIS_1_IGBP' = 17, 'MODIS_2_UMD' = 17, 'MODIS_3_LAI' = 17, 
               'MODIS_4_BGC' = 15, 'MODIS_5_PFT' = 16, 'NLCD_canopy_10' = 17, 
               'NLCD_canopy_20' = 17, 'NLCD_canopy_60' = 17, 'NLCD_canopy_80' = 17, 
               'NLCD_canopy_perc' = 15, 'NLCD_forest' = 6, 'NLCD_forest_woodywet' = 2, 
               'NRI_nonfederal_forest' = 17)
  
  # Assign legend shapes -- this variable is used for making the legend
  # And must be in the same order as levs and colors
  # 2 = hollow triange, 6 = hollow upside down triange,
  # 15 = square, 16 = circle, 17 = triangle
  leg.shps <- c(16, 16, 17,
                17, 17, 17,
                15, 17, 17,
                15, 15, 6, 
                15, 16, 15, 
                16, 16, 16, 
                17, 17, 17, 
                15, 16, 17, 
                17, 17, 17, 
                15, 6, 2, 
                17)
  
  ######## CREATE LINE CHART DATA ########
  #### SQ KM DF ####
  # Extract the CONUS rows and drop the state column
  df1 <- df[df$state == 'CONUS', -2]
  
  # Melt to long and coerce year column from factor to numeric
  df1.long <- reshape2::melt(df1, id.vars = 'dataset_id')
  colnames(df1.long) <- c('dataset_id', 'year', 'km2')
  df1.long$year <- as.numeric(as.character(df1.long$year))
  
  # Set factor levels
  df1.long$dataset_id <- factor(df1.long$dataset_id, levels = levs)
  
  #### PCT DF ####
  # Join land areas by state
  # Land areas for calculating % forest
  land_areas <- read.csv(here::here("data", "derived-data", "land_areas.csv"), stringsAsFactors = F)
  df2 <- dplyr::left_join(df, land_areas, by = c('state' = 'State'))
  
  # Keep just the CONUS rows and drop the state column
  df2 <- df2[df2$state == 'CONUS', -2]
  
  # Calculate % forest based on dataset_id
  # NRI datasets use nonfederal land as denominator
  # All other datasets use CONUS land area
  # Just need to match each total with correct denominator
  products <- unique(df$dataset_id)
  years <- colnames(df2)[-c(1, 41, 42, 43)]    # Get years from DF column names 
  
  # Dataframe to store results
  pct_df <- data.frame('dataset_id' = character(),
                       stringsAsFactors = FALSE)
  
  c <- 1   # Counter for inserting new rows
  for (p in products) {
    pct_df[c, 'dataset_id'] <- p
    # First check to see if NRI
    if (substr(p, 1, 3) == 'NRI'){
      for (year in years) {
        # Divide by non-federal land area (doesn't matter which row since all are the same, the sum of CONUS states)
        pct_forest <- df2[df2$dataset_id == p, year] / df2[1, 'non_fed_land_sq_km'] * 100
        pct_df[c, year] <- pct_forest
      }
    } else{   # Then all other datasets
      for (year in years){
        # Divide by land area (doesn't matter which row since all are the same)
        pct_forest <- df2[df2$dataset_id == p, year] / df2[1, 'land_sq_km'] * 100
        pct_df[c, year] <- pct_forest
      }
    } 
    c <- c + 1   # Increment counter to write next row
  }
  
  # Melt to long and coerce year column from factor to numeric
  df.pct.long <- reshape2::melt(pct_df, id.vars = 'dataset_id')
  colnames(df.pct.long) <- c('dataset_id', 'year', 'pct')
  df.pct.long$year <- as.numeric(as.character(df.pct.long$year))
  
  # Set the factor levels
  df.pct.long$dataset_id <- factor(df.pct.long$dataset_id, levels = levs)
  
  #### COMBINE AREA AND PERCENT DATA ####
  # All line charts will pull from this dataframe
  df_combined <- dplyr::left_join(df1.long, df.pct.long[, -4], by = c('dataset_id', 'year'))
  
  # Add column to store point shape code based on pt_shps named vector
  df_combined$pntshp <- pt_shps[match(df_combined$dataset_id, names(pt_shps))]
  
  
  ######## CREATE FIGURE 1 - COMBINED SQ KM & PCT ########
  # This version does not have NRI, so need to get variables above without that dataset
  levs2 <- levs[-31]
  leg.shps2 <- leg.shps[-31]
  light_colors2 <- light_colors[-31]
  labels2 <- leg_labels[-31]
  
  # Get CONUS land area for calculating secondary axis (% land area)
  conus_land_area <- land_areas[land_areas$State == 'CONUS', 'land_sq_km']
  
  # Remove NRI_nonfederal_forest from data and reset factor levels
  df_fig1 <- df_combined[df_combined$dataset_id != "NRI_nonfederal_forest", ]
  df_fig1$dataset_id <- factor(df_fig1$dataset_id, levels = levs2)
  
  # Assign shapes that match the point shape code in the data
  pnt_values <- c('16' = 16, '17' = 17, '1' = 1, '15' = 15, '4' = 4, '6' = 6, '2' = 2, '3' = 3, '12' = 12,
                  '0' = 0, '7' = 7, '13' = 13, '18' = 18)
  
  # IMPORTANT NOTES:
  # na.omit() is needed to draw lines between discontinuous products
  # guides() is used to merge the point and line legends into one (hence the need to manually define point shapes for legend)
  combined_line_chart <- ggplot(na.omit(df_fig1), aes(x = year, y = km2, color = dataset_id, shape = as.factor(pntshp))) +
    geom_point(size = 1.1) + geom_line(linewidth = 0.5) +
    scale_color_manual(values = light_colors2, name = "Dataset", labels = labels2) + 
    scale_shape_manual(values = pnt_values, labels = labels2, guide = "none") +
    scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale()), name = bquote("Area"~(km^2)), 
                       sec.axis = sec_axis(~ . / conus_land_area * 100, name = "Percent of Land Area")) +
    xlab('Year') + theme_bw() + ggtitle("Tree and Forest Area Estimates: CONUS") +
    guides(colour = guide_legend(override.aes = list(shape = leg.shps2, color = light_colors2), ncol = 1)) +
    theme(legend.text = element_text(size = 9))
  #combined_line_chart
  ggsave(here::here("figures", "conus_linechart_fig1_20240904.png"), combined_line_chart,
         width = 6.5, height = 9)
  print('Saved Figure 1')
  
  
  ######## CREATE FIGURE S1 ########
  # Drop the pct column from df_combined
  df_area <- df_combined[, -4]
  
  # Make the plot!
  g <- ggplot(na.omit(df_area), aes(x = year, y = km2, color = dataset_id, shape = as.factor(pntshp))) + 
    geom_point(size = 1.1) + geom_line(linewidth = 0.5) + 
    scale_colour_manual(values = light_colors, name = 'Dataset', labels = leg_labels) +
    scale_shape_manual(values = pnt_values, labels = leg_labels, guide = 'none') +
    scale_y_continuous(labels = scales::label_number(scale_cut = scales::cut_short_scale()), name = bquote('Area'~(km^2))) + 
    xlab('Year') + theme_bw() + #dark_theme_bw() + 
    guides(colour = guide_legend(override.aes = list(shape = leg.shps, color = light_colors), ncol = 1)) +
    theme(legend.text = element_text(size = 9)) + ggtitle('Tree and Forest Area Estimates: CONUS')
  #g
  
  ggsave(here::here("figures", "conus_linechart_sq_km_figS1_20240904.png"), g, width = 6.5, height = 8.5)
  print('Saved Figure S1')
  
  
  ######## CREATE FIGURE S2 ########
  # Drop the sq km column from combined DF
  df_pct <- df_combined[, -3]
  
  # IMPORTANT NOTES:
  # na.omit() is needed to draw lines between discontinuous products
  # guides() is used to merge the point and line legends into one (hence the need to manually define point shapes for legend)
  g.pct <- ggplot(na.omit(df_pct), aes(x = year, y = pct, color = dataset_id, shape = as.factor(pntshp))) + 
    geom_point(size = 1.1) + geom_line(linewidth = 0.5) + 
    scale_colour_manual(values = light_colors, name = 'Dataset', labels = leg_labels) +
    scale_shape_manual(values = pnt_values, labels = leg_labels, guide = 'none') +
    scale_y_continuous(name = 'Percent of Land Area') + xlab('Year') + theme_bw() + #dark_theme_bw() + 
    guides(colour = guide_legend(override.aes = list(shape = leg.shps, color = light_colors), ncol = 1)) + 
    ggtitle('Percent Tree and Forest Area Estimates: CONUS')
  # g.pct
  
  ggsave(here::here("figures", "conus_linechart_pct_figS2_20240904.png"), g.pct, width = 6.5, height = 8.5)
  print('Saved Figure S2')
}
