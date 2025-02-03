
create_tree_bar_plot_data <- function(df) {
  # Set column names back to 'X1985' format for differencing columns
  tree.bp <- df
  colnames(tree.bp) <- c('dataset_id', 'state', 'X1985', 'X1986', 'X1987', 'X1988', 'X1989', 'X1990', 'X1991',
                         'X1992', 'X1993', 'X1994', 'X1995', 'X1996', 'X1997', 'X1998', 'X1999', 'X2000', 'X2001',
                         'X2002', 'X2003', 'X2004', 'X2005', 'X2006', 'X2007', 'X2008', 'X2009', 'X2010', 'X2011',
                         'X2012', 'X2013', 'X2014', 'X2015', 'X2016', 'X2017', 'X2018', 'X2019', 'X2020', 'X2021',
                         'X2022')
  
  # Subset to tree cover datasets
  trees <- c("DW_trees_annual_mode", "ESRI_annual_trees", "LCMAP_trees", "LCMAP_trees_woodywet", "LCMS_trees", 
             "LCMS_trees_shrubs_mix", "MODIS_4_BGC", "MODIS_5_PFT")
  tree.bp <- tree.bp[tree.bp$dataset_id %in% trees, ]
  
  # Calculate the difference of each year
  # For tree datasets, all data are continuous
  tree.bp <- tree.bp %>%
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
  
  # Drop original year fields
  tree.bp <- tree.bp[, -c(3:40)]
  
  # Keep only CONUS rows
  tree.bp.conus <- tree.bp[tree.bp$state == 'CONUS', -2]   # Drop the state column
  
  # Reshape data for plotting
  # Rename columns so after melting to long format they can be numeric
  colnames(tree.bp.conus) <- c('dataset_id', '1986', '1987', '1988', '1989', '1990', '1991', '1992',
                               '1993', '1994', '1995', '1996', '1997', '1998', '1999', '2000', '2001', '2002', '2003',
                               '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014',
                               '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022')
  tree.bp.conus.long <- reshape2::melt(tree.bp.conus, id.vars = 'dataset_id')
  colnames(tree.bp.conus.long) <- c("dataset_id", "year", "sq_km")
  tree.bp.conus.long$year <- as.numeric(as.character(tree.bp.conus.long$year))
  
  # Return for use in figure function
  return(tree.bp.conus.long)
}