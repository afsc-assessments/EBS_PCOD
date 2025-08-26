library(coldpool)
library(curl)
library(data.table)
library(DBI)
library(dplyr)
library(extrafont)
library(ggpubr)
library(heatwaveR)
library(INLAspacetime)
library(lubridate)
library(ncdf4)
library(odbc)
library(PCICt)
library(png)
library(raster)
library(scales)
library(sdmTMB)
library(sp)
library(surveyjoin)
library(tidync)
library(tidyr)
library(tidyverse)
library(zoo)



#--- Connect to AFSC Oracle DB ---
afsc <- DBI::dbConnect(
  odbc::odbc(), "afsc",
  UID = keyring::key_list("afsc")$username,
  PWD = keyring::key_get("afsc", keyring::key_list("afsc")$username)
)

#--- Oracle-safe SQL (no ::int, use CAST) ---
sql_data <- "
SELECT
  CAST(EXTRACT(YEAR FROM h.start_time) AS INTEGER) AS year,
  c.survey_name,
  h.hauljoin                     AS event_id,
  h.start_time                   AS date1,
  h.start_latitude               AS lat_start,
  h.start_longitude              AS lon_start,
  h.end_latitude                 AS lat_end,
  h.end_longitude                AS lon_end,
  h.bottom_depth                 AS depth_m,
  (h.distance_fished * (h.net_width / 1000)) AS effort,
  h.performance,
  h.stratum,
  h.gear_temperature             AS bottom_temp_c,
  h.region,
  ca.vessel,
  ca.species_code,
  ca.number_fish                 AS catch_numbers,
  (ca.weight / 1000)             AS catch_weight,     -- tonnes
  s.species_name                 AS scientific_name,
  s.common_name,
  h.abundance_haul
FROM racebase.catch ca
JOIN racebase.haul   h ON h.cruisejoin = ca.cruisejoin AND ca.hauljoin = h.hauljoin
JOIN racebase.cruise c ON h.cruisejoin = c.cruisejoin
JOIN racebase.species s ON ca.species_code = s.species_code
WHERE EXTRACT(YEAR FROM h.start_time) > 1980
  AND h.performance = 0
  AND h.region IN ('BS','GOA')
  AND h.end_longitude < -158
ORDER BY year, c.survey_name, h.start_time
"

#--- Read + lowercase column names immediately ---
d <- dbGetQuery(afsc, sql_data) %>%
  as.data.table() %>%
  rename_with(tolower)

#--- Filter down to your survey set ---
surveys <- unique(d$survey_name)[c(2,3,17,20,30,31,32,36,38,40:42,45,46,48,50,52,54,58:63,65:67,69:71,73,75:80,82:98)]
d <- d[survey_name %in% surveys]
d$month<-month(d$date1)
d<-d[month%in%c(5:10)]

#--- Split into cod vs. non-cod hauls efficiently ---
d_cod   <- d[species_code == 21720]
cod_ids <- unique(d_cod$event_id)
all_ids <- unique(d$event_id)
nocod_ids <- setdiff(all_ids, cod_ids)

# Keep one record per non-cod haul and add zeros
d_nocod <- unique(d[event_id %in% nocod_ids,
  .(year, survey_name, event_id, date1, vessel,
    lat_start, lon_start, lat_end, lon_end,
    depth_m, effort, performance, stratum,
    bottom_temp_c, region, abundance_haul)]
)
d_nocod[, `:=`(
  species_code   = 21720L,
  catch_numbers  = 0L,
  catch_weight   = 0,
  scientific_name = d_cod$scientific_name[1],
  common_name     = d_cod$common_name[1]
)]

# Combine
d <- rbindlist(list(d_cod, d_nocod), use.names = TRUE)

#--- Standardize survey_name values ---
d[, survey_name := fcase(
  region == "GOA", "Gulf of Alaska",
  region == "BS" & grepl("\\(Loss of Sea Ice\\)", survey_name), "northern Bering Sea",
  region == "BS" & year == 2018 & abundance_haul == "N", "northern Bering Sea",
  region == "BS" & year %in% c(1982,1991,2001,2005,2006) &
    lat_end > 60 & abundance_haul == "N", "northern Bering Sea",
  region == "BS" & survey_name != "northern Bering Sea", "eastern Bering Sea",
  default = survey_name
)]

