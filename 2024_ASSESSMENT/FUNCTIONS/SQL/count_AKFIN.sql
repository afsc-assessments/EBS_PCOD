SELECT
    gap_products.akfin_cruise.year           AS year,
    COUNT(DISTINCT racebase.length.hauljoin) AS HAULS
FROM
         gap_products.akfin_cruise
    INNER JOIN gap_products.akfin_haul ON gap_products.akfin_cruise.cruisejoin = gap_products.akfin_haul.cruisejoin
    INNER JOIN racebase.catch ON gap_products.akfin_haul.cruisejoin = racebase.catch.cruisejoin
                                 AND gap_products.akfin_haul.hauljoin = racebase.catch.hauljoin
    INNER JOIN racebase.length ON racebase.catch.cruisejoin = racebase.length.cruisejoin
                                  AND racebase.catch.hauljoin = racebase.length.hauljoin
                                  AND racebase.catch.catchjoin = racebase.length.catchjoin
WHERE
    gap_products.akfin_cruise.survey_definition_id 
    -- insert survey
    AND racebase.length.species_code
    -- insert species
GROUP BY
    gap_products.akfin_cruise.year,
    racebase.length.species_code
ORDER BY
    year