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
    AND obsint.debriefed_spcomp.year > 2019
    AND obsint.debriefed_haul.nmfs_area > 500
    AND obsint.debriefed_haul.nmfs_area < 539
    AND norpac.atl_lov_gear_type.geartype_form = 'H'"





    CATCH=sql_run(afsc, FSH_QUERY) %>% 
         dplyr::rename_all(toupper) %>%
        data.table()

CATCH<-read.csv("CATCH.CSV")
CATCH<-data.table(CATCH)
CATCH$CPUE=0
CATCH[GEAR_TYPE%in%c(6,8)]$CPUE<-CATCH[GEAR_TYPE%in%c(6,8)]$EXTRAPOLATED_WEIGHT/CATCH[GEAR_TYPE%in%c(6,8)]$TOTAL_HOOKS_POTS
CATCH[GEAR_TYPE%in%c(1,2,3,4)]$CPUE<-CATCH[GEAR_TYPE%in%c(1,2,3,4)]$EXTRAPOLATED_WEIGHT/CATCH[GEAR_TYPE%in%c(1,2,3,4)]$DURATION_IN_MIN

CATCH1<-data.frame(CATCH)



pdf("EBS_COD_LONGLINE20.pdf",width=8, height=8)

Years=sort(unique(CATCH1$YEAR))

for(i in 1:length(Years)){
    cod<-subset(CATCH1,YEAR==Years[i]&GEAR_TYPE%in%c(8))
  
opt1<-make_idw_map_FSH(x = cod,
                         COMMON_NAME = NA,
                         LATITUDE = NA,
                         LONGITUDE = NA,
                         CPUE = NA,
                         region = "bs.all",
                         extrap.box = NULL,
                         extrapolation.grid.type = "sf",
                         set.breaks = 'fisher',
                         grid.cell = c(20000,20000),
                         in.crs = "+proj=longlat",
                         out.crs = "EPSG:3338",
                         key.title = paste0("Pacific cod Longline ",Years[i]),
                         key.title.units = "CPUE (kg/hook)",
                         log.transform = TRUE,
                         idw.nmax = 4,
                         use.survey.bathymetry = FALSE,
                         return.continuous.grid = FALSE)

    print(opt1$plot)
 }
dev.off()


pdf("EBS_COD_POT20.pdf",width=8, height=8)

for(i in 1:length(Years)){
    cod<-subset(CATCH1, YEAR==Years[i] & GEAR_TYPE%in%c(6))
  

opt1<-make_idw_map_FSH(x = cod,
                         COMMON_NAME = NA,
                         LATITUDE = NA,
                         LONGITUDE = NA,
                         CPUE = NA,
                         region = "bs.all",
                         extrap.box = NULL,
                         extrapolation.grid.type = "sf",
                         set.breaks = 'fisher',
                         grid.cell = c(20000,20000),
                         in.crs = "+proj=longlat",
                         out.crs = "EPSG:3338",
                         key.title = paste0("Pacific cod Pot ",Years[i]),
                         key.title.units = "CPUE (kg/pot)",
                         log.transform = TRUE,
                         idw.nmax = 4,
                         use.survey.bathymetry = FALSE,
                         return.continuous.grid = FALSE)

    print(opt1$plot)
 }
dev.off()


pdf("EBS_COD_TRAWL20.pdf",width=8, height=8)

for(i in 1:length(Years)){
    cod<-subset(CATCH1,YEAR==Years[i]&GEAR_TYPE%in%c(1:4))


opt1<-make_idw_map_FSH(x = cod,
                         COMMON_NAME = NA,
                         LATITUDE = NA,
                         LONGITUDE = NA,
                         CPUE = NA,
                         region = "bs.all",
                         extrap.box = NULL,
                         extrapolation.grid.type = "sf",
                         set.breaks = 'fisher',
                         grid.cell = c(20000,20000),
                         in.crs = "+proj=longlat",
                         out.crs = "EPSG:3338",
                         key.title = paste0("Pacific cod Trawl ",Years[i]),
                         key.title.units = "CPUE (kg/minute)",
                         log.transform = TRUE,
                         idw.nmax = 4,
                         use.survey.bathymetry = FALSE,
                         return.continuous.grid = FALSE)

    print(opt1$plot)
 }
dev.off()