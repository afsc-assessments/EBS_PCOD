SELECT
    haehnr.sizecomp_nbs_stratum.year,
    haehnr.sizecomp_nbs_stratum.length/10 AS LENGTH,
    haehnr.sizecomp_nbs_stratum.total AS NBS_TOTAL
FROM
    haehnr.sizecomp_nbs_stratum
WHERE
    haehnr.sizecomp_nbs_stratum.species_code
    -- insert species
    AND haehnr.sizecomp_nbs_stratum.stratum > 9999
ORDER BY
    haehnr.sizecomp_nbs_stratum.year,
    haehnr.sizecomp_nbs_stratum.length