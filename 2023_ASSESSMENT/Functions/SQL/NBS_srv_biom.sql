SELECT
    haehnr.biomass_nbs_safe.species_code,
    haehnr.biomass_nbs_safe.year,
    haehnr.biomass_nbs_safe.biomass,
    haehnr.biomass_nbs_safe.population,
    haehnr.biomass_nbs_safe.varbio,
    haehnr.biomass_nbs_safe.varpop,
    haehnr.biomass_nbs_safe.haulcount   AS numhauls,
    haehnr.biomass_nbs_safe.catcount    AS numcaught
FROM
    haehnr.biomass_nbs_safe
WHERE haehnr.biomass_nbs_safe.stratum = 999 
                AND haehnr.biomass_nbs_safe.species_code
    -- insert species
ORDER BY
    haehnr.biomass_nbs_safe.year