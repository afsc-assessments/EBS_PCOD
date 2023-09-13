SELECT
        norpac.debriefed_age.species,
        norpac.debriefed_age.year,
        TO_CHAR(norpac.debriefed_age.haul_offload_date, 'mm') AS month,
        norpac.debriefed_age.haul_offload_date,
        norpac.debriefed_age.cruise,
        norpac.debriefed_age.vessel,
        norpac.debriefed_age.gear,
        norpac.debriefed_age.sex,
	norpac.debriefed_age.age,
        norpac.debriefed_age.length,
        norpac.debriefed_age.weight
    FROM
        norpac.debriefed_age
    WHERE
        norpac.debriefed_age.species
        -- insert species
        AND norpac.debriefed_age.length IS NOT NULL
        AND norpac.debriefed_age.weight IS NOT NULL
        AND norpac.debriefed_age.nmfs_area 
        -- insert location
    ORDER BY
        norpac.debriefed_age.year,
        norpac.debriefed_age.cruise,
        norpac.debriefed_age.vessel,
        norpac.debriefed_age.length,
        norpac.debriefed_age.weight
