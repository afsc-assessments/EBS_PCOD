# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

# this function gets data for one region at a time


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
                              LL_DAT=FALSE,
                              ICC_T=FALSE)
{

  new_data$sourcefile <- new_file

## ----- get REGION catch -----

 catch= readLines('sql/dom_catch.sql')
 catch = sql_filter(sql_precode = "<=", x = final_year, sql_code = catch, flag = '-- insert year')
 catch = sql_filter(sql_precode = "IN", x = fsh_sp_label, sql_code = catch, flag = '-- insert species_catch')
 catch = sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = catch, flag = '-- insert subarea')
 
 
  CATCH=sql_run(akfin, catch) %>% 
         dplyr::rename_all(toupper)

  CATCH$GEAR1<-"TRAWL"
  CATCH$GEAR1[CATCH$GEAR=="POT"]<-"POT"
  CATCH$GEAR1[CATCH$GEAR=="HAL"]<-"LONGLINE"
  CATCH$GEAR1[CATCH$GEAR=="JIG"]<-"OTHER"
  CATCH_TOTAL<-aggregate(list(TONS=CATCH$TONS),by=list(YEAR=CATCH$YEAR,GEAR=CATCH$GEAR1),FUN=sum)

## Add the old catch (pre-1991) from csv file   
  if(exists("OLD_SEAS_GEAR_CATCH")){
        OLD_SEAS_GEAR_CATCH$GEAR1<-"TRAWL"
        OLD_SEAS_GEAR_CATCH$GEAR1[OLD_SEAS_GEAR_CATCH$GEAR=="POT"]<-"POT"
        OLD_SEAS_GEAR_CATCH$GEAR1[OLD_SEAS_GEAR_CATCH$GEAR=="LONGLINE"]<-"LONGLINE"
        OLD_SEAS_GEAR_CATCH$GEAR1[OLD_SEAS_GEAR_CATCH$GEAR=="OTHER"]<-"LONGLINE"
        OLD_GEAR_CATCH<-aggregate(list(TONS=OLD_SEAS_GEAR_CATCH$TONS),by=list(YEAR=OLD_SEAS_GEAR_CATCH$YEAR,GEAR=OLD_SEAS_GEAR_CATCH$GEAR1),FUN=sum)
        CATCH<-rbind(OLD_GEAR_CATCH,CATCH_TOTAL)
        CATCH<-CATCH[order(CATCH$GEAR,CATCH$YEAR),]
    }else{
          print("Warning: No old catch information provided")
          CATCH<-CATCH_TOTAL
         }

## check that all gears have the same number of years covered; add zeros if necessary
  c_y <- sort(unique(CATCH$YEAR))

  grid<-expand.grid(YEAR=c(min(c_y):max(c_y)))
  CATCH<-data.table(merge(CATCH,grid,all=T))
  CATCH$TONS[is.na(CATCH$TONS)]<-0.0

## For 2021 base models only a single fleet is used
  if(ONE_FLEET){
    CATCH<-CATCH[,list(TONS=sum(TONS)),by="YEAR"]
    CATCH <- CATCH[order(CATCH$YEAR),]
    CATCH$fleet= 1
    catch<-data.frame(year=CATCH$YEAR,seas=1,fleet=CATCH$fleet,catch=CATCH$TONS,catch_se=0.01)
    x<- data.frame(year=-999,seas=1,fleet=1,catch=42500,catch_se= 0.01)
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
     catch<-rbind(x,catch)
     catch<-catch[order(catch$fleet,catch$year),]
   }

## write catch data into new data files
  new_data$N_catch<-nrow(catch)
  new_data$catch<-catch


## ----- Get survey shelf biomass estimates -----

    VAST_abundance<-data.table(VAST_abundance)[Fleet=="Both"]
    BIOM<-VAST_abundance
    if(ONE_FLEET){ BIOM$index <-2 
       }else{BIOM$index<- 4}

    names(BIOM)<-c("YEAR","Unit","Fleet","BIOM","se_log","SD_mt","index")

  BIOM[YEAR==2020]$index<-BIOM[YEAR==2020]$index*-1
  CPUE<-data.frame(year=BIOM$YEAR,seas=7,index=BIOM$index,obs=BIOM$BIOM,se_log=BIOM$se_log)


