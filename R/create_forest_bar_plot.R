#' Create forest bar plot
#' 
#' @description
#' Creates and saves a bar plot of change
#' from previous measurement for Figure 2.
#' 
#' @param df Dataframe of bar plot data
#' returned by create_forest_bar_plot_data() or
#' create_tree_bar_plot_data()
#' 
#' @param type Type of bar plot, either "tree"
#' or "forest". This parameter will change the plot
#' title and output file name.
#' 
#' @return This function does not return anything but
#' saves figure to disk in the figures folder.

create_forest_bar_plot <- function(df, type = c("tree", "forest")) {
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
                  'NRI_nonfederal_forest' = 'NRI Forest (non-federal)')
  
  # Categorize change and set factor levels
  df$change <- ifelse(df$sq_km > 15000, "Large increase",
                                        ifelse(df$sq_km > 0, "Increase",
                                               ifelse(df$sq_km < -15000, "Large decrease",
                                                      ifelse(df$sq_km < 0, "Decrease", "No change"))))
  df$change <- factor(df$change,
                      levels = c("Large increase", "Increase", "No change", "Decrease", "Large decrease"))
  
  # Set title and output file name depending on whether tree or forest
  if (type == "forest") {
    plot_title <- "Change from previous forest area estimate: CONUS"
    out_name <- "conus_forest_change_norm_fig2B.png"
  } else if (type == "tree") {
    plot_title <- "Change from previous tree cover estimate: CONUS"
    out_name <- "conus_tree_cover_change_norm_fig2A.png"
  }
  
  # Make the plot -- note that although scale_pattern_manual is used, it doesn't work well
  # and this figure was finished in Adobe Illustrator to apply the stripes to the legend
  normbp.conus <- ggplot(na.omit(df), aes(x = year, y = sq_km, fill = change, pattern = change)) + 
    ggpattern::geom_col_pattern(color = "black", pattern_fill = "black", 
                                pattern_spacing = 0.1, pattern_size = 0.4) + 
    facet_wrap(~ dataset_id, ncol = 1, scales = "free_y", labeller = labeller(dataset_id = leg_labels)) +
    ggtitle(plot_title) +
    labs(x = "Year", y = "Change from previous measurement (sq km)") + theme_bw() +
    scale_fill_manual(values = c("Large increase" = "#4daf4a", "Increase" = "#4daf4a", "No change" = "grey80",
                                 "Decrease" = '#a65628', "Large decrease" = '#a65628'),
                      name = "Change") +
    ggpattern::scale_pattern_manual(values = c("Large increase" = "stripe", "Increase" = "none",
                                               "No change" = "none",
                                               "Decrease" = "none", "Large decrease" = "stripe"),
                                    name = "Change") +
    scale_x_continuous(breaks = c(1986:2022), expand = c(0, 0)) +
    scale_y_continuous(labels = scales::comma) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey") +
    theme(axis.text.x = element_text(angle = 90, margin = margin(2, 0, 0, 0), vjust = 0.2),
          panel.grid.minor.x = element_blank())
  
  # Save the figure
  ggsave(paste0(here::here(), "/figures/", out_name), 
         normbp.conus, width = 6.5, height = 9)
  print(paste0("Saved ", type, " bar plot to figures folder"))
}
