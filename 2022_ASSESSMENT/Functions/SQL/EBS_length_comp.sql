SELECT
    			haehnr.sizecomp_ebs_plusnw.year,
    			haehnr.sizecomp_ebs_plusnw.length / 10 AS length,
    			haehnr.sizecomp_ebs_plusnw.total AS EBS_TOTAL
		FROM
    			haehnr.sizecomp_ebs_plusnw
		WHERE
    			haehnr.sizecomp_ebs_plusnw.species_code 
                -- insert species
    			AND haehnr.sizecomp_ebs_plusnw.subarea > 999
		ORDER BY
    			haehnr.sizecomp_ebs_plusnw.year,
    			length