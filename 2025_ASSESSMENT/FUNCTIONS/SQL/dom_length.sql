SELECT
      CASE 
        WHEN norpac.DEBRIEFED_LENGTH.GEAR in (1,2,3,4) 
        THEN 'TRW'
        WHEN norpac.DEBRIEFED_LENGTH.GEAR in 6 
        THEN 'POT' 
        WHEN norpac.DEBRIEFED_LENGTH.GEAR in (5,7,9,10,11,68,8) 
        THEN 'HAL' 
      END                                              AS GEAR, 
      CONCAT('H',TO_CHAR(norpac.DEBRIEFED_SPCOMP.HAUL_JOIN))  AS HAUL_JOIN, 
      TO_CHAR(norpac.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') AS MONTH, 
      TO_CHAR(norpac.DEBRIEFED_SPCOMP.HAUL_DATE, 'YYYY') AS YEAR,
      norpac.DEBRIEFED_LENGTH.SPECIES AS SPECIES,
      norpac.DEBRIEFED_SPCOMP.EXTRAPOLATED_NUMBER        AS NUMB, 
      norpac.DEBRIEFED_SPCOMP.CRUISE        AS CRUISE, 
      norpac.DEBRIEFED_SPCOMP.PERMIT        AS PERMIT, 
      norpac.DEBRIEFED_SPCOMP.HAUL        AS HAUL, 
      norpac.DEBRIEFED_SPCOMP.EXTRAPOLATED_WEIGHT,
      CASE 
        WHEN norpac.DEBRIEFED_LENGTH.SEX IN 'F'
        THEN '1'
        WHEN norpac.DEBRIEFED_LENGTH.SEX IN 'M'
        THEN '2'
        WHEN norpac.DEBRIEFED_LENGTH.SEX IN 'U'
        THEN '3'
      END  AS SEX,
      norpac.DEBRIEFED_LENGTH.LENGTH                     AS LENGTH, 
      norpac.DEBRIEFED_LENGTH.FREQUENCY                  AS sum_frequency, 
      norpac.DEBRIEFED_SPCOMP.HAUL_DATE AS HDAY, 
      norpac.DEBRIEFED_HAUL.NMFS_AREA AS AREA, 
      norpac.DEBRIEFED_HAUL.CATCHER_BOAT_ADFG AS VES_AKR_ADFG,
      'DOMESTIC' AS SOURCE 
FROM norpac.DEBRIEFED_HAUL 
  INNER JOIN norpac.DEBRIEFED_SPCOMP 
  ON norpac.DEBRIEFED_HAUL.HAUL_JOIN = norpac.DEBRIEFED_SPCOMP.HAUL_JOIN 
  INNER JOIN norpac.DEBRIEFED_LENGTH 
  ON norpac.DEBRIEFED_HAUL.HAUL_JOIN = norpac.DEBRIEFED_LENGTH.HAUL_JOIN 
WHERE 
       norpac.DEBRIEFED_HAUL.NMFS_AREA 
         -- insert region
      AND norpac.DEBRIEFED_SPCOMP.SPECIES  
          -- insert species
      AND norpac.DEBRIEFED_LENGTH.SPECIES 
          -- insert species
