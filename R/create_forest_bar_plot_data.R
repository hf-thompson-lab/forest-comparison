#' Create forest bar plot data
#' 
#' @description
#' Creates the data in the bar plot of change from
#' previous measurement for forest datasets at CONUS
#' scale (Figure 2)
#' 
#' @param df Main dataframe returned by create_base_data()
#' 
#' @return Returns a dataframe which is the input into
#' the function that creates the bar plot

create_forest_bar_plot_data <- function(df) {
  # Define 'not in' operator -- useful for removing multiple datasets from a df
  `%!in%` <- Negate(`%in%`)
  
  # Set column names back to 'X1985' format for differencing columns
  df.bp <- df
  colnames(df.bp) <- c('dataset_id', 'state', 'X1985', 'X1986', 'X1987', 'X1988', 'X1989', 'X1990', 'X1991',
                       'X1992', 'X1993', 'X1994', 'X1995', 'X1996', 'X1997', 'X1998', 'X1999', 'X2000', 'X2001',
                       'X2002', 'X2003', 'X2004', 'X2005', 'X2006', 'X2007', 'X2008', 'X2009', 'X2010', 'X2011',
                       'X2012', 'X2013', 'X2014', 'X2015', 'X2016', 'X2017', 'X2018', 'X2019', 'X2020', 'X2021',
                       'X2022')
  
  # Subset to forest datasets
  forest <- c("EPA_forest", 'FIA_forest', 'Hansen_GFC', "LCMS_forest", "NLCD_forest", "NLCD_forest_woodywet",
              "NRI_nonfederal_forest", "MODIS_1_IGBP", "MODIS_2_UMD", "MODIS_3_LAI")
  df.bp.forest <- df.bp[df.bp$dataset_id %in% forest, ]
  
  ######## Create df of interannual change for continuous datsets #########
  # Calculate the difference of each year
  # This code only works for data without gaps!
  # For CONUS, this includes: EPA, ESA, ESRI, FIA, Hansen, MODIS, LCMAP, LCMS, DW
  df.bp1 <- df.bp.forest %>%
    dplyr::group_by(state, dataset_id) %>%
    dplyr::mutate(D1986 = X1986-X1985,
                  D1987 = X1987-X1986,
                  D1988 = X1988-X1987,
                  D1989 = X1989-X1988,
                  D1990 = X1990-X1989,
                  D1991 = X1991-X1990,
                  D1992 = X1992-X1991,
                  D1993 = X1993-X1992,
                  D1994 = X1994-X1993,
                  D1995 = X1995-X1994,
                  D1996 = X1996-X1995,
                  D1997 = X1997-X1996,
                  D1998 = X1998-X1997,
                  D1999 = X1999-X1998,
                  D2000 = X2000-X1999,
                  D2001 = X2001-X2000,
                  D2002 = X2002-X2001,
                  D2003 = X2003-X2002,
                  D2004 = X2004-X2003,
                  D2005 = X2005-X2004,
                  D2006 = X2006-X2005,
                  D2007 = X2007-X2006,
                  D2008 = X2008-X2007,
                  D2009 = X2009-X2008,
                  D2010 = X2010-X2009,
                  D2011 = X2011-X2010,
                  D2012 = X2012-X2011,
                  D2013 = X2013-X2012,
                  D2014 = X2014-X2013,
                  D2015 = X2015-X2014,
                  D2016 = X2016-X2015,
                  D2017 = X2017-X2016,
                  D2018 = X2018-X2017,
                  D2019 = X2019-X2018,
                  D2020 = X2020-X2019,
                  D2021 = X2021-X2020,
                  D2022 = X2022-X2021)
  
  # Drop original year fields and non-continuous datasets at CONUS scale (NLCD, NRI)
  not_continuous <- c("NLCD_forest", "NLCD_forest_woodywet", "NRI_nonfederal_forest")
  df.bp1 <- df.bp1[df.bp1$dataset_id %!in% not_continuous , -c(3:40)]
  
  ########### Calculate change from previous measurement for non-continuous datasets ##########
  # Calculate differences for NRI and NLCD
  # NLCD: 2001, 2004, 2006, 2008, 2011, 2013, 2016, 2019, 2021
  df.bp2 <- df.bp.forest[df.bp.forest$dataset_id %in% c("NLCD_forest", "NLCD_forest_woodywet"), ]
  df.bp2 <- df.bp2 %>%
    dplyr::group_by(state, dataset_id) %>%
    dplyr::mutate(D2004 = X2004-X2001,
                  D2006 = X2006-X2004,
                  D2008 = X2008-X2006,
                  D2011 = X2011-X2008,
                  D2013 = X2013-X2011,
                  D2016 = X2016-X2013,
                  D2019 = X2019-X2016,
                  D2021 = X2021-X2019)
  
  # Drop original year columns
  df.bp2 <- df.bp2[, -c(3:40)]
  
  # NRI: 1987, 1992, 1997, 2002, 2007, 2012, 2017
  df.bp3 <- df.bp.forest[df.bp.forest$dataset_id == "NRI_nonfederal_forest", ]
  df.bp3 <- df.bp3 %>%
    dplyr::group_by(state) %>%
    dplyr::mutate(D1992 = X1992-X1987,
                  D1997 = X1997-X1992,
                  D2002 = X2002-X1997,
                  D2007 = X2007-X2002,
                  D2012 = X2012-X2007,
                  D2017 = X2017-X2012)
  
  # Drop original year columns
  df.bp3 <- df.bp3[, -c(3:40)]
  
  ############## Combine and format data ###############
  # Combine df.bp1, df.bp2, and df.bp3, keeping only CONUS rows
  # Since FIA was handled for CONUS, not for states
  forest.bp.conus <- dplyr::bind_rows(df.bp1, df.bp2, df.bp3)
  forest.bp.conus <- forest.bp.conus[forest.bp.conus$state == 'CONUS', -2]   # Drop the state column
  
  # Reshape data for plotting
  # Rename columns so after melting to long format they can be numeric
  colnames(forest.bp.conus) <- c('dataset_id', '1986', '1987', '1988', '1989', '1990', '1991', '1992',
                                 '1993', '1994', '1995', '1996', '1997', '1998', '1999', '2000', '2001', '2002', '2003',
                                 '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014',
                                 '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022')
  forest.bp.conus.long <- reshape2::melt(forest.bp.conus, id.vars = 'dataset_id')
  colnames(forest.bp.conus.long) <- c("dataset_id", "year", "sq_km")
  forest.bp.conus.long$year <- as.numeric(as.character(forest.bp.conus.long$year))   # Convert year from factor to numeric
  
  # Return df for use in figure function
  return(forest.bp.conus.long)
}
