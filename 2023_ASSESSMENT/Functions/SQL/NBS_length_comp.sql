SELECT
    afsc.RACE_LENGTH_NBS.year,
    afsc.RACE_LENGTH_NBS.length/10 AS LENGTH,
    afsc.RACE_LENGTH_NBS.total AS NBS_TOTAL
FROM
    afsc.RACE_LENGTH_NBS
WHERE
    afsc.RACE_LENGTH_NBS.species_code
    -- insert species
    AND afsc.RACE_LENGTH_NBS.stratum > 9999
ORDER BY
    afsc.RACE_LENGTH_NBS.year,
    afsc.RACE_LENGTH_NBS.length
