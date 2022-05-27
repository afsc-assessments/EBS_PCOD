SELECT
    norpac.foreign_age.year,
    to_char(norpac.foreign_haul.dt,'MM') as MONTH,
    norpac.foreign_age.species,
    CASE
        WHEN norpac.foreign_fishing_operation.vessel_type_code IN (
            1,
            2,
            3,
            4
        ) THEN
            'TRW'
        WHEN norpac.foreign_fishing_operation.vessel_type_code IN (
            6
        ) THEN
            'POT'
        WHEN norpac.foreign_fishing_operation.vessel_type_code IN (
            5,
            7,
            9,
            10,
            11,
            68,
            8
        ) THEN
            'HAL'
    END AS gear,
    norpac.foreign_haul.generic_area AS nmfs_area,
    concat('H', norpac.foreign_age.haul_join) AS haul_join,
    norpac.foreign_age.sex,
    norpac.foreign_age.length,
    norpac.foreign_age.age,
    'FOREIGN' AS source   
FROM
    norpac.foreign_haul
    INNER JOIN norpac.foreign_age ON norpac.foreign_haul.haul_join = norpac.foreign_age.haul_join
    INNER JOIN norpac.foreign_fishing_operation ON norpac.foreign_haul.cruise = norpac.foreign_fishing_operation.cruise
    AND norpac.foreign_haul.vessel = norpac.foreign_fishing_operation.vessel
WHERE
    norpac.foreign_haul.generic_area 
     -- insert region
    AND norpac.foreign_age.species
     -- insert species