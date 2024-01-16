SELECT
    afsc.race_sizecomp_nbs.year,
    afsc.race_sizecomp_nbs.length /10 AS LENGTH,
    afsc.race_sizecomp_nbs.total AS NBS_TOTAL
FROM
    afsc.race_sizecomp_nbs 
WHERE
    afsc.race_sizecomp_nbs.species_code
-- insert species
    AND afsc.race_sizecomp_nbs.stratum = 999999   
ORDER BY
    afsc.race_sizecomp_nbs.year,
    afsc.race_sizecomp_nbs.length 			