## pulling in LL survey RPN data from AKFIN.
  if(LL_DAT){ 

        bsrpn = readLines('sql/LL_RPN.sql')
 	bsrpn = sql_filter(sql_precode = "<=", x = ly, sql_code = bsrpn, flag = '-- insert year')
 	bsrpn = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = bsrpn, flag = '-- insert species')
 	bsrpn = sql_filter(sql_precode = "IN", x = sp_area, sql_code = bsrpn, flag = '-- insert area')
 	bsrpn = sql_filter(sql_precode = "IN", x = LL_sp_region, sql_code = bsrpn, flag = '-- insert region')

	LL_RPN=sql_run(akfin, bsrpn) %>% 
         	dplyr::rename_all(tolower) %>% 
       	        group_by(year) %>% 
       	        summarize(rpn = sum(rpn, na.rm = TRUE),
                 se = sqrt(sum(rpn_var, na.rm = TRUE)))%>%
                data.table()
     	

     
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
    
  FISHLCOMP<-LENGTH_BY_CATCH_short(species=fsh_sp_str ,species_catch=fsh_sp_label, for_species_catch=for_sp_label,sp_area=fsh_sp_area ,ly=final_year, SEX=FALSE, PORT=TRUE)

  if(ONE_FLEET){

    FSH_LCOMP<-FISHLCOMP[[1]]
    Nsamp<-FSH_LCOMP[,list(nsamp=max(NHAUL)),by=c("YEAR")]

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
    FSH_LCOMP<-FISHLCOMP[[2]]
    
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
        x[,6]<-Nsamp[GEAR1==j]$nsamp
           
##/(mean(Nsamp[GEAR1==j]$nsamp)/mean(SRV_LCOMP_SS$Nsamp)))  ## scale number of hauls to survey number of stations...

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

        bsll = readLines('sql/LL_LENGTH.sql')
 	bsll = sql_filter(sql_precode = "<=", x = ly, sql_code = bsll, flag = '-- insert year')
 	bsll = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = bsll, flag = '-- insert species')
 	bsll = sql_filter(sql_precode = "IN", x = LL_sp_region, sql_code = bsll, flag = '-- insert region')

	lens=sql_run(akfin, bsll) %>% rename_all(tolower)

        bsllav = readLines('sql/LL_AREA_VIEW.sql')
 	
        areaview <- sql_run(akfin, bsllav) %>% rename_all(tolower)

     lens <- lens %>% 
          left_join(areaview, by = c("area_code", "geographic_area_name", "council_sablefish_management_area"))

     lens <- lens %>% filter(exploitable == 1)

     # RPN-weighted lengths in the EBS

     LL_length <- lens %>% 
       group_by(year, length)%>% 
       summarize(rpn = sum(rpn))%>%data.table()

   
    names(LL_length)<-c("year","length","FREQ")

    LL_LENGTHY <- LL_length[,list(TOT=sum(FREQ)),by="year"]
    LL_LENGTH  <- merge(LL_length,LL_LENGTHY,by="year")
    LL_LENGTH$PROP <- LL_LENGTH$FREQ/LL_LENGTH$TOT

    grid <- expand.grid(year=sort(unique(LL_LENGTH$year)),length=seq(0,116,by=1))
    LL_LENGTHG <- merge(LL_LENGTH,grid,by=c("year","length"),all=T)
    LL_LENGTHG$PROP[is.na(LL_LENGTHG$PROP)] <- 0

    SS3_LLL <- reshape2::dcast(LL_LENGTHG,formula=year~length,value.var="PROP")

    if(ONE_FLEET){flt<- -3}else{flt= -5}

    LL_LENGTH<-data.frame(Year=SS3_LLL$year,Seas=7,FltSrv=flt,Gender=0,part=0,Nsamp=32)  ## need to look at the sample size. Currently set at number of stations
    LL_LENGTH<-cbind(LL_LENGTH,SS3_LLL[2:ncol(SS3_LLL)])
   names(LL_LENGTH) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)

    LCOMP<-rbind(LCOMP,LL_LENGTH)

  }

