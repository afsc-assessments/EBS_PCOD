SELECT haehnr.biomass_EBS_PLUSNW.YEAR as YEAR,
                haehnr.biomass_EBS_PLUSNW.BIOMASS as BIOM,
                haehnr.biomass_EBS_PLUSNW.POPULATION as POP,
                haehnr.biomass_EBS_PLUSNW.VARBIO as BIOMVAR,
                haehnr.biomass_EBS_PLUSNW.VARPOP as POPVAR,
                haehnr.biomass_EBS_PLUSNW.HAULCOUNT as NUMHAULS,
                haehnr.biomass_EBS_PLUSNW.CATCOUNT as NUMCAUGHT
FROM haehnr.biomass_EBS_PLUSNW
WHERE haehnr.biomass_EBS_PLUSNW.stratum = 999 
                AND haehnr.biomass_EBS_PLUSNW.SPECIES_CODE 
                -- insert species
ORDER BY haehnr.biomass_EBS_PLUSNW.YEAR