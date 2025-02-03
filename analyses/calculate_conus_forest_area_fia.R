# Retrieves FIA forest and timberland data and
# saves the results as  CSV
#
# NOTE: This code is not called by make.R because
# it takes many hours (and >60 GB) to download the raw FIA data
# and because this code always retrieves the latest FIA data,
# which would result in data not used in analysis.
# This code generated the CSV in data/derived-data/fia,
# which was created in December 2023 to replace
# older FIA data.
#
# Author: Luca Morreale
# Date: December 2023


#### Initialization ####
#devtools::install_github("hunter-stanke/rFIA") #download rFIA package from GitHub
library(tidyverse)
library(viridis)
library(rFIA)
library(parallel)
options(timeout = 3600)

sts <- datasets::state.abb

#### download FIA data ####
for(i in 1:length(sts)){
  all <- rFIA::getFIA(sts[i], dir = here::here("data", "raw-data", "fia"), common = T, load = F)
  print(paste0(i, " downloaded."))
}

#### Load in FIA data and calculate annual forest area (or Timberlands area) ####
CONUS <- sts[which(!sts %in% c("HI","AK"))]

# Timberland - byLandType = T
timberland_area_list <- vector(mode = "list",length = 49)
for(i in 1:length(CONUS)){
  st <- CONUS[i]
  print(st)
  st.FIA <- rFIA::readFIA(states = st, dir = here::here("data", "raw-data", "fia"))
  st.area <- rFIA::area(db = st.FIA, byLandType = TRUE, variance = TRUE, method = "ANNUAL")
  timberland_area_list[[i]] <- st.area
  gc()
}

# Forest area - byLandType = F
forest_area_list <- vector(mode = "list",length = 49)
for(i in 1:length(CONUS)){
  st <- CONUS[i]
  print(st)
  st.FIA <- rFIA::readFIA(states = st, dir = here::here("data", "raw-data", "fia"))
  st.area <- area(db = st.FIA, byLandType = FALSE, variance = TRUE, method = "ANNUAL")
  forest_area_list[[i]] <- st.area
  gc()
}

# Name each list item with state abbreviation
names(forest_area_list) <- CONUS
names(timberland_area_list) <- CONUS

##### Combine and clean data #####
both_list <- vector("list",length = length(forest_area_list))
names(both_list) <- CONUS
for(s in 1:length(CONUS)){
  ta <- timberland_area_list[[s]]
  fa <- forest_area_list[[s]]
  fa_cln <- fa %>%
    dplyr::mutate(Area_Km2 = AREA_TOTAL * 0.00404686,
                  StandDev_Km2 = sqrt(AREA_TOTAL_VAR) * 0.00404686,
                  dataset_id = "FIA_forest") %>%
    dplyr::select(YEAR, Area_Km2, StandDev_Km2, Total_Variance = AREA_TOTAL_VAR, N_Forested = nPlots_AREA, dataset_id)
  ta_cln <- ta %>% 
    dplyr::filter(landType == "Timber") %>% 
    dplyr::mutate(Area_Km2 = AREA_TOTAL * 0.00404686,
                  StandDev_Km2 = sqrt(AREA_TOTAL_VAR) * 0.00404686,
                  dataset_id = "FIA_timberland") %>%
    dplyr::select(YEAR, Area_Km2, StandDev_Km2, Total_Variance = AREA_TOTAL_VAR, N_Forested = nPlots_AREA, dataset_id)
  both_cln <- fa_cln %>% 
      rbind(ta_cln)
  both_list[[s]] <- both_cln
  out <- here::here("data", "derived-data", "fia", paste0("VAR_forest_timber_area_", names(forest_area_list)[s], ".csv"))
  write.csv(both_cln, out)
}


allstates <- dplyr::bind_rows(both_list, .id = "State")
out_fia <- allstates %>% 
  tidyr::pivot_wider(id_cols = c(State,dataset_id), names_from = YEAR,values_from = Area_Km2)

# Save result
write.csv(out_fia, file = here::here("data", "derived-data", "fia", "forest_comparison_fia_v2.csv"))