## write into SS3 files
  new_data$lencomp<-LCOMP
  new_data$N_lencomp<-nrow(LCOMP)

  print("All LCOMP done")

## get age comp
 #   if(!VAST){
 #     print("Sorry at this point you need to use VAST estimates")
 #    }

#  if(VAST){
     agecompV <- data.table(VAST_AGECOMP)[Region=='Both'&Year!=2020]
     years=unique(agecompV$Year)
     ACOMP<-data.frame(YEAR=agecompV$Year,month=7,fleet=2,sex=0,part=0,ageerr=1,lbin_lo=1,lbin_hi=120,Nsamp=data.table(SRV_LCOMP_SS)[Year%in%years]$Nsamp,agecompV[,c(2:14)])
     new_data$agebin_vector<-c(0:12)
#   }

      new_data$agecomp<-ACOMP
      new_data$N_agecomp<-nrow(ACOMP)

      ## Get all survey Age Data
     
    if(fsh_sp_area=='GOA'){ survey<- 47
     } else if(fsh_sp_area=='BS'){ survey<- 98
       } else if(fsh_sp_area=='AI'){ survey<- 52
         } else if(fsh_sp_area=='SLOPE'){ survey<- 78
           } else { stop("Not a valid survey")}
    
        bsage = readLines('sql/survey_age.sql')
 	bsage = sql_filter(sql_precode = "<=", x = new_year, sql_code = bsage, flag = '-- insert year')
 	bsage = sql_filter(sql_precode = "IN", x = survey, sql_code = bsage, flag = '-- insert survey')
        bsage = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = bsage, flag = '-- insert species')

	Age_w <- sql_run(afsc, bsage) %>% rename_all(toupper)
        Age_w$AGE1<-Age_w$AGE
        Age_w$AGE1[Age_w$AGE >= max_age]=max_age


      print("GET_SURV_AGE done")

  
## format survey mean size-at-age data for SS3
 if(ONE_FLEET){
          Sur <- 2
         }else{Sur <- 4} 

  AGE_LENGTH_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w,max_age=max_age,type="L",seas=7,flt=-Sur,gender=0,part=0))
  
  if (is_new_SS_DAT_file)
  {
      names(AGE_LENGTH_SS) <- c("Year","Seas","FltSrv","Gender","Part","Ageerr","Ignore",rep(seq(0,max_age,1),2))
  } else
  {
      names(AGE_LENGTH_SS) <- names(old_data$MeanSize_at_Age_obs)
  }

## write size at age to new data file
  new_data$MeanSize_at_Age_obs<-AGE_LENGTH_SS
  new_data$N_MeanSize_at_Age_obs<-nrow(AGE_LENGTH_SS)


## Environmental data for length weight 
  len_weight<-get_lengthweight(species=fsh_sp_str,area=fsh_sp_area,K=7,Alpha_series=2,Beta_series=3)

  en1<-data.table(YEAR=1976,SERIES=1,VALUE=1)

  new_data$envdat<-data.frame(rbind(en1,len_weight))

  print("Length_weights are finished")


## format survey mean weight-at-age data for SS3
  AGE_WEIGHT_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=data.table(Age_w)[!is.na(WEIGHT)&!is.na(AGE)],max_age=max_age,type="W",seas=7,gender=3,growpattern=1,birthseas=1,flt=-1))
  names(AGE_WEIGHT_SS) <- c("#Year","Seas","Gender","GrowPattern","Birthseas","Fleet",seq(1,max_age,1))
  print("Formatting AGE Means done")

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
	new_data$ageerror<-data.frame(error)
  }

  new_data
}
