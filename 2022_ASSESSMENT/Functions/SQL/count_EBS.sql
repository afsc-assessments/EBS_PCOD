		SELECT
    			haehnr.length_ebsshelf.species_code,
    			COUNT(DISTINCT haehnr.length_ebsshelf.hauljoin) AS HAULS,
    			haehnr.length_ebsshelf.cruise
		FROM
    			haehnr.length_ebsshelf
		WHERE
    			haehnr.length_ebsshelf.species_code 
                -- insert species
		GROUP BY
    			haehnr.length_ebsshelf.species_code,
    			haehnr.length_ebsshelf.cruise
		ORDER BY
    			haehnr.length_ebsshelf.cruise
