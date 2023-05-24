
#
# Using just JAN/FEB data

root_dir = "C:/Users/James.Thorson/Desktop/Work files/AFSC/2022-05 -- Barbeaux Pacific cod CPUE/"

# Settings
Response = c("Numbers", "Biomass")[1]  # Number
Region = c("strata", "data")[2]        # SSC recommends Data
Data_set = c("SAFE2022", "SAFE2023")[2]

#
Date = Sys.Date()
date_dir = paste0(root_dir,Date,"/")
  dir.create(date_dir)

# Load package
library(VAST)
library(googledrive)

# Parse
if( Data_set == "SAFE2022" ){
  File_name = "WINTER_LONGLINECPUE_22.csv"
}else if( Data_set == "SAFE2023" ){
  File_name = "LLCPUE_SPRING23.csv"
}

# Download from Google drive
setwd(date_dir)
  CPUE_drive <- drive_get(File_name, corpus = "allDrives")
drive_download( CPUE_drive$id )

#
Data = read.csv( file.path(date_dir,File_name) )
Strata = "eastern_bering_sea"

#
if( Data_set == "SAFE2022" ){
  Data$Date = as.POSIXlt( Data$HAUL_DATE, format="%Y/%m/%d %H:%M" )
}else if( Data_set == "SAFE2023" ){
  Data$Date = as.POSIXlt( Data$HAUL_DATE, format="%m/%d/%Y" )
  Data$YEAR = Data$Date$year + 1900
}

#
sps0 = rgdal::readOGR( dsn=file.path(root_dir,"EBSshelf.shp"), verbose=FALSE ) #, p4s=projargs_for_shapefile )
sps0 = sp::spTransform(sps0, sp::CRS("+proj=longlat +ellps=WGS84") )
lonlat = sp::SpatialPoints( coords = data.frame(long=Data$RETRIEVAL_LONGITUDE_DD, lat=Data$RETRIEVAL_LATITUDE_DD),
    proj4string = sp::CRS("+proj=longlat +ellps=WGS84") )

#
out = sp::over( lonlat, sps0 )
Data = Data[ which(!is.na(out$Shape_Area)),  ]
#
sp::plot(sps0)
points(x=Data$RETRIEVAL_LONGITUDE_DD, y=Data$RETRIEVAL_LATITUDE_DD)

# Define

# Check encounter proportion
tapply( Data$EXTRAPOLATED_NUMBER, INDEX=Data$YEAR, FUN=function(vec){mean(vec>0)} )
tapply( Data$EXTRAPOLATED_NUMBER / Data[,'TOTAL_HOOKS_POTS'], INDEX=Data$YEAR, FUN=mean )

###################
# Make shapefile
###################

# Make a shapefile
if( FALSE ){
  library(raster)
  library(sp)

  #
  #plot( y=DF[,'Latitude'], x=DF[,'Longitude'] )
  #maps::map("world", add=TRUE)

  # hake_shape = rgdal::readOGR( paste0(root_dir,"hake.shp") )

  LL <- locator(30)
  # saveRDS(LL, file=paste0(root_dir,"LL.rds"))
  region_extent <- data.frame(long=LL$x, lat=LL$y)
  str(region_extent)
  ## > 'data.frame':	42 obs. of  2 variables:
  ## $ long: num  -166 -166 -165 -165 -164 ...
  ## $ lat : num  53.9 54.1 54.2 54.6 55 ...

  #### Turn it into a spatial polygon object
  ## Need to duplicate a point so that it is connected
  region_extent <- rbind(region_extent, region_extent[1,])
  ## https://www.maths.lancs.ac.uk/~rowlings/Teaching/Sheffield2013/cheatsheet.html
  poly <- Polygon(region_extent)
  polys <- Polygons(list(poly), ID='all')
  sps <- SpatialPolygons(list(polys))
  ## I think the F_AREA could be dropped here
  sps <- SpatialPolygonsDataFrame(sps, data.frame(Id=factor('all'), F_AREA=1, row.names='all'))
  proj4string(sps)<- CRS("+proj=longlat +datum=WGS84")
  sps <- spTransform(sps, CRS("+proj=longlat +lat_0=90 +lon_0=180 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "))
  ### Get UTM zone for conversion to UTM projection
  ## retrieves spatial bounding box from spatial data [,1] is
  ## longitude
  lon <- sum(bbox(sps)[1,])/2
  ## convert decimal degrees to utm zone for average longitude, use
  ## for new CRS
  utmzone <- floor((lon + 180)/6)+1
  crs_LL <- CRS('+proj=longlat +ellps=WGS84 +no_defs')
  sps@proj4string <- crs_LL

  out = raster::intersect( SpatialPolygons(sps@polygons), SpatialPolygons(sps0@polygons) )
  proj4string(out) = "+proj=longlat +ellps=WGS84 +no_defs"

  raster::shapefile( out, filename=paste0(root_dir,"winter_CPUE_extent"), overwrite=TRUE )
  plot(out,add=TRUE, col=rgb(0,0,1,0.2))
}

