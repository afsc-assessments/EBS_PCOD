		SELECT
    			haehnr.sizecomp_ebs_standard_stratum.year,
    			haehnr.sizecomp_ebs_standard_stratum.length / 10 AS length,
    			SUM(haehnr.sizecomp_ebs_standard_stratum.total) AS EBS_TOTAL
		FROM
    			haehnr.sizecomp_ebs_standard_stratum
		WHERE
    			haehnr.sizecomp_ebs_standard_stratum.year 
                -- insert year
    			AND haehnr.sizecomp_ebs_standard_stratum.species_code 
                -- insert species
    			AND haehnr.sizecomp_ebs_standard_stratum.stratum > 9999
		GROUP BY
   			haehnr.sizecomp_ebs_standard_stratum.year,
    			haehnr.sizecomp_ebs_standard_stratum.length / 10
		ORDER BY
   			haehnr.sizecomp_ebs_standard_stratum.year,
    			length