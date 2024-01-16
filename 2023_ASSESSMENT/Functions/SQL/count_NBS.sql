		SELECT
    			haehnr.length_nbs.species_code,
    			COUNT(DISTINCT haehnr.length_nbs.hauljoin) AS nbs_hauls,
    			haehnr.length_nbs.cruise
		FROM
    			haehnr.length_nbs
		WHERE
   			 haehnr.length_nbs.species_code 
         -- insert species
		GROUP BY
   			 haehnr.length_nbs.species_code,
    			haehnr.length_nbs.cruise
		ORDER BY
   			 haehnr.length_nbs.cruise