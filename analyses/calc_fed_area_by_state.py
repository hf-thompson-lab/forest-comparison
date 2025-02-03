# Calculates area of federal fee lands by state
# using USGS PAD-US v3.0 to identify federally owned land
#
# Datasets were downloaded from the following links and copied into project geodatabase
# PADUS geodatabase: https://www.sciencebase.gov/catalog/item/61794fc2d34ea58c3c6f9f69
# US state boundaries (2020 TIGER/Line+): https://www.nhgis.org/ 
#
# Author: Lucy Lee
# Date: June 2023

import arcpy
import os

# Set up extensions and workspace
arcpy.CheckOutExtension('Spatial')
path = "D:/Lee/Forest_Product_Comparison/forest_comparison/data"
arcpy.env.workspace = path
os.chdir(path)

# Input datasets
padus_fee = "raw-data/shapefile/PADUS3_0Fee.shp"
state_poly = "raw-data/shapefile/US_state_2020.shp"

# Make PADUS feature layer to include only rows where Own_Type = 'FED'
arcpy.management.MakeFeatureLayer(padus_fee, "padus_fed_fee", """"Own_Type" = 'FED'""")

# Calculate federal land area (in sq m) within each state
arcpy.sa.TabulateArea(in_zone_data = state_poly,
                      zone_field = "NAME",
                      in_class_data = "padus_fed_fee",
                      class_field = "Own_Type",
                      out_table = "derived-data/padus3_fed_area_by_state.dbf",
                      processing_cell_size = 30)

# Return extension
arcpy.CheckInExtension('Spatial')
