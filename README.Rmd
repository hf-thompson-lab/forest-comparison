---
output: 
  html_document: 
    keep_md: true
---
# Forest Dataset Comparison

This project contains the code that compiles data, conducts statistical tests,
and creates figures for the following publication:

Lee, L. G., Pasquarella, V. J., Glass, B., Morreale, L. L., 
  Chung, N., Gao, X., and Thompson, J. R. A comparison shopper's guide to
  forest datasets. In review.
  
It is structured as a research compendium to make the majority of the
analysis easily reproducible. Note that the computation of remote
sensing data was done on Google Earth Engine and is accessible at 
https://github.com/valpasq/ee-forests/tree/main. The calculation of federal land 
area was done in Python using a proprietary library (ArcPy). Therefore that 
portion is not reproducible but the code used is included for transparency. 
Similarly, code to retrieve raw FIA data is included here for transparency
but is not run in `make.R`, due to long processing time and the fact that
the code would now return updated data different than what was used in analysis.
The FIA data used in analysis is instead read in directly, and the code used
to create that data is included in the `analysis` folder (see project tree below)
but is not run. Additionally, some datasets were not downloaded through scripting and are 
already in `data/raw-data/` - each script has details on where and how such 
data were downloaded for transparency. Finally, not all figures were
created with R but this project produces all figures that were created in R and generates
the data for the figure created in ArcGIS Pro.

## Content

This project is structured as follows:
```
.
|
├─ forest_comparison.Rproj                               # RStudio project file
|
├─ README.md                                             # Presentation of the project
├─ DESCRIPTION                                           # Project metadata
├─ LICENSE.md                                            # Project license
|
├─ data/                                                 # Data downloaded from sources
|  └─ raw-data/              
|     └─ fia/                                            # Empty folder created in case FIA code is run
|     └─ RDS-2023-0020_Walters_et_al_2023/
|        └─ Data/
|           └─ By_State/
|              └─ LULUC_area_by_State.csv                # Updated EPA data
|     └─ census_state_area_measurements_2010.xlsx        # 2010 US Census land areas
|     └─ nri_grazed_nongrazed_nonfederal_forest.csv      # NRI non-federal forest data
| └─ derived-data/                                       # Processed data
|    └─ fia/
|        └─ forest_comparison_fia_v2.csv                 # Updated FIA data (12/2023)
|    └─ land_areas.csv                                   # Total, federal, non-federal land area by state
|    └─ lower48_v5-1_20240904.csv                        # Merged CSVs
|    └─ n_obs_fia.csv                                    # Number of FIA observations in trend analysis
|    └─ nri_grazed_notgrazed_total_forest_acres.csv      # Reshaped NRI data
|    └─ padus3_fed_area_by_state.dbf                     # Federal land area by state
|
├─ results/                                              # Results of statistical tests
|  └─ conus_and_state_trends_by_dataset_20240904.csv
|  └─ conus_trend_counts_20240904.csv                    # Data for Fig 5
|  └─ state_trend_counts_20240904.csv                    # Data for Fig 5
|
├─ figures/                                              # Figures
|  └─ conus_forest_change_norm_20240904.png              # Fig 2
|  └─ conus_linechart_fig1_20240904.png                  # Fig 1
|  └─ conus_linechart_pct_figS2_20240904.png             # Fig S2
|  └─ conus_linechart_sq_km_figS1_20240904.png           # Fig S1
|  └─ conus_tree_cover_change_norm_20240510.png          # Fig 2
|  └─ cormat_20241122.png                                # Fig 3
|  └─ state_trends_2000-2019_20241216.png                # Fig 4
|
├─ R/                                                    # Contains R functions
|  └─ calc_lm.R                                          # Calculates linear models
|  └─ calc_percent_forest.R                              # Calculates percent forest
|  └─ combine_data.R                                     # Combines CSVs to form merged dataset
|  └─ count_fia_obs.R                                    # Counts number of FIA observations used in trend analysis
|  └─ create_base_data.R                                 # Final preparation of data for use in R
|  └─ create_correlation_matrix.R                        # Creates correlation matrix figure
|  └─ create_forest_bar_plot.R                           # Creates bar plot of change from previous estimate
|  └─ create_forest_bar_plot_data.R                      # Creates data for bar plot (forest datasets)
|  └─ create_line_charts.R                               # Creates line chart figures
|  └─ create_pie_chart_data.R                            # Creates data for pie chart map figure
|  └─ create_state_trends_maps.R                         # Creates multipanel state trends maps figure
|  └─ create_tree_bar_plot_data.R                        # Creates data for bar plot (tree datasets)
|  └─ prep_epa.R                                         # Prepares updated EPA data
|  └─ prep_fia.R                                         # Prepares updated FIA data
|  └─ prep_land_areas.R                                  # Calculates non-federal land area by state
|  └─ prep_nri.R                                         # Prepares NRI data
|
├─ analyses/                                             # Contains R scripts
|  └─ calc_fed_area_by_state.py                          # Calculates federal area by state
|  └─ calculate_conus_forest_area_fia.R                  # NOT RUN processes raw FIA data
|  └─ make_fig_2.R                                       # Makes Figure 2 (bar plots)
|  └─ make_fig_3.R                                       # Makes Figure 3 (correlation matrix)
|  └─ make_fig_4.R                                       # Makes Figure 4 (state trends maps)
|  └─ make_fig_5_data.R                                  # Makes data for Figure 5 pie charts
|  └─ make_figs_1_s1_s2.R                                # Makes Figures 1, S1, S2 (line charts)
|  └─ make_table_s2.R                                    # Makes Table S2 (# of FIA observations)
|  └─ merge_data.R                                       # Merges CSVs
|  └─ save_trend_summary_table.R                         # Saves table of summary of linear models
|
└─ make.R                                                # Script to setup & run the project
```

## Installation

This analysis is packaged as an R project (.Rproj) which can only be opened with RStudio. R and RStudio must be installed to run the analysis.

## Usage

Open the `forest_comparison.Rproj` file in RStudio and run `source("make.R")` to launch 
analyses. 

- All packages will be automatically installed and loaded
- Input data is located in `data/raw-data/`
- Processed data is saved to `data/derived-data/`
- Tabular results are saved to `results/`
- Figures are saved to `figures/`

## Citation

Lee, L.G., and Morreale, L.L. 2025. Comparison shopper's guide to forest datasets analysis code v1.0. https://github.com/hf-thompson-lab/forest-comparison