d[(survey_name == "Gulf of Alaska" & year > 1987 & abundance_haul == "N") |
    (survey_name == "eastern Bering Sea" & abundance_haul == "N"),
  survey_name := "bad"]

d <- d[survey_name != "bad"]

#--- Add mid-point coordinates ---
d[, `:=`(
  lon_mid = (lon_start + lon_end) / 2,
  lat_mid = (lat_start + lat_end) / 2
)]

#--- Basic filters ---
d <- d[
  !is.na(lon_mid) & !is.na(lat_mid) &
  !is.na(bottom_temp_c) &
  year > 1981 & effort > 0
]

#--- CPUEs ---
d[, `:=`(
  cpuew = catch_weight / effort,     # t / km²
  cpuen = catch_numbers / effort,    # numbers / km²
  nation = "USA"
)]

# Refactor: Russian data + join + scaling
russian_data <- fread("RUSSIANALLCATCH_join3.csv") %>%
  rename_with(tolower)

russian_data[, survey_name := "western Bering Sea"]
russian_data[survey_def == 98,  survey_name := "eastern Bering Sea"]
russian_data[survey_def == 143, survey_name := "northern Bering Sea"]
russian_data[, nation := "RUSSIA"]

setnames(russian_data, c("lon_mid","lat_mid"), old=c("min_lon","mid_lat"), skip_absent=TRUE) # keep if already named
setnames(russian_data, "bottom_tem", "bottom_temp_c", skip_absent=TRUE)
setnames(russian_data, c("catch_numbers","catch_weight"), old=c("catch_numb","catch_weig"), skip_absent=TRUE)

# Ensure cpueW in t/km2
if ("cpueW" %in% names(russian_data)) russian_data[, cpueW := cpueW/1000]

# Normalize date once
russian_data[, date1 := as.IDate(date1, format = "%m/%d/%Y")]
d[, date1 := as.IDate(date1)]  # from DB already date/time; IDATE strips time cheaply

# Keep only common cols and bind (no copies, same types)
common_cols <- intersect(names(d), names(russian_data))
d3 <- rbindlist(list(d[, ..common_cols], russian_data[, ..common_cols]), use.names = TRUE)

# Add projected coords once
d3 <- sdmTMB::add_utm_columns(
  d3,
  ll_names = c("lon_mid", "lat_mid"),
  utm_crs  = 32603
)


setDT(d3)
d3[, `:=`(
  year = as.integer(year),
  fyear = as.factor(year),
  month = month(date1),
  doy = as.integer(strftime(date1, "%j")),
  survey_name2 = fifelse(survey_name %in% c("eastern Bering Sea","northern Bering Sea"),
                         "northern and eastern Bering Sea", survey_name),
  nation = factor(nation),
  vessel = factor(vessel),
  nation_vessel = factor(paste(nation, vessel, sep = "_"))
)]
d3 <- d3[month %between% c(5L, 11L)]

# avewt (avoid divide-by-zero)
d3[, avewt := fifelse(catch_numbers > 0, catch_weight / catch_numbers, NA_real_)]
d3[nation == "USA" & catch_numbers > 0, avewt := (catch_weight * 1000) / catch_numbers]

# Cold pool
cold <- as.data.table(coldpool::cold_pool_index)%>%
  rename_with(tolower)  

#setnames(cold, names(cold)[1], "year")
d3 <- cold[d3, on="year"]  # left join: adds AREA_LTE2_KM2, MEAN_GEAR_TEMPERATURE, etc.

d3$survey_name2<-as.factor(d3$survey_name2)

# Consistent scaling (compute on model data once)
scale_cols <- function(x) list(mu=mean(x, na.rm=TRUE), sd=sd(x, na.rm=TRUE))
sc_year   <- scale_cols(d3$year)
sc_depth  <- scale_cols(d3$depth_m)
sc_temp   <- scale_cols(d3[bottom_temp_c > -999]$bottom_temp_c)
sc_cold   <- scale_cols(d3$area_lte2_km2)

