# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

# this function gets data for one region at a time

#                              new_data           = new_data
#                              new_file           = new_SS_dat_filename
#                              new_year           = new_SS_dat_year
#                              sp_area            = sp_area
#                              fsh_sp_label       = fsh_sp_label
#                              fsh_sp_area        = fsh_sp_area
#                              fsh_sp_str         = fsh_sp_str
#                             fsh_start_yr       = fsh_start_yr
#                              srv_sp_str         = srv_sp_str
#                              srv_start_yr       = srv_start_yr
#                              len_bins           = len_bins
#                              max_age            = max_age
#                              is_new_SS_DAT_file = is_new_SS_DAT_file
#             		             AUXFCOMP           = 1
#                              ONE_FLEET          =TRUE
#                              VAST               =TRUE
#                              LL_DAT             =FALSE
#                              ICC_T              =FALSE



SBSS_GET_ALL_DATA <- function(new_data     = new_data,
                              new_file     = "blarYYYY.dat",
                              new_year     = 9999,
                              sp_area      = "'foo'",
                              fsh_sp_label = "'foo'",
                              fsh_sp_area  = "'foo'",
                              fsh_sp_str   = "999",
                              fsh_start_yr = 1977,
                              srv_sp_str   = "99999",
                              srv_start_yr = 1977,
                              new_SS_dat_year= new_SS_dat_year,
                              len_bins     = seq(4,109,3),
                              max_age      = 20,
                              is_new_SS_DAT_file = FALSE,
                              AUXFCOMP           = 1,
			      ONE_FLEET= FALSE,
                              VAST=TRUE,
                              LL_DAT=FALSE,
                              ICC_T=FALSE)
{

  new_data$sourcefile <- new_file

## ----- get REGION catch -----

  CATCH<- GET_CATCH(fsh_sp_area=fsh_sp_area ,fsh_sp_label=fsh_sp_label,final_year=final_year,ADD_OLD_FILE=TRUE,OLD_FILE=OLD_SEAS_GEAR_CATCH)

 
## check that all gears have the same number of years covered; add zeros if necessary
  c_y <- sort(unique(CATCH[[2]]$YEAR))

  grid<-expand.grid(YEAR=c(min(c_y):max(c_y)))
  CATCH<-data.table(merge(CATCH[[2]],grid,all=T))
  CATCH$TONS[is.na(CATCH$TONS)]<-0.0

## For 2021 base models only a single fleet is used
  if(ONE_FLEET){
    CATCH<-CATCH[,list(TONS=sum(TONS)),by="YEAR"]
    CATCH <- CATCH[order(CATCH$YEAR),]
    CATCH$fleet= 1

	catch<-data.frame(year=CATCH$YEAR,seas=1,fleet=CATCH$fleet,catch=CATCH$TONS,catch_se=0.01)
	x<- data.frame(year=-999,seas=1,fleet=1,catch=42500,catch_se= 0.01)

	#x2<-data.frame(year=-9999,seas=0,fleet=0,catch=0,catch_se=0)

	catch<-rbind(x,catch)
	catch<-catch[order(catch$fleet,catch$year),]
   }



  if(!ONE_FLEET){ 
  	CATCH[GEAR=="OTHER"]$GEAR<-"LONGLINE"
	CATCH<-CATCH[,list(TONS=sum(TONS)),by=c("GEAR","YEAR")]
  	CATCH$fleet= 1
  	CATCH[GEAR=="LONGLINE"]$fleet<- 2
  	CATCH[GEAR=="POT"]$fleet<- 3
  	CATCH<-CATCH[order(fleet,YEAR),]

	catch<-data.frame(year=CATCH$YEAR,seas=1,fleet=CATCH$fleet,catch=CATCH$TONS,catch_se=0.01)

	x<- data.frame(year=c(-999,-999,-999),seas=c(1,1,1),fleet=c(1,2,3),catch=c(0,0,0),catch_se=rep(0.05,3))

	#x2<-data.frame(year=-9999,seas=0,fleet=0,catch=0,catch_se=0)

	catch<-rbind(x,catch)
	catch<-catch[order(catch$fleet,catch$year),]
   }

## write catch data into new data files
  new_data$N_catch<-nrow(catch)
  new_data$catch<-catch


## ----- Get survey shelf biomass estimates -----
  if(!VAST){
    BS_BIOM <- GET_BS_BIOM(srv_sp_str)

    if(ONE_FLEET){ BS_BIOM$index <-2 
       }else{BS_BIOM$index <-4}
    
    BIOM <- rbind(BS_BIOM)
    
    BIOM$CV <- sqrt(BIOM$POPVAR)/BIOM$POP
    BIOM$se_log <- sqrt(log(1.0 + (BIOM$CV^2)))
  }

 if(VAST){
    VAST_abundance<-data.table(VAST_abundance)[Fleet=="Both"]
    BIOM<-VAST_abundance
    if(ONE_FLEET){ BIOM$index <-2 
       }else{BIOM$index<- 4}

    names(BIOM)<-c("YEAR","Unit","Fleet","BIOM","se_log","SD_mt","index")
   }

  BIOM[YEAR==2020]$index<-BIOM[YEAR==2020]$index*-1
  CPUE<-data.frame(year=BIOM$YEAR,seas=7,index=BIOM$index,obs=BIOM$BIOM,se_log=BIOM$se_log)


## pulling in LL survey RPN data from AKFIN.
  if(LL_DAT){ 
   LL_RPN<-data.table(GET_BS_LL_RPN(species=srv_sp_str,FYR=LLsrv_start_yr ))
   LL_RPN<-LL_RPN[year>=LLsrv_start_yr]
   gridc<-expand.grid(year=min(LL_RPN$year):max(LL_RPN$year))
   LL_RPN<-merge(LL_RPN,gridc,by="year",all=T)
   LL_RPN[is.na(LL_RPN)]<- 1

   if(ONE_FLEET){ind<-3}else{ind<-5}
   LL_CPUE<-data.table(year=LL_RPN$year,seas=7,index=ind,obs=LL_RPN$rpn,se_log=LL_RPN$se/LL_RPN$rpn)
   LL_CPUE[obs==1]$index<-LL_CPUE[obs==1]$index*-1
   CPUE<-rbind(CPUE,LL_CPUE)
  }


## write to new data file
  new_data$N_cpue<-nrow(CPUE)
  new_data$CPUE<-CPUE

## ----- get size composition data -----
 
## BS bottom trawl survey size comp
  if(ONE_FLEET){flt <- 2}else{flt <- 4}
  SRV_LCOMP_SS <- data.frame(GET_BS_LCOMP1(species=srv_sp_str,bins=len_bins,bin=TRUE,SS=TRUE,seas=7,flt=flt,gender=0,part=0))
  names(SRV_LCOMP_SS) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)
 
