SELECT
    afsc.race_sizecmp_ebsshelf_plusnw.year,
    afsc.race_sizecmp_ebsshelf_plusnw.length /10 AS LENGTH,
    afsc.race_sizecmp_ebsshelf_plusnw.total AS EBS_TOTAL
FROM
    afsc.race_sizecmp_ebsshelf_plusnw 
WHERE
    afsc.race_sizecmp_ebsshelf_plusnw.species_code
-- insert species
    AND afsc.race_sizecmp_ebsshelf_plusnw.subarea = 999   
ORDER BY
    afsc.race_sizecmp_ebsshelf_plusnw.year,
    afsc.race_sizecmp_ebsshelf_plusnw.length 			
