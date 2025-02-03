# Create data for Figure 5 pie charts
# The CSVs saved in this script are then added to ArcPro
# and used to make the pie charts shown in the Fig 5 maps
#
# Author: Lucy Lee
# Date: May 2024

# Get base data
all_data <- create_base_data(from_drive = FALSE)

# Calculate percent forest
pct_forest <- calc_percent_forest(all_data)

# Calculate and summarize linear models
linear_trends <- calc_lm(pct_forest)

# Get counts of inc, dec, and insig trends
create_pie_chart_data(linear_trends)
