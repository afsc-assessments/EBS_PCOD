
## Function to pull and process length composition data for the domestic fisheries. 
## This produces a single fishery model as per the 2021 production model and a split by gear (HAL, POT, TRW)
## This function proportions the lengths to the catch from the haul/delivery level extrapolated 
## number from the species composition data and to the total catch for the area, gear,
## and month by the blend catch information. There are a number of sample size measures attempted, 
## number of samples, number of hauls, and a facile bootstrap approach from fishmethods library. 
##
##  You will need to connect to the two databases before using this function.
##  
##  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
##                      UID = 'sbarb', PWD = '')
##  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
##                      UID = 'sbarbeaux', PWD = '') 
##
##  For this function to work you need to include the utility funcitons in the utils.r file and have the sql code in /sql folder in your working directory.
##  
##  species is the observer species code, species_catch is the species catch accounting name, for_species_catch is the foriegn species identifier, 
##  sp_area is the area (BS, GOA, AI), ly is the last year, SEX is whether to include sex (True/False), PORT is whether to include port data (TRUE/FALSE)
## 
##  Example: LENGTH_BY_CATCH<-function(species= 202 ,species_catch= 'PCOD', for_species_catch='PACIFIC COD',sp_area='AI' ,ly=2022, SEX=FALSE, PORT=FALSE)
##  Example: ysol=LENGTH_BY_CATCH<-function(species= 140 ,species_catch= 'YSOL', for_species_catch='YELLOWFIN SOLE',sp_area='BS' ,ly=2022, SEX=TRUE, PORT=FALSE)


