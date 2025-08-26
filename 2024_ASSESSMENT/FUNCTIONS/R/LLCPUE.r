
get_LLCPUE<-function(species=202,target='C'){

 libs <- c("tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","vcdExtra","misty")

  if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
    install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
    lapply(libs, library, character.only = TRUE)

    source('R/utils.r')

  afsc=connect("afsc")
  akfin=connect("akfin")


  CPUE = readLines('sql/LL_CPUE.sql')
  CPUE = sql_filter(sql_precode = "IN", x =target , sql_code = CPUE, flag = '-- insert target')
  CPUE = sql_filter(sql_precode = "IN", x =species , sql_code = CPUE, flag = '-- insert species')
  CPUE = sql_run(akfin, CPUE) %>% data.table() %>%
      dplyr::rename_all(toupper)




  CPUE$RETRIEVAL_LATITUDE_DD<-as.numeric(CPUE$RETRIEVAL_LATITUDE_DD)
  CPUE$RETRIEVAL_LONGITUDE_DD<-as.numeric(CPUE$RETRIEVAL_LONGITUDE_DD)
  CPUE$TOTAL_HOOKS_POTS <- as.numeric(CPUE$TOTAL_HOOKS_POTS)
  CPUE$EXTRAPOLATED_WEIGHT <- as.numeric(CPUE$EXTRAPOLATED_WEIGHT)
  CPUE$EXTRAPOLATED_NUMBER <- as.numeric(CPUE$EXTRAPOLATED_NUMBER)

  CPUE$DATE1<-format(as.Date(CPUE$HAUL_DATE),'%m/%d/%Y')
  CPUE$MONTH=month(CPUE$HAUL_DATE)

  CPUE_FALL<-CPUE[MONTH%in%c(9,10)]
  CPUE_SPRING<-CPUE[MONTH%in%c(1,2)]
  CPUE_ALL<-list(CPUE_SPRING,CPUE_FALL)
  CPUE_ALL
}




#  write.csv(CPUE_ALL[[2]],"LLCPUE_FALL23.csv")
#  write.csv(CPUE_ALL[[1]],"LLCPUE_SPRING23.csv")

