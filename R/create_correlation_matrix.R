#' Create correlation matrix
#' 
#' @description
#' Creates and saves the correlation matrix (Figure 3)
#' 
#' @param df Main dataframe returned by create_base_data()
#' 
#' @return This function does not return anything but saves
#' the correlation matrix to the figures folder

create_correlation_matrix <- function(df) {
  #### PREPARE DATA FOR CORRELATION CALCULATION #####
  # Note: Including NRI results in an error, most likely because there is not enough data to calculate significance
  # Therefore, NRI is excluded from this figure
  
  # Get CONUS data
  cor.df <- df[df$state == 'CONUS', -2]
  
  # Limit to 2000-2019
  cor.df <- cor.df[, c("dataset_id", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010",
                       "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019")]
  
  labels <- c('EPA Forest', "FIA Forest", "FIA Timberland", "Hansen Global Forest Cover", "LCMAP Trees",
              "LCMAP Trees, Woody wetlands", "LCMS Trees, Shrubs, Barren", "LCMS Forest", "LCMS Trees",
              "LCMS Trees, Shrubs", "MODIS 1 (IGBP)", "MODIS 2 (UMD)", "MODIS 3 (LAI)", "MODIS 4 (BGC)",
              "MODIS 5 (PFT)", "NLCD Forest", "NLCD Forest, Woody wetlands")
  
  # Datasets to include -- everything with at least 5 estimates over the trend period (2000-2019)
  # NRI only has 4, DW trees and ESRI only have 3
  datasets <- c("LCMAP_trees", "LCMAP_trees_woodywet", "LCMS_all_trees_mixes", "LCMS_forest", "LCMS_trees",
                "LCMS_trees_shrubs_mix", "Hansen_GFC", "MODIS_1_IGBP", "MODIS_2_UMD", "MODIS_3_LAI", "MODIS_4_BGC",
                "MODIS_5_PFT", "EPA_forest", "NLCD_forest", "NLCD_forest_woodywet", "FIA_timberland", "FIA_forest")
  cor.df <- cor.df[cor.df$dataset_id %in% datasets, ]
  
  # Format data for correlation
  cor.df2 <- reshape2::melt(cor.df, id.vars = 'dataset_id')
  colnames(cor.df2) <- c("dataset_id", "year", "sq_km")
  
  cor.df3 <- reshape2::acast(cor.df2, year ~ dataset_id)
  
  ##### CORRELATE #####
  # The corr.test function in psych package provides significance with the coefficients
  x <- psych::corr.test(cor.df3, method = "pearson")
  
  # Extract the correlation coefficients and their significance
  coefs <- x$r
  pvals <- x$p
  
  # Set column and row names for the matrix
  rownames(coefs) <- labels
  colnames(coefs) <- labels
  
  ###### VISUALIZE #####
  # Visualize the correlation matrix with coefficients overlaid on significant pairs
  # Leaving insignificant correlations blank (white, no label)
  # With NRI included, this produces an error because it gives a -1 coef (which seems wrong) for NRI and FIA
  # but NaN for the p-value. So they can't be plotted together...
  correlation_matrix <- ggcorrplot::ggcorrplot(coefs, method = "square", ggtheme = theme_dark(), 
                                               p.mat = pvals, insig="blank",
                                               colors = c("#a65628", "white", "#4daf4a"),
                                               lab = TRUE, lab_size = 2.5, type = "lower", tl.col = "black", tl.cex = 10, 
                                               title = "Correlation of CONUS Tree / Forest Data, 2000-2019", 
                                               legend.title = "")
  ggsave(here::here("figures", "cormat_20250910.png"), correlation_matrix, width = 7)
  print("Saved correlation matrix to figures folder")
}