d3[, `:=`(
  year_scaled  = (year - sc_year$mu)/sc_year$sd,
  depth_scaled = (depth_m - sc_depth$mu)/sc_depth$sd,
  temp_scaled  = fifelse(bottom_temp_c == -999,
                         NA_real_, (bottom_temp_c - sc_temp$mu)/sc_temp$sd),
  cold_scaled  = (area_lte2_km2 - sc_cold$mu)/sc_cold$sd
)]

##Refactor: MOM6 grid once + reuse scales
# Read grid (sf → one transform)
grid_40K <- sf::st_read(file.path(getwd(), "shapes", "40km_intersect2.shp"))
grid_40K <- sf::st_transform(grid_40K, 32603)

# MOM6 (fast group means with data.table)
mom6 <- fread(file.path(getwd(), "shapes","MOM6_40KMgrid2.csv"))%>%
  rename_with(tolower)

MOM6 <- as.data.table(mom6)[, .(
  depth_m      = mean(depth, na.rm=TRUE),
  bottom_temp  = mean(tob,   na.rm=TRUE)
), by = .(day, fid_2, survey_def, poly_area, centroid_x, centroid_y)]

MOM6[, day := as.IDate(day, format="%m/%d/%Y")]
MOM6_sf <- sf::st_as_sf(MOM6, coords=c("centroid_x","centroid_y"), crs=sf::st_crs(32603))
ll <- sf::st_transform(MOM6_sf, 4326)
coords <- sf::st_coordinates(ll)
MOM6[, `:=`(longitude = coords[,1], latitude = coords[,2])]
MOM6 <- add_utm_columns(MOM6, ll_names=c("longitude","latitude"), utm_crs=32603)
MOM6[, year := year(day)]
MOM6[, survey_name := fcase(
  survey_def == 143, "northern Bering Sea",
  survey_def == 999, "western Bering Sea",
  survey_def == 47,  "Gulf of Alaska",
  default = "eastern Bering Sea"
)]
MOM6[, nation := fifelse(survey_name == "western Bering Sea", "RUSSIA", "USA")]

# Single dummy vessel per nation (use existing levels to match model matrices)
# Pick most common vessel by nation from d3:
v_us  <- d3[nation=="USA", .N, by=vessel][order(-N)][1, vessel]
v_ru  <- d3[nation=="RUSSIA", .N, by=vessel][order(-N)][1, vessel]
MOM6[, vessel := fifelse(nation=="USA", as.character(v_us), as.character(v_ru))]
MOM6[, `:=`(
  survey_name2 = fifelse(survey_name %in% c("eastern Bering Sea","northern Bering Sea"),
                         "northern and eastern Bering Sea", survey_name),
  year_scaled  = (year - sc_year$mu)/sc_year$sd,
  depth_scaled = (depth_m - sc_depth$mu)/sc_depth$sd,
  temp_scaled  = (bottom_temp - sc_temp$mu)/sc_temp$sd
)]
MOM6 <- cold[MOM6, on="year"]
MOM6[, cold_scaled := (area_lte2_km2 - sc_cold$mu)/sc_cold$sd]

# Factor alignment
MOM6[, `:=`(
  vessel        = factor(vessel, levels=levels(d3$vessel)),
  nation        = factor(nation, levels=levels(d3$nation)),
  survey_name2  = factor(survey_name2, levels=levels(d3$survey_name2)),
  nation_vessel = factor(paste(nation, vessel, sep="_"),
                         levels=levels(d3$nation_vessel))
)]

##Refactor: mesh + models

source("add_barrier_mesh2.r")
source("mesh2fem.barrier2.r")

d3<-d3[year%in%c(1981:2019,2021:2024)]


mesh_all <- make_mesh(d3, xy_cols=c("X","Y"), type="cutoff_search", n_knots=300)
bm_all   <- add_barrier_mesh2(spde_obj=mesh_all,
                              barrier_sf=sf::st_transform(sf::st_read("shapes/Russian_US_MESH.shp"), 32603),
                              range_fraction=0.2, proj_scaling=1000, plot=FALSE)