## ----- Get Fishery catch at size composition data -----
  DOM_FSH_LCOMP <- LENGTH_BY_CATCH_ICC_BS(fsh_sp_str=fsh_sp_str ,fsh_sp_label=fsh_sp_label, ly=final_year,ICC=ICC_T)
  FOR_FSH_LCOMP  <- LENGTH_BY_CATCH_ICC_BS_FOREIGN(fsh_sp_str=202, foriegn_sp_label = for_sp_label, ly=final_year,ICC=ICC_T)
  
  if(ONE_FLEET){
    FSH_LCOMP<-rbind(FOR_FSH_LCOMP[[1]],DOM_FSH_LCOMP[[1]])
    Nsamp<-FSH_LCOMP[,list(nsamp=max(NHAUL)),by="YEAR"]

    lcomp<-BIN_LEN_DATA(data=FSH_LCOMP,len_bins=len_bins)
    lcomp<-aggregate(list(TOTAL=lcomp$FREQ),by=list(BIN=lcomp$BIN,YEAR=lcomp$YEAR),FUN=sum)

    N_TOTAL <- aggregate(list(T_NUMBER=lcomp$TOTAL),by=list(YEAR=lcomp$YEAR),FUN=sum)
    lcomp <- merge(lcomp,N_TOTAL)
    lcomp$TOTAL <- lcomp$TOTAL / lcomp$T_NUMBER

    years<-unique(lcomp$YEAR)

    nbin=length(len_bins)

    nyr<-length(years)

    x<-matrix(ncol=((nbin)+6),nrow=nyr)
    x[,2]<-1
    x[,3]<-1
    x[,4]<-0
    x[,5]<-0
    x[,6]<-round(Nsamp$nsamp/(mean(Nsamp$nsamp)/mean(SRV_LCOMP_SS$Nsamp)))  ## scale number of hauls to survey number of stations...

    for(i in 1:nyr)
        {
            x[i,1]<-years[i]
            x[i,7:(nbin+6)]<-lcomp$TOTAL[lcomp$YEAR==years[i]]
        }
        FISHLCOMP<-data.frame(x)

      names(FISHLCOMP) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)
   }

  if(!ONE_FLEET){ 
    FSH_LCOMP<-rbind(FOR_FSH_LCOMP[[2]],DOM_FSH_LCOMP[[2]])
    Nsamp<-FSH_LCOMP[,list(nsamp=max(NHAUL)),by=c("GEAR","YEAR")]

    lcomp<-BIN_LEN_DATA(data=FSH_LCOMP,len_bins=len_bins)

    lcomp<-aggregate(list(TOTAL=lcomp$FREQ),by=list(BIN=lcomp$BIN,GEAR=lcomp$GEAR,YEAR=lcomp$YEAR),FUN=sum)

    N_TOTAL <- aggregate(list(T_NUMBER=lcomp$TOTAL),by=list(GEAR=lcomp$GEAR,YEAR=lcomp$YEAR),FUN=sum)

    lcomp <- data.table(merge(lcomp,N_TOTAL))
    lcomp$TOTAL <- lcomp$TOTAL / lcomp$T_NUMBER

    lcomp$GEAR1<-1
    lcomp[GEAR=='HAL']$GEAR1<-2
    lcomp[GEAR=='POT']$GEAR1<-3

    Nsamp$GEAR1<-1
    Nsamp[GEAR=='HAL']$GEAR1<-2
    Nsamp[GEAR=='POT']$GEAR1<-3  

   
      gear  <- unique(lcomp$GEAR1)
      nbin  <- length(len_bins)
      ngear <- length(gear)

      y <- vector("list")
      
      for(j in 1:3){
        lcomp1<-lcomp[GEAR1==j]
        years <- unique(lcomp1$YEAR)
        nyr   <- length(years)

        x<-matrix(ncol=((nbin)+6),nrow=nyr)
        x[,2]<-1
        x[,4]<-0
        x[,5]<-0
        x[,6]<-round(Nsamp[GEAR1==j]$nsamp/(mean(Nsamp[GEAR1==j]$nsamp)/mean(SRV_LCOMP_SS$Nsamp)))  ## scale number of hauls to survey number of stations...

        for(i in 1:nyr)
          {
            x[i,1]<-years[i]
            x[i,3]<-j
            x[i,7:(nbin+6)]<-lcomp1$TOTAL[lcomp1$YEAR==years[i]]
          }
         y[[j]]<-x
     }
      y=do.call(rbind,y)  
      FISHLCOMP<-data.frame(y)
      names(FISHLCOMP) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)
  }

  print("Fisheries LCOMP done")
       
