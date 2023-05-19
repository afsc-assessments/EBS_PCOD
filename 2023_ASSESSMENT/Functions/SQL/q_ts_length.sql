SELECT
    racebase.cruise.region,
    racebase.cruise.survey_name,
    racebase.haul.end_latitude,
    racebase.haul.end_longitude,
    racebase.haul.bottom_depth,
    racebase.haul.abundance_haul,
    racebase.haul.stratum,
    TO_CHAR(racebase.cruise.start_date, 'yyyy') AS year,
    racebase.length.species_code,
    racebase.length.sex,
    racebase.length.length,
    racebase.length.frequency
FROM
    racebase.haul
    INNER JOIN racebase.cruise ON racebase.haul.cruisejoin = racebase.cruise.cruisejoin
    INNER JOIN racebase.length ON racebase.haul.cruisejoin = racebase.length.cruisejoin
                                  AND racebase.haul.hauljoin = racebase.length.hauljoin
WHERE
    racebase.haul.abundance_haul = 'Y'
    AND racebase.cruise.region 
    -- insert region
    AND TO_CHAR(racebase.cruise.start_date, 'yyyy')
    -- insert year
    AND racebase.length.species_code
    -- insert species