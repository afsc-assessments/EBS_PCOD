 SELECT
    norpac.domestic_port.fish_ticket_no,
    norpac.domestic_port.year,
    norpac.domestic_port.cruise,
    norpac.domestic_port.vessel,
    norpac.domestic_port.delivery_date,
    norpac.domestic_port.delivery,
    CASE 
        WHEN norpac.domestic_port.gear_type in (1,2,3,4) 
        THEN 'TRW'
        WHEN norpac.domestic_port.gear_type in 6 
        THEN 'POT' 
        WHEN norpac.domestic_port.gear_type in (5,7,9,10,11,68,8) 
        THEN 'HAL' 
     END                                AS GEAR, 
    norpac.domestic_port.nmfs_area_code AS AREA,
    norpac.domestic_port.delivering_vessel,
    norpac.atl_lov_vessel.name,
    concat('P', TO_CHAR(norpac.domestic_length.port_join)) AS haul_join,
    norpac.domestic_length.species,
    CASE
        WHEN norpac.domestic_length.sex IN ('F') 
        THEN  '1'
        WHEN norpac.domestic_length.sex IN ('M')
        THEN  '2'
        WHEN norpac.domestic_length.sex IN ('U')
        THEN '3'
    END AS sex,
    norpac.domestic_length.length,
    norpac.domestic_length.frequency AS sum_frequency,
    'DOMESTIC PORT' AS SOURCE
FROM
    norpac.domestic_port
    INNER JOIN norpac.atl_lov_vessel ON norpac.domestic_port.delivering_vessel = norpac.atl_lov_vessel.adfg_number
    INNER JOIN norpac.domestic_length ON norpac.domestic_port.port_join = norpac.domestic_length.port_join
WHERE
    norpac.domestic_port.fish_ticket_no IS NOT NULL
    AND norpac.domestic_port.year > 1998
    AND norpac.domestic_port.nmfs_area_code
    -- insert region
    AND norpac.domestic_length.species
    -- insert species
ORDER BY
    norpac.domestic_port.year,
    norpac.domestic_port.fish_ticket_no