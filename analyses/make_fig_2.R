# Creates Figure 2 - forest / tree area bar plots
# change from previous measurement
# Note that the legend didn't display right so that was finished
# (stipes added) in Adobe Illustrator
#
# Author: Lucy Lee
# Date: May 2024

##### Read in and clean data #####
all_data <- create_base_data(from_drive = FALSE)

##### Create first bar plot - forest area ####
forest_bp_data <- create_forest_bar_plot_data(all_data)

create_forest_bar_plot(forest_bp_data, type = "forest")

##### Create second bar plot -- tree area ####
tree_bp_data <- create_tree_bar_plot_data(all_data)

create_forest_bar_plot(tree_bp_data, type = "tree")