## combine all the length comp data
  LCOMP<-rbind(FISHLCOMP,SRV_LCOMP_SS)

## pulling in longline survey length composition data from Dana's csv files 
  if(LL_DAT){  
    LL_length<-GET_BS_LL_LENGTH(species=srv_sp_str,FYR=LLsrv_start_yr)
  
    names(LL_length)<-c("year","length","FREQ")

    LL_LENGTHY <- LL_length[,list(TOT=sum(FREQ)),by="year"]
    LL_LENGTH  <- merge(LL_length,LL_LENGTHY,by="year")
    LL_LENGTH$PROP <- LL_LENGTH$FREQ/LL_LENGTH$TOT

    grid <- expand.grid(year=sort(unique(LL_LENGTH$year)),length=seq(0,116,by=1))
    LL_LENGTHG <- merge(LL_LENGTH,grid,by=c("year","length"),all=T)
    LL_LENGTHG$PROP[is.na(LL_LENGTHG$PROP)] <- 0

    SS3_LLL <- reshape2::dcast(LL_LENGTHG,formula=year~length,value.var="PROP")

    if(ONE_FLEET){flt<-3}else{flt=5}

    LL_LENGTH<-data.frame(Year=SS3_LLL$year,Seas=7,FltSrv=flt,Gender=0,part=0,Nsamp=32)  ## need to look at the sample size. Currently set at number of stations
    LL_LENGTH<-cbind(LL_LENGTH,SS3_LLL[2:ncol(SS3_LLL)])
   names(LL_LENGTH) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)

    LCOMP<-rbind(LCOMP,LL_LENGTH)

  }

