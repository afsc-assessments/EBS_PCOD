select    *
from      afsc.lls_length_rpn_by_area_all_strata
where     species_code 
           -- insert species 
           and country = 'United States' 
           and year 
           -- insert year
           and council_sablefish_management_area
           -- insert region 
           and length < 999
order by   year asc
             