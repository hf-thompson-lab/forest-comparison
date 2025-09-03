# Calculate trend significance for use in line chart legends
#
# Author: Lucy Lee
# Date: May 2024
#       Updated September 2025 to create alt line chart

####### Create the data ######
# Get data and do some final cleaning for use in R
all_data <- create_base_data(from_drive = FALSE)

#### Create the charts #####
# Significance for CONUS trends is added manually into legend
# by looking at CSV saved by calc_lm (also trend_df)
create_line_charts(all_data)

# Alternate Fig 1 that has legend in visual order of lines
create_alt_line_charts(all_data)