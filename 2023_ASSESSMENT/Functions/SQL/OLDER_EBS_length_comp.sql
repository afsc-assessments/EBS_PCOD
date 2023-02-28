		SELECT
    			afsc.sizecmp_ebsshelf_standard.year,
    			afsc.sizecmp_ebsshelf_standard.length / 10 AS length,
    			SUM(afsc.sizecmp_ebsshelf_standard.total) AS EBS_TOTAL
		FROM
    			afsc.sizecmp_ebsshelf_standard
		WHERE
    			afsc.sizecmp_ebsshelf_standard.year 
                -- insert year
    			AND afsc.sizecmp_ebsshelf_standard.species_code 
                -- insert species
    			AND afsc.sizecmp_ebsshelf_standard.subarea = 999
		GROUP BY
   			afsc.sizecmp_ebsshelf_standard.year,
    			afsc.sizecmp_ebsshelf_standard.length / 10
		ORDER BY
   			afsc.sizecmp_ebsshelf_standard.year,
    			length
