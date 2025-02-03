# Create Figure 4 - state trends multi-panel maps
#
# Author: Lucy Lee
# Date: May 2024

##### Get data ######
all_data <- create_base_data(from_drive = FALSE)

# Percent forest
pct_forest <- calc_percent_forest(all_data)

# Calculate and summarize linear models
linear_trends <- calc_lm(pct_forest)

##### Create figure #####
create_state_trends_maps(pct_forest, linear_trends)
