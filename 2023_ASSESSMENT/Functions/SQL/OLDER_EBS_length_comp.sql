		SELECT
    			afsc.race_sizecmp_ebsshelf_standard.year,
    			afsc.race_sizecmp_ebsshelf_standard.length / 10 AS length,
    			SUM(afsc.race_sizecmp_ebsshelf_standard.total) AS EBS_TOTAL
		FROM
    			afsc.race_sizecmp_ebsshelf_standard
		WHERE
    			afsc.race_sizecmp_ebsshelf_standard.year 
                -- insert year
    			AND afsc.race_sizecmp_ebsshelf_standard.species_code 
                -- insert species
    			AND afsc.race_sizecmp_ebsshelf_standard.subarea = 999
		GROUP BY
   			afsc.race_sizecmp_ebsshelf_standard.year,
    			afsc.race_sizecmp_ebsshelf_standard.length / 10
		ORDER BY
   			afsc.race_sizecmp_ebsshelf_standard.year,
    			length
