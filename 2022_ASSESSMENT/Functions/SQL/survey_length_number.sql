SELECT
    TO_CHAR(racebase.haul.start_time, 'yyyy') AS year,
    SUM(racebase.length.frequency) AS survey_length
FROM
    racebase.length
    INNER JOIN racebase.haul ON racebase.length.cruisejoin = racebase.haul.cruisejoin
                                AND racebase.length.hauljoin = racebase.haul.hauljoin
WHERE
    racebase.length.region 
    -- insert survey
    AND racebase.length.species_code
    -- insert species
    AND racebase.haul.abundance_haul = 'Y'
GROUP BY
    racebase.length.region,
    TO_CHAR(racebase.haul.start_time, 'yyyy'),
    racebase.length.species_code
ORDER BY
    year