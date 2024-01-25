SELECT
    gap_products.akfin_length.species_code,
    gap_products.akfin_cruise.year,
    SUM(gap_products.akfin_length.frequency) AS survey_length
FROM
         gap_products.akfin_haul
    INNER JOIN gap_products.akfin_cruise ON gap_products.akfin_cruise.cruisejoin = gap_products.akfin_haul.cruisejoin
    INNER JOIN gap_products.akfin_length ON gap_products.akfin_haul.hauljoin = gap_products.akfin_length.hauljoin
WHERE
    gap_products.akfin_cruise.survey_definition_id
    -- insert survey
    AND gap_products.akfin_length.species_code
    -- insert species
GROUP BY
    gap_products.akfin_length.species_code,
    gap_products.akfin_cruise.year
ORDER BY
    gap_products.akfin_length.species_code,
    gap_products.akfin_cruise.year