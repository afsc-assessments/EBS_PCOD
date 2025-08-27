SELECT
     replace(concat(concat(council.comprehensive_ft.adfg_h_ticket_type, council.comprehensive_ft.adfg_h_ticket_year), council.comprehensive_ft
    .adfg_h_pre_print_ticket), ' ', '') AS fish_ticket_no,
    council.comprehensive_ft.akfin_species_code,
    council.comprehensive_ft.akfin_year,
    council.comprehensive_ft.adfg_h_date_landed AS DELIVERY_DATE,
    council.comprehensive_ft.week_end_date,
    council.comprehensive_ft.species_name,
    council.comprehensive_ft.vessel_id,
    council.comprehensive_ft.ves_akr_cg_num,
    council.comprehensive_ft.ves_akr_name,
    council.comprehensive_ft.adfg_h_adfg_number AS DELIVERING_VESSEL,
    council.comprehensive_ft.reporting_area_code,
    council.comprehensive_ft.fmp_subarea,
    council.comprehensive_ft.fmp_gear,
    SUM(council.comprehensive_ft.adfg_i_whole_pounds * 0.000453592) AS tons
FROM
    council.comprehensive_ft
WHERE
    council.comprehensive_ft.akfin_species_code 
    -- insert species
    AND council.comprehensive_ft.akfin_year > 1998
GROUP BY
    council.comprehensive_ft.akfin_species_code,
    council.comprehensive_ft.akfin_year,
    council.comprehensive_ft.adfg_h_date_landed,
    council.comprehensive_ft.week_end_date,
    council.comprehensive_ft.species_name,
    council.comprehensive_ft.vessel_id,
    council.comprehensive_ft.reporting_area_code,
    council.comprehensive_ft.fmp_subarea,
    council.comprehensive_ft.fmp_gear,
    replace(concat(concat(council.comprehensive_ft.adfg_h_ticket_type, council.comprehensive_ft.adfg_h_ticket_year), council.comprehensive_ft
    .adfg_h_pre_print_ticket), ' ', ''),
    council.comprehensive_ft.ves_akr_cg_num,
    council.comprehensive_ft.ves_akr_name,
    council.comprehensive_ft.adfg_h_adfg_number
