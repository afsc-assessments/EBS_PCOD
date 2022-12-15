SELECT
    racebase.specimen.region,
    to_char(racebase.haul.start_time, 'yyyy') AS year,
    racebase.specimen.cruise,
    racebase.haul.vessel,
    racebase.specimen.hauljoin,
    racebase.specimen.haul,
    racebase.specimen.species_code,
    racebase.specimen.length,
    racebase.specimen.sex,
    racebase.specimen.weight,
    racebase.specimen.maturity,
    racebase.specimen.age,
    racebase.haul.gear,
    racebase.specimen.specimen_sample_type,
    racebase.specimen.specimenid,
    racebase.specimen.biostratum,
    racebase.cruise.survey_name
FROM
    racebase.specimen
    INNER JOIN racebase.haul ON racebase.specimen.cruisejoin = racebase.haul.cruisejoin
                                AND racebase.specimen.hauljoin = racebase.haul.hauljoin
    INNER JOIN racebase.cruise ON racebase.cruise.cruisejoin = racebase.haul.cruisejoin
WHERE
    to_char(racebase.haul.start_time, 'yyyy')
    -- insert year
    AND racebase.specimen.species_code 
    -- insert species
    AND racebase.haul.region
    -- insert survey
    AND racebase.cruise.survey_name
    -- insert sname
    AND racebase.haul.abundance_haul = 'Y'
ORDER BY
    to_char(racebase.haul.start_time, 'yyyy')