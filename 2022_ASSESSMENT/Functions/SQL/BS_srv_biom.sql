SELECT afsc.race_biomass_ebsshelf_plusnw.YEAR as YEAR,
                afsc.race_biomass_ebsshelf_plusnw.BIOMASS as BIOM,
                afsc.race_biomass_ebsshelf_plusnw.POPULATION as POP,
                afsc.race_biomass_ebsshelf_plusnw.VARBIO as BIOMVAR,
                afsc.race_biomass_ebsshelf_plusnw.VARPOP as POPVAR,
                afsc.race_biomass_ebsshelf_plusnw.HAULCOUNT as NUMHAULS,
                afsc.race_biomass_ebsshelf_plusnw.CATCOUNT as NUMCAUGHT
FROM afsc.race_biomass_ebsshelf_plusnw
WHERE afsc.race_biomass_ebsshelf_plusnw.stratum = 999 
                AND afsc.race_biomass_ebsshelf_plusnw.SPECIES_CODE 
                -- insert species
ORDER BY afsc.race_biomass_ebsshelf_plusnw.YEAR