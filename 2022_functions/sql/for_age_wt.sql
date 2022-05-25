SELECT
        norpac.foreign_age.species,
        norpac.foreign_age.year,
        TO_CHAR(norpac.foreign_age.dt, 'mm') AS month,
        norpac.foreign_age.dt,
        norpac.foreign_age.cruise,
        norpac.foreign_age.vessel,
        norpac.foreign_fishing_operation.vessel_type_code,
        norpac.foreign_age.sex,
        norpac.foreign_age.length,
        norpac.foreign_age.indiv_weight
    FROM
        norpac.foreign_age
        INNER JOIN norpac.foreign_haul ON norpac.foreign_age.haul_join = norpac.foreign_haul.haul_join
        AND norpac.foreign_age.cruise = norpac.foreign_haul.cruise
        AND norpac.foreign_age.vessel = norpac.foreign_haul.vessel
        INNER JOIN norpac.foreign_fishing_operation ON norpac.foreign_haul.cruise = norpac.foreign_fishing_operation.cruise
        AND norpac.foreign_haul.vessel = norpac.foreign_fishing_operation.vessel
    WHERE
        norpac.foreign_age.species 
        -- insert species
        AND norpac.foreign_haul.generic_area
        -- insert location
    ORDER BY
        norpac.foreign_age.year,
        norpac.foreign_age.cruise,
        norpac.foreign_age.vessel,
        norpac.foreign_age.length,
        norpac.foreign_age.indiv_weight
