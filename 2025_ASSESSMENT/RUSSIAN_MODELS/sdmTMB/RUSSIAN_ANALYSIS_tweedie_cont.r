
library(ncdf4)
library(curl)
library(lubridate)
library(PCICt)
library(data.table)
library(sp)
library(heatwaveR)
library(dplyr)
library(png)
library(ggpubr)
library(extrafont)
library(raster)
library(zoo)
library(scales)
library(tidyverse)
library(tidync)
library(coldpool)
library(surveyjoin)
library(sdmTMB)
library(tidyr)
library(INLAspacetime)

setwd('C:/Users/steve.barbeaux/Work/WORKING_FOLDER/EBS_PCOD_work_folder/2025_ASSESSMENT/MULTIAREA/RUSSIAN_ANALYSIS')

source('utils.r')
source('mesh2fem.barrier2.r')
source('add_barrier_mesh2.r')


afsc_user  =  keyring::key_list("afsc")$username  ## enter afsc username
afsc_pwd   = keyring::key_get("afsc", keyring::key_list("afsc")$username)   ## enter afsc password
akfin_user = keyring::key_list("akfin")$username ## enter AKFIN username
akfin_pwd  =  keyring::key_get("akfin", keyring::key_list("akfin")$username)   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "AKFIN",
                      UID = akfin_user, PWD = akfin_pwd)

