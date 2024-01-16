SELECT haehnr.biomass_EBS_STANDARD.YEAR as YEAR,
                haehnr.biomass_EBS_STANDARD.BIOMASS as BIOM,
                haehnr.biomass_EBS_STANDARD.POPULATION as POP,
                haehnr.biomass_EBS_STANDARD.VARBIO as BIOMVAR,
                haehnr.biomass_EBS_STANDARD.VARPOP as POPVAR,
                haehnr.biomass_EBS_STANDARD.HAULCOUNT as NUMHAULS,
                haehnr.biomass_EBS_STANDARD.CATCOUNT as NUMCAUGHT
FROM haehnr.biomass_EBS_STANDARD
WHERE haehnr.biomass_EBS_STANDARD.stratum = 999
                AND haehnr.biomass_EBS_STANDARD.YEAR < 1987  
                AND haehnr.biomass_EBS_STANDARD.SPECIES_CODE 
                -- insert species
ORDER BY haehnr.biomass_EBS_STANDARD.YEAR