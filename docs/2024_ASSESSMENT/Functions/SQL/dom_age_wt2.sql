SELECT
    norpac.debriefed_age.gear,
    norpac.debriefed_age.nmfs_area,
    norpac.debriefed_age.species,
    norpac.debriefed_age.sex,
    norpac.debriefed_age.age,
    norpac.debriefed_age.length,
    norpac.debriefed_age.weight,
    norpac.debriefed_age.year,
    to_char(
        norpac.debriefed_haul.haul_date, 'mm'
    ) AS month
FROM
    norpac.debriefed_age
    INNER JOIN norpac.debriefed_haul ON norpac.debriefed_age.haul_join = norpac.debriefed_haul.haul_join
WHERE
    norpac.debriefed_age.nmfs_area
    -- insert location
    AND norpac.debriefed_age.species
    -- insert species
ORDER BY
    norpac.debriefed_age.year,
    month
