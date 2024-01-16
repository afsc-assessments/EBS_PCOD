SELECT
    obsint.debriefed_length.species,
    obsint.debriefed_length.nmfs_area           AS area,
    obsint.debriefed_length.year                AS year,
    TO_CHAR(obsint.debriefed_length.haul_offload_date, 'MM') AS month,
    obsint.debriefed_length.haul_offload_date   AS DELIVERY_DATE,
    obsint.debriefed_length.cruise,
    obsint.debriefed_length.permit,
    norpac.atl_lov_vessel.adfg_number as DELIVERING_VESSEL,
    CASE
        WHEN obsint.debriefed_length.gear IN (
            1,
            2,
            3,
            4
        ) THEN
            'TRW'
        WHEN obsint.debriefed_length.gear IN (
            6
        ) THEN
            'POT'
        WHEN obsint.debriefed_length.gear IN (
            5,
            7,
            9,
            10,
            11,
            68,
            8
        ) THEN
            'HAL'
    END AS gear,
    obsint.debriefed_length.haul_offload        AS haul,
    concat('P', TO_CHAR(obsint.debriefed_length.port_join)) AS haul_join,
    obsint.debriefed_length.landing_report_id,
    CASE
        WHEN obsint.debriefed_length.sex IN (
            'F'
        ) THEN
            '1'
        WHEN obsint.debriefed_length.sex IN (
            'M'
        ) THEN
            '2'
        WHEN obsint.debriefed_length.sex IN (
            'U'
        ) THEN
            '3'
    END AS sex,
    obsint.debriefed_length.length,
    obsint.debriefed_length.frequency           AS sum_frequency,
    '0' AS numb,
    'DOMESTIC PORT' AS source
FROM
    obsint.debriefed_length
    INNER JOIN norpac.atl_lov_vessel ON obsint.debriefed_length.vessel = norpac.atl_lov_vessel.vessel_code
WHERE
    obsint.debriefed_length.species
    -- insert species
    AND obsint.debriefed_length.nmfs_area
    -- insert region
    AND obsint.debriefed_length.year between 2008 and 2010
    AND obsint.debriefed_length.port_join IS NOT NULL