sql_data=paste0("SELECT
    to_char(racebase.haul.start_time, 'yyyy')                    AS year,
    racebase.cruise.survey_name,
    racebase.haul.hauljoin                                       AS event_id,
    racebase.haul.start_time                                     AS date1,
    racebase.catch.vessel,
    racebase.haul.start_latitude                                 AS lat_start,
    racebase.haul.start_longitude                                AS lon_start,
    racebase.haul.end_latitude                                   AS lat_end,
    racebase.haul.end_longitude                                  AS lon_end,
    racebase.haul.bottom_depth                                   AS depth_m,
    racebase.haul.distance_fished * (racebase.haul.net_width / 1000) AS effort,
    racebase.haul.performance,
    racebase.haul.stratum,
    racebase.haul.gear_temperature                               AS bottom_temp_c,
    racebase.haul.region,
    racebase.catch.species_code,
    racebase.catch.number_fish                                   AS catch_numbers,
    racebase.catch.weight/1000                                   AS catch_weight,
    racebase.species.species_name                                AS scientific_name,
    racebase.species.common_name,
    racebase.haul.abundance_haul
FROM
    racebase.catch
    INNER JOIN racebase.haul ON racebase.haul.cruisejoin = racebase.catch.cruisejoin
                                AND racebase.catch.hauljoin = racebase.haul.hauljoin
    INNER JOIN racebase.cruise ON racebase.haul.cruisejoin = racebase.cruise.cruisejoin
    INNER JOIN racebase.species ON racebase.catch.species_code = racebase.species.species_code
WHERE
        to_char(racebase.haul.start_time, 'yyyy') > 1980
    AND racebase.haul.performance = 0
    AND racebase.haul.region != 'AI'
ORDER BY
    year,
    racebase.cruise.survey_name,
    date1")

d <- sql_run(afsc, sql_data) %>%
  dplyr::rename_all(tolower)

surveys=unique(d$survey_name)[c(3,4,32,53,59,61,91,105,106,111,118,120,127,135,140,142,151,153,158,165,166,170,177,178,182,184,187,188,190,192:197,199:214)]

d<-data.table(d)[survey_name%in% surveys&region%in%c('BS','GOA')&lon_end < -158]

all_hauls <- unique(d$event_id)

d_cod <- data.table(d)[species_code==21720]
cod_hauls <- unique(d_cod$event_id)

nocod_hauls<-all_hauls[is.na(match(all_hauls, cod_hauls))]

d_nocod<-unique(d[event_id%in%nocod_hauls][,c(1:15,21)])
ab<-d_nocod$abundance_haul
d_nocod<-d_nocod[,-c('abundance_haul')]
d_nocod$species_code=21720
d_nocod$catch_numbers=0

d_nocod$catch_weight=0
d_nocod$scientific_name=d_cod[1,19]
d_nocod$common_name=d_cod[1,20]
d_nocod$abundance_haul=ab

d<-rbind(d_cod,d_nocod)

d[region=='GOA']$survey_name<-'Gulf of Alaska'
d[region=='BS'&survey_name%like%'(Loss of Sea Ice)']$survey_name<-'northern Bering Sea'
d[region=='BS'&year==2018&abundance_haul=='N']$survey_name<-'northern Bering Sea'
d[region=='BS'&year%in%c(1982,1991,2001,2005,2006)&lat_end>60&abundance_haul=='N']$survey_name<-'northern Bering Sea'
d[region=='BS'&survey_name!='northern Bering Sea']$survey_name<-'eastern Bering Sea'
d[survey_name=='Gulf of Alaska' & year>1987 & abundance_haul=='N']$survey_name<-'bad'
d[survey_name=='eastern Bering Sea' & abundance_haul=='N']$survey_name<-'bad'
d<-d[survey_name!='bad']


d <- dplyr::mutate(d, 
                   lon_mid = (lon_start + lon_end)/2,
                   lat_mid = (lat_start + lat_end)/2) |>
  dplyr::filter(!is.na(lon_mid), !is.na(lat_mid))

d <- dplyr::filter(d, !is.na(year))
d <- dplyr::filter(d, !is.na(bottom_temp_c))
d <- dplyr::filter(d, year>1981)
d <- dplyr::filter(d, effort>0)

d$cpueW <- d$catch_weight/d$effort ## tons per km2
d$cpueN <- d$catch_number/d$effort ## tons per km2
d$nation='USA'

## get coldpool data
cold<-tibble(coldpool::cold_pool_index)
names(cold)[1]<-'year'

## get and process Russian data

russian_data<-data.table(read.csv("RUSSIANALLCATCH_join3.csv"))
russian_data$survey_name<-'western Bering Sea'
russian_data[SURVEY_DEF==98]$survey_name<-'eastern Bering Sea'
russian_data[SURVEY_DEF==143]$survey_name<-'northern Bering Sea'
russian_data$nation<-'RUSSIA'

names(russian_data)[9]<-"bottom_temp_c"
names(russian_data)[3:4]<-c('lon_mid','lat_mid')
names(russian_data)[20:21]<-c("catch_numbers","catch_weight")

russian_data$cpueW<-russian_data$cpueW/1000  ## change cpueW from kg/km2 to t/km2

russian_data$date1<-format(as.Date(russian_data$date1, "%m/%d/%Y"),"%d-%b-%Y")
d$date1<-format(d$date1, "%d-%b-%Y")

common_cols<-intersect(names(d),names(russian_data))

 x<-d[,..common_cols]
 y<-russian_data[,..common_cols]

## Bring US and Russian data together
 d3<-rbind(x,y)
 d3 <- add_utm_columns(d3, ll_names = c("lon_mid","lat_mid"),utm_crs=32603)

 d3$year<-as.numeric(d3$year)
 d3$fyear <- as.factor(d3$year)

d3$year_scaled <- as.numeric(scale(d3$year))
d3$depth_scaled <- as.numeric(scale(d3$depth_m))

d3$temp_scaled<-0
d3[bottom_temp_c > -999]$temp_scaled <- as.numeric(scale(d3[bottom_temp_c > -999]$bottom_temp_c))
d3[bottom_temp_c == -999]$temp_scaled <- mean(d3[bottom_temp_c > -999]$temp_scaled)

## merge data with coldpool data
d3<-merge(d3,cold,by='year',all.x=T)
d3$cold_scaled <- as.numeric(scale(d3$AREA_LTE2_KM2))

d3<-d3[year%in%c(1982:2019,2021:2024)]
d3$vessel<-factor(d3$vessel)
d3$month<-month(as.Date(d3$date1,format = "%d-%b-%Y"))
d3$doy<-as.numeric(format(as.Date(d3$date1,format = "%d-%b-%Y"),"%j"))
d3<-d3[month%in% c(5:11)]
d3$avewt<-d3$catch_weight/d3$catch_numbers
d3[nation=='USA']$avewt<-(d3[nation=='USA']$catch_weight*1000)/d3[nation=='USA']$catch_numbers

d3$survey_name2<-d3$survey_name
d3[survey_name%in%c('eastern Bering Sea','northern Bering Sea')]$survey_name2<-'northern and eastern Bering Sea'
d3$survey_name2<-factor(d3$survey_name2)

d3$nation<-factor(d3$nation)

d3$nation_vessel<-factor(paste0(d3$nation,"_",d3$vessel))


# Function to read, project, simplify, and fix any errors in each shapefile
read_shapefile <-
function( loc,
          crs = "+init=epsg:4326" ){

  out = st_read( loc )
  out = st_make_valid(out)
  out = st_transform( st_geometry(out), crs )
  out = st_simplify(out, dTolerance = 1000)    # dTolerance is in meters
  return(out)
}


## make/get various maps for creating meshes and plotting

map_data <- rnaturalearth::ne_countries(
  scale = "medium",
  returnclass = "sf", country = c("united states of america","Russia"))
coast <- suppressWarnings(suppressMessages(
  sf::st_crop(map_data,
    c(xmin = -200, ymin = 50, xmax = -158, ymax = 69))))
coast_proj <- sf::st_transform(coast, crs = 32603)

shapefile_dir = paste0(getwd(),'/shapes')

setwd('C:/Users/steve.barbeaux/Work/WORKING_FOLDER/EBS_PCOD_work_folder/2025_ASSESSMENT/MULTIAREA/RUSSIAN_ANALYSIS/shapes')

grid_40K <- st_read("40km_intersect2.shp")
grid_40K <- sf::st_transform(grid_40K, crs = 32603)

## 40 km x 40 km grid
mom6<-data.table(read.csv("MOM6_40KMgrid2.csv"))
MOM6_sum<-mom6[,list(depth_m=mean(depth),bottom_temp=mean(tob)),by=c("day","FID_2","SURVEY_DEF","POLY_AREA","CENTROID_X","CENTROID_Y")]
utm_crs <- st_crs(32603)
MOM6 <- st_as_sf(MOM6_sum, coords = c("CENTROID_X", "CENTROID_Y"), crs = utm_crs)

sfc <- st_transform(MOM6, crs = "+proj=longlat +datum=WGS84")
coords <- st_coordinates(sfc)
MOM6$latitude <- coords[, "Y"]
MOM6$longitude <- coords[, "X"]

MOM6 <- add_utm_columns(MOM6, ll_names = c("longitude","latitude"),utm_crs=32603)
MOM6<-data.table(MOM6)
MOM6$survey_name <- 'eastern Bering Sea'
MOM6[SURVEY_DEF==143]$survey_name <- 'northern Bering Sea'
MOM6[SURVEY_DEF==999]$survey_name <- 'western Bering Sea'
MOM6[SURVEY_DEF==47]$survey_name <- 'Gulf of Alaska'
MOM6$nation='USA'
MOM6[survey_name=='western Bering Sea']$nation<-'RUSSIA'
MOM6$day<-as.Date(MOM6$day, format = "%m/%d/%Y")
MOM6$year<-year(MOM6$day)

MOM6$vessel <- sort(unique(d3$vessel))[8]

MOM6[nation=='RUSSIA']$vessel<-sort(unique(d3$vessel))[51]

MOM6$vessel<-factor(MOM6$vessel,levels=sort(unique(d3$vessel)))

MOM6_template<-subset(MOM6,year==1993)
MOM6_template$bottom_temp <- NA
MOM6_add<-list()
years2<-1982:1992
for(i in 1:length(years2)){
    MOM6_add[[i]]<-MOM6_template
    MOM6_add[[i]]$day<-as.Date(paste0(years2[i],'-07-11'),format = "%Y-%m-%d")
    MOM6_add[[i]]$year<-years2[i]
}

MOM6_add<-do.call(rbind,MOM6_add)
MOM6<-rbind(MOM6_add,MOM6)
MOM6$year_scaled <- (MOM6$year - mean(d3$year)) / sd(d3$year)
MOM6<-merge(MOM6,cold,by='year',all.x=T)
MOM6$cold_scaled <- (MOM6$AREA_LTE2_KM2-mean(d3$AREA_LTE2_KM2))/sd(d3$AREA_LTE2_KM2)
MOM6$depth_scaled<-(MOM6$depth_m - mean(d3$depth_m)) / sd(d3$depth_m)
MOM6$temp_scaled<-(MOM6$bottom_temp - mean(d3$bottom_temp_c)) / sd(d3$bottom_temp_c)
MOM6<-MOM6[,-'geometry']
MOM6$survey_name2<-MOM6$survey_name
MOM6[survey_name%in%c('northern Bering Sea','eastern Bering Sea')]$survey_name2<-'northern and eastern Bering Sea'
MOM6$survey_name2<-factor(MOM6$survey_name2)
MOM6$vessel<-factor(as.character(MOM6$vessel),levels=as.character(unique(d3$vessel)))
MOM6$nation_vessel<-factor(paste0(MOM6$nation,"_",MOM6$vessel),levels=as.character(unique(d3$nation_vessel)))
MOM6$nation<-factor(MOM6$nation)

MOM7<-MOM6[nation=='USA'&!survey_name%in%'western Bering Sea']
MOM7$vessel<-factor(as.character(MOM7$vessel),levels=as.character(unique(d3[nation=='USA']$vessel)))
MOM7$nation_vessel<-factor(as.character(MOM7$nation_vessel),levels=as.character(unique(d3[nation=='USA']$nation_vessel)))

## barrier clip shapefiles
## full Bering Sea and WGOA
B_CLIP2 = read_shapefile( "Russian_US_MESH.shp")
b_clip2<- B_CLIP2 %>% # select the central parts
  st_sf() 
 b_clip2 <- sf::st_transform(b_clip2, crs = 32603)

##just US zone
B_CLIP3 = read_shapefile( "Russian_US_MESH3.shp")
b_clip3<- B_CLIP3 %>% # select the central parts
  st_sf() 
 b_clip3 <- sf::st_transform(b_clip3, crs = 32603)




d5<-read.csv('all_data2.csv')
d5$nation<-factor(d5$nation)
d5$survey_name2<-factor(d5$survey_name2)



# Making mesh and barrier mesh
mesh_temp3 <- make_mesh(d3, xy_cols = c("X","Y"), type='cutoff_search', n_knots=300)

mesh_temp_test3<-add_barrier_mesh2(
   spde_obj = mesh_temp3,
   barrier_sf = b_clip2,
   range_fraction = 0.2,
   proj_scaling = 1000,
   plot = TRUE
 )


## just US zone
d4<-d3[nation=='USA']
d4$vessel<-factor(d4$vessel)
d4$nation_vessel<-factor(d4$nation_vessel)

mesh_temp3_US <- make_mesh(d4, xy_cols = c("X","Y"), type='cutoff_search', n_knots=300)

mesh_temp_test3_US<-add_barrier_mesh2(
   spde_obj = mesh_temp3_US,
   barrier_sf = b_clip3,
   range_fraction = 0.2,
   proj_scaling = 1000,
   plot = TRUE
 )



## sdmTMB models
control = sdmTMBcontrol()

 # fit_RV_twe_Survey4 <- sdmTMB( 
 #           cpueW ~ 0 + nation+year_scaled*survey_name2+s(depth_scaled, by=survey_name2)+(1|nation_vessel),
 #           spatial_varying = ~cold_scaled+survey_name2,
 #           data = d3, 
 #           mesh = mesh_temp_test3,
 #           family = tweedie(), 
 #           time = "year", 
 #           spatial = "on",
 #           spatiotemporal = "ar1",
 #           extra_time = 2020L, 
 #           silent = TRUE,
 #           anisotropy = FALSE,
 #           control = control
 #         )


fit_RV_twe_Survey5 <- sdmTMB( 
          cpueW ~ 0 + nation+year_scaled+s(depth_scaled, by=survey_name2),
          spatial_varying = ~cold_scaled+survey_name2,
          data = d3, 
          mesh = mesh_temp_test3,
          family = tweedie(), 
          time = "year", 
          spatial = "on",
          spatiotemporal = "ar1",
          extra_time = 2020L, 
          silent = TRUE,
          anisotropy = FALSE,
          control = control
        )



# fit_NRV_twe_Survey4 <- sdmTMB( 
#           cpueW ~ 0+year_scaled+s(depth_scaled)+(1|vessel),
#           spatial_varying = ~cold_scaled,
#           data = d3[nation=='USA'], 
#           mesh = mesh_temp_test3_US,
#           family = tweedie(), 
#           time = "year", 
#           spatial = "on",
#           spatiotemporal = "ar1",
#           extra_time = 2020L, 
#           silent = TRUE,
#           anisotropy = FALSE,
#           control = control
#         )


fit_NRV_twe_Survey5 <- sdmTMB( 
          cpueW ~ 0+year_scaled+s(depth_scaled),
          spatial_varying = ~cold_scaled,
          data = d4, 
          mesh = mesh_temp_test3_US,
          family = tweedie(), 
          time = "year", 
          spatial = "on",
          spatiotemporal = "ar1",
          extra_time = 2020L, 
          silent = TRUE,
          anisotropy = FALSE,
          control = control
        )


## creating projections and indices

# p_stW_RV_twe <- predict(fit_RV_twe_Survey4, newdata = MOM6[year%in%c(1982:2019,2021:2024)], return_tmb_object = TRUE)


# indexW_RV_twe <- get_index(p_stW_RV_twe, area=p_stW_RV_twe$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe$REGION="ALL"
# indexW_RV_twe$MODEL="With Russian data RandV"

# p_stW_RV_twe.1 <- predict(fit_RV_twe_Survey4, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],!survey_name %in% 'western Bering Sea'), return_tmb_object = TRUE)
# indexW_RV_twe.1 <- get_index(p_stW_RV_twe.1, area=p_stW_RV_twe.1$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe.1$REGION="ALL-WBS"
# indexW_RV_twe.1$MODEL="With Russian data RandV"

# p_stW_RV_twe.2 <- predict(fit_RV_twe_Survey4, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'eastern Bering Sea'), return_tmb_object = TRUE)
# indexW_RV_twe.2 <- get_index(p_stW_RV_twe.2, area=p_stW_RV_twe.2$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe.2$REGION="EBS"
# indexW_RV_twe.2$MODEL="With Russian data RandV"

# p_stW_RV_twe.3 <- predict(fit_RV_twe_Survey4, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'Gulf of Alaska'), return_tmb_object = TRUE)
# indexW_RV_twe.3 <- get_index(p_stW_RV_twe.3, area=p_stW_RV_twe.3$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe.3$REGION="GOA"
# indexW_RV_twe.3$MODEL="With Russian data RandV"

# p_stW_RV_twe.4 <- predict(fit_RV_twe_Survey4, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'western Bering Sea'), return_tmb_object = TRUE)
# indexW_RV_twe.4 <- get_index(p_stW_RV_twe.4, area=p_stW_RV_twe.4$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe.4$REGION="WBS"
# indexW_RV_twe.4$MODEL="With Russian data RandV"

# p_stW_RV_twe.5 <- predict(fit_RV_twe_Survey4, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'northern Bering Sea'), return_tmb_object = TRUE)
# indexW_RV_twe.5 <- get_index(p_stW_RV_twe.5, area=p_stW_RV_twe.5$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe.5$REGION="NBS"
# indexW_RV_twe.5$MODEL="With Russian data RandV"

# p_stW_RV_twe.6 <- predict(fit_RV_twe_Survey4, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% c('eastern Bering Sea','northern Bering Sea')), return_tmb_object = TRUE)
# indexW_RV_twe.6 <- get_index(p_stW_RV_twe.6, area=p_stW_RV_twe.6$data$POLY_AREA, bias_correct=TRUE)
# indexW_RV_twe.6$REGION="EBS+NBS"
# indexW_RV_twe.6$MODEL="With Russian data RandV"


# index_RV_survey7<-rbind(indexW_RV_twe,indexW_RV_twe.1,indexW_RV_twe.2,indexW_RV_twe.3,indexW_RV_twe.4,indexW_RV_twe.5)


## no random vessel in model

p_stW_RV_twe5 <- predict(fit_RV_twe_Survey5, newdata = MOM6[year%in%c(1982:2019,2021:2024)], return_tmb_object = TRUE)


indexW_RV_twe <- get_index(p_stW_RV_twe5, area=p_stW_RV_twe$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe$REGION="ALL"
indexW_RV_twe$MODEL="With Russian data noRandV"

p_stW_RV_twe.1 <- predict(fit_RV_twe_Survey5, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],!survey_name %in% 'western Bering Sea'), return_tmb_object = TRUE)
indexW_RV_twe.1 <- get_index(p_stW_RV_twe.1, area=p_stW_RV_twe.1$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe.1$REGION="ALL-WBS"
indexW_RV_twe.1$MODEL="With Russian data noRandV"

p_stW_RV_twe.2 <- predict(fit_RV_twe_Survey5, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'eastern Bering Sea'), return_tmb_object = TRUE)
indexW_RV_twe.2 <- get_index(p_stW_RV_twe.2, area=p_stW_RV_twe.2$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe.2$REGION="EBS"
indexW_RV_twe.2$MODEL="With Russian data noRandV"

p_stW_RV_twe.3 <- predict(fit_RV_twe_Survey5, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'Gulf of Alaska'), return_tmb_object = TRUE)
indexW_RV_twe.3 <- get_index(p_stW_RV_twe.3, area=p_stW_RV_twe.3$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe.3$REGION="GOA"
indexW_RV_twe.3$MODEL="With Russian data noRandV"

p_stW_RV_twe.4 <- predict(fit_RV_twe_Survey5, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'western Bering Sea'), return_tmb_object = TRUE)
indexW_RV_twe.4 <- get_index(p_stW_RV_twe.4, area=p_stW_RV_twe.4$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe.4$REGION="WBS"
indexW_RV_twe.4$MODEL="With Russian data noRandV"

p_stW_RV_twe.5 <- predict(fit_RV_twe_Survey5, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% 'northern Bering Sea'), return_tmb_object = TRUE)
indexW_RV_twe.5 <- get_index(p_stW_RV_twe.5, area=p_stW_RV_twe.5$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe.5$REGION="NBS"
indexW_RV_twe.5$MODEL="With Russian data noRandV"

p_stW_RV_twe.6 <- predict(fit_RV_twe_Survey5, newdata = filter(MOM6[year%in%c(1982:2019,2021:2024)],survey_name %in% c('eastern Bering Sea','northern Bering Sea')), return_tmb_object = TRUE)
indexW_RV_twe.6 <- get_index(p_stW_RV_twe.6, area=p_stW_RV_twe.6$data$POLY_AREA, bias_correct=TRUE)
indexW_RV_twe.6$REGION="EBS+NBS"
indexW_RV_twe.6$MODEL="With Russian data noRandV"


index_RV_survey8<-rbind(indexW_RV_twe5,indexW_RV_twe.1,indexW_RV_twe.2,indexW_RV_twe.3,indexW_RV_twe.4,indexW_RV_twe.5)



## Creating US zone model plots and indices

p_stW_NRV_twe <- predict(fit_NRV_twe_Survey5, newdata = MOM7[year%in%c(1982:2019,2021:2024)], return_tmb_object = TRUE)


indexW_NRV_twe <- get_index(p_stW_NRV_twe, area=p_stW_NRV_twe$data$POLY_AREA, bias_correct=TRUE)
indexW_NRV_twe$REGION="ALL-WBS"
indexW_NRV_twe$MODEL="Without Russian data"


p_stW_NRV_twe.2 <- predict(fit_NRV_twe_Survey5, newdata = filter(MOM7[year%in%c(1982:2019,2021:2024)],survey_name %in% 'eastern Bering Sea'), return_tmb_object = TRUE)
indexW_NRV_twe.2 <- get_index(p_stW_NRV_twe.2, area=p_stW_NRV_twe.2$data$POLY_AREA, bias_correct=TRUE)
indexW_NRV_twe.2$REGION="EBS"
indexW_NRV_twe.2$MODEL="Without Russian data"

p_stW_NRV_twe.3 <- predict(fit_NRV_twe_Survey5, newdata = filter(MOM7[year%in%c(1982:2019,2021:2024)],survey_name %in% 'Gulf of Alaska'), return_tmb_object = TRUE)
indexW_NRV_twe.3 <- get_index(p_stW_NRV_twe.3, area=p_stW_NRV_twe.3$data$POLY_AREA, bias_correct=TRUE)
indexW_NRV_twe.3$REGION="GOA"
indexW_NRV_twe.3$MODEL="Without Russian data"


p_stW_NRV_twe.5 <- predict(fit_NRV_twe_Survey5, newdata = filter(MOM7[year%in%c(1982:2019,2021:2024)],survey_name %in% 'northern Bering Sea'), return_tmb_object = TRUE)
indexW_NRV_twe.5 <- get_index(p_stW_NRV_twe.5, area=p_stW_NRV_twe.5$data$POLY_AREA, bias_correct=TRUE)
indexW_NRV_twe.5$REGION="NBS"
indexW_NRV_twe.5$MODEL="Without Russian data"


p_stW_NRV_twe.6 <- predict(fit_NRV_twe_Survey5, newdata = filter(MOM7[year%in%c(1982:2019,2021:2024)],survey_name %in% c('eastern Bering Sea','northern Bering Sea')), return_tmb_object = TRUE)
indexW_NRV_twe.6 <- get_index(p_stW_NRV_twe.6, area=p_stW_NRV_twe.6$data$POLY_AREA, bias_correct=TRUE)
indexW_NRV_twe.6$REGION="EBS+NBS"
indexW_NRV_twe.6$MODEL="Without Russian data"

index_NRV_survey6<-rbind(indexW_NRV_twe,indexW_NRV_twe.2,indexW_NRV_twe.3,indexW_NRV_twe.5)

index_RV_NRV<-rbind(index_RV_survey8,index_NRV_survey6)

## creating plots

##maps of combined models biomass
years1<-unique(d3[year>1981]$year)
shapefile_with_values <- left_join(grid_40K, p_stW_RV_twe5$data, by=c('FID_2','SURVEY_DEF','POLY_AREA'))


pdf('plot_RV_twe_survey6.pdf',width=10,height=10)

for(i in 1:length(years1)){
p1 <- ggplot(coast_proj) + 
geom_sf(data = filter(shapefile_with_values,year==years1[i]),aes(fill = exp(est)),color=NA) +
  labs(title = "Map with Values") +scale_fill_viridis_c(trans = "pseudo_log",
      # trim extreme high values to make spatial variation more visible
    na.value = "yellow", limits = c(0, 15)) +
  geom_sf(fill="wheat") +
  theme_bw() +
  labs(x = "Longitude", y = "Latitude",fill='tons/km2')+facet_wrap(~year,nrow=4)

print(p1)
}
dev.off()

##maps of US only models biomass

years1<-unique(d3[year>1981]$year)
shapefile_with_values <- left_join(grid_40K, p_stW_NRV_twe$data, by=c('FID_2','SURVEY_DEF','POLY_AREA'))

pdf('plot_NRV_twe_survey6.pdf',width=10,height=10)

for(i in 1:length(years1)){
p1 <- ggplot(coast_proj) + 
geom_sf(data = filter(shapefile_with_values,year==years1[i]),aes(fill = exp(est)),color=NA) +
  labs(title = "Map with Values") +scale_fill_viridis_c(trans = "pseudo_log",
      # trim extreme high values to make spatial variation more visible
    na.value = "yellow", limits = c(0, 15)) +
  geom_sf(fill="wheat") +
  theme_bw() +
  labs(x = "Longitude", y = "Latitude",fill='tons/km2')+facet_wrap(~year,nrow=4)

print(p1)
}
dev.off()

## index plots

 I_RV1<-ggplot(data.table(index_RV_NRV)[year>1982&REGION%in%c('ALL-WBS')], aes(year, est, color=MODEL)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=MODEL),color=NA,alpha=0.1) +
   geom_line(lwd = 1)+
   labs(title="All US areas",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)

 I_RV2<-ggplot(data.table(index_RV_NRV)[year>1982&REGION%in%c('EBS')], aes(year, est, color=MODEL)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=MODEL),color=NA,alpha=0.1) +
   geom_line(lwd = 1)+
   labs(title="Eastern Bering Sea",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)

 I_RV3<-ggplot(data.table(index_RV_NRV)[year>1982&REGION%in%c('NBS')], aes(year, est, color=MODEL)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=MODEL),color=NA,alpha=0.1) +
   geom_line(lwd = 1)+
   labs(title="Northern Bering Sea",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)

  I_RV4<-ggplot(data.table(index_RV_NRV)[year>1982&REGION%in%c('GOA')], aes(year, est, color=MODEL)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=MODEL),color=NA,alpha=0.1) +
   geom_line(lwd = 1)+
   labs(title="Western Gulf of Alaska",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)

  I_RV5<-ggplot(data.table(index_RV_NRV)[year>1982&REGION%in%c('WBS')], aes(year, est, color=MODEL)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=MODEL),color=NA,alpha=0.1) +
   geom_line(lwd = 1)+
   labs(title="Western Bering Sea",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)

  I_RV6<-ggplot(data.table(index_RV_NRV)[year>1982&MODEL=="With Russian data noRandV" & REGION!="ALL-WBS"], aes(year, est, color=REGION)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=REGION),color=NA,alpha=0.1) + geom_line(lwd = 1)+
   labs(title="With Russian data",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)+
   scale_color_manual(name = "Regions", 
                         values = c("ALL" = "black", 
                                    "EBS" = "blue", 
                                    "NBS" = "purple",
                                    "GOA" = "orange",
                                    "WBS" = "red"))+
    scale_fill_manual(name = "Regions", 
                         values = c("ALL" = "black", 
                                    "EBS" = "blue", 
                                    "NBS" = "purple",
                                    "GOA" = "orange",
                                    "WBS" = "red"))

  I_RV7<-ggplot(data.table(index_RV_NRV)[year>1982&MODEL=="Without Russian data" & REGION!="ALL"], aes(year, est, color=REGION)) +
   geom_ribbon(aes(ymin = lwr, ymax = upr,fill=REGION),color=NA,alpha=0.1) + geom_line(lwd = 1)+
   labs(title="Without Russian data",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)+
   scale_color_manual(name = "Regions", 
                         values = c("ALL-WBS" = "black", 
                                    "EBS" = "blue", 
                                    "NBS" = "purple",
                                    "GOA" = "orange"))+
     scale_fill_manual(name = "Regions", 
                         values = c("ALL-WBS" = "black", 
                                    "EBS" = "blue", 
                                    "NBS" = "purple",
                                    "GOA" = "orange"))

