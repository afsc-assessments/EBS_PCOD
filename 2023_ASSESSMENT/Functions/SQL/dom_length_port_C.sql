SELECT
    obsint.debriefed_length.species,
    obsint.debriefed_length.nmfs_area AS area,
    obsint.debriefed_length.year AS year,
    TO_CHAR(obsint.debriefed_length.haul_offload_date, 'MM') AS month,
    obsint.debriefed_length.haul_offload_date AS HDAY,
    obsint.debriefed_length.cruise,
    obsint.debriefed_length.permit,
     CASE 
        WHEN obsint.debriefed_length.gear in (1,2,3,4) 
        THEN 'TRW'
        WHEN obsint.debriefed_length.gear in 6 
        THEN 'POT' 
        WHEN obsint.debriefed_length.gear in (5,7,9,10,11,68,8) 
        THEN 'HAL' 
     END                                AS GEAR,
    obsint.debriefed_length.haul_offload AS HAUL,
    concat('P', TO_CHAR(obsint.debriefed_length.port_join)) AS haul_join,
    obsint.debriefed_length.landing_report_id,
    CASE
        WHEN obsint.debriefed_length.sex IN ('F') 
        THEN  '1'
        WHEN obsint.debriefed_length.sex IN ('M')
        THEN  '2'
        WHEN obsint.debriefed_length.sex IN ('U')
        THEN '3'
    END AS sex,
    obsint.debriefed_length.length,
    obsint.debriefed_length.frequency AS SUM_FREQUENCY,
    norpac_views.atl_landing_mgm_id_mv.round_weight_metric_tons AS TONS_LANDED,
    '0' AS NUMB,
    'DOMESTIC PORT' AS SOURCE
FROM
    norpac_views.atl_landing_mgm_id_mv
    INNER JOIN obsint.debriefed_length ON obsint.debriefed_length.landing_report_id = norpac_views.atl_landing_mgm_id_mv.report_id
WHERE
    norpac_views.atl_landing_mgm_id_mv.species_group_code 
    -- insert catch_species
    AND obsint.debriefed_length.species
    -- insert species
    AND obsint.debriefed_length.nmfs_area 
    -- insert region
    AND obsint.debriefed_length.port_join IS NOT NULL
    AND obsint.debriefed_length.landing_report_id IS NOT NULL