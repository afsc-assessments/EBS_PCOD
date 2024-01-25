SELECT
    gap_products.akfin_agecomp.year,
    gap_products.akfin_agecomp.age,
    SUM(gap_products.akfin_agecomp.population_count) AS "AGEPOP"
FROM
    gap_products.akfin_agecomp
WHERE
    gap_products.akfin_agecomp.age >= 0
    AND  gap_products.akfin_agecomp.species_code
        -- insert species
    AND gap_products.akfin_agecomp.area_id 
        -- insert area_id
    AND gap_products.akfin_agecomp.year
        -- insert start_year 
GROUP BY
    gap_products.akfin_agecomp.year,
    gap_products.akfin_agecomp.age
ORDER BY
    gap_products.akfin_agecomp.year