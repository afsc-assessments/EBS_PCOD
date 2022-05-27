SELECT
      norpac.foreign_blend.species_name AS SPECIES,
      SUM(norpac.foreign_blend.blend_tonnage) AS TONS,
      to_char(norpac.foreign_blend.week_date,'MM') AS MONTH_WED,
      CASE
           WHEN norpac.foreign_blend.vessel_class LIKE '%POT%'
           THEN 'POT'
           WHEN norpac.foreign_blend.vessel_class LIKE '%LONG%'
           THEN 'HAL'
           ELSE 'TRW'
      END AS GEAR, 
      norpac.foreign_blend.yr as YEAR,
      norpac.foreign_blend.area_number AS AREA,
      'FOREIGN' as SOURCE   
  FROM
      norpac.foreign_blend
  WHERE
      norpac.foreign_blend.species_name 
      -- insert species_catch
      AND norpac.foreign_blend.area_name 
        -- insert subarea
  GROUP BY
      norpac.foreign_blend.species_name,
      norpac.foreign_blend.yr,
      to_char(norpac.foreign_blend.week_date,'MM'),
      norpac.foreign_blend.area_number,
      CASE WHEN norpac.foreign_blend.vessel_class LIKE '%POT%' THEN 'POT' 
      WHEN norpac.foreign_blend.vessel_class LIKE '%LONG%' THEN 'HAL'
      ELSE 'TRW'
      END
ORDER BY
      norpac.foreign_blend.species_name,
      norpac.foreign_blend.yr,
      to_char(norpac.foreign_blend.week_date,'MM'),
      norpac.foreign_blend.area_number,
      CASE WHEN norpac.foreign_blend.vessel_class LIKE '%POT%' THEN 'POT' 
      WHEN norpac.foreign_blend.vessel_class LIKE '%LONG%' THEN 'HAL'
      ELSE 'TRW'
      END