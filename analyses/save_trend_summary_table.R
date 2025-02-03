# Save the table of linear trend significance
# for use in line chart legends
#
# Author: Lucy Lee
# Date: May 2024

##### Create data #####
# Get data and do some final cleaning for use in R
all_data <- create_base_data(from_drive = FALSE)

pct_forest <- calc_percent_forest(all_data)

#### Get significance of linear trends for some datasets ####
# This is used to add CONUS significance to the legend for 
# datasets used in trend analysis
linear_trends <- calc_lm(pct_forest)