d_US <- d3[nation == "USA"]
d_US$vessel<-factor(d_US$vessel)
d_US$survey_name2<-factor(d_US$survey_name2)


mesh_us <- make_mesh(d_US, xy_cols=c("X","Y"), type="cutoff_search", n_knots=300)
bm_us   <- add_barrier_mesh2(spde_obj=mesh_us,
                             barrier_sf=sf::st_transform(sf::st_read("shapes/Russian_US_MESH3.shp"), 32603),
                             range_fraction=0.2, proj_scaling=1000, plot=FALSE)



ctrl <- sdmTMBcontrol()

fit_all <- sdmTMB(
  cpuew ~ 0 + nation + year_scaled + s(depth_scaled, by=survey_name2),
  spatial_varying = ~ cold_scaled + survey_name2,
  data = d3, mesh = bm_all, family = tweedie(),
  time = "year", spatial = "on", spatiotemporal = "ar1",
  extra_time = 2020L, anisotropy = FALSE, silent = TRUE, control = ctrl
)

fit_us <- sdmTMB(
  cpuew ~ 0 + year_scaled + s(depth_scaled),
  spatial_varying = ~ cold_scaled,
  data = d_US, mesh = bm_us, family = tweedie(),
  time = "year", spatial = "on", spatiotemporal = "ar1",
  extra_time = 2020L, anisotropy = FALSE, silent = TRUE, control = ctrl
)

##Refactor: predictions + indices (single pass)

yrs <- c(1982:2019, 2021:2024)
MOM6_all <- MOM6[year %in% yrs]
MOM6_us  <- MOM6_all[nation == "USA" & survey_name != "western Bering Sea"]

# Define newdata sets once
nd_all <- list(
  `ALL`     = MOM6_all,
  `ALL-WBS` = MOM6_all[survey_name != "western Bering Sea"],
  `EBS`     = MOM6_all[survey_name == "eastern Bering Sea"],
  `GOA`     = MOM6_all[survey_name == "Gulf of Alaska"],
  `WBS`     = MOM6_all[survey_name == "western Bering Sea"],
  `EBS+NBS` = MOM6_all[survey_name %chin% c("eastern Bering Sea","northern Bering Sea")]
)

nd_us <- list(
  `ALL-WBS` = MOM6_us,
  `EBS`     = MOM6_us[survey_name == "eastern Bering Sea"],
  `GOA`     = MOM6_us[survey_name == "Gulf of Alaska"],
  `NBS`     = MOM6_us[survey_name == "northern Bering Sea"],
  `EBS+NBS` = MOM6_us[survey_name %chin% c("eastern Bering Sea","northern Bering Sea")]
)

# Helper: predict + index
mk_index <- function(fit, nd, model_tag) {
  p <- predict(fit, newdata = nd, return_tmb_object = TRUE)
  ix <- get_index(p, area = p$data$poly_area, bias_correct = TRUE)
  setDT(ix)[, `:=`(REGION = deparse(substitute(nd)), MODEL = model_tag)]
  ix
}

# Vectorized over named lists
idx_all <- rbindlist(lapply(names(nd_all), function(k) {
  p <- predict(fit_all, newdata = nd_all[[k]], return_tmb_object = TRUE)
  ix <- get_index(p, area = p$data$poly_area, bias_correct = TRUE)
  setDT(ix)[, `:=`(REGION = k, MODEL = "With Russian data")]
}), fill = TRUE)

idx_us <- rbindlist(lapply(names(nd_us), function(k) {
  p <- predict(fit_us, newdata = nd_us[[k]], return_tmb_object = TRUE)
  ix <- get_index(p, area = p$data$poly_area, bias_correct = TRUE)
  setDT(ix)[, `:=`(REGION = k, MODEL = "Without Russian data")]
}), fill = TRUE)

index_RV_NRV <- rbindlist(list(idx_all, idx_us), use.names = TRUE, fill = TRUE)

##Refactor: maps & indices plotting (concise)
# ---- Packages ----
library(sf)
library(viridisLite)
library(scales)

