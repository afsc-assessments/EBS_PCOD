SELECT
    obsint.debriefed_age.year,
    to_char(obsint.debriefed_age.haul_offload_date,'MM') as MONTH,
    obsint.debriefed_age.species,
    CASE
        WHEN obsint.debriefed_age.gear IN (
            1,
            2,
            3,
            4
        ) THEN
            'TRW'
        WHEN obsint.debriefed_age.gear IN (
            6
        ) THEN
            'POT'
        WHEN obsint.debriefed_age.gear IN (
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
    obsint.debriefed_age.nmfs_area,
    CASE
        WHEN obsint.debriefed_age.port_join IS NULL THEN
            concat('H', TO_CHAR(obsint.debriefed_age.haul_join))
        WHEN obsint.debriefed_age.haul_join IS NULL THEN
            concat('P', TO_CHAR(obsint.debriefed_age.port_join))
        ELSE
            concat('H', TO_CHAR(obsint.debriefed_age.haul_join))
    END AS haul_join,
    obsint.debriefed_age.sex,
    obsint.debriefed_age.length,
    obsint.debriefed_age.age,
    'DOMESTIC' AS source
FROM OBSINT.DEBRIEFED_AGE
WHERE OBSINT.DEBRIEFED_AGE.NMFS_AREA
    -- insert region
  AND OBSINT.DEBRIEFED_AGE.SPECIES
    -- insert species
ORDER BY OBSINT.DEBRIEFED_AGE.YEAR