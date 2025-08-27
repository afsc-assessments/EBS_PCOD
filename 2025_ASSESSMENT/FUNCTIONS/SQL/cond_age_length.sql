SELECT
    gap_products.akfin_cruise.year,
    gap_products.akfin_cruise.cruisejoin,
    gap_products.akfin_cruise.cruise,
    gap_products.akfin_cruise.vessel_id,
    gap_products.akfin_specimen.hauljoin,
    gap_products.akfin_haul.haul,
    gap_products.akfin_specimen.species_code,
    gap_products.akfin_specimen.length_mm,
    gap_products.akfin_specimen.sex,
    gap_products.akfin_specimen.weight_g,
    gap_products.akfin_specimen.maturity,
    gap_products.akfin_specimen.age,
    gap_products.akfin_haul.latitude_dd_end,
    gap_products.akfin_haul.longitude_dd_end,
    gap_products.akfin_haul.haul_type,
    gap_products.akfin_haul.gear,
    gap_products.akfin_haul.performance,
    gap_products.akfin_specimen.specimen_sample_type,
    gap_products.akfin_specimen.specimen_id,
    gap_products.akfin_cruise.survey_definition_id
FROM
         gap_products.akfin_cruise
    INNER JOIN gap_products.akfin_haul ON gap_products.akfin_cruise.cruisejoin = gap_products.akfin_haul.cruisejoin
    INNER JOIN gap_products.akfin_specimen ON gap_products.akfin_haul.hauljoin = gap_products.akfin_specimen.hauljoin
WHERE
        gap_products.akfin_cruise.year
	-- insert start_year
	AND gap_products.akfin_specimen.species_code
	-- insert species
	AND gap_products.akfin_haul.performance >= 0
    AND gap_products.akfin_cruise.survey_definition_id
	-- insert survey
	ORDER BY
    gap_products.akfin_cruise.year,
    gap_products.akfin_specimen.sex