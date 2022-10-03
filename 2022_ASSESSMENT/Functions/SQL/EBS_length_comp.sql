SELECT
    haehnr.sizecomp_ebs_plusnw_stratum.year,
    haehnr.sizecomp_ebs_plusnw_stratum.length /10 AS LENGTH,
    haehnr.sizecomp_ebs_plusnw_stratum.total AS EBS_TOTAL
FROM
    haehnr.sizecomp_ebs_plusnw_stratum
WHERE
    haehnr.sizecomp_ebs_plusnw_stratum.species_code
-- insert species
    AND haehnr.sizecomp_ebs_plusnw_stratum.stratum > 9999   
ORDER BY
    haehnr.sizecomp_ebs_plusnw_stratum.year,
    haehnr.sizecomp_ebs_plusnw_stratum.length 			