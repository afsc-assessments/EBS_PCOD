SELECT
    			haehnr.nbs_sizecomp.year,
    			haehnr.nbs_sizecomp.length / 10 AS length,
    			haehnr.nbs_sizecomp.total AS NBS_TOTAL
		FROM
    			haehnr.nbs_sizecomp
		WHERE
    			haehnr.nbs_sizecomp.species_code
          -- insert species
    			AND haehnr.nbs_sizecomp.stratum > 9999
		ORDER BY
   			haehnr.nbs_sizecomp.year,
    			length
