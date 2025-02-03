# Calculate number of FIA observations used for trend analysis
# aka create Table S2
#
# Author: Lucy Lee
# Date: June 2024

##### Get data ######
all_data <- create_base_data(from_drive = FALSE)

# Percent forest
pct_forest <- calc_percent_forest(all_data)

#### Count FIA observations ####
count_fia_obs(pct_forest)
