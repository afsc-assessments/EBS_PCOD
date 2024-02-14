SELECT
    akr.v_noncommercial_fishery_catch.collection_name,
    akr.v_noncommercial_fishery_catch.collection_year,
    akr.v_noncommercial_fishery_catch.species_code,
    SUM(akr.v_noncommercial_fishery_catch.weight) AS "Sum_WEIGHT"
FROM
    akr.v_noncommercial_fishery_catch
WHERE
    akr.v_noncommercial_fishery_catch.reporting_area
    -- insert region
    AND akr.v_noncommercial_fishery_catch.collection_year
    -- insert fyr
    AND akr.v_noncommercial_fishery_catch.species_code
    -- insert code
GROUP BY
    akr.v_noncommercial_fishery_catch.collection_name,
    akr.v_noncommercial_fishery_catch.collection_year,
    akr.v_noncommercial_fishery_catch.species_code
ORDER BY
    akr.v_noncommercial_fishery_catch.collection_name,
    akr.v_noncommercial_fishery_catch.collection_year