#LCOMP[7:ncol(LCOMP),]<- round(LCOMP[7:ncol(LCOMP),],5)


## write into SS3 files
  new_data$lencomp<-LCOMP
  new_data$N_lencomp<-nrow(LCOMP)

  print("All LCOMP done")


## get age comp
    if(!VAST){
      print("Sorry at this point you need to use VAST estimates")

#      BS_ACOMP<-GET_BS_ACOMP1(srv_sp_str=srv_sp_str, max_age=max_age,Seas=7,FLT=-4,Gender=0,Part=0,Ageerr=1,Lgin_lo=-1,Lgin_hi=-1,Nsamp=100)
#      if(ONE_FLEET){BS_ACOMP$FLT <- -2}
#      print("Survey agecomp done")

#      BS_ACOMPF<-LENGTH4AGE_BY_CATCH_BS(fsh_sp_str=202 ,fsh_sp_label = "'PCOD'",sy=fsh_age_start_yr,ly=new_year, STATE=1, max_age=max_age)

      ## Note that these aren't used in the current model so are turned off here...
#      BS_ACOMPF$FltSrv<-AI_ACOMPF$FltSrv*-1 

#      names(BS_ACOMPF)<-names(BS_ACOMP)
#     print("Fisheries agecomp done")
    
      

#      cond_age_length<-data.frame(cond_length_age_cor(max_age1=max_age)$norm)
#      names(cond_age_length)<-names(BS_ACOMP)
#      print("Conditional survey age length done")      

#      cond_age_lengthFISH<-data.frame(cond_length_age_corFISH(max_age1=max_age)$norm)
      
  ## negating the older fish ages from the file
#      cond_age_lengthFISH<-data.table(cond_age_lengthFISH)

#      cond_age_lengthFISH[X1<2007]$X3 = cond_age_lengthFISH[X1<2007]$X3 * -1
#      cond_age_lengthFISH<-data.frame(cond_age_lengthFISH)
#      names(cond_age_lengthFISH)<-names(BS_ACOMP)
#      print("Conditional fisheries age length done")     
      
#      ACOMP<-rbind(BS_ACOMPF,BS_ACOMP,cond_age_lengthFISH,cond_age_length)
#      ACOMP[10:ncol(ACOMP),]<- round(ACOMP[10:ncol(ACOMP),],5)
     }

  if(VAST){
     agecompV <- data.table(VAST_AGECOMP)[Region=='Both']
     years=unique(agecompV$Year)
     ACOMP<-data.frame(YEAR=agecompV$Year,month=7,fleet=2,sex=0,part=0,ageerr=1,lbin_lo=1,lbin_hi=120,Nsamp=data.table(SRV_LCOMP_SS)[Year%in%years]$Nsamp,agecompV[,c(2:14)])
     new_data$agebin_vector<-c(0:12)
     }

      new_data$agecomp<-ACOMP
      new_data$N_agecomp<-nrow(ACOMP)

      ## Get all survey Age Data

      Age_w<-GET_SURV_AGE_cor(sp_area=fsh_sp_area,srv_sp_str=srv_sp_str,start_yr=srv_start_yr,max_age=max_age)
      print("GET_SURV_AGE done")

      if(ONE_FLEET){
          Age_w$Sur <- 2
         }else{Age_w$Sur <- 4}      
      
      
