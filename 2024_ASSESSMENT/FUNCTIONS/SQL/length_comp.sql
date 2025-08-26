SELECT
    gap_products.akfin_sizecomp.year                  AS year,
    gap_products.akfin_sizecomp.sex                   AS sex, 
    gap_products.akfin_sizecomp.length_mm / 10        AS length,
    SUM(gap_products.akfin_sizecomp.population_count) AS total
FROM
    gap_products.akfin_sizecomp
WHERE
    gap_products.akfin_sizecomp.area_id
    -- insert area_id
    AND gap_products.akfin_sizecomp.species_code
    -- insert species 
GROUP BY
    gap_products.akfin_sizecomp.year,
    gap_products.akfin_sizecomp.sex,
    gap_products.akfin_sizecomp.length_mm / 10
ORDER BY
    year, 
    sex,
    length