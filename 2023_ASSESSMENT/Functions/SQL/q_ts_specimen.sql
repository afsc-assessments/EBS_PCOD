SELECT
    racebase.specimen.species_code,
    racebase.specimen.length,
    racebase.specimen.sex,
    racebase.specimen.weight,
    racebase.specimen.age,
    racebase.specimen.maturity,
    racebase.cruise.region,
    racebase.cruise.survey_name,
    racebase.haul.end_latitude,
    racebase.haul.end_longitude,
    racebase.haul.bottom_depth,
    racebase.haul.abundance_haul,
    racebase.haul.stratum,
    TO_CHAR(racebase.cruise.start_date, 'yyyy') AS year
FROM
    racebase.haul
    INNER JOIN racebase.cruise ON racebase.haul.cruisejoin = racebase.cruise.cruisejoin
    INNER JOIN racebase.specimen ON racebase.haul.cruisejoin = racebase.specimen.cruisejoin
                                    AND racebase.haul.hauljoin = racebase.specimen.hauljoin
WHERE
    racebase.specimen.species_code
    -- insert species_code 
    AND racebase.cruise.region
    -- insert region
    AND racebase.cruise.survey_name
    -- insert survey_name
    AND racebase.haul.abundance_haul = 'Y'
    AND TO_CHAR(racebase.cruise.start_date, 'yyyy') 
    -- insert year
 