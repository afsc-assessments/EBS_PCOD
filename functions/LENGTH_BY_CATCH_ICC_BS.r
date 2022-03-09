
## Function to pull and process length composition data for the domestic fisheries. 
## This is for a single fishery model as per the 2021 production model
## This function proportions the lengths to the catch from the haul level extrapolated 
## number from the species composition data and to the total catch for the area, gear,
## and month by the blend catch information.  There are a number of sample size measures attempted, 
## but none used except the number of hauls, these are then reduced to average to the averagenumber of stations
## from the bottom trawl survey data. 
## ICC is only exploratory and uses the intra-correlation coeffient to calculate input sample size, it takes a bit of time to do, if marked FALSE it is not calculated.
## Exports length compostitions for both single combined fishery and POT, Longline, Trawl fishery category in the output.
## FLENGTH<-LENGTH_BY_CATCH_ICC_BS_FOREIGN()
## FLENGTH[[1]] would be the combined fishery length comps and FLENGTH[[2]] would be separate 


LENGTH_BY_CATCH_ICC_BS<-function(fsh_sp_str=fsh_sp_str ,fsh_sp_label=fsh_sp_label, ly=final_year, ICC=FALSE ){
  require(RODBC)
  require(data.table)
  require(reshape2)
  require(rgdal)
  require(dplyr)
  require(lubridate)


  test <- paste("SELECT \n ",
      "CASE \n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in (1,2,3,4) \n ",
      "  THEN 'TRW'\n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in 6 \n ",
      "  THEN 'POT' \n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in (5,7,9,10,11,68,8) \n ",
      "  THEN 'HAL' \n ",
      "END                                              AS GEAR, \n ",
      "CONCAT('H',TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN))       AS HAUL_JOIN, \n ",
      "TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') AS MONTH, \n ",
      "TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'YYYY') AS YEAR, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_NUMBER        AS NUMB, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.CRUISE        AS CRUISE, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.PERMIT        AS PERMIT, \n ",
       "OBSINT.DEBRIEFED_SPCOMP.HAUL        AS HAUL, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_WEIGHT, \n ",
      "OBSINT.DEBRIEFED_LENGTH.LENGTH                     AS LENGTH, \n ",
      "OBSINT.DEBRIEFED_LENGTH.FREQUENCY                  AS sum_frequency, \n ",
       "OBSINT.DEBRIEFED_HAUL.LONDD_END AS LON, \n",
        "OBSINT.DEBRIEFED_HAUL.LATDD_END AS LAT, \n",
        "OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE AS HDAY, \n",
      "OBSINT.DEBRIEFED_HAUL.NMFS_AREA AS AREA, \n",
      "obsint.debriefed_haul.catcher_boat_adfg as VES_AKR_ADFG \n",
      "FROM OBSINT.DEBRIEFED_HAUL \n ",
      "INNER JOIN OBSINT.DEBRIEFED_SPCOMP \n ",
      "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN \n ",
      "INNER JOIN OBSINT.DEBRIEFED_LENGTH \n ",
      "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_LENGTH.HAUL_JOIN \n ",
      "WHERE OBSINT.DEBRIEFED_HAUL.NMFS_AREA BETWEEN 500 AND 539 \n",
      "AND OBSINT.DEBRIEFED_SPCOMP.SPECIES  in  (",fsh_sp_str,")",
      "AND OBSINT.DEBRIEFED_LENGTH.SPECIES    in  (",fsh_sp_str,")",sep="")

  Dspcomp=data.table(sqlQuery(AFSC,test))

  WED<-function(x=Dspcomp$HDAY[1])
   { y<-data.table(
     weekday=weekdays(x),
     wed=ceiling_date(x, "week"),  
     plus= ifelse(weekdays(x) %in% c("Sunday"), 6, -1),
     YR=year(x))
     y$next_saturday<-date(y$wed)+y$plus
     y[YR<1993]$next_saturday<-date(y[YR<1993]$wed)
     y$yr2<-year(y$next_saturday)
     y[YR!=yr2]$next_saturday<-date(paste0(y[YR!=yr2]$YR,"-12-31"))
     return(y$next_saturday)
   }
 
 
   Dspcomp$WED<-WED(Dspcomp$HDAY)
   Dspcomp$MONTH_WED<-month(Dspcomp$WED)

   Dspcomp<-Dspcomp[YEAR>=1990]

   Dspcomp<-Dspcomp[EXTRAPOLATED_WEIGHT>0]
   Dspcomp<-Dspcomp[NUMB>0]
  
   Dspcomp$AREA2<-trunc(Dspcomp$AREA/10)*10
   Dspcomp[AREA2==500]$AREA2<-510
  
   Dspcomp[is.na(VES_AKR_ADFG)]$VES_AKR_ADFG<- Dspcomp[is.na(VES_AKR_ADFG)]$PERMIT
   Dspcomp[is.na(PERMIT)]$PERMIT<- Dspcomp[is.na(PERMIT)]$VES_AKR_ADFG

## pull blend information on catch

 test2 <- paste0("SELECT SUM(COUNCIL.COMPREHENSIVE_BLEND_CA.WEIGHT_POSTED)AS TONS,
                  to_char(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE,'MM') AS MONTH_WED,
                  COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR AS GEAR, 
                  COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR AS YEAR, 
                  COUNCIL.COMPREHENSIVE_BLEND_CA.REPORTING_AREA_CODE AS AREA 
                  FROM COUNCIL.COMPREHENSIVE_BLEND_CA 
                   WHERE COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA in ('BS') 
                   AND COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR <= ",ly,
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE in (",fsh_sp_label,") ",
                  "GROUP BY COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR,
                  to_char(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE,'MM'), 
                  COUNCIL.COMPREHENSIVE_BLEND_CA.REPORTING_AREA_CODE, 
                  COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR" )


    CATCH<-data.table(sqlQuery(CHINA,test2))

    CATCH<-CATCH[TONS>0]

    CATCH$AREA2<-trunc(CATCH$AREA/10)*10
    CATCH[AREA2==500]$AREA2<-510
    CATCH<-CATCH[GEAR%in%c("POT","TRW","HAL")]

 
 	 Length<-Dspcomp[GEAR%in%c("POT","TRW","HAL")]



  x<-Length[,list(FREQ_YAGMH=sum(SUM_FREQUENCY),EX_NUMBER=max(NUMB),AVE_WEIGHT_1=max(EXTRAPOLATED_WEIGHT)/max(NUMB)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","PERMIT","VES_AKR_ADFG","HAUL")]
  x2<-x[,list(AVE_WEIGHT_YAGM=mean(AVE_WEIGHT_1)),by=c("AREA2","MONTH_WED","GEAR","YEAR")]   ## average weight for strata area/month/gear/year
  x<-merge(x,x2,all.x=T,by=c("AREA2","MONTH_WED","GEAR","YEAR"))
  x<-merge(Length,x,all.x=T,by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","PERMIT","VES_AKR_ADFG","HAUL"))

  xt_YAGM<-CATCH[,list(YAGM_TONS=sum(TONS)),by=c("AREA2","GEAR","MONTH_WED","YEAR")]

  y<-merge(x,xt_YAGM,all=T,by=c("AREA2","MONTH_WED","GEAR","YEAR"))
  y2<-y[!is.na(YAGM_TONS)]                                          ## lose 7311 length frequencies which don't have catch assosiated in the blend table...

  y2$YAGM_TNUM<-y2$YAGM_TONS/y2$AVE_WEIGHT_YAGM

  y3<-y2[,list(YAGM_TNUM=max(YAGM_TNUM),YAGM_TONS=max(YAGM_TONS)),by=c("AREA2","YEAR","MONTH_WED","GEAR")]
  y4<-y3[!is.na(YAGM_TNUM)][,list(YG_TNUM=sum(YAGM_TNUM)),by=c("GEAR","YEAR")]
  y5<-y3[!is.na(YAGM_TNUM)][,list(Y_TNUM=sum(YAGM_TNUM)),by=c("YEAR")]
 
  y2<-merge(y2,y4,by=c("GEAR","YEAR"))
  y2<-merge(y2,y5,by=c("YEAR"))

  y_AGM<-y2[!is.na(YAGM_TNUM) & !is.na(EX_NUMBER)]

  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","PERMIT","VES_AKR_ADFG","HAUL")]
  test_YAGM<-test[,list(SNUM_YAGM=sum(sample)),by=c("AREA2","MONTH_WED","GEAR","YEAR")]
  y2<-merge(y2,test_YAGM,all=T,by=c("AREA2","MONTH_WED","GEAR","YEAR"))

  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","PERMIT","VES_AKR_ADFG","HAUL")]
  test_YAG<-test[,list(SNUM_YAG=sum(sample)),by=c("AREA2","GEAR","YEAR")]
  y2<-merge(y2,test_YAG,all=T,by=c("AREA2","GEAR","YEAR"))


  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","PERMIT","VES_AKR_ADFG","HAUL")]
  test_YG<-test[,list(SNUM_YG=sum(sample)),by=c("GEAR","YEAR")]
  y2<-merge(y2,test_YG,all=T,by=c("GEAR","YEAR"))


  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","PERMIT","VES_AKR_ADFG","HAUL")]
  test_Y<-test[,list(SNUM_Y=sum(sample)),by=c("YEAR")]
  y2<-merge(y2,test_Y,all=T,by=c("YEAR"))

  x_YAGM<-Length[,list(FREQ_YAGM=sum(SUM_FREQUENCY)),by=c("AREA2","MONTH_WED","GEAR","YEAR")]
  x_YG<-Length[,list(FREQ_YG=sum(SUM_FREQUENCY)),by=c("GEAR","YEAR")]
  x_Y<-Length[,list(FREQ_Y=sum(SUM_FREQUENCY)),by=c("YEAR")]

  y2<-merge(y2,x_YAGM,by=c("AREA2","MONTH_WED","GEAR","YEAR"),all=T)
  y2<-merge(y2,x_YG,by=c("GEAR","YEAR"),all=T)
  y2<-merge(y2,x_Y,by=c("YEAR"),all=T)

  y2[is.na(SUM_FREQUENCY)]$SUM_FREQUENCY<-0
  y2[is.na(FREQ_YAGM)]$FREQ_YAGM<-0

  y2[is.na(FREQ_YG)]$FREQ_YG<-0
  y2[is.na(FREQ_Y)]$FREQ_Y<-0


  y2[is.na(EX_NUMBER)]$EX_NUMBER<-0
  y2[is.na(SNUM_YAGM)]$SNUM_YAGM<-0
  y2[is.na(SNUM_YAG)]$SNUM_YAG<-0
  y2[is.na(SNUM_YG)]$SNUM_YG<-0
  y2[is.na(SNUM_Y)]$SNUM_Y<-0

  ## calculate weights for propotioning

  y2$WEIGHT1<-y2$SUM_FREQUENCY/y2$FREQ_YAGMH  ## individual weight of length in length sample at the haul level
  y2$WEIGHT2<-y2$EX_NUMBER/y2$SNUM_YAGM        ## weight of haul numbers for the year, area, gear, month strata (proportion of total observer samples for strata)
  y2$WEIGHT3<-y2$YAGM_TNUM/y2$YG_TNUM           ## weight of total number of catch by year/area/gear/month to year/gear catch for 3 fishery models
  y2$WEIGHT4<-y2$YAGM_TNUM/y2$Y_TNUM             ## weight of total number of catch by year/area/gear/month to year catch for single fishery models

  y2[WEIGHT1=='NaN']$WEIGHT1<-0
  y2[WEIGHT2=='NaN']$WEIGHT2<-0

  y3<- y2[,c("YEAR","GEAR","AREA2","MONTH_WED","CRUISE",
    "PERMIT", "HAUL", "LENGTH", "SUM_FREQUENCY", "FREQ_YAGMH", 
    "EX_NUMBER","FREQ_YAGM", "FREQ_YG","FREQ_Y","YAGM_TNUM","YG_TNUM","Y_TNUM",
    "SNUM_YAGM","SNUM_YG","SNUM_YG","SNUM_Y","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]     

  y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4   ## weight of individual length sample for single fishery model
  y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3
  y3<-y3[WEIGHTX>0]                              ## exluding those lengths with zero weight due to lack of catch for that YAGM strata in the blend data 
   
 
  y3$HAUL_JOIN<-paste(y3$CRUISE,y3$PERMIT,y3$HAUL,sep="_")
  y3$STRATA<-paste(y3$AREA2,y3$MONTH_WED,y3$GEAR,sep="_")

  y3$STRATA1<-as.numeric(as.factor(y3$STRATA))
  y3$HAUL_JOIN1<-as.numeric(as.factor(y3$HAUL_JOIN))
 

  y4<-y3[FREQ_YAGM>30][,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata
  y4.1<-y3[FREQ_YAGM>30][,list(WEIGHT_GEAR=sum(WEIGHTX_GEAR)),by=c("LENGTH","GEAR","YEAR")]  ## setting minumal sample size to 30 lengths for Year, area, gear, month strata
  

  y5<-y4[,list(TWEIGHT=sum(WEIGHT)),by=c("YEAR")] 
  y5=merge(y4,y5)
  y5$FREQ<-y5$WEIGHT/y5$TWEIGHT
  y6<-y5[,-c("WEIGHT","TWEIGHT")]

  grid<-data.table(expand.grid(YEAR=unique(y5$YEAR),LENGTH=1:max(y5$LENGTH)))
  y7<-merge(grid,y6,all.x=TRUE,by=c("YEAR","LENGTH"))
  y7[is.na(FREQ)]$FREQ <-0

  y5.1<-y4.1[,list(TWEIGHT=sum(WEIGHT_GEAR)),by=c("GEAR","YEAR")] 
  y5.1=merge(y4.1,y5.1)
  y5.1$FREQ<-y5.1$WEIGHT_GEAR/y5.1$TWEIGHT
  y6.1<-y5.1[,-c("WEIGHT_GEAR","TWEIGHT")]

  grid<-data.table(expand.grid(YEAR=unique(y6.1$YEAR),GEAR=unique(y6.1$GEAR),LENGTH=1:max(y6.1$LENGTH)))
  y7.1<-merge(grid,y6.1,all.x=TRUE,by=c("YEAR","GEAR","LENGTH"))
  y7.1[is.na(FREQ)]$FREQ <-0


  ## everything after this is exploratory for input sample sizes

   y3.1<- y3[,c("YEAR","HAUL_JOIN1","STRATA1","LENGTH", "SUM_FREQUENCY", "FREQ_YAGMH", 
    "EX_NUMBER","FREQ_YAGM", "FREQ_YG","FREQ_Y","YAGM_TNUM","YG_TNUM","Y_TNUM",
    "SNUM_YAGM","SNUM_YG","SNUM_Y")] 

    y3.1<-y3.1[FREQ_YAGM>30] 

  require(vcdExtra)
  require(misty)

  years<-unique(y3.1$YEAR)

  ESS<-vector("list",length=length(years))

  for(i in 1:length(years)){
 	 data<-y3.1[YEAR==years[i]]
   N = sum(data$SUM_FREQUENCY)
   H = length(unique(data$HAUL_JOIN1))
   S = length(unique(data$STRATA1))
   Liu_ESS = H

   if(ICC){ 
 	   d_EXP<-expand.dft(data, freq="SUM_FREQUENCY")
  	  strata=unique(d_EXP$STRATA1)
    	ICC_STRATA<-vector("list",length=length(strata))
  
 	   for(k in 1:length(strata)){
    	  ICC_STRATA[[k]] <- 0
    	  if(length(unique(d_EXP[STRATA1==strata[k]]$HAUL_JOIN1))>1){
     	  ICC_STRATA[[k]]<-multilevel.icc(d_EXP[STRATA1==strata[k]]$LENGTH,cluster=d_EXP[STRATA1==strata[k]]$HAUL_JOIN1,method="lme4")}
 	    }
  
     ICC_STRATA <- data.table(STRATA1=strata,ICC=do.call(rbind,ICC_STRATA)[,1])

     WEIGHT=d_EXP[,list(STons=max(YAGM_TNUM),TSample=max(SNUM_Y),SSample=max(SNUM_YAGM),M=mean(FREQ_YAGM)),by="STRATA1"]
     WEIGHT$TTons=sum(WEIGHT$STons)
     WEIGHT=merge(ICC_STRATA,WEIGHT,by="STRATA1")

     WEIGHT$TWEIGHT<-(((WEIGHT$STons/WEIGHT$TTons)^2)*(WEIGHT$TSample/WEIGHT$SSample))*(1+WEIGHT$ICC*(WEIGHT$M-1))

     Liu_ESS=N/sum(WEIGHT$TWEIGHT)
    }
     
     ESS[[i]] <-data.table(YEAR=years[i],ESS=Liu_ESS,NSAMP=N,NHAUL=H,NSTRATA=S)
     print(years[i])
    }


y3.2<- y3[,c("YEAR","GEAR","HAUL_JOIN1","STRATA1","LENGTH", "SUM_FREQUENCY", "FREQ_YAGMH", 
    "EX_NUMBER","FREQ_YAGM", "FREQ_YG","YAGM_TNUM","YG_TNUM","SNUM_YAGM","SNUM_YG")] 

    y3.2<-y3.2[FREQ_YAGM>30] 

  years<-unique(y3.2$YEAR)
  gear=unique(y3.2$GEAR)

  b=1
  ESS.1<-vector("list",length=length(years)*length(gear))
  for(j in 1:length(gear)){ 
    for(i in 1:length(years)){
  
       data<-y3.2[YEAR==years[i]&GEAR==gear[[j]]]

       N = sum(data$SUM_FREQUENCY)
       H = length(unique(data$HAUL_JOIN1))
       S = length(unique(data$STRATA1))
       Liu_ESS = H

       if(ICC){

         d_EXP<-expand.dft(data, freq="SUM_FREQUENCY")
         strata=unique(d_EXP$STRATA1)
         ICC_STRATA<-vector("list",length=length(strata))
  
         for(k in 1:length(strata)){
            ICC_STRATA[[k]] <- 0
            if(length(unique(d_EXP[STRATA1==strata[k]]$HAUL_JOIN1))>1){
            ICC_STRATA[[k]]<-multilevel.icc(d_EXP[STRATA1==strata[k]]$LENGTH,cluster=d_EXP[STRATA1==strata[k]]$HAUL_JOIN1,method="lme4")}
           }
         ICC_STRATA <- data.table(STRATA1=strata,ICC=do.call(rbind,ICC_STRATA)[,1])
         WEIGHT=d_EXP[,list(STons=max(YAGM_TNUM),TSample=max(SNUM_YG),SSample=max(SNUM_YAGM),M=mean(FREQ_YAGM)),by="STRATA1"]
         WEIGHT$TTons=sum(WEIGHT$STons)
         WEIGHT=merge(ICC_STRATA,WEIGHT,by="STRATA1")
         WEIGHT$TWEIGHT<-(((WEIGHT$STons/WEIGHT$TTons)^2)*(WEIGHT$TSample/WEIGHT$SSample))*(1+WEIGHT$ICC*(WEIGHT$M-1))
         Liu_ESS=N/sum(WEIGHT$TWEIGHT)
         }

       ESS.1[[b]] <-data.table(YEAR=years[i],GEAR=gear[[j]],ESS=Liu_ESS,NSAMP=N,NHAUL=H,NSTRATA=S)
       b <- b+1
       print(paste0(gear[[j]]," in ",years[i]))
      }
     }


  ESS=do.call(rbind, ESS)
  ESS.1=do.call(rbind, ESS.1)
  LF1<-merge(y7,ESS,by="YEAR")
  LF1.1<-merge(y7.1,ESS.1,by=c("YEAR","GEAR"))
  LF1.1<-LF1.1[NSAMP>0]
  LF<-list(LF1,LF1.1)
}

