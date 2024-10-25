SELECT
    norpac.debriefed_age.year,
    to_char(norpac.debriefed_age.haul_offload_date,'MM') as MONTH,
    norpac.debriefed_age.species,
    CASE
        WHEN norpac.debriefed_age.gear IN (
            1,
            2,
            3,
            4
        ) THEN
            'TRW'
        WHEN norpac.debriefed_age.gear IN (
            6
        ) THEN
            'POT'
        WHEN norpac.debriefed_age.gear IN (
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
    norpac.debriefed_age.nmfs_area,
    CASE
        WHEN norpac.debriefed_age.port_join IS NULL THEN
            concat('H', TO_CHAR(norpac.debriefed_age.haul_join))
        WHEN norpac.debriefed_age.haul_join IS NULL THEN
            concat('P', TO_CHAR(norpac.debriefed_age.port_join))
        ELSE
            concat('H', TO_CHAR(norpac.debriefed_age.haul_join))
    END AS haul_join,
    norpac.debriefed_age.sex,
    norpac.debriefed_age.length,
    norpac.debriefed_age.age,
    'DOMESTIC' AS source
FROM norpac.DEBRIEFED_AGE
WHERE norpac.DEBRIEFED_AGE.NMFS_AREA
    -- insert region
  AND norpac.DEBRIEFED_AGE.SPECIES
    -- insert species
ORDER BY norpac.DEBRIEFED_AGE.YEAR
