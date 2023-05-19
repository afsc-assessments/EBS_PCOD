
library(RODBC)
library(data.table)
username= "######"  ## enter your akfin username
password= "######"  ## enter your akfin password

AKFIN=odbcConnect("AKFIN",username,password,believeNRows=FALSE)



test2<-paste0("SELECT
    council.comprehensive_obs.cruise,
    council.comprehensive_obs.obs_vessel_id,
    council.comprehensive_obs.haul_date,
    council.comprehensive_obs.haul_number,
    council.comprehensive_obs.haul_join,
    council.comprehensive_obs.obs_gear_code,
    council.comprehensive_obs.official_total_catch,
    council.comprehensive_obs.total_hooks_pots,
    council.comprehensive_obs.year,
    council.comprehensive_obs.trip_target_code,
    council.comprehensive_obs.obs_specie_code,
    council.comprehensive_obs.extrapolated_weight,
    council.comprehensive_obs.extrapolated_number,
    council.comprehensive_obs.species_name,
    council.comprehensive_obs.target_fishery_name,
    council.comprehensive_obs.trip_target_name,
    council.comprehensive_obs.fmp_area,
    council.comprehensive_obs.fmp_subarea,
    council.comprehensive_obs.duration_in_min,
    council.comprehensive_obs.adfg_stat_area_id,
    council.comprehensive_obs.adfg_stat_area_code,
    council.comprehensive_obs.retrieval_latitude_dd,
    council.comprehensive_obs.retrieval_longitude_dd,
    council.comprehensive_obs.ves_akr_name,
    council.comprehensive_obs.ves_akr_cg_num,
    council.comprehensive_obs.ves_akr_length,
    council.comprehensive_obs.ves_akr_homeport_city,
    council.comprehensive_obs.ves_akr_homeport_state,
    council.comprehensive_obs.ves_akr_net_tonnage,
    council.comprehensive_obs.ves_akr_gross_tonnage,
    council.comprehensive_obs.ves_akr_horsepower,
    council.comprehensive_obs.ves_akr_class,
    council.comprehensive_obs.ves_cfec_length,
    council.comprehensive_obs.ves_cfec_homeport_city,
    council.comprehensive_obs.ves_cfec_homeport_state,
    council.comprehensive_obs.haul_purpose_code
FROM
    council.comprehensive_obs
WHERE
    council.comprehensive_obs.obs_gear_code = 8
    AND council.comprehensive_obs.trip_target_code = 'C'
    AND council.comprehensive_obs.obs_specie_code = 202
ORDER BY
    council.comprehensive_obs.haul_date")


CPUE<- data.table(sqlQuery(AKFIN,test2,as.is=T))


CPUE$RETRIEVAL_LATITUDE_DD<-as.numeric(CPUE$RETRIEVAL_LATITUDE_DD)
  CPUE$RETRIEVAL_LONGITUDE_DD<-as.numeric(CPUE$RETRIEVAL_LONGITUDE_DD)
   CPUE$TOTAL_HOOKS_POTS <- as.numeric(CPUE$TOTAL_HOOKS_POTS)
   CPUE$EXTRAPOLATED_WEIGHT <- as.numeric(CPUE$EXTRAPOLATED_WEIGHT)
    CPUE$EXTRAPOLATED_NUMBER <- as.numeric(CPUE$EXTRAPOLATED_NUMBER)

CPUE$DATE1<-format(as.Date(CPUE$HAUL_DATE),'%m/%d/%Y')
CPUE$MONTH=month(CPUE$HAUL_DATE)

CPUE_FALL<-CPUE[MONTH%in%c(9,10)]
CPUE_SPRING<-CPUE[MONTH%in%c(1,2)]

write.csv(CPUE_FALL,"LLCPUE_FALL22.csv")
write.csv(CPUE_SPRING,"LLCPUE_SPRING22.csv")