# ---- 1) Helpers ----

# Build a prediction surface (est, lwr, upr) for a fitted sdmTMB model + newdata
pred_surface <- function(fit, newdata) {
  # sdmTMB predict; keep TMB object so we have $data with grid IDs
  p <- predict(fit, newdata = newdata, return_tmb_object = TRUE)
  # Extract predictions on link scale; sdmTMB returns data.frame
  out <- as.data.table(p$est)  # columns: est, se, etc.
  dat <- as.data.table(p$data) # the newdata echoed back (incl. FID_2, SURVEY_DEF, POLY_AREA, year)
  stopifnot(nrow(out) == nrow(dat))
  # add confidence intervals on response (Tweedie with log link → exp())
  out[, `:=`(
    est_resp = exp(est),
    lwr_resp = exp(est - 1.96 * se),
    upr_resp = exp(est + 1.96 * se)
  )]
  # Carry keys over for merge with grid
  keep <- c("fid_2", "survey_def", "poly_area", "year", "survey_name", "nation")
  keep <- keep[keep %in% names(dat)]
  cbind(dat[, ..keep], out[, .(est_resp, lwr_resp, upr_resp)])
}

# Make a faceted map for selected years (fills are on response scale)
map_predictions <- function(surf_dt, grid_sf, years, title = "Predicted CPUEW (t/km²)") {
  # Keep only the requested years
  surf_dt <- surf_dt[year %in% years]
  # Merge to polygons (assumes grid_sf has FID_2, SURVEY_DEF, POLY_AREA)
  # Convert grid to data.frame to avoid sf/data.table hiccups on merge
  grid_df <- as.data.frame(grid_sf)
  stopifnot(all(c("fid_2","survey_def","poly_area") %in% names(grid_df)))
  # Minimal columns from grid to speed merge; keep geometry
  grid_min <- grid_df[, intersect(names(grid_df), c("fid_2","survey_def","poly_area"))]
  grid_min <- cbind(grid_min, geometry = st_geometry(grid_sf)) # stash geometry column
  grid_min <- st_as_sf(grid_min, sf_column_name = "geometry", crs = st_crs(grid_sf))
  # Do a left join by IDs
  surf_sf <- grid_min |>
    merge(as.data.frame(surf_dt), by = c("fid_2","survey_def","poly_area"), all.x = TRUE) |>
    st_as_sf()

  # Plot
  ggplot(surf_sf) +
    geom_sf(aes(fill = est_resp), color = NA) +
    facet_wrap(~ year) +
    scale_fill_viridis_c(trans = "sqrt", labels = label_number(accuracy = 0.01)) +
    labs(fill = "t/km²", title = title) +
    theme_bw(base_size = 12) +
    theme(panel.grid.major = element_line(linewidth = 0.2, colour = "grey90"))
}

# Index time series with ribbons by MODEL (expects columns: year, est, lwr, upr, REGION, MODEL)
plot_indices <- function(idx_dt, region_filter = "ALL-WBS", title = "Biomass index (±95% CI)") {
  df <- idx_dt[REGION %in% region_filter]
  ggplot(df, aes(x = year, y = est, color = MODEL, fill = MODEL)) +
    geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.12, colour = NA) +
    geom_line(linewidth = 0.9) +
    scale_y_continuous(labels = label_number(scale_cut = cut_short_scale())) +
    labs(x = NULL, y = "Index (biomass units)", title = title) +
    theme_bw(base_size = 12) +
    theme(legend.position = "top")
}

# ---- 2) Build prediction surfaces ----

# You already created these earlier:
#   - fit_all (with Russian data)
#   - fit_us  (USA-only)
#   - MOM6_all (newdata across regions/years)
#   - MOM6_us  (subset for USA predictions)

surf_all <- pred_surface(fit_all, MOM6_all)
surf_us  <- pred_surface(fit_us,  MOM6_us)

# ---- 3) Maps for a couple of “key” years ----
# Pick years that highlight contrast; adjust as needed:
years_to_show <- c(2010, 2014, 2019, 2024)

