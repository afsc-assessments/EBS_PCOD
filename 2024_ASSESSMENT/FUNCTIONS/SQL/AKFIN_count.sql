SELECT
    gap_products.akfin_cruise.year                       AS year,
    COUNT(DISTINCT gap_products.akfin_length_v.hauljoin) AS hauls,
    SUM(gap_products.akfin_length_v.frequency)           AS lengths
FROM
         gap_products.akfin_cruise
    INNER JOIN gap_products.akfin_length_v ON gap_products.akfin_cruise.cruisejoin = gap_products.akfin_length_v.cruisejoin
WHERE
    gap_products.akfin_length_v.species_code 
    -- insert species
    AND gap_products.akfin_cruise.survey_definition_id
    -- insert survey
GROUP BY
    gap_products.akfin_cruise.year,
    gap_products.akfin_length_v.species_code
ORDER BY
    year