combined_plot <- ggarrange(I_RV1, I_RV2, I_RV3, I_RV4, ncol = 2,nrow=2,legend="bottom",common.legend=T)


## plot of survey regions

grid_40K_x<-filter(grid_40K,SURVEY_DEF!=52)
grid_40K_x$survey_name <- 'eastern Bering Sea'
grid_40K_x[grid_40K_x$SURVEY_DEF=='47','survey_name']<-"Gulf of Alaska"
grid_40K_x[grid_40K_x$SURVEY_DEF=='143','survey_name']<-"northern Bering Sea"
grid_40K_x[grid_40K_x$SURVEY_DEF=='999','survey_name']<-"western Bering Sea"


p1 <- ggplot(coast_proj) + 
geom_sf(data = grid_40K_x,aes(fill = factor(survey_name)),color=NA) +
  labs(title = "Survey Regions")+ 
  geom_sf(fill="wheat") +
  theme_bw() +
  labs(x = "Longitude", y = "Latitude",fill='Region')+   
  scale_fill_manual(name = "Regions", 
                         values = c("eastern Bering Sea" = "blue", 
                                    "northern Bering Sea" = "purple",
                                    "Gulf of Alaska" = "orange",
                                    "western Bering Sea" = "red"))

print(p1)



## creating centroids

