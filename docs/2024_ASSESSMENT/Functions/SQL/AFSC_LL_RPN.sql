SELECT
    afsc.lls_fmp_subarea_all_strata.year,
    afsc.lls_fmp_subarea_all_strata.council_management_area,
    afsc.lls_fmp_subarea_all_strata.rpn,
    afsc.lls_fmp_subarea_all_strata.rpn_var
FROM
    afsc.lls_fmp_subarea_all_strata
WHERE
    afsc.lls_fmp_subarea_all_strata.year > 1996
    AND afsc.lls_fmp_subarea_all_strata.council_management_area
    -- insert area
    AND afsc.lls_fmp_subarea_all_strata.species_code
    -- insert species
ORDER BY
    afsc.lls_fmp_subarea_all_strata.year