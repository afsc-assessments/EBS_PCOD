FSH_QUERY<-"SELECT
    obsint.debriefed_spcomp.species,
    obsint.debriefed_spcomp.species_name,
    obsint.debriefed_spcomp.year,
    obsint.debriefed_haul.latdd_end        AS latitude,
    obsint.debriefed_haul.londd_end        AS longitude,
    obsint.debriefed_haul.gear_type,
    obsint.debriefed_haul.duration_in_min,
    obsint.debriefed_haul.total_hooks_pots,
    obsint.debriefed_haul.nmfs_area,
    norpac.atl_lov_gear_type.description   AS gear,
    obsint.debriefed_spcomp.extrapolated_weight,
    obsint.debriefed_spcomp.extrapolated_number
FROM
    obsint.debriefed_haul
    INNER JOIN obsint.debriefed_spcomp ON obsint.debriefed_haul.haul_join = obsint.debriefed_spcomp.haul_join
    INNER JOIN norpac.atl_lov_gear_type ON obsint.debriefed_haul.gear_type = norpac.atl_lov_gear_type.gear_type_code
WHERE
    obsint.debriefed_spcomp.species = 202
    AND obsint.debriefed_spcomp.year > 1990
    AND obsint.debriefed_haul.nmfs_area > 500
    AND obsint.debriefed_haul.nmfs_area < 539
    AND norpac.atl_lov_gear_type.geartype_form = 'H'"





    CATCH=sql_run(afsc, FSH_QUERY) %>% 
         dplyr::rename_all(toupper) %>%
        data.table()

#CATCH<-read.csv("CATCH.CSV")
CATCH<-data.table(CATCH)
CATCH$CPUE=0
CATCH[GEAR_TYPE%in%c(6,8)]$CPUE<-CATCH[GEAR_TYPE%in%c(6,8)]$EXTRAPOLATED_WEIGHT/CATCH[GEAR_TYPE%in%c(6,8)]$TOTAL_HOOKS_POTS
CATCH[GEAR_TYPE%in%c(1,2,3,4)]$CPUE<-CATCH[GEAR_TYPE%in%c(1,2,3,4)]$EXTRAPOLATED_WEIGHT/CATCH[GEAR_TYPE%in%c(1,2,3,4)]$DURATION_IN_MIN

CATCH1<-data.frame(CATCH)


make_idw_map_FSH(x = subset(CATCH1,YEAR==2021&GEAR_TYPE%in%c(1:4)), # Pass data as a data frame
             region = "bs.all", # Predefined bs.all area
             set.breaks = c(0,5,10,15,30,900), # Gets Jenks breaks from classint::classIntervals()
             in.crs = "+proj=longlat", # Set input coordinate reference system
             out.crs = "EPSG:3338", # Set output coordinate reference system
             grid.cell = c(20000, 20000), # 20x20km grid
             key.title = "test")








  library(sf)
library(raster)
library(ggplot2)


# Load the shapefile
shapefile <- st_read("suvevey_area.shp")

# Load your data

# Load the shapefile
shapefile <- st_read("suvevey_area.shp")
akland<- st_read("akland2.shp")
sgrid<-st_read("survey_grid.shp")

grat<-st_read("graticule.shp")
bathym<-st_read("bathymetry.shp")


# Load your data
data <- CATCH

# Convert your data to a sf object
data_sf <- st_as_sf(data, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)

# Create a grid of polygons with a resolution of 5 units (change this to your desired resolution)
grid <- st_make_grid(shapefile, cellsize = 0.5, square = TRUE)


grid<-sgrid
# Convert the grid to a sf object
grid_sf <- st_sf(geometry = st_sfc(grid))

grid_sf<-st_as_sfc(geometry = st_sfc(grid))

# Join the data to the grid
grid_with_data <- st_join(grid_sf, data_sf)




