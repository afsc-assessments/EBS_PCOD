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


make_idw_map_FSH(x = subset(CATCH1,YEAR==2021&GEAR_TYPE%in%c(1:4)), # Pass data as a data frame
             region = "bs.all", # Predefined bs.all area
             set.breaks = "Jenks", # Gets Jenks breaks from classint::classIntervals()
             in.crs = "+proj=longlat", # Set input coordinate reference system
             out.crs = "EPSG:3338", # Set output coordinate reference system
             grid.cell = c(20000, 20000), # 20x20km grid
             key.title = "test")