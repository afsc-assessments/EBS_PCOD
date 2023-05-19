SELECT
    COUNT(DISTINCT afsc.race_length_nbs.hauljoin) AS hauls,
    trunc(afsc.race_length_nbs.cruise / 100) AS year
FROM
    afsc.race_length_nbs
WHERE
    afsc.race_length_nbs.species_code 
    -- insert species
GROUP BY
    afsc.race_length_nbs.species_code,
    trunc(afsc.race_length_nbs.cruise / 100)
ORDER BY
    year