SELECT
      CASE 
        WHEN norpac.foreign_fishing_operation.vessel_type_code in (1,2,3,4) 
        THEN 'TRW'
        WHEN norpac.foreign_fishing_operation.vessel_type_code in 6 
        THEN 'POT' 
        WHEN norpac.foreign_fishing_operation.vessel_type_code in (5,7,9,10,11,68,8) 
        THEN 'HAL' 
      END AS GEAR, 
      CONCAT('H',TO_CHAR(norpac.foreign_haul.haul_join))  AS HAUL_JOIN, 
      TO_CHAR(norpac.foreign_length.dt, 'MM') AS MONTH,  
      norpac.foreign_length.year, 
      norpac.foreign_length.species AS SPECIES,
      norpac.foreign_spcomp.species_haul_number as NUMB,
      norpac.foreign_length.cruise,
      norpac.foreign_length.vessel AS PERMIT,
      norpac.foreign_length.haul as HAUL,
      norpac.foreign_spcomp.species_haul_weight as extrapolated_weight,
      CASE 
        WHEN norpac.foreign_length.SEX IN 'F'
        THEN '1'
        WHEN norpac.foreign_length.SEX IN 'M'
        THEN '2'
        WHEN norpac.foreign_length.SEX IN 'U'
        THEN '3'
       END  AS SEX,
      norpac.foreign_length.size_group AS LENGTH,
      SUM(norpac.foreign_length.frequency) AS sum_frequency,
      norpac.foreign_length.dt AS HDAY,
      norpac.foreign_haul.generic_area AS AREA,
      norpac.foreign_haul.ADFG_NUMBER AS VES_AKR_ADFG,
      'FOREIGN' AS SOURCE
  FROM
      norpac.foreign_length
      INNER JOIN norpac.foreign_haul ON norpac.foreign_haul.cruise = norpac.foreign_length.cruise
                                      AND norpac.foreign_haul.vessel = norpac.foreign_length.vessel
                                      AND norpac.foreign_haul.year = norpac.foreign_length.year
                                      AND norpac.foreign_haul.haul = norpac.foreign_length.haul
                                      AND norpac.foreign_length.haul_join = norpac.foreign_haul.haul_join
      INNER JOIN norpac.foreign_fishing_operation ON norpac.foreign_fishing_operation.cruise = norpac.foreign_haul.cruise
                                                   AND norpac.foreign_fishing_operation.vessel = norpac.foreign_haul.vessel
      INNER JOIN norpac.foreign_vessel_type ON norpac.foreign_fishing_operation.vessel_type_code = norpac.foreign_vessel_type.vessel_type_code
      INNER JOIN norpac.foreign_spcomp ON norpac.foreign_length.cruise = norpac.foreign_spcomp.cruise
                                        AND norpac.foreign_length.vessel = norpac.foreign_spcomp.vessel
                                        AND norpac.foreign_length.haul = norpac.foreign_spcomp.haul
                                        AND norpac.foreign_length.year = norpac.foreign_spcomp.year
                                        AND norpac.foreign_length.species = norpac.foreign_spcomp.species
                                        AND norpac.foreign_length.haul_join = norpac.foreign_spcomp.haul_join
  WHERE
     norpac.foreign_length.year > 1976
     AND norpac.foreign_length.year < 1991
     AND norpac.foreign_length.species 
         -- insert species
     AND norpac.foreign_haul.generic_area 
          -- insert region
  GROUP BY
      norpac.foreign_length.size_group,
      norpac.foreign_length.sex,
      norpac.foreign_length.cruise,
      norpac.foreign_length.vessel,
      norpac.foreign_length.year,
      norpac.foreign_length.dt,
      norpac.foreign_length.haul,
      norpac.foreign_length.species,
      norpac.foreign_haul.generic_area,
      norpac.foreign_fishing_operation.vessel_type_code,
      norpac.foreign_spcomp.species_haul_number,
      norpac.foreign_spcomp.species_haul_weight,
      norpac.foreign_haul.haul_join,
      norpac.foreign_haul.ADFG_NUMBER
  ORDER BY
      norpac.foreign_length.dt,
      norpac.foreign_length.haul,
      norpac.foreign_length.sex,
      norpac.foreign_length.size_group