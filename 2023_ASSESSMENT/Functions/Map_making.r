
libs <- c("akgfmaps","tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)


afsc_user  = "****"   ## enter afsc username
afsc_pwd   = "****"    ## enter afsc password



afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)



query1<- 
"SELECT
    haehnr.cpue_ebs_plusnw.species_code,
    haehnr.cpue_ebs_plusnw.species_name,
    haehnr.cpue_ebs_plusnw.common_name,
    haehnr.cpue_ebs_plusnw.year,
    haehnr.cpue_ebs_plusnw.stratum,
    haehnr.cpue_ebs_plusnw.stationid,
    haehnr.cpue_ebs_plusnw.latitude,
    haehnr.cpue_ebs_plusnw.longitude,
    haehnr.cpue_ebs_plusnw.cpue_kgha,
    haehnr.cpue_ebs_plusnw.cpue_noha
FROM
    haehnr.cpue_ebs_plusnw
WHERE
    haehnr.cpue_ebs_plusnw.species_code = 21720
    AND haehnr.cpue_ebs_plusnw.year > 2009
ORDER BY
    haehnr.cpue_ebs_plusnw.year DESC"

query2<- 
"SELECT
    haehnr.cpue_nbs.species_code,
    haehnr.cpue_nbs.species_name,
    haehnr.cpue_nbs.common_name,
    haehnr.cpue_nbs.year,
    haehnr.cpue_nbs.stratum,
    haehnr.cpue_nbs.stationid,
    haehnr.cpue_nbs.latitude,
    haehnr.cpue_nbs.longitude,
    haehnr.cpue_nbs.cpue_kgha,
    haehnr.cpue_nbs.cpue_noha
FROM
    haehnr.cpue_nbs
WHERE
    haehnr.cpue_nbs.species_code = 21720
    AND haehnr.cpue_nbs.year > 2009
ORDER BY
    haehnr.cpue_nbs.year DESC"


 
  EBS=sql_run(afsc, query1) %>% 
         dplyr::rename_all(toupper)


  NBS=sql_run(afsc, query2) %>% 
         dplyr::rename_all(toupper)


#data<-read.csv("EBSCOD_SURVEY.csv")
#nbsdata<-read.csv("NBSCOD_SURVEY.csv")
data<-rbind(EBS,NBS)

Years=c(2010,2017,2019,2021,2022)

pdf("NBS_COD.pdf",width=8, height=8)

for(i in 1:length(Years)){
	cod<-subset(data,YEAR==Years[i])

	opt1 <- make_idw_map(x = cod, # Pass data as a data frame
             region = "bs.all", # Predefined bs.all area
             set.breaks = c(0,15,50,150,300,500), # Gets Jenks breaks from classint::classIntervals()
             in.crs = "+proj=longlat", # Set input coordinate reference system
             out.crs = "EPSG:3338", # Set output coordinate reference system
             grid.cell = c(20000, 20000), # 20x20km grid
             key.title = paste0("Pacific cod ",Years[i])) # Include Pcod sole in the legend title
	print(opt1$plot)
 }
dev.off()


Years=c(2011:2016,2018)

pdf("EBS_COD.pdf",width=8, height=8)

for(i in 1:length(Years)){
    cod<-subset(data,YEAR==Years[i])

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

