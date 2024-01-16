SELECT
    COUNT(DISTINCT afsc.race_length_ebsshelf.hauljoin) AS hauls,
    trunc(afsc.race_length_ebsshelf.cruise / 100) AS year
FROM
    afsc.race_length_ebsshelf
WHERE
    afsc.race_length_ebsshelf.species_code
    -- insert species
GROUP BY
    afsc.race_length_ebsshelf.species_code,
    trunc(afsc.race_length_ebsshelf.cruise / 100)
ORDER BY
    year