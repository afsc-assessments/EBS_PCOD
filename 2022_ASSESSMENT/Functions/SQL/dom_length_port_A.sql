SELECT
    norpac.domestic_length.species,
    norpac.domestic_port.nmfs_area_code as area,
    norpac.domestic_length.year,
    TO_CHAR(norpac.domestic_length.haul_date, 'MM') AS month,
    norpac.domestic_length.haul_date      AS hday,
    norpac.domestic_length.cruise,
    norpac.domestic_length.vessel         AS permit,
    norpac.domestic_port.delivering_vessel AS VES_AKR_ADFG,
    CASE
        WHEN norpac.domestic_port.gear_type IN (1,2,3,4)
        THEN 'TRW'
        WHEN norpac.domestic_port.gear_type IN (6)
        THEN 'POT'
        WHEN norpac.domestic_port.gear_type IN (5, 7, 9, 10, 11, 68, 8) 
        THEN 'HAL'
    END AS gear,
    norpac.domestic_port.delivery AS HAUL,
    concat('P', TO_CHAR(norpac.domestic_length.port_join)) AS haul_join,
   CASE
        WHEN norpac.domestic_length.sex IN ('F') 
        THEN  '1'
        WHEN norpac.domestic_length.sex IN ('M')
        THEN  '2'
        WHEN norpac.domestic_length.sex IN ('U')
        THEN '3'
    END AS sex,
    norpac.domestic_length.length,
    norpac.domestic_length.frequency      AS sum_frequency,
    CASE
      WHEN norpac.domestic_port_spcomp.wsd_mt_lb = 'MT' 
      THEN norpac.domestic_port_spcomp.sample_delivered*1000
      WHEN norpac.domestic_port_spcomp.wsd_mt_lb = 'LB'
      THEN norpac.domestic_port_spcomp.sample_delivered*0.453592
      END AS EXTRAPOLATED_WEIGHT,
    '0' AS NUMB,
    'DOMESTIC PORT' AS SOURCE 
FROM
    norpac.domestic_port
    INNER JOIN norpac.domestic_length ON norpac.domestic_port.port_join = norpac.domestic_length.port_join
    INNER JOIN norpac.domestic_port_spcomp ON norpac.domestic_length.port_join = norpac.domestic_port_spcomp.port_join
WHERE
    norpac.domestic_length.species
    -- insert species
    AND norpac.domestic_port.nmfs_area_code
    -- insert region
    AND norpac.domestic_port_spcomp.species 
    -- insert species
ORDER BY
    norpac.domestic_port.delivery_date