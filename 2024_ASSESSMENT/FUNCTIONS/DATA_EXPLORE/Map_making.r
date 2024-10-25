
libs <- c("akgfmaps","tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)



afsc_user  =  keyring::key_list("afsc")$username  ## enter afsc username
afsc_pwd   = keyring::key_get("afsc", keyring::key_list("afsc")$username)   ## enter afsc password
akfin_user = keyring::key_list("akfin")$username ## enter AKFIN username
akfin_pwd  =  keyring::key_get("akfin", keyring::key_list("akfin")$username)   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)


query1<-"SELECT
    gap_products.akfin_cpue.species_code,
    gap_products.taxon_groups.species_name,
    gap_products.taxon_groups.common_name,
    gap_products.akfin_cruise.year,
    gap_products.akfin_haul.stratum          AS station_id,
    gap_products.akfin_haul.station,
    gap_products.akfin_haul.latitude_dd_end  AS latitude,
    gap_products.akfin_haul.longitude_dd_end AS longitude,
    gap_products.akfin_cpue.cpue_kgkm2/100       AS cpue_kgha,
    gap_products.akfin_cpue.cpue_nokm2/100       AS cpue_noha
FROM
         gap_products.akfin_cpue
    INNER JOIN gap_products.akfin_haul ON gap_products.akfin_cpue.hauljoin = gap_products.akfin_haul.hauljoin
    INNER JOIN gap_products.akfin_cruise ON gap_products.akfin_haul.cruisejoin = gap_products.akfin_cruise.cruisejoin
    INNER JOIN gap_products.taxon_groups ON gap_products.akfin_cpue.species_code = gap_products.taxon_groups.species_code
WHERE
        gap_products.akfin_cpue.species_code = 21720
    AND gap_products.akfin_cruise.survey_definition_id IN ( 98, 143 )
ORDER BY
    gap_products.akfin_cruise.year DESC"



 
  data=sql_run(afsc, query1) %>% 
         dplyr::rename_all(toupper)




#data<-read.csv("EBSCOD_SURVEY.csv")
#nbsdata<-read.csv("NBSCOD_SURVEY.csv")

Years=c(2010,2017:2019,2021:2023)

pdf("NBS_COD.pdf",width=8, height=8)

for(i in 1:length(Years)){
	  cod<-data.table(subset(data,YEAR==Years[i]))
    cod<-cod[!is.na(LATITUDE)]

	opt1 <- make_idw_map(x = cod, # Pass data as a data frame
             region = "bs.all", # Predefined bs.all area
             set.breaks = c(0,15,50,150,300,500), # Gets Jenks breaks from classint::classIntervals()
             in.crs = "+proj=longlat", # Set input coordinate reference system
             out.crs = "EPSG:3338", # Set output coordinate reference system
             grid.cell = c(20000, 20000), # 20x20km grid
             key.title = paste0("Pacific cod ",Years[i]), # Include Pcod sole in the legend title
             key.title.units = "CPUE (kg/ha)")
	print(opt1$plot)
 }
dev.off()


Years=c(1982:2019,2021:2023)

pdf("EBS_COD2.pdf",width=8, height=8)

for(i in 1:length(Years)){
    cod<-data.table(subset(data,YEAR==Years[i]))
    cod<-cod[!is.na(LATITUDE)]
    

    opt1 <- make_idw_map(x = cod, # Pass data as a data frame
             region = "bs.south", # Predefined bs.all area
             set.breaks = c(0,15,50,150,300,500), # Gets Jenks breaks from classint::classIntervals()
             in.crs = "+proj=longlat", # Set input coordinate reference system
             out.crs = "EPSG:3338", # Set output coordinate reference system
             grid.cell = c(20000, 20000), # 20x20km grid
             key.title = paste0("Pacific cod ",Years[i])) # Include Pcod sole in the legend title
    print(opt1$plot)
 }
dev.off()

