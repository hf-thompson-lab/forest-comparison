# Creates the data that is the basis of the figures and trend analysis
#
# Author: Lucy Lee
# Date: September 2024

##### Preprocess updated FIA and EPA data ######
# Preprocess FIA data
fia_data <- here::here("data", "derived-data", "fia", "forest_comparison_fia_v2.csv")
fia_df <- prep_fia(fia_data)

# Preprocess EPA data
epa_data <- here::here("data", "raw-data", "RDS-2023-0020_Walters_et_al_2023", "Data", "By_State",
                       "LULUC_area_by_State.csv")
epa_df <- prep_epa(epa_data)

####### Prepare final dataset for analysis ######
# Merge CSVs from Google Drive and replace old FIA and EPA data
combine_data(epa_df, fia_df, upload = FALSE)