p_map_all <- map_predictions(
  surf_dt = surf_all[survey_name != "western Bering Sea"],  # drop WBS if you want NEBS focus
  grid_sf = grid_40K,
  years   = years_to_show,
  title   = "Predicted CPUEW (t/km²): With Russian data"
)

p_map_us <- map_predictions(
  surf_dt = surf_us,
  grid_sf = grid_40K,
  years   = years_to_show,
  title   = "Predicted CPUEW (t/km²): USA-only"
)

# Print to device (RStudio) or save
print(p_map_all)
print(p_map_us)

# Optional: save to files
ggsave("map_pred_with_russia.png", p_map_all, width = 10, height = 7, dpi = 300)
ggsave("map_pred_usa_only.png",   p_map_us,  width = 10, height = 7, dpi = 300)

# ---- 4) Index plots ----
# index_RV_NRV was built earlier (rbind of idx_all + idx_us)
p_idx_allwbs <- plot_indices(index_RV_NRV, region_filter = "ALL-WBS",
                             title = "Index: ALL-WBS region (With-Russia vs USA-only)")
p_idx_ebs    <- plot_indices(index_RV_NRV, region_filter = "EBS",
                             title = "Index: EBS region")
p_idx_goa    <- plot_indices(index_RV_NRV, region_filter = "GOA",
                             title = "Index: GOA region")

print(p_idx_allwbs)
print(p_idx_ebs)
print(p_idx_goa)

ggsave("index_ALL-WBS.png", p_idx_allwbs, width = 9, height = 5, dpi = 300)
ggsave("index_EBS.png",     p_idx_ebs,    width = 9, height = 5, dpi = 300)
ggsave("index_GOA.png",     p_idx_goa,    width = 9, height = 5, dpi = 300)

##Centroid analysis

# ---- 1) Helper: biomass-weighted centroids per year ----
# surf_dt must have: FID_2, SURVEY_DEF, POLY_AREA, year, est_resp (t/km^2), survey_name
# grid_sf must be sf polygons with same keys and geometry; CRS should be EPSG:32603 (UTM 3N).
centroids_from_surface <- function(
  surf_dt, grid_sf,
  include_surveys = NULL,   # character vector of survey_name to keep; NULL = keep all
  drop_wbs = FALSE          # convenience: TRUE = drop "western Bering Sea"
) {
  dt <- as.data.table(surf_dt)
  if (!is.null(include_surveys)) dt <- dt[survey_name %in% include_surveys]
  if (isTRUE(drop_wbs))         dt <- dt[survey_name != "western Bering Sea"]

  stopifnot(all(c("fid_2","survey_def","poly_area","year","est_resp") %in% names(dt)))

  # Ensure grid is in UTM 32603 for stable XY
  if (is.na(sf::st_crs(grid_sf))) stop("grid_sf is missing a CRS.")
  if (sf::st_crs(grid_sf)$epsg != 32603) grid_sf <- sf::st_transform(grid_sf, 32603)

  # Join predictions to polygons
  join_keys <- c("fid_2","survey_def","poly_area")
  surf_sf <- merge(
    grid_sf[, join_keys],           # keep only IDs + geometry
    as.data.frame(dt),              # plain data.frame for base merge
    by = join_keys, all.y = TRUE
  )
  surf_sf <- sf::st_as_sf(surf_sf)  # back to sf

  # Robust interior points as coordinates
  pts <- sf::st_point_on_surface(surf_sf)
  xy  <- sf::st_coordinates(pts)
  surf_sf$X <- xy[,1]
  surf_sf$Y <- xy[,2]

  # Biomass per cell = density (t/km^2) * area (km^2)
  surf_sf$biomass_t <- surf_sf$est_resp * surf_sf$poly_area

  # Summaries per year
  dts <- as.data.table(surf_sf)
  cent <- dts[is.finite(biomass_t) & biomass_t >= 0,
              .(X = weighted.mean(X, biomass_t, na.rm=TRUE),
                Y = weighted.mean(Y, biomass_t, na.rm=TRUE),
                biomass_total_t = sum(biomass_t, na.rm=TRUE),
                n_cells = .N),
              by = .(year)]

  # Convert to lon/lat for reporting
  cent_sf <- sf::st_as_sf(cent, coords = c("X","Y"), crs = 32603, remove = FALSE)
  cent_ll <- sf::st_transform(cent_sf, 4326)
  ll <- sf::st_coordinates(cent_ll)
  cent[, `:=`(lon = ll[,1], lat = ll[,2])]
  data.table::setorder(cent, year)

  # Step and cumulative displacement (in km) in UTM space
  cent[, `:=`(
    step_km = sqrt((X - data.table::shift(X))^2 + (Y - data.table::shift(Y))^2) / 1000,
    cum_km  = cumsum(replace(step_km, is.na(step_km), 0))
  )]

  cent[]
}