fit_data<-data.table(p_stW_RV_twe$data)
fit_data$Wlon<-fit_data$lon*exp(fit_data$est)
fit_data$Wlat<-fit_data$lat*exp(fit_data$est)
fit_data$WY<-fit_data$Y*exp(fit_data$est)
fit_data$WX<-fit_data$X*exp(fit_data$est)

centroids=fit_data[,list(SUMEST=sum(exp(est)),SUMLON=sum(Wlon),SUMX=sum(WX),SUMY=sum(WY),SUMLAT=sum(Wlat)),by='year']

centroids$CLON<-centroids$SUMLON/centroids$SUMEST
centroids$CLAT<-centroids$SUMLAT/centroids$SUMEST
centroids$CY<-centroids$SUMY/centroids$SUMEST
centroids$CX<-centroids$SUMX/centroids$SUMEST

centroids=merge(centroids,cold,by='year',all.x=T)
centroids=merge(centroids,index_RV_survey6)


ggplot(centroids,aes(x=MEAN_GEAR_TEMPERATURE,y=CY,color=year))+geom_point(size=2)+geom_smooth(method='lm',color='red')+theme_bw(base_size=20)+labs(y=expression('CPUE weighted northings (km)'),x=expression('Mean bottom temperature ('~degree~C~')'))+scale_color_gradient(low = "blue", high = "red")

