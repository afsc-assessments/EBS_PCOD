
## Function to pull and process length composition data for the foreign observer fisheries data. 
## This is for a single fishery model as per the 2021 production model
## This function proportions the lengths to the catch from the haul level extrapolated 
## number from the species composition data and to the total catch for the area, gear,
## and month by the blend catch information.  There are a number of sample size measures attempted, 
## but none used except the number of hauls, these are then reduced to average to the averagenumber of stations
## from the bottom trawl survey data.  
## ICC is only exploratory and uses the intra-correlation coeffient to calculate input sample size if marked FALSE it is not calculated.
## Exports length compostitions for both single combined fishery and POT, Longline, Trawl fishery category in the output.
##  FLENGTH<-LENGTH_BY_CATCH_ICC_BS_FOREIGN()
## FLENGTH[[1]] would be the combined fishery length comps and FLENGTH[[2]] would be separate 

LENGTH_BY_CATCH_ICC_BS_FOREIGN<-function(fsh_sp_str=202 ,foriegn_sp_label = "'PACIFIC COD'",ly=new_year,ICC=FALSE){
  require(RODBC)
  require(data.table)
  require(reshape2)
  require(rgdal)
  require(dplyr)
  require(lubridate)


  fspcomp<-paste0("SELECT
    	norpac.foreign_length.size_group AS LENGTH,
    	SUM(norpac.foreign_length.frequency) AS sum_frequency,
    	norpac.foreign_length.cruise,
    	norpac.foreign_length.vessel,
    	norpac.foreign_length.year,
    	norpac.foreign_length.dt AS HDAY,
    	norpac.foreign_length.haul as HN,
    	norpac.foreign_length.species,
    	norpac.foreign_haul.generic_area,
    	norpac.foreign_fishing_operation.vessel_type_code,
    	norpac.foreign_vessel_type.vessel_type_definition,
    	norpac.foreign_spcomp.species_haul_number as numb,
    	norpac.foreign_spcomp.species_haul_weight as extrapolated_weight,
    	norpac.foreign_haul.haul_join as HAUL
	FROM
    	norpac.foreign_length
    	INNER JOIN norpac.foreign_haul ON norpac.foreign_haul.cruise = norpac.foreign_length.cruise
                                      AND norpac.foreign_haul.vessel = norpac.foreign_length.vessel
                                      AND norpac.foreign_haul.year = norpac.foreign_length.year
                                      AND norpac.foreign_haul.haul = norpac.foreign_length.haul
                                      AND norpac.foreign_length.haul_join = norpac.foreign_haul.haul_join
    	INNER JOIN norpac.foreign_fishing_operation ON norpac.foreign_fishing_operation.cruise = norpac.foreign_haul.cruise
                                                   AND norpac.foreign_fishing_operation.vessel = norpac.foreign_haul.vessel
    	INNER JOIN norpac.foreign_vessel_type ON norpac.foreign_fishing_operation.vessel_type_code = norpac.foreign_vessel_type.vessel_type_code
    	INNER JOIN norpac.foreign_spcomp ON norpac.foreign_length.cruise = norpac.foreign_spcomp.cruise
                                        AND norpac.foreign_length.vessel = norpac.foreign_spcomp.vessel
                                        AND norpac.foreign_length.haul = norpac.foreign_spcomp.haul
                                        AND norpac.foreign_length.year = norpac.foreign_spcomp.year
                                        AND norpac.foreign_length.species = norpac.foreign_spcomp.species
                                        AND norpac.foreign_length.haul_join = norpac.foreign_spcomp.haul_join
	WHERE
   	 norpac.foreign_length.year > 1976
   	 AND norpac.foreign_length.species = ",fsh_sp_str,
   	 "AND norpac.foreign_haul.generic_area between 500 and 539
	GROUP BY
    	norpac.foreign_length.size_group,
    	norpac.foreign_length.cruise,
    	norpac.foreign_length.vessel,
    	norpac.foreign_length.year,
    	norpac.foreign_length.dt,
    	norpac.foreign_length.haul,
    	norpac.foreign_length.species,
    	norpac.foreign_haul.generic_area,
    	norpac.foreign_fishing_operation.vessel_type_code,
    	norpac.foreign_vessel_type.vessel_type_definition,
    	norpac.foreign_spcomp.species_haul_number,
    	norpac.foreign_spcomp.species_haul_weight,
    	norpac.foreign_haul.haul_join
	ORDER BY
    	norpac.foreign_length.dt,
    	norpac.foreign_length.haul,
    	norpac.foreign_length.size_group")

	Dspcomp=data.table(sqlQuery(AFSC,fspcomp))
	

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

   Dspcomp<-Dspcomp[YEAR<1991]

   Dspcomp<-Dspcomp[EXTRAPOLATED_WEIGHT>0]
   Dspcomp<-Dspcomp[NUMB>0]
  
   Dspcomp$AREA2<-trunc(Dspcomp$GENERIC_AREA/10)*10
   Dspcomp[AREA2==500]$AREA2<-510
  
   #Dspcomp[is.na(VES_AKR_ADFG)]$VES_AKR_ADFG<- Dspcomp[is.na(VES_AKR_ADFG)]$PERMIT
   #Dspcomp[is.na(PERMIT)]$PERMIT<- Dspcomp[is.na(PERMIT)]$VES_AKR_ADFG



    test=paste0("SELECT
    	norpac.foreign_blend.yr as YEAR,
    	norpac.foreign_blend.species_name,
    	SUM(norpac.foreign_blend.blend_tonnage) AS TONS,
    	norpac.foreign_blend.vessel_class,
    	norpac.foreign_blend.area_number,
    	norpac.foreign_blend.area_name,
    	norpac.foreign_blend.week_date
	FROM
   		norpac.foreign_blend
	WHERE
    	norpac.foreign_blend.species_name = ",foriegn_sp_label,
    	"AND norpac.foreign_blend.area_name LIKE '%BERING%'
	GROUP BY
    	norpac.foreign_blend.yr,
    	norpac.foreign_blend.species_name,
    	norpac.foreign_blend.vessel_class,
    	norpac.foreign_blend.area_number,
    	norpac.foreign_blend.area_name,
    	norpac.foreign_blend.week_date
	ORDER BY
    	norpac.foreign_blend.yr,
    	norpac.foreign_blend.vessel_class")

	CATCH<- data.table(sqlQuery(AFSC,test))
    CATCH$MONTH_WED<-month(CATCH$WEEK_DATE)
	

	CATCH<-CATCH[TONS>0]
	CATCH$AREA2<- 0
	CATCH[AREA_NUMBER>=500]$AREA2<- trunc(CATCH[AREA_NUMBER>=500]$AREA_NUMBER/10)*10
	CATCH[AREA_NUMBER<500]$AREA2<- CATCH[AREA_NUMBER<500]$AREA_NUMBER*10
	CATCH[AREA2==500]$AREA2<-510



#[1] "FREEZER MSHIP"    "LG TRAWLER"       "LONGLINER"        "SMALL TRAWL"      "SNAIL POT"        "SURIMI MSHIP"     "MED TRAWLER"      "JV MSHIP"         "LG FRZ TRAWL"     "LONGLINE COD"     "LONGLINE SAB"    
#[12] "SURIMI MSHIP1"    "SURIMI MSHIP2"    "SURIMI MSHIP3"    "SURIMI MSHIP4"    "SURIMI MSHIP5"    "SURIMI TRAWL"     "JV/LG FRZ TRAWL"  "JV/SURIMI TRAWL"  "OTHER FREEZER JV" "OTHER SURIMI JV"  "YELL/FLAT FRZ JV"
#[23] "YELL/FLAT SUR JV" "POLL-BOT FRZ JV"  "POLL-BOT SUR JV"  "POLL-MID FRZ JV"  "POLL-MID SUR JV" 

CATCH$GEAR='TRW'
CATCH[VESSEL_CLASS %like%"LONG"]$GEAR<-'HAL'
CATCH[VESSEL_CLASS %like%"POT"]$GEAR<-'HAL'


Dspcomp$GEAR<-'TRW'
Dspcomp[VESSEL_TYPE_DEFINITION%like%"Longline"]$GEAR<-'HAL'
Dspcomp[VESSEL_TYPE_DEFINITION%like%"Pot"]$GEAR<-'HAL'

Length<-Dspcomp
#Length$HAUL<-paste(yday(Length$HDAY),Length$HAUL,sep="_")

  x<-Length[,list(FREQ_YAGMH=sum(SUM_FREQUENCY),EX_NUMBER=max(NUMB),AVE_WEIGHT_1=max(EXTRAPOLATED_WEIGHT)/max(NUMB)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","VESSEL","HAUL")]
  x2<-x[,list(AVE_WEIGHT_YAGM=mean(AVE_WEIGHT_1)),by=c("AREA2","MONTH_WED","GEAR","YEAR")]
  x<-merge(x,x2,all.x=T,by=c("AREA2","MONTH_WED","GEAR","YEAR"))
  x<-merge(Length,x,all.x=T,by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","VESSEL","HAUL"))

  xt_YAGM<-CATCH[,list(YAGM_TONS=sum(TONS)),by=c("AREA2","GEAR","MONTH_WED","YEAR")]

  y<-merge(x,xt_YAGM,all=T,by=c("AREA2","MONTH_WED","GEAR","YEAR"))
  y2<-y[!is.na(YAGM_TONS)] ## lose 7311 length frequencies...

  y2$YAGM_TNUM<-(y2$YAGM_TONS*1000)/y2$AVE_WEIGHT_YAGM

  y3<-y2[,list(YAGM_TNUM=max(YAGM_TNUM),YAGM_TONS=max(YAGM_TONS)),by=c("AREA2","YEAR","MONTH_WED","GEAR")]
  y4<-y3[!is.na(YAGM_TNUM)][,list(YG_TNUM=sum(YAGM_TNUM)),by=c("GEAR","YEAR")]
  y5<-y3[!is.na(YAGM_TNUM)][,list(Y_TNUM=sum(YAGM_TNUM)),by=c("YEAR")]
 
  y2<-merge(y2,y4,by=c("GEAR","YEAR"))
  y2<-merge(y2,y5,by=c("YEAR"))

  y_AGM<-y2[!is.na(YAGM_TNUM) & !is.na(EX_NUMBER)]

  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","VESSEL","HAUL")]
  test_YAGM<-test[,list(SNUM_YAGM=sum(sample)),by=c("AREA2","MONTH_WED","GEAR","YEAR")]
  y2<-merge(y2,test_YAGM,all=T,by=c("AREA2","MONTH_WED","GEAR","YEAR"))

  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","VESSEL","HAUL")]
  test_YAG<-test[,list(SNUM_YAG=sum(sample)),by=c("AREA2","GEAR","YEAR")]
  y2<-merge(y2,test_YAG,all=T,by=c("AREA2","GEAR","YEAR"))


  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","VESSEL","HAUL")]
  test_YG<-test[,list(SNUM_YG=sum(sample)),by=c("GEAR","YEAR")]
  y2<-merge(y2,test_YG,all=T,by=c("GEAR","YEAR"))


  test<-y_AGM[,list(sample=max(EX_NUMBER),catch=max(YAGM_TNUM)),by=c("AREA2","MONTH_WED","GEAR","YEAR","CRUISE","VESSEL","HAUL")]
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

  y2$WEIGHT1<-y2$SUM_FREQUENCY/y2$FREQ_YAGMH
  y2$WEIGHT2<-y2$EX_NUMBER/y2$SNUM_YAGM
  y2$WEIGHT3<-y2$YAGM_TNUM/y2$YG_TNUM
  y2$WEIGHT4<-y2$YAGM_TNUM/y2$Y_TNUM

  y2[WEIGHT1=='NaN']$WEIGHT1<-0
  y2[WEIGHT2=='NaN']$WEIGHT2<-0

  y3<- y2[,c("YEAR","GEAR","AREA2","MONTH_WED","CRUISE",
    "VESSEL", "HAUL", "LENGTH", "SUM_FREQUENCY", "FREQ_YAGMH", 
    "EX_NUMBER","FREQ_YAGM", "FREQ_YG","FREQ_Y","YAGM_TNUM","YG_TNUM","Y_TNUM",
    "SNUM_YAGM","SNUM_YG","SNUM_YG","SNUM_Y","WEIGHT1","WEIGHT2","WEIGHT3","WEIGHT4")]     

  y3$WEIGHTX<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT4
  y3$WEIGHTX_GEAR<-y3$WEIGHT1*y3$WEIGHT2*y3$WEIGHT3
  y3<-y3[WEIGHTX>0]  
   
 
  y3$HAUL_JOIN<-paste(y3$CRUISE,y3$VESSEL,y3$HAUL,sep="_")
  y3$STRATA<-paste(y3$AREA2,y3$MONTH_WED,y3$GEAR,sep="_")

  y3$STRATA1<-as.numeric(as.factor(y3$STRATA))
  y3$HAUL_JOIN1<-as.numeric(as.factor(y3$HAUL_JOIN))
 

  y4<-y3[FREQ_YAGM>30][,list(WEIGHT=sum(WEIGHTX)),by=c("LENGTH","YEAR")]
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





  ## everything after this is exploratory and could be ignored...

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