LENGTH_BY_CATCH_QUARTER_short<-function(species=fsh_sp_str ,species_catch=fsh_sp_label, for_species_catch=for_sp_label,sp_area=fsh_sp_area ,ly=final_year, SEX=TRUE, PORT=TRUE, minN=100 ){

  require(data.table)
  require(reshape2)
  require(rgdal)
  require(dplyr)
  require(lubridate)
  require(swo)
  require(vcdExtra)
  require(misty)
## defining region for later use

  if(sp_area=='AI')
    {
        region<-"BETWEEN 539 and 544"
    }
  if(sp_area=='GOA')
    {
        region<-"BETWEEN 600 and 699"
    }
  if(sp_area=='BS')
    {
        region<-"BETWEEN 500 and 539"
    }


## pull domestic length and species composition data for haul data  

  lfreq = readLines('sql/dom_length.sql')
  lfreq = sql_filter(sql_precode = "IN", x = species, sql_code = lfreq, flag = '-- insert species')
  lfreq = sql_add(x = region, sql_code = lfreq, flag = '-- insert region')
 
  Dspcomp=sql_run(afsc, lfreq) %>% 
    dplyr::rename_all(toupper) %>% subset(EXTRAPOLATED_WEIGHT > 0 & NUMB > 0)

  Dspcomp <- subset(Dspcomp,EXTRAPOLATED_WEIGHT > 0)
  Dspcomp<- subset(Dspcomp,NUMB>0)   
  Dspcomp$QUARTER<-trunc((as.numeric(Dspcomp$MONTH)/3)-0.3)+1

## pull foreign length and species composition data for haul data

  Flfreq = readLines('sql/for_length.sql')
  Flfreq = sql_filter(sql_precode = "IN", x = species, sql_code = Flfreq, flag = '-- insert species')
  Flfreq = sql_add(x = region, sql_code = Flfreq, flag = '-- insert region')

  Fspcomp=sql_run(afsc, Flfreq) %>% 
   dplyr::rename_all(toupper)
  Fspcomp$MONTH<-as.numeric(Fspcomp$MONTH)
  Fspcomp$QUARTER<-trunc((Fspcomp$MONTH/3)-0.3)+1

  Tspcomp<-data.table(rbind(Fspcomp,Dspcomp))
  Tspcomp$WED<-WED(Tspcomp$HDAY)
  Tspcomp$MONTH_WED<-month(Tspcomp$WED)
  Tspcomp$MONTH<-as.numeric(Tspcomp$MONTH)

  Tspcomp<-Tspcomp[EXTRAPOLATED_WEIGHT>0]
  Tspcomp<-Tspcomp[NUMB>0]   

  Tspcomp[is.na(VES_AKR_ADFG)]$VES_AKR_ADFG<- Tspcomp[is.na(VES_AKR_ADFG)]$PERMIT
  Tspcomp[is.na(VES_AKR_ADFG)]$VES_AKR_ADFG<- as.numeric(as.factor(Tspcomp[is.na(VES_AKR_ADFG)]$PERMIT))
  Tspcomp[is.na(PERMIT)]$PERMIT<- Tspcomp[is.na(PERMIT)]$VES_AKR_ADFG

  Tspcomp$AREA2<-trunc(Tspcomp$AREA/10)*10
  Tspcomp[AREA2==500]$AREA2<-510

  if(sp_area=='BS'){Tspcomp$AREA2<-Tspcomp$AREA2} else {Tspcomp$AREA2<-Tspcomp$AREA}
        
  OBS_DATA<-Tspcomp[,c("SPECIES","YEAR","GEAR","AREA2","AREA","MONTH","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","SEX","LENGTH","SUM_FREQUENCY","EXTRAPOLATED_WEIGHT","NUMB","SOURCE")]

## Calculate average weights to calculate number of fish in landings data, which are only in weight

  YAGM_AVWT=data.table(Tspcomp)[,list(YAGM_AVE_WT=sum(EXTRAPOLATED_WEIGHT)/sum(NUMB)),by=c('YEAR','AREA2','MONTH','GEAR')]
  YAGM_AVWT$YEAR<-as.numeric(YAGM_AVWT$YEAR)
  YAM_AVWT=data.table(Tspcomp)[,list(YAM_AVE_WT=sum(EXTRAPOLATED_WEIGHT)/sum(NUMB)),by=c('YEAR','AREA2','MONTH')]
  YAM_AVWT$YEAR<-as.numeric(YAM_AVWT$YEAR)
  YGM_AVWT=data.table(Tspcomp)[,list(YGM_AVE_WT=sum(EXTRAPOLATED_WEIGHT)/sum(NUMB)),by=c('YEAR','GEAR','MONTH')]
  YGM_AVWT$YEAR<-as.numeric(YGM_AVWT$YEAR)
  YGQ_AVWT=data.table(Tspcomp)[,list(YGQ_AVE_WT=sum(EXTRAPOLATED_WEIGHT)/sum(NUMB)),by=c('YEAR','GEAR','QUARTER')]
  YGQ_AVWT$YEAR<-as.numeric(YGQ_AVWT$YEAR)
  YAQ_AVWT=data.table(Tspcomp)[,list(YAQ_AVE_WT=sum(EXTRAPOLATED_WEIGHT)/sum(NUMB)),by=c('YEAR','AREA2','QUARTER')]
  YAQ_AVWT$YEAR<-as.numeric(YAQ_AVWT$YEAR)
  YG_AVWT=data.table(Tspcomp)[,list(YG_AVE_WT=sum(EXTRAPOLATED_WEIGHT)/sum(NUMB)),by=c('YEAR','GEAR')]
  YG_AVWT$YEAR<-as.numeric(YG_AVWT$YEAR)

  YAGM_AVWT$MONTH<-as.numeric(YAGM_AVWT$MONTH)
  YGM_AVWT$MONTH<-as.numeric(YGM_AVWT$MONTH)
  YGQ_AVWT$QUARTER<-as.numeric(YGQ_AVWT$QUARTER)
  YAM_AVWT$MONTH<-as.numeric(YAM_AVWT$MONTH)
  YAQ_AVWT$QUARTER<-as.numeric(YAQ_AVWT$QUARTER)

## the port data is very complex and needed quite a bit of finessing to make work, this needs review. There are four time periods that need to 
## conducted differently due to what data were available for those time periods. 1990-1998 there was port species composition data so observer length data
## could be used by itself, 1999-2007 there was fish ticket data available, for 2008-2010 there were no unique identifiers in the data to link lengths to the
## catch information, 2011 to present there is the landing_report_id which connects all the data.
  
  if(PORT){
## pull domestic length and composition for port data 1990-1998
       PAlfreq = readLines('sql/dom_length_port_A.sql')
       PAlfreq = sql_filter(sql_precode = "IN", x = species, sql_code = PAlfreq, flag = '-- insert species')
       PAlfreq = sql_add(x = region, sql_code = PAlfreq, flag = '-- insert region')
 
       PADspcomp=sql_run(afsc, PAlfreq) %>% 
         dplyr::rename_all(toupper)

      PADspcomp<-subset(PADspcomp,!is.na(EXTRAPOLATED_WEIGHT))
      PADspcomp<-subset(PADspcomp,!is.na(GEAR))
      PADspcomp$MONTH<-as.numeric(PADspcomp$MONTH)
      PADspcomp$QUARTER<-trunc((PADspcomp$MONTH/3)-0.3)+1

      PADspcomp$AREA2<-trunc(PADspcomp$AREA/10)*10
      PADspcomp$AREA2[PADspcomp$AREA2==500]<-510
      
## calculating average weight for a series of nested levels with the hierarchy of which one is used explained below 
 
      PADspcomp2<-data.table(PADspcomp)
      PADspcomp2<-merge(PADspcomp2,YAGM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH','GEAR'))  ## first is year, area, gear, month
      PADspcomp2<-merge(PADspcomp2,YGM_AVWT,all.x=T,by=c('YEAR','GEAR','MONTH'))           ## second choice is year, gear, month
      PADspcomp2<-merge(PADspcomp2,YGQ_AVWT,all.x=T,by=c('YEAR','GEAR','QUARTER'))         ## third choice is year, gear, quarter
      PADspcomp2<-merge(PADspcomp2,YAM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH'))          ## fourth choice is year, area, month
      PADspcomp2<-merge(PADspcomp2,YAQ_AVWT,all.x=T,by=c('YEAR','AREA2','QUARTER'))        ## fourth choice is year, gear
      PADspcomp2<-merge(PADspcomp2,YG_AVWT,all.x=T,by=c('YEAR','GEAR'))                    ## fill in any others by year, area
      PADspcomp2$AVEWT<-PADspcomp2$YAGM_AVE_WT
      PADspcomp2[is.na(AVEWT)]$AVEWT<-PADspcomp2[is.na(AVEWT)]$YAM_AVE_WT
      PADspcomp2[is.na(AVEWT)]$AVEWT<-PADspcomp2[is.na(AVEWT)]$YAQ_AVE_WT
      PADspcomp2[is.na(AVEWT)]$AVEWT<-PADspcomp2[is.na(AVEWT)]$YGM_AVE_WT
      PADspcomp2[is.na(AVEWT)]$AVEWT<-PADspcomp2[is.na(AVEWT)]$YGQ_AVE_WT
      PADspcomp2[is.na(AVEWT)]$AVEWT<-PADspcomp2[is.na(AVEWT)]$YG_AVE_WT

      PADspcomp2<-PADspcomp2[order(HDAY,CRUISE,PERMIT,HAUL_JOIN,SEX,LENGTH),]
      PADspcomp<-data.frame(data.table(PADspcomp)[order(HDAY,CRUISE,PERMIT,HAUL_JOIN,SEX,LENGTH),])
      
      PADspcomp$NUMB<-PADspcomp2$EXTRAPOLATED_WEIGHT/PADspcomp2$AVEWT
      
      PORTAL<-PADspcomp[,c("SPECIES","YEAR","GEAR","AREA2","AREA","MONTH","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","SEX","LENGTH","SUM_FREQUENCY","EXTRAPOLATED_WEIGHT","NUMB","SOURCE")]
    
      
## pull domestic length and composition for port data 1999-2007

      PBlfreq = readLines('sql/dom_length_port_B.sql')
      PBlfreq = sql_filter(sql_precode = "IN", x = species, sql_code = PBlfreq, flag = '-- insert species')
      PBlfreq = sql_add(x = region, sql_code = PBlfreq, flag = '-- insert region')

      PBLFREQ=sql_run(afsc, PBlfreq) %>% 
        dplyr::rename_all(toupper)

      PBftckt = readLines('sql/fish_ticket.sql')
      PBftckt = sql_filter(sql_precode = "IN", x = species_catch, sql_code = PBftckt, flag = '-- insert species')
 
## pull in and format fish ticket information from AKFIN     
      PBFTCKT=sql_run(akfin, PBftckt) %>% 
         dplyr::rename_all(toupper)

      PBLFREQ$DELIVERING_VESSEL<-as.numeric(PBLFREQ$DELIVERING_VESSEL)
      PBFTCKT$DELIVERING_VESSEL<-as.numeric(PBFTCKT$DELIVERING_VESSEL)

      PBFTCKT2<-data.table(PBFTCKT)[,list(TONS_LANDED=sum(TONS),AREA_NUMBER=length(REPORTING_AREA_CODE),ALL_AREA=paste(unique(REPORTING_AREA_CODE),collapse=",")),
        by=c("AKFIN_SPECIES_CODE",  "AKFIN_YEAR","DELIVERY_DATE", "WEEK_END_DATE", "SPECIES_NAME", "VESSEL_ID","FMP_SUBAREA", "FMP_GEAR", "VES_AKR_CG_NUM", "VES_AKR_NAME", "DELIVERING_VESSEL" )]
    
      PBFTCKT3<-merge(PBFTCKT,PBFTCKT2,all.x=T)

      PBLFREQ$DELIVERY_DATE<-format(as.Date(PBLFREQ$DELIVERY_DATE,format='%Y-%m-%d',origin="1970-01-01"))
      PBFTCKT3$DELIVERY_DATE<-format(as.Date(PBFTCKT3$DELIVERY_DATE,format='%Y%m%d',origin="1970-01-01"))
      PBCOMB<-merge(PBLFREQ,PBFTCKT3,by=c("FISH_TICKET_NO"),all.x=T)
      colnames(PBCOMB)[which(names(PBCOMB) == "DELIVERY_DATE.x")] <- "DELIVERY_DATE"
      colnames(PBCOMB)[which(names(PBCOMB) == "DELIVERING_VESSEL.x")] <- "DELIVERING_VESSEL"
     
      NAPBCOMB<-data.frame(data.table(PBCOMB)[is.na(TONS)][,c(1:16)])
      names(NAPBCOMB)=names(PBLFREQ)

      PBCOMB2<-subset(PBCOMB,!is.na(TONS))
      PBCOMB2$FISH_TICKET_NO.y<-PBCOMB2$FISH_TICKET_NO
      PBCOMB2$date_diff<-Sys.Date()-Sys.Date()
      PBCOMB3<-fuzzy_dates(length_data=NAPBCOMB,Fish_ticket=PBFTCKT3,ndays=7)
 
      PBCOMB3<-PBCOMB3[names(PBCOMB2)]
      PBCOMB4<-rbind(PBCOMB2,subset(PBCOMB3,!is.na(TONS)))
      PBCOMB4$MONTH<-as.numeric(month(PBCOMB4$DELIVERY_DATE))
      PBCOMB4$QUARTER<-trunc((PBCOMB4$MONTH/3)-0.3)+1

      PBCOMB4$AREA2<-trunc(PBCOMB4$AREA/10)*10   ## using a more gross area definition for matching average weights as the NMFS area were too small.
      PBCOMB4$AREA2[PBCOMB4$AREA2==500]<-510     ## pre-1991 data had some differing NMFS area numbers in the Bering Sea
  
 ## assign average weights to calculate number with hierarchy defined below.  
      PBCOMB5<-data.table(PBCOMB4) 
      PBCOMB5<-merge(PBCOMB5,YAGM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH','GEAR'))  ## first is year, area, gear, month
      PBCOMB5<-merge(PBCOMB5,YGM_AVWT,all.x=T,by=c('YEAR','GEAR','MONTH'))           ## second choice is year, gear, month
      PBCOMB5<-merge(PBCOMB5,YGQ_AVWT,all.x=T,by=c('YEAR','GEAR','QUARTER'))         ## third choice is year, gear, quarter
      PBCOMB5<-merge(PBCOMB5,YAM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH'))          ## fourth choice is year, area, month      
      PBCOMB5<-merge(PBCOMB5,YAQ_AVWT,all.x=T,by=c('YEAR','AREA2','QUARTER'))        ## fifth choice is year, area, quarter 
      PBCOMB5<-merge(PBCOMB5,YG_AVWT,all.x=T,by=c('YEAR','GEAR'))                    ## fill in any others by year, area, month
      PBCOMB5$AVEWT<-PBCOMB5$YAGM_AVE_WT
      PBCOMB5[is.na(AVEWT)]$AVEWT<-PBCOMB5[is.na(AVEWT)]$YAM_AVE_WT
      PBCOMB5[is.na(AVEWT)]$AVEWT<-PBCOMB5[is.na(AVEWT)]$YGQ_AVE_WT
      PBCOMB5[is.na(AVEWT)]$AVEWT<-PBCOMB5[is.na(AVEWT)]$YGM_AVE_WT
      PBCOMB5[is.na(AVEWT)]$AVEWT<-PBCOMB5[is.na(AVEWT)]$YGQ_AVE_WT
      PBCOMB5[is.na(AVEWT)]$AVEWT<-PBCOMB5[is.na(AVEWT)]$YG_AVE_WT

      PBCOMB5<-PBCOMB5[order(DELIVERY_DATE,CRUISE,DELIVERING_VESSEL,HAUL_JOIN,SPECIES,SEX,LENGTH),]
      PBCOMB4<-data.frame(data.table(PBCOMB4)[order(DELIVERY_DATE,CRUISE,DELIVERING_VESSEL,HAUL_JOIN,SPECIES,SEX,LENGTH),])
          
      PBCOMB4$NUMB<-PBCOMB5$TONS_LANDED/(PBCOMB5$AVEWT/1000)
      colnames(PBCOMB4)[which(names(PBCOMB4) == "DELIVERING_VESSEL")] <- "VES_AKR_ADFG"
      PBCOMB4$EXTRAPOLATED_WEIGHT <- PBCOMB4$TONS_LANDED*1000

      PORTBL<-PBCOMB4[,c("SPECIES","YEAR","GEAR","AREA2","AREA","MONTH","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","SEX","LENGTH","SUM_FREQUENCY","EXTRAPOLATED_WEIGHT","NUMB","SOURCE")]
    
## pull domestic length and composition for port data 2011-present

      PClfreq = readLines('sql/dom_length_port_C.sql')
      PClfreq = sql_filter(sql_precode = "IN", x = species, sql_code = PClfreq, flag = '-- insert species')
      PClfreq = sql_filter(sql_precode = "IN", x = species_catch, sql_code = PClfreq, flag = '-- insert catch_species')
      PClfreq = sql_add(x = region, sql_code = PClfreq, flag = '-- insert region')
 
      PCDspcomp=sql_run(afsc, PClfreq) %>% 
         dplyr::rename_all(toupper)

      PCDspcomp<-subset(PCDspcomp,!is.na(TONS_LANDED))
      PCDspcomp$MONTH<-as.numeric(PCDspcomp$MONTH)
      PCDspcomp$QUARTER<-trunc((PCDspcomp$MONTH/3)-0.3)+1

      PCDspcomp$AREA2<-trunc(PCDspcomp$AREA/10)*10
      PCDspcomp$AREA2[PCDspcomp$AREA2==500]<-510

      PCDspcomp2<-data.table(PCDspcomp)
      PCDspcomp2<-merge(PCDspcomp2,YAGM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH','GEAR'))  ## first choice is year, area, gear, month
      PCDspcomp2<-merge(PCDspcomp2,YGM_AVWT,all.x=T,by=c('YEAR','GEAR','MONTH'))           ## second choice is year, gear, month
      PCDspcomp2<-merge(PCDspcomp2,YGQ_AVWT,all.x=T,by=c('YEAR','GEAR','QUARTER'))         ## third choice is year, gear, quarter
      PCDspcomp2<-merge(PCDspcomp2,YAM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH'))          ## fourth choice is year, area, month
      PCDspcomp2<-merge(PCDspcomp2,YAQ_AVWT,all.x=T,by=c('YEAR','AREA2','QUARTER'))        ## fourth choice is year, area, quarter
      PCDspcomp2<-merge(PCDspcomp2,YG_AVWT,all.x=T,by=c('YEAR','GEAR'))                    ## fill in any others by year, area
  ## fill in average weight based on priority
      PCDspcomp2$AVEWT<-PCDspcomp2$YAGM_AVE_WT
      PCDspcomp2[is.na(AVEWT)]$AVEWT<-PCDspcomp2[is.na(AVEWT)]$YAM_AVE_WT
      PCDspcomp2[is.na(AVEWT)]$AVEWT<-PCDspcomp2[is.na(AVEWT)]$YAQ_AVE_WT
      PCDspcomp2[is.na(AVEWT)]$AVEWT<-PCDspcomp2[is.na(AVEWT)]$YGM_AVE_WT
      PCDspcomp2[is.na(AVEWT)]$AVEWT<-PCDspcomp2[is.na(AVEWT)]$YGQ_AVE_WT
      PCDspcomp2[is.na(AVEWT)]$AVEWT<-PCDspcomp2[is.na(AVEWT)]$YG_AVE_WT
      
      PCDspcomp2<-PCDspcomp2[order(HDAY,CRUISE,PERMIT,HAUL_JOIN,SEX,LENGTH),]
      PCDspcomp<-data.frame(data.table(PCDspcomp)[order(HDAY,CRUISE,PERMIT,HAUL_JOIN,SEX,LENGTH),])
 
      PCDspcomp$NUMB<-PCDspcomp2$TONS_LANDED/(PCDspcomp2$AVEWT/1000)

      colnames(PCDspcomp)[which(names(PCDspcomp) == "PERMIT")] <- "VES_AKR_ADFG"
      PCDspcomp$EXTRAPOLATED_WEIGHT <- PCDspcomp$TONS_LANDED*1000

      PORTCL<-PCDspcomp[,c("SPECIES","YEAR","GEAR","AREA2","AREA","MONTH","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","SEX","LENGTH","SUM_FREQUENCY","EXTRAPOLATED_WEIGHT","NUMB","SOURCE")]
    
## pull domestic length and composition for port data 2008-2010
   
      PDlfreq = readLines('sql/dom_length_port_D.sql')
      PDlfreq = sql_filter(sql_precode = "IN", x = species, sql_code = PDlfreq, flag = '-- insert species')
      PDlfreq = sql_add(x = region, sql_code = PDlfreq, flag = '-- insert region')  

      PDLFREQ=sql_run(afsc, PDlfreq) %>% 
         dplyr::rename_all(toupper)

      PDLFREQ$DELIVERING_VESSEL<-as.numeric(PDLFREQ$DELIVERING_VESSEL)

      PDCOMB<-fuzzy_dates(length_data=PDLFREQ,Fish_ticket=PBFTCKT3,ndays=7)  ## using fuzzy dates function from utils.r to match lengths with landings data
  
      PDCOMB$MONTH<-as.numeric(month(PDCOMB$DELIVERY_DATE))
      PDCOMB$QUARTER<-trunc((PDCOMB$MONTH)/3-0.3)+1

      PDCOMB$AREA2<-trunc(PDCOMB$AREA/10)*10
      PDCOMB$AREA2[PDCOMB$AREA2==500]<-510


 ## assign average weights to calculate number   
      PDCOMB2<-data.table(PDCOMB) 
      PDCOMB2<-merge(PDCOMB2,YAGM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH','GEAR'))  ## first is year, area, gear, month
      PDCOMB2<-merge(PDCOMB2,YGM_AVWT,all.x=T,by=c('YEAR','GEAR','MONTH'))           ## second choice is year, gear, month
      PDCOMB2<-merge(PDCOMB2,YGQ_AVWT,all.x=T,by=c('YEAR','GEAR','QUARTER'))         ## third choice is year, gear, quarter
      PDCOMB2<-merge(PDCOMB2,YAM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH'))          ## fourth choice is by year, area, month
      PDCOMB2<-merge(PDCOMB2,YG_AVWT,all.x=T,by=c('YEAR','GEAR'))                    ## fill in any other missing by year and gear
      PDCOMB2$AVEWT<-PDCOMB2$YAGM_AVE_WT
      PDCOMB2[is.na(AVEWT)]$AVEWT<-PDCOMB2[is.na(AVEWT)]$YGQ_AVE_WT
      PDCOMB2[is.na(AVEWT)]$AVEWT<-PDCOMB2[is.na(AVEWT)]$YGM_AVE_WT
      PDCOMB2[is.na(AVEWT)]$AVEWT<-PDCOMB2[is.na(AVEWT)]$YGQ_AVE_WT
      PDCOMB2[is.na(AVEWT)]$AVEWT<-PDCOMB2[is.na(AVEWT)]$YG_AVE_WT

      PDCOMB2<-PDCOMB2[order(DELIVERY_DATE,CRUISE,DELIVERING_VESSEL,HAUL_JOIN,SPECIES,SEX,LENGTH),]
      PDCOMB<-data.frame(data.table(PDCOMB)[order(DELIVERY_DATE,CRUISE,DELIVERING_VESSEL,HAUL_JOIN,SPECIES,SEX,LENGTH),])
          
      PDCOMB$NUMB<-PDCOMB2$TONS_LANDED/(PDCOMB2$AVEWT/1000)

      colnames(PDCOMB)[which(names(PDCOMB) == "DELIVERING_VESSEL")] <- "VES_AKR_ADFG"
      PDCOMB$EXTRAPOLATED_WEIGHT <- PDCOMB$TONS_LANDED*1000

      PORTDL<-PDCOMB[,c("SPECIES","YEAR","GEAR","AREA2","AREA","MONTH","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","SEX","LENGTH","SUM_FREQUENCY","EXTRAPOLATED_WEIGHT","NUMB","SOURCE")]
   

## combine all the port data
      PORT_DATA<-data.table(rbind(PORTAL,PORTBL,PORTCL,PORTDL))
      ALL_DATA<-rbind(OBS_DATA,PORT_DATA)
  } else {                                                        ## if PORT is false use only at-sea observer data
       ALL_DATA <- OBS_DATA
     }


## pull domestic age data 
#  dage = readLines('sql/dom_age.sql')
#  dage = sql_filter(sql_precode = "IN", x = species, sql_code = dage, flag = '-- insert species')
#  dage = sql_add(x = region, sql_code = dage, flag = '-- insert region')
#  Dage=sql_run(afsc, dage) %>% 
#     dplyr::rename_all(toupper)

## pull foreign age data
#  fage = readLines('for_age.sql')
#  fage = sql_filter(sql_precode = "IN", x = species, sql_code = fage, flag = '-- insert species')
#  fage = sql_add(x = region, sql_code = fage, flag = '-- insert region')
#  Fage=sql_run(afsc, fage) %>% 
#         dplyr::rename_all(toupper)

## combind foreign and domestic ages
#  Tage<-rbind(Fage,Dage)

 
  
## pull blend information on domestic catch

  catch= readLines('sql/dom_catch.sql')
  catch = sql_filter(sql_precode = "<=", x = ly, sql_code = catch, flag = '-- insert year')
  catch = sql_filter(sql_precode = "IN", x = species_catch, sql_code = catch, flag = '-- insert species_catch')
  catch = sql_filter(sql_precode = "IN", x = sp_area, sql_code = catch, flag = '-- insert subarea')
 
 
  CATCH=sql_run(akfin, catch) %>% 
         dplyr::rename_all(toupper)

## pull blend information on foreign catch  1977-1990
## note that this does not include domestic catch for this time period and is limited to reported foriegn catch

  if(sp_area=='BS') foreign_catch_area <- "LIKE '%BERING%'"
  if(sp_area=='AI') foreign_catch_area <- "LIKE '%ALEUTIANS%'"
  if(sp_area=='GOA') foreign_catch_area <- "IN ('KODIAK','YAKUTAT', 'SHUMAGIN','S.E. ALASKA', 'SHELIKOF STR.','CHIRIKOF')"

  fcatch= readLines('sql/for_catch.sql')
  fcatch = sql_filter(sql_precode = "IN", x = for_species_catch, sql_code = fcatch, flag = '-- insert species_catch')
  fcatch = sql_add(x = foreign_catch_area, sql_code = fcatch, flag = '-- insert subarea')

  FCATCH=sql_run(afsc, fcatch) %>% 
         dplyr::rename_all(toupper)
    
  FCATCH<-data.table(FCATCH)
  FCATCH[AREA<100]$AREA<-FCATCH[AREA<100]$AREA*10



##Combine foriegn and domestic catch    
  CATCHT<-data.table(rbind(FCATCH,CATCH))
  
  CATCHT<-CATCHT[TONS>0]
  CATCHT$AREA<-as.numeric(CATCHT$AREA)

  CATCHT$MONTH<-as.numeric(CATCHT$MONTH_WED)
  CATCHT$QUARTER<-trunc((CATCHT$MONTH)/3-0.3)+1


  CATCHT$AREA2<-trunc(CATCHT$AREA/10)*10
  CATCHT[AREA2==500]$AREA2<-510

  if(sp_area=='BS'){CATCHT$AREA2 <- CATCHT$AREA2} else {CATCHT$AREA2 <- CATCHT$AREA}

  CATCHT<-CATCHT[GEAR%in%c("POT","TRW","HAL")]
  CATCHT$YEAR<-as.numeric(CATCHT$YEAR)

  ## use average weights to calculate number of fish caught

  CATCHT2<-data.table(CATCHT) 
  CATCHT2<-merge(CATCHT2,YAGM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH','GEAR'))  ## first is year, area, gear, month
  CATCHT2<-merge(CATCHT2,YGM_AVWT,all.x=T,by=c('YEAR','GEAR','MONTH'))          ## second choice is year, gear, month
  CATCHT2<-merge(CATCHT2,YGQ_AVWT,all.x=T,by=c('YEAR','GEAR','QUARTER'))        ## third choice is year, gear, quarter
  CATCHT2<-merge(CATCHT2,YAM_AVWT,all.x=T,by=c('YEAR','AREA2','MONTH'))          ## fourth choice by year, area, month
  CATCHT2<-merge(CATCHT2,YG_AVWT,all.x=T,by=c('YEAR','GEAR'))                   ## fill in any more missing by year and gear
  CATCHT2$AVEWT<-CATCHT2$YAGM_AVE_WT
  CATCHT2[is.na(AVEWT)]$AVEWT<-CATCHT2[is.na(AVEWT)]$YGM_AVE_WT
  CATCHT2[is.na(AVEWT)]$AVEWT<-CATCHT2[is.na(AVEWT)]$YGQ_AVE_WT
  CATCHT2[is.na(AVEWT)]$AVEWT<-CATCHT2[is.na(AVEWT)]$YAM_AVE_WT
  CATCHT2[is.na(AVEWT)]$AVEWT<-CATCHT2[is.na(AVEWT)]$YG_AVE_WT

  CATCHT3<-data.table(data.frame(CATCHT2)[,names(CATCHT)])
  CATCHT3$NUMBER<-CATCHT3$TONS/(CATCHT2$AVEWT/1000)        ## estimate the number of fish caught using average weights
  CATCHT3$SPECIES=species
  CATCHT3$SPECIES=as.numeric(CATCHT3$SPECIES)
  CATCHT3<-CATCHT3[!is.na(NUMBER)]
  
  CATCHT4<-CATCHT3[,list(YAGM_TONS=sum(TONS),YAGM_TNUM=sum(NUMBER)),by=c("SPECIES","YEAR","GEAR","AREA2","QUARTER")]

  xt_YAG<-CATCHT4[,list(YAG_TONS=sum(YAGM_TONS),YAG_TNUM=sum(YAGM_TNUM)),by=c("AREA2","GEAR","YEAR")]
  CATCHT4<-merge(CATCHT4,xt_YAG,by=c("YEAR","AREA2","GEAR"), all.x=T)
  xt_YG<-CATCHT4[,list(YG_TONS=sum(YAGM_TONS),YG_TNUM=sum(YAGM_TNUM)),by=c("GEAR","YEAR")]
  CATCHT4<-merge(CATCHT4,xt_YG,by=c("YEAR","GEAR"), all.x=T)
  xt_Y<-CATCHT4[,list(Y_TONS=sum(YAGM_TONS),Y_TNUM=sum(YAGM_TNUM)),by=c("YEAR")]
  CATCHT4<-merge(CATCHT4,xt_Y,by=c("YEAR"), all.x=T)

       
  Length<-ALL_DATA[GEAR%in%c("POT","TRW","HAL")]
  Length$YEAR<-as.numeric(Length$YEAR)
  Length$MONTH<-as.numeric(Length$MONTH)
  
  Length$YAGMH_STONS<-Length$EXTRAPOLATED_WEIGHT/1000
  Length$YAGMH_SNUM<-Length$NUMB


if(!SEX){
    Length<-Length[,list(SUM_FREQUENCY=sum(SUM_FREQUENCY)),by=c("SPECIES","YEAR","AREA2","GEAR","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","LENGTH","YAGMH_STONS","YAGMH_SNUM")]
    L_YAGMH<-Length[,list(YAGMH_SFREQ=sum(SUM_FREQUENCY)),by=c("CRUISE","VES_AKR_ADFG","HAUL_JOIN")]
    Length<-merge(Length,L_YAGMH,by=c("CRUISE","VES_AKR_ADFG","HAUL_JOIN"), all.x=T)
    L_YAGM<-Length[,list(YAGM_STONS=sum(YAGMH_STONS),YAGM_SNUM=sum(YAGMH_SNUM),YAGM_SFREQ=sum(SUM_FREQUENCY)),by=c("AREA2","GEAR","QUARTER","YEAR")]
    Length<-merge(Length,L_YAGM,by=c("YEAR","AREA2","GEAR","QUARTER"), all.x=T)
    L_YAG<-Length[,list(YAG_STONS=sum(YAGMH_STONS),YAG_SNUM=sum(YAGMH_SNUM),YAG_SFREQ=sum(SUM_FREQUENCY)),by=c("AREA2","GEAR","YEAR")]
    Length<-merge(Length,L_YAG,by=c("YEAR","AREA2","GEAR"), all.x=T)
    L_YG<-Length[,list(YG_STONS=sum(YAGMH_STONS),YG_SNUM=sum(YAGMH_SNUM),YG_SFREQ=sum(SUM_FREQUENCY)),by=c("GEAR","YEAR")]
    Length<-merge(Length,L_YG,by=c("YEAR","GEAR"), all.x=T)
    L_Y<-Length[,list(Y_STONS=sum(YAGMH_STONS),Y_SNUM=sum(YAGMH_SNUM),Y_SFREQ=sum(SUM_FREQUENCY)),by=c("YEAR")]
    Length<-merge(Length,L_Y,by=c("YEAR"), all.x=T)

    x<-merge(Length,CATCHT4,by=c("SPECIES","YEAR","AREA2","GEAR","QUARTER"),all.x=T)

    y2<-x[!is.na(YAGM_TNUM)]

 
    y2$WEIGHT1<-y2$SUM_FREQUENCY/y2$YAGMH_SFREQ  ## individual weight of length in length sample at the haul level
    y2$WEIGHT2<-y2$YAGMH_SNUM/y2$YAGM_SNUM        ## weight of haul numbers for the year, area, gear, month strata (proportion of total observer samples for strata)
    y2$WEIGHT3<-y2$YAGM_TNUM/y2$YG_TNUM           ## weight of total number of catch by year/area/gear/month to year/gear catch for 3 fishery models
    y2$WEIGHT4<-y2$YAGM_TNUM/y2$Y_TNUM             ## weight of total number of catch by year/area/gear/month to year catch for single fishery models

  
    y3<- y2[,c("YEAR","GEAR","AREA2","QUARTER","CRUISE",
      "HAUL_JOIN", "LENGTH", "SUM_FREQUENCY", "YAGMH_SNUM", 
      "YAGMH_SFREQ","YAGM_SFREQ", "YG_SFREQ","Y_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM","YAGMH_SNUM",
      "YAGM_SNUM","YG_SNUM","YG_SNUM","Y_SNUM","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]     

    y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4   ## weight of individual length sample for single fishery model
    y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3
    y3$STRATA<-paste(y3$AREA2,y3$QUARTER,y3$GEAR,sep="_")  ## simple strata of area, month, gear for clustered bootstrap
    y3$STRATA1<-as.numeric(as.factor(y3$STRATA))
    y3$HAUL_JOIN1<-as.numeric(as.factor(y3$HAUL_JOIN))
 

    y4<-y3[YAGM_SFREQ>minN][,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata
    y4.1<-y3[YAGM_SFREQ>minN][,list(WEIGHT_GEAR=sum(WEIGHTX_GEAR)),by=c("LENGTH","GEAR","YEAR")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata
  

    y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] 
    y5=merge(y4,y5)
    y5$FREQ<-y5$WEIGHT/y5$TWEIGHT
    y6<-y5[,-c("WEIGHT","TWEIGHT")]

    grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:max(y5$LENGTH)))
    y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","LENGTH"))
    y7[is.na(FREQ)]$FREQ <-0                                  ## this is the proportion at length for a single fishery

  ## calculations for multiple gear fisheries

    y5.1<-y4.1[,list(TWEIGHT=sum(WEIGHT_GEAR)),by=c("GEAR","YEAR")] 
    y5.1=merge(y4.1,y5.1)
    y5.1$FREQ<-y5.1$WEIGHT_GEAR/y5.1$TWEIGHT
    y6.1<-y5.1[,-c("WEIGHT_GEAR","TWEIGHT")]

    grid<-data.table(expand.grid(YEAR=unique(y6.1$YEAR),GEAR=unique(y6.1$GEAR),LENGTH=1:max(y6.1$LENGTH)))
    y7.1<-merge(grid,y6.1,all.x=TRUE,by=c("YEAR","GEAR","LENGTH"))
    y7.1[is.na(FREQ)]$FREQ <-0   ## this is the proportion at length by gear


    y3.1<- y3[,c("YEAR","HAUL_JOIN1","STRATA1","LENGTH", "SUM_FREQUENCY", "YAGMH_SFREQ", 
      "YAGMH_SNUM","YAGM_SFREQ", "YG_SFREQ","Y_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM",
      "YAGM_SNUM","YG_SNUM","Y_SNUM")] 

      y3.1<-y3.1[YAGM_SFREQ>minN] 



    years<-unique(y3.1$YEAR)

    ESS<-vector("list",length=length(years))

    for(i in 1:length(years)){
 	      data<-y3.1[YEAR==years[i]]
        N = sum(data$SUM_FREQUENCY)
        H = length(unique(data$HAUL_JOIN1))
        S = length(unique(data$STRATA1))
   
        #d_EXP<- vcdExtra::expand.dft(data, freq="SUM_FREQUENCY")
        #cm   <- fishmethods::clus.mean(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1, clustotal = round(d_EXP$YAGM_TNUM), rho=clus.rho(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1)$icc[1],nboot = 10000)
  	        
        ESS[[i]] <-data.table(YEAR=years[i],BootESS=NA,df=NA,NSAMP=N,NHAUL=H,NSTRATA=S)
        print(years[i])
       }


    y3.2<- y3[,c("YEAR","GEAR","HAUL_JOIN1","STRATA1","LENGTH", "SUM_FREQUENCY", "YAGMH_SFREQ", 
        "YAGM_SFREQ", "YG_SFREQ","YAGM_TNUM","YG_TNUM","YAGMH_SNUM","YAGM_SNUM","YG_SNUM")] 

    y3.2<-y3.2[YAGM_SFREQ>minN] 

    years<-unique(y3.2$YEAR)
    gears=unique(y3.2$GEAR)

    b=1
    ESS.1<-vector("list",length=length(years)*length(gears))
    for(j in 1:length(gears)){ 
        for(i in 1:length(years)){
  
            data<-y3.2[YEAR==years[i]&GEAR==gears[[j]]]
            if(nrow(data>0)){
              N = sum(data$SUM_FREQUENCY)
              H = length(unique(data$HAUL_JOIN1))
              S = length(unique(data$STRATA1))
       

         #d_EXP<-vcdExtra::expand.dft(data, freq="SUM_FREQUENCY")
         
         #if(S>1){
         #        cm=fishmethods::clus.mean(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1, clustotal = round(d_EXP$YAGM_SNUM), rho=clus.rho(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1)$icc[1],nboot = 10000)
         #        } else {cm <- rep(NA,12)
         #        print("Only one strata for this year and gear combination")} 
         }

          ESS.1[[b]] <-data.table(YEAR=years[i],GEAR=gears[[j]],BootESS=NA,df=NA,NSAMP=N,NHAUL=H,NSTRATA=S)
          b <- b+1
          print(paste0(gears[[j]]," in ",years[i]))
          }
      }


    ESS=do.call(rbind, ESS)
    ESS.1=do.call(rbind, ESS.1)
    LF1<-merge(y7,ESS,by="YEAR")
    LF1.1<-merge(y7.1,ESS.1,by=c("YEAR","GEAR"))
    LF1.1<-LF1.1[NSAMP>0]
    LF<-list(LF1,LF1.1)
  }

  ## for species with seperate sexes

  if(SEX){
    Length<-Length[,list(SUM_FREQUENCY=sum(SUM_FREQUENCY)),by=c("SPECIES","YEAR","AREA2","GEAR","QUARTER","CRUISE","VES_AKR_ADFG","HAUL_JOIN","SEX","LENGTH","YAGMH_STONS","YAGMH_SNUM")]
    L_YAGMH<-Length[,list(YAGMH_SFREQ=sum(SUM_FREQUENCY)),by=c("CRUISE","VES_AKR_ADFG","HAUL_JOIN")]
    Length<-merge(Length,L_YAGMH,by=c("CRUISE","VES_AKR_ADFG","HAUL_JOIN"), all.x=T)
  
    L_YAGM<-Length[,list(YAGM_STONS=sum(YAGMH_STONS),YAGM_SNUM=sum(YAGMH_SNUM),YAGM_SFREQ=sum(SUM_FREQUENCY)),by=c("AREA2","GEAR","QUARTER","YEAR")]
    Length<-merge(Length,L_YAGM,by=c("YEAR","AREA2","GEAR","QUARTER"), all.x=T)
    L_YAG<-Length[,list(YAG_STONS=sum(YAGMH_STONS),YAG_SNUM=sum(YAGMH_SNUM),YAG_SFREQ=sum(SUM_FREQUENCY)),by=c("AREA2","GEAR","YEAR")]
    Length<-merge(Length,L_YAG,by=c("YEAR","AREA2","GEAR"), all.x=T)
    L_YG<-Length[,list(YG_STONS=sum(YAGMH_STONS),YG_SNUM=sum(YAGMH_SNUM),YG_SFREQ=sum(SUM_FREQUENCY)),by=c("GEAR","YEAR")]
    Length<-merge(Length,L_YG,by=c("YEAR","GEAR"), all.x=T)
    L_Y<-Length[,list(Y_STONS=sum(YAGMH_STONS),Y_SNUM=sum(YAGMH_SNUM),Y_SFREQ=sum(SUM_FREQUENCY)),by=c("YEAR")]
    Length<-merge(Length,L_Y,by=c("YEAR"), all.x=T)

    x<-merge(Length,CATCHT4,by=c("SPECIES","YEAR","AREA2","GEAR","QUARTER"),all.x=T)

    y2<-x[!is.na(YAGM_TNUM)]


    y2$WEIGHT1<-y2$SUM_FREQUENCY/y2$YAGMH_SFREQ  ## individual weight of length in length sample at the haul level
    y2$WEIGHT2<-y2$YAGMH_SNUM/y2$YAGM_SNUM        ## weight of haul numbers for the year, area, gear, month strata (proportion of total observer samples for strata)
    y2$WEIGHT3<-y2$YAGM_TNUM/y2$YG_TNUM           ## weight of total number of catch by year/area/gear/month to year/gear catch for 3 fishery models
    y2$WEIGHT4<-y2$YAGM_TNUM/y2$Y_TNUM                ## weight of total number of catch by year/area/gear/month to year catch for single fishery models

 

    y3<- y2[,c("YEAR","GEAR","AREA2","QUARTER","CRUISE",
        "HAUL_JOIN", "SEX","LENGTH", "SUM_FREQUENCY", "YAGMH_SNUM", 
        "YAGMH_SFREQ","YAGM_SFREQ", "YG_SFREQ","Y_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM","YAGMH_SNUM",
        "YAGM_SNUM","YG_SNUM","YG_SNUM","Y_SNUM","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]       

    y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4   ## weight of individual length sample for single gear fishery model
    y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3 ## weight of individual length sample for multiple gear fishery model
    y3<-y3[WEIGHTX>0]                              ## exluding those lengths with zero weight due to lack of catch for that YAGM strata in the blend data 
   
    y3$STRATA<-paste(y3$AREA2,y3$QUARTER,y3$GEAR,sep="_")

    y3$STRATA1<-as.numeric(as.factor(y3$STRATA))
    y3$HAUL_JOIN1<-as.numeric(as.factor(y3$HAUL_JOIN))
 
    y4<-y3[YAGM_SFREQ>minN][,list(WEIGHT=sum(WEIGHTX)),by=c("SEX","LENGTH","YEAR","Y_TNUM")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata
    y4.1<-y3[YAGM_SFREQ>minN][,list(WEIGHT_GEAR=sum(WEIGHTX_GEAR)),by=c("SEX","LENGTH","GEAR","YEAR")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata
  
    y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] 
    y5=merge(y4,y5)
    y5$FREQ<-y5$WEIGHT/y5$TWEIGHT
    y6<-y5[,-c("WEIGHT","TWEIGHT")]

    grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),SEX=as.character(1:3),LENGTH=1:max(y5$LENGTH)))
    y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","SEX","LENGTH"))
    y7[is.na(FREQ)]$FREQ <-0 ## Proportion at length by sex for single gear

    y5.1<-y4.1[,list(TWEIGHT=sum(WEIGHT_GEAR)),by=c("GEAR","YEAR")] 
    y5.1=merge(y4.1,y5.1)
    y5.1$FREQ<-y5.1$WEIGHT_GEAR/y5.1$TWEIGHT
    y6.1<-y5.1[,-c("WEIGHT_GEAR","TWEIGHT")]

    grid<-data.table(expand.grid(YEAR=unique(y6.1$YEAR),GEAR=unique(y6.1$GEAR),SEX=as.character(1:3),LENGTH=1:max(y6.1$LENGTH)))
    y7.1<-merge(grid,y6.1,all.x=TRUE,by=c("YEAR","GEAR","SEX","LENGTH"))
    y7.1[is.na(FREQ)]$FREQ <-0  ## Proportion at length by sex for multiple gears


  ## everything after this is exploratory input sample sizes

    y3.1<- y3[,c("YEAR","HAUL_JOIN1","STRATA1","SEX","LENGTH", "SUM_FREQUENCY", "YAGMH_SFREQ", 
        "YAGMH_SNUM","YAGM_SFREQ", "YG_SFREQ","Y_SFREQ","YAGM_TNUM","YG_TNUM","Y_TNUM",
        "YAGM_SNUM","YG_SNUM","Y_SNUM")] 
    y3.1<-y3.1[YAGM_SFREQ>minN] 

    years<-unique(y3.1$YEAR)
    sexs<-as.character(1:3)
    ESS<-vector("list",length=length(years)*length(sexs))
  
    b=1
    for(i in 1:length(years)){
       for (k in 1:length(sexs)){
            data<-y3.1[YEAR==years[i]&SEX ==sexs[k]]
            N = sum(data$SUM_FREQUENCY)
            H = length(unique(data$HAUL_JOIN1))
            S = length(unique(data$STRATA1))
     
            #d_EXP<-vcdExtra::expand.dft(data, freq="SUM_FREQUENCY")
    
            #if(S > 1) {
            #          cm=fishmethods::clus.mean(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1, clustotal = round(d_EXP$YAGM_SNUM), rho=clus.rho(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1)$icc[1],nboot = 10000)
            #        } else {cm <- rep(NA,12)
            #          print("Only one strata for this year and sex combination")
            #      } 
     
            ESS[[b]] <-data.table(YEAR=years[i],SEX=sexs[k],BootESS=NA,df=NA,NSAMP=N,NHAUL=H,NSTRATA=S)
            print(paste0(years[i]," for sex ",sexs[k]))
            b<-b+1
          }
      }

    y3.2<- y3[,c("YEAR","GEAR","HAUL_JOIN1","STRATA1","SEX","LENGTH", "SUM_FREQUENCY", "YAGMH_SFREQ", 
        "YAGM_SFREQ", "YG_SFREQ","YAGM_TNUM","YG_TNUM","YAGMH_SNUM","YAGM_SNUM","YG_SNUM")] 

    y3.2<-y3.2[YAGM_SFREQ>minN] 

      years<-unique(y3.2$YEAR)
      gears=unique(y3.2$GEAR)

      b=1
      ESS.1<-vector("list",length=length(years)*length(gears)*length(sexs))
      for(j in 1:length(gears)){ 
        for(i in 1:length(years)){
          for(k in 1:length(sexs)){
  
              data<-y3.2[YEAR==years[i]&GEAR==gears[j]&SEX==sexs[k]]
              if(nrow(data>0)){
                  N = sum(data$SUM_FREQUENCY)
                  H = length(unique(data$HAUL_JOIN1))
                  S = length(unique(data$STRATA1))
      

                # d_EXP<-vcdExtra::expand.dft(data, freq="SUM_FREQUENCY")
                # if(S>1){
                #         cm=fishmethods::clus.mean(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1, clustotal = round(d_EXP$YAGM_SNUM), rho=clus.rho(popchar =d_EXP$LENGTH , cluster = d_EXP$STRATA1)$icc[1],nboot = 10000)
                #      } else {cm <- rep(NA,12)
                #              print("Only one strata for this year, gear, and sex combination")} 
                    }

        ESS.1[[b]] <-data.table(YEAR=years[i],SEX=sexs[k],GEAR=gears[j],BootESS=NA,df=NA,NSAMP=N,NHAUL=H,NSTRATA=S)
        b <- b+1
        print(paste0(gears[j]," in ",years[i], "for sex ",sexs[k]))
        }
     }
   }


  ESS=do.call(rbind, ESS)
  ESS.1=do.call(rbind, ESS.1)
  LF1<-merge(y7,ESS,by=c("YEAR","SEX"))
  LF1.1<-merge(y7.1,ESS.1,by=c("YEAR","SEX","GEAR"))
  LF1.1<-LF1.1[NSAMP>0]
  LF<-list(LF1,LF1.1)
 }

 return(LF)
}



# AI_PCOD3=LENGTH_BY_CATCH_QUARTER_short(species= 202 ,species_catch= 'PCOD', for_species_catch='PACIFIC COD',sp_area='AI' ,ly=2022, SEX=FALSE, PORT=FALSE,minN=100)
# ggplot(AI_PCOD3[[2]][GEAR=='TRW'],aes(x=LENGTH,y=FREQ,color=GEAR))+geom_line()+facet_wrap(~YEAR) 