ggplot(centroids,aes(x=MEAN_GEAR_TEMPERATURE,y=CX,color=year))+geom_point()+geom_smooth(method='lm')+theme_bw(base_size=20)+labs(y=expression('CPUE weighted eastings (km)'),x=expression('Mean bottom temperature ('~degree~C~')'))+scale_color_gradient(low = "blue", high = "red")

y1=ggplot(centroids,aes(x=year,y=CY,color=MEAN_GEAR_TEMPERATURE))+geom_point(size=2)+
geom_line()+theme_bw(base_size=20)+
labs(y=expression('CPUE weighted northings (km)'),x='Year',color=expression('Mean bottom temperature ('~degree~C~')'))+
scale_color_gradient(low = "blue", high = "red")

x1=ggplot(centroids,aes(x=year,y=CX,color=MEAN_GEAR_TEMPERATURE))+geom_point(size=2)+
geom_line()+theme_bw(base_size=20)+
labs(y=expression('CPUE weighted eastings'),x='Year',color=expression('Mean bottom temperature ('~degree~C~')'))+
scale_color_gradient(low = "blue", high = "red")

xy1=ggplot(centroids,aes(y=CY,x=CX,color=MEAN_GEAR_TEMPERATURE,label=year))+geom_point()+geom_path()+theme_bw(base_size=20)+labs(x=expression('CPUE weighted eastings (km)'),y=expression('CPUE weighted northings (km)'))+geom_text(hjust=0, vjust=0)+scale_color_gradient(low = "blue", high = "red")

