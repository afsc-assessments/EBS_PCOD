SELECT
    'Survey' as "Source",
    racebase.specimen.weight / 1000 AS "Weight_kg",
    CASE
      When racebase.specimen.sex =1 then 'F'
      When racebase.specimen.sex =2 then 'M'
      When racebase.specimen.sex=3 then 'U'
      else 'U'
      END AS "Sex",
    racebase.specimen.age           AS "Age_yrs",
    racebase.specimen.length/10        AS "Length_cm",
    to_char(
        racebase.haul.start_time, 'mm'
    )                               AS "Month",
    to_char(
        racebase.haul.start_time, 'yyyy'
    )                               AS "Year"
FROM
    racebase.haul
    INNER JOIN racebase.specimen ON racebase.haul.cruisejoin = racebase.specimen.cruisejoin
                                    AND racebase.haul.hauljoin = racebase.specimen.hauljoin
WHERE
    racebase.specimen.species_code
    -- insert species
    AND racebase.specimen.region
    -- insert region
    AND racebase.haul.abundance_haul = 'Y'