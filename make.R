# Loads and runs the project
# Lucy Lee, 12/2023

################ SET UP ######################
# Install packages
devtools::install_deps(upgrade = "never")

# Load packages and functions
devtools::load_all()

############# CREATE DATA ###################
# Prepare NRI and land areas data
prep_nri()

prep_land_areas()

# Create data by merging various CSVs
source(here::here("analyses", "merge_data.R"))

############# CREATE FIGURES AND TABLES ###################
# Save CSV of trends - to add CONUS trend significance
#  to line chart legends
source(here::here("analyses", "save_trend_summary_table.R"))

# Create Figures 1, S1, S2 (line charts)
source(here::here("analyses", "make_figs_1_s1_s2.R"))

# Create Figure 2 - bar plots of change from previous measurement
# This figure was finalized in Adobe Illustrator
source(here::here("analyses", "make_fig_2.R"))

# Create Figure 3 - correlation matrix
source(here::here("analyses", "make_fig_3.R"))

# Create Figure 4
source(here::here("analyses", "make_fig_4.R"))

# Create data for Figure 5 which is made in ArcGIS Pro
source(here::here("analyses", "make_fig_5_data.R"))

# Create Table S2 - count of FIA observations used in trend analysis
source(here::here("analyses", "make_table_s2.R"))