###################
# RUN VAST
###################

Region = switch(Region, "strata"=Strata, "data"=paste0(root_dir,"winter_CPUE_extent.shp") )

# Make settings (turning off bias.correct to save time for example)
settings = make_settings( n_x = 250,
  Region = Region,
  purpose = "index2",
  ObsModel = c(2,4),
  RhoConfig = c("Beta1"=0, "Beta2"=0, "Epsilon1"=0, "Epsilon2"=4) )
settings$FieldConfig[c('Omega','Epsilon'),'Component_1'] = 0

# Run model
install_unit("hk", "count")
install_unit("num", "hk")
fit = fit_model( settings = settings,
  Lat_i = Data[,'RETRIEVAL_LATITUDE_DD'],
  Lon_i = Data[,'RETRIEVAL_LONGITUDE_DD'],
  t_i = Data[,'YEAR'],
  #b_i = list( Data[,'EXTRAPOLATED_WEIGHT'], Data[,'EXTRAPOLATED_NUMBER'] )[[switch(Response,"Biomass"=1,"Numbers"=2)]],
  #a_i = Data[,'TOTAL_HOOKS_POTS'],
  b_i = list( as_units(Data[,'EXTRAPOLATED_WEIGHT'],"kg"), as_units(Data[,'EXTRAPOLATED_NUMBER'],"count") )[[switch(Response,"Biomass"=1,"Numbers"=2)]],
  a_i = as_units(Data[,'TOTAL_HOOKS_POTS'],"hk"),
  test_fit = FALSE,
  grid_dim_km = c(10,10),
  working_dir = date_dir,
  observations_LL = cbind("Lat"=Data[,'RETRIEVAL_LATITUDE_DD'],"Lon"=Data[,'RETRIEVAL_LONGITUDE_DD']),
  run_model = TRUE,
  build_model = TRUE,
  getJointPrecision = TRUE,
  framework = "TMBad" )
saveRDS( fit,
         file = file.path(date_dir,"fit.rds") )
#plot(fit$extrapolation_list)

# Plot results
plots = plot_results( fit,
  working_dir = date_dir,
  projargs='+proj=natearth +lon_0=-170 +units=km',
  country = c("united states of america","russia"),
  plot_set = c(),
  n_cells = 20^2 )
# Plot results
plot( fit,
  plot_set = c(3,7,17),
  working_dir = date_dir,
  projargs='+proj=natearth +lon_0=-170 +units=km',
  country = c("united states of america","russia"),
  check_residuals = FALSE )
plot( fit,
  plot_set = c(3),
  working_dir = date_dir,
  projargs='+proj=natearth +lon_0=-170 +units=km',
  country = c("united states of america","russia"),
  plot_value = sd,
  check_residuals = FALSE )

