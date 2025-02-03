#' Calculate linear models
#' 
#' @description
#' This function calculates linear models of % forest over time for
#' the lower 48 states and CONUS. It categorizes trend significance
#' into increase, decrease, or not sig (N/S) based on 0.05 p value.
#' It saves a summary of the LMs (slope, p-value, classification, etc.)
#' to CSV in the results folder. The CONUS rows from that table are
#' used to add trend significance to the legends in Figs 1, S1, and S2.
#' 
#' @param pct_df The dataframe of percent forest 2000-2019 returned
#' by calc_percent_forest()
#' 
#' @return Returns a dataframe containing the summarized linear models.

calc_lm <- function(pct_df) {
  #### CREATE & SUMMARIZE LINEAR MODELS ####
  # Loop through products & states to construct a linear model for each state/product
  # Big dataframe to add each product results (key coefficients / stats) to
  big_df <- data.frame('dataset_id' = character(0),
                       'state' = character(0),
                       'intercept' = numeric(0),
                       'slope' = numeric(0),
                       'rsquared' = numeric(0),
                       stringsAsFactors = FALSE)
  
  # Create vectors of states and products to loop through from pct_df
  products <- unique(pct_df$dataset_id)
  states <- unique(pct_df$state)
  
  # outer loop is product
  for (p in products){
    # make a 49-row out_df for each product (lower 48+CONUS)
    out_df <- data.frame('dataset_id' = character(49),
                         'state' = character(49),
                         'intercept' = numeric(49),
                         'slope' = numeric(49),
                         'rsquared' = numeric(49),
                         'slope_sig' = character(49),
                         stringsAsFactors = FALSE)
    # populate product_id and state columns
    out_df$dataset_id <- p
    out_df$state <- unique(pct_df$state)
    # inner loop is state
    for (s in states){
      # Subset to product of interest
      ss <- pct_df[pct_df$dataset_id == p & pct_df$state == s, ]
      # Transform from wide to long
      ss <- reshape2::melt(ss, id.vars = c('dataset_id', 'state'))
      colnames(ss) <- c('dataset_id', 'state', 'year', 'pct')
      ss$year <- as.numeric(as.character(ss$year))
      # Construct model
      model <- lm(pct ~ year, ss)
      model.summary <- summary(model)
      # Classify slope p-values into significance groups
      sig <- model.summary$coefficients[2, 4]
      p.sig <- ifelse(sig <= 0.01, '0.01',
                      ifelse(sig <= 0.05, '0.05', 'N/S'))
      # Grab model coefficients from model summary and populate remaining out_df columns
      out_df[out_df$dataset_id == p & out_df$state == s, 'intercept'] <- model.summary$coefficients[1]
      out_df[out_df$dataset_id == p & out_df$state == s, 'slope'] <- model.summary$coefficients[2]  
      out_df[out_df$dataset_id == p & out_df$state == s, 'rsquared'] <- model.summary$r.squared
      out_df[out_df$dataset_id == p & out_df$state == s, 'slope_sig'] <- p.sig
    }
    # append product table out_df to larger table big_df
    big_df <- rbind(big_df, out_df)
  }
  
  # Summarize the overall trend for each state/product
  big_df$trend <- ifelse(big_df$slope < 0 & big_df$slope_sig != 'N/S', 'decrease',
                         ifelse(big_df$slope > 0 & big_df$slope_sig != 'N/S', 'increase', 'not sig'))
  
  
  # Table of CONUS trend sigs by dataset for use in Fig 1 dataset legend
  write.csv(big_df, here::here("results", "conus_and_state_trends_by_dataset_20240904.csv"), row.names = F)
  
  return(big_df)
}
