SELECT
        obsint.debriefed_age.species,
        obsint.debriefed_age.year,
        TO_CHAR(obsint.debriefed_age.haul_offload_date, 'mm') AS month,
        obsint.debriefed_age.haul_offload_date,
        obsint.debriefed_age.cruise,
        obsint.debriefed_age.vessel,
        obsint.debriefed_age.gear,
        obsint.debriefed_age.sex,
        obsint.debriefed_age.length,
        obsint.debriefed_age.weight
    FROM
        obsint.debriefed_age
    WHERE
        obsint.debriefed_age.species
        -- insert species
        AND obsint.debriefed_age.length IS NOT NULL
        AND obsint.debriefed_age.weight IS NOT NULL
        AND obsint.debriefed_age.nmfs_area 
        -- insert location
    ORDER BY
        obsint.debriefed_age.year,
        obsint.debriefed_age.cruise,
        obsint.debriefed_age.vessel,
        obsint.debriefed_age.length,
        obsint.debriefed_age.weight