# Group by grid cell and sum the EXTRAPOLATED_WEIGHT
grid_with_data <- grid_with_data %>%
  group_by(geometry, YEAR) %>%
  summarise(EXTRAPOLATED_WEIGHT = sum(EXTRAPOLATED_WEIGHT, na.rm = TRUE))



grid_with_data1 <- subset(grid_with_data, !is.na(YEAR))
grid_with_data1 <- subset(grid_with_data1, YEAR %in% c(2010,2017:2023))


# Plot the data

akland_cropped <- st_crop(akland, grid_sf)

bathym_cropped <- st_crop(bathym, grid_sf)

trans_power <- scales::trans_new(
  name = "power",
  transform = function(x) x^(1/5),
  inverse = function(x) x^5
)


min_weight <- min(grid_with_data1$EXTRAPOLATED_WEIGHT/1000, na.rm = TRUE)
max_weight <- max(grid_with_data1$EXTRAPOLATED_WEIGHT/1000, na.rm = TRUE)

# Generate breaks at regular intervals across the range
breaks <- round(seq(from = min_weight, to = max_weight, length.out = 5))

ggplot(grid_with_data1) +
  geom_sf(aes(fill = EXTRAPOLATED_WEIGHT/1000), color = NA) +
  geom_sf(data = akland_cropped, fill = "gray50", color = NA) +
  geom_sf(data = shapefile, fill=NA,color = 'gray20',linetype=1) +
  scale_fill_gradient(low="light blue",high= "red", trans = "sqrt", breaks = breaks) +
  theme_bw(base_size=20) +
  facet_wrap(~YEAR,ncol=4)+labs(fill="Observed catch (t)")






centroids <- st_centroid(grid_with_data1)


# Define a function to calculate the weighted centroid of a group
weighted_centroid_group <- function(data, weight) {
  # Calculate the weighted coordinates
  weighted_coords <- st_coordinates(data$geometry) * weight
  # Calculate the total weight
  total_weight <- sum(weight)
  # Calculate the weighted centroid
  centroid <- colSums(weighted_coords) / total_weight
  # Convert the centroid to an sf point
  centroid_sf <- st_as_sf(as.data.frame(t(centroid)), coords = c("X", "Y"), crs = st_crs(data$geometry))
  return(centroid_sf)
}

# Group by YEAR and calculate the weighted centroid of each group
centroids_by_year <- centroids %>%
  group_by(YEAR) %>%
  group_map(~ weighted_centroid_group(.x, .x$EXTRAPOLATED_WEIGHT))



# Collapse the list into a single sf object
centroids_by_year_sf <- do.call(rbind, centroids_by_year)
years <- 1991:2023
centroids_by_year_sf$YEAR<-years



centroids_by_year_df <- as.data.frame(st_coordinates(centroids_by_year_sf))

# Add the YEAR column
centroids_by_year_df$YEAR <- centroids_by_year_sf$YEAR



target_crs <- "+proj=utm +zone=2 +datum=WGS84 +units=m +no_defs"

# Transform the CRS of the sf object
centroids_by_year_sf_utm <- st_transform(centroids_by_year_sf, target_crs)

# Convert the sf object to a data frame
centroids_by_year_df_utm <- as.data.frame(st_coordinates(centroids_by_year_sf_utm))

centroids_by_year_df_utm$YEAR <- centroids_by_year_sf_utm$YEAR




ggplot(centroids_by_year_df_utm,aes(x=YEAR,y=Y/1000))+geom_point(size=2)+geom_line()+theme_bw(base_size=16)+labs(x='Year',y='Northings (km)')



  ggplot(centroids_by_year_sf)+
  geom_sf(aes(color = factor(YEAR))) +
   geom_sf(data = akland_cropped, fill = "gray50", color = NA) +
   geom_sf(data = shapefile, fill=NA,color = 'gray20',linetype=1) +
   theme_bw()+labs(title='Fishery Center of Gravity',color='Year')