# Calculate trend significance for use in line chart legends
#
# Author: Lucy Lee
# Date: May 2024

####### Create the data ######
# Get data and do some final cleaning for use in R
all_data <- create_base_data(from_drive = FALSE)

#### Create the charts #####
# Significance for CONUS trends is added manually into legend
# by looking at CSV saved by calc_lm (also trend_df)
create_line_charts(all_data)