combined_plot2 <- ggarrange(x1, y1,nrow=2,legend="bottom",common.legend=T)

ggplot(centroids,aes(x=AREA_LTE2_KM2,y=CY,color=year))+geom_point(size=2)+geom_smooth(method='lm',color='red')+theme_bw(base_size=20)+labs(y=expression('CPUE weighted northings (km)'),x=expression('Cold pool area (<2'~degree~C~')'))+scale_color_gradient(low = "blue", high = "red")


y2=ggplot(centroids[REGION=='ALL'],aes(y=CY,x=est,color=MEAN_GEAR_TEMPERATURE,label=year))+geom_point()+geom_path()+theme_bw(base_size=20)+labs(x=expression('Pacific cod biomass (t)'),y=expression('CPUE weighted northings (km)'))+geom_text(hjust=0, vjust=0)+scale_color_gradient(low = "blue", high = "red")




# p1 <- ggplot(coast_proj) + 
# geom_sf(data = filter(shapefile_with_values,year==years1[i]),aes(fill = exp(est)),color=NA) +
#   labs(title = "Map with Values") +scale_fill_viridis_c(trans = "pseudo_log",
#       # trim extreme high values to make spatial variation more visible
#     na.value = "yellow", limits = c(0, 15)) +
#   geom_sf(fill="wheat") +
#   theme_bw() +
#   labs(x = "Longitude", y = "Latitude",fill='tons/km2')+facet_wrap(~year,nrow=4)

# print(p1)


# I_RV1<-ggplot(data.table(index_RV_survey7)[year>1982&!REGION%in%('ALL-WBS')], aes(year, est, color=REGION)) +
#    geom_ribbon(aes(ymin = lwr, ymax = upr,fill=REGION),color=NA,alpha=0.1) +
#    geom_line(lwd = 1)+
#    labs(title="All US areas",x = "Year", y = "Pacific cod biomass (t)")+theme_bw(base_size=20)