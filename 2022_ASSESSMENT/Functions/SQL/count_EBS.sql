SELECT
  racebase.length.species_code,
  COUNT(DISTINCT racebase.length.hauljoin) AS HAULS,
  trunc(racebase.length.cruise / 100) AS YEAR
FROM
  racebase.length
  INNER JOIN racebase.haul ON racebase.length.hauljoin = racebase.haul.hauljoin
  AND racebase.length.cruisejoin = racebase.haul.cruisejoin
WHERE
  racebase.length.region NOT IN ('GOA','AI')
  AND racebase.length.species_code
  -- insert species
  AND racebase.haul.abundance_haul = 'Y'
GROUP BY
  racebase.length.region,
  racebase.length.species_code, 
  trunc(racebase.length.cruise / 100),
  racebase.haul.abundance_haul
ORDER BY
  YEAR DESC