# ---- 2) Compute centroids for the two models ----
# Typical “NEBS focus”: drop WBS from the With-Russia surface for apples-to-apples
cent_allwbs <- centroids_from_surface(surf_all, grid_40K, drop_wbs = TRUE)
cent_usonly <- centroids_from_surface(surf_us,  grid_40K)

# You can also get region-specific tracks, e.g. EBS only:
cent_ebs_all <- centroids_from_surface(surf_all, grid_40K, include_surveys = "eastern Bering Sea")
cent_ebs_us  <- centroids_from_surface(surf_us,  grid_40K, include_surveys = "eastern Bering Sea")

# ---- 3) Plot: centroid tracks on map ----
plot_centroid_tracks <- function(grid_sf, cent_list, labels, title = "Biomass-weighted centroid tracks") {
  stopifnot(length(cent_list) == length(labels))
  # Light basemap: outlines only to keep files small
  base <- ggplot() +
    geom_sf(data = grid_sf, fill = NA, color = "grey80", linewidth = 0.2) +
    coord_sf() +
    theme_bw(base_size = 12) +
    labs(title = title, x = NULL, y = NULL)

  # Add each track
  for (i in seq_along(cent_list)) {
    ci <- cent_list[[i]]
    base <- base +
      geom_path(data = ci, aes(X, Y), linewidth = 0.8) +
      geom_point(data = ci, aes(X, Y), size = 1.8) +
      ggrepel::geom_text_repel(
        data = ci[year %in% range(ci$year)],
        aes(X, Y, label = year),
        size = 3, min.segment.length = 0, box.padding = 0.2, max.overlaps = 50
      )
  }
  # Legend proxy (colors optional; here we keep default to avoid style settings)
  # If you want distinct colors, add a MODEL column before binding and map color=MODEL.
  base
}

# Tracks for ALL-WBS region
p_tracks_allwbs <- plot_centroid_tracks(
  grid_sf = grid_40K,
  cent_list = list(
    data.table(cent_allwbs, MODEL = "With Russian data"),
    data.table(cent_usonly, MODEL = "USA only")
  ),
  labels = c("With Russian data", "USA only"),
  title = "Centroid tracks (ALL-WBS)"
)
print(p_tracks_allwbs)

# ---- 4) Plot: centroid latitude through time (compare models) ----
cent_compare <- rbindlist(list(
  data.table(cent_allwbs, MODEL = "With Russian data", REGION = "ALL-WBS"),
  data.table(cent_usonly, MODEL = "USA only",        REGION = "ALL-WBS")
), use.names = TRUE)

p_lat_ts <- ggplot(cent_compare, aes(year, lat, color = MODEL)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = label_number(accuracy = 0.1)) +
  labs(x = NULL, y = "Centroid latitude (°N)", title = "Centroid latitude over time (ALL-WBS)") +
  theme_bw(base_size = 12) + theme(legend.position = "top")
print(p_lat_ts)

# (Optional) Distance diagnostics
p_dist <- ggplot(cent_compare, aes(year, step_km, color = MODEL)) +
  geom_line(linewidth = 0.9) + geom_point(size = 1.5) +
  labs(x = NULL, y = "Year-to-year shift (km)", title = "Annual centroid displacement (ALL-WBS)") +
  theme_bw(base_size = 12) + theme(legend.position = "top")
print(p_dist)