## format survey mean size-at-age data for SS3
 if(ONE_FLEET){
          Sur <- 2
         }else{Sur <- 4} 

  AGE_LENGTH_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w,max_age=max_age,type="L",seas=7,flt=-Sur,gender=0,part=0))
  
  if (is_new_SS_DAT_file)
  {
      names(AGE_LENGTH_SS) <- c("Year","Seas","FltSrv","Gender","Part","Ageerr","Ignore",rep(seq(1,max_age,1),2))
  } else
  {
      names(AGE_LENGTH_SS) <- names(old_data$MeanSize_at_Age_obs)
  }

## write size at age to new data file
  new_data$MeanSize_at_Age_obs<-AGE_LENGTH_SS
  new_data$N_MeanSize_at_Age_obs<-nrow(AGE_LENGTH_SS)


## Environmental data for length weight 
  len_weight<-get_lengthweight(species=fsh_sp_str,area='EBS',K=7,Alpha_series=2,Beta_series=3)

  en1<-data.table(YEAR=1976,SERIES=1,VALUE=1)

  new_data$envdat<-data.frame(rbind(en1,len_weight))

  print("Length_weights are finished")


## format survey mean weight-at-age data for SS3
  AGE_WEIGHT_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w[!is.na(WEIGHT)&!is.na(AGE)],max_age=max_age,type="W",seas=1,gender=3,growpattern=1,birthseas=1,flt=-2))
print("Formatting AGE Means done")
  # Fleet = -1 indicates that this is the population weight-at-age in the middle of the season
 #AGE_WEIGHT_SS<-data.frame(FORMAT_AGE_WEIGHT(data=AGE_WEIGHT,seas=1,gender=3,growpattern=1,birthseas=1,flt=-1))
  names(AGE_WEIGHT_SS) <- c("#Year","Seas","Gender","GrowPattern","Birthseas","Fleet",seq(1,max_age,1))

# write out empirical/survey mean weight-at-age data to file wtatage.ss
waa.ss <- file("wtatage.ss","w")
write(paste(nrow(AGE_WEIGHT_SS)," #N rows"),file=waa.ss,append=TRUE)
write(paste(max_age," #N ages"),file=waa.ss,append=TRUE)
write(paste0(names(AGE_WEIGHT_SS),collapse=" "),file=waa.ss,append=TRUE)
write(t(AGE_WEIGHT_SS),file=waa.ss,ncolumns=ncol(AGE_WEIGHT_SS),append=TRUE)
close(waa.ss)


## fill in a bunch of stuff in the new_data structure
  if (is_new_SS_DAT_file)
  {

  } else
  {            
        new_data$agebin_vector = seq(1,(max_age),1)
      	error<-matrix(ncol=(max_age+1),nrow=2)
	error[1,]<-rep(-1,max_age+1)
	error[2,]<-rep(-0.001,max_age+1)
	#error[3,]<-seq(0.5,(max_age+0.5),by=1)
        #error[4,]<-c( 0.096, 0.210583, 0.325167, 0.43975, 0.554333, 0.668917, 0.7835, 0.898083, 1.01267, 1.12725, 1.471)

	#error[4,]<-c( 0.096, 0.210583, 0.325167, 0.43975, 0.554333, 0.668917, 0.7835, 0.898083, 1.01267, 1.12725, 1.24183, 1.35642, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471)
	new_data$ageerror<-data.frame(error)
  }

  new_data
}