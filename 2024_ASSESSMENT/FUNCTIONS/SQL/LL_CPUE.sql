SELECT
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
    AND council.comprehensive_obs.trip_target_code
    -- insert target
    AND council.comprehensive_obs.obs_specie_code
    -- insert species
ORDER BY
    council.comprehensive_obs.haul_date