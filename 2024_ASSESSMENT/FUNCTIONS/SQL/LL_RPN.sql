select    *
from      afsc.lls_area_rpn_all_strata
where     species_code 
             -- insert species
          and country = 'United States' 
          and year           
             -- insert year 
          and exploitable = 1 and
          fmp_management_area 
             -- insert area
          and council_sablefish_management_area 
             -- insert region
order by  year asc