# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

# this function gets data for one region at a time


SBSS_GET_ALL_DATA <- function(new_data        = new_data,
                              new_file        = "blarYYYY.dat",
                              new_year        = 9999,
                              sp_area         = "'foo'",
                              fsh_sp_label    = "'foo'",
                              fsh_sp_area     = "'foo'",
                              fsh_sp_str      = "999",
                              fsh_start_yr    = 1977,
                              srv_sp_str      = "99999",
                              srv_start_yr    = 1977,
                              new_SS_dat_year = new_SS_dat_year,
                              len_bins        = seq(4,109,3),
                              max_age         = 20,
                              vmax_age        = 12,
                              is_new_SS_DAT_file = FALSE,
                              AUXFCOMP        = 1,
			                        ONE_FLEET       = FALSE,
                              LL_DAT          = FALSE,
                              ICC_T           = FALSE,
                              VAST            = TRUE)
{

  new_data$sourcefile <- new_file

## ----- get REGION catch -----

 #catch= readLines('sql/dom_catch.sql')
 #catch = sql_filter(sql_precode = "<=", x = final_year, sql_code = catch, flag = '-- insert year')
 #catch = sql_filter(sql_precode = "IN", x = fsh_sp_label, sql_code = catch, flag = '-- insert species_catch')
 #catch = sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = catch, flag = '-- insert subarea')
 
  catch <- tryCatch({
    catch <- readLines('sql/dom_catch.sql')
    catch <- sql_filter(sql_precode = "<=", x = final_year, sql_code = catch, flag = '-- insert year')
    catch <- sql_filter(sql_precode = "IN", x = fsh_sp_label, sql_code = catch, flag = '-- insert species_catch')
    catch <- sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = catch, flag = '-- insert subarea')
  }, error = function(e) {
    # Handle the error here
    # You can print an error message or perform any necessary actions
    print(paste("An error occurred and the program will be stopped:", e$message))
    # Assign a default value to catch or handle the error in an appropriate way
    stop()
 
  })

  CATCH <- sql_run(akfin, catch) %>%
  dplyr::rename_all(toupper)%>%
  dplyr::mutate(GEAR1 = case_when(
    GEAR == "POT" ~ "POT",
    GEAR == "HAL" ~ "LONGLINE",
    GEAR == "JIG" ~ "OTHER",
    TRUE ~ "TRAWL"
  )) %>%
  dplyr::group_by(YEAR, GEAR1)%>% 
  dplyr::summarise(TONS = sum(TONS)) %>%
  dplyr::ungroup() %>% data.table()
  
  CATCH$YEAR<-as.numeric(CATCH$YEAR)

## Add the old catch (pre-1991) from csv file   
  if(exists("OLD_SEAS_GEAR_CATCH")){
      OLD_SEAS_GEAR_CATCH <- OLD_SEAS_GEAR_CATCH %>%
      dplyr::mutate(GEAR1 = case_when(
      GEAR == "POT" ~ "POT",
      GEAR == "LONGLINE" ~ "LONGLINE",
      GEAR == "OTHER" ~ "LONGLINE",
      TRUE ~ "TRAWL"
    ))

      OLD_GEAR_CATCH <- OLD_SEAS_GEAR_CATCH %>%
      dplyr::group_by(YEAR, GEAR1) %>%
      dplyr::summarise(TONS = sum(TONS)) %>%
      dplyr::ungroup() %>% data.table()

      CATCH <- bind_rows(OLD_GEAR_CATCH, CATCH) %>%
      arrange(GEAR1, YEAR)
  }else{
      print("Warning: No old catch information provided")
      CATCH<-CATCH_TOTAL
         }

## check that all gears have the same number of years covered; add zeros if necessary
  
  CATCH <- CATCH %>%
    complete(YEAR = full_seq(YEAR, 1)) %>%
    dplyr::mutate(TONS = if_else(is.na(TONS), 0.0, TONS)) %>% data.table()

## For 2024 base models only a single fleet is used
  if(ONE_FLEET){
    
    CATCH <- CATCH %>%
      dplyr::group_by(YEAR) %>%
      dplyr::summarise(TONS = sum(TONS)) %>%
      dplyr::arrange(YEAR) %>%
      dplyr::mutate(fleet = 1)%>% data.table()

    catch <- data.frame(year = as.numeric(CATCH$YEAR), seas = 1, fleet = CATCH$fleet, catch = CATCH$TONS, catch_se = 0.01)

    equal_catch <- data.frame(year = -999, seas = 1, fleet = 1, catch = 42500, catch_se = 0.01) ## equalibruim catch for pre-1977

    catch <- bind_rows(equal_catch, catch) %>%
      arrange(fleet, year)
    }


  if(!ONE_FLEET){ 
    CATCH <- CATCH %>%
      dplyr::mutate(GEAR1 = if_else(GEAR1 == "OTHER", "LONGLINE", GEAR1)) %>%
      dplyr::group_by(GEAR1, YEAR) %>%
      dplyr::summarise(TONS = sum(TONS)) %>%
      dplyr::mutate(fleet = case_when(
          GEAR1 == "LONGLINE" ~ 2,
          GEAR1 == "POT" ~ 3,
          TRUE ~ 1
    )) %>%
      dplyr::arrange(fleet, YEAR)%>% data.table()


    catch <- data.frame(
      year = CATCH$YEAR,
      seas = 1,
      fleet = CATCH$fleet,
      catch = CATCH$TONS,
      catch_se = 0.01
    )
## adding in closing line for catch in SS data file
    catch_close <- data.frame(
      year = rep(-999, 3),
      seas = rep(1, 3),
      fleet = 1:3,
      catch = rep(0, 3),
      catch_se = rep(0.05, 3)
    )

    catch <- bind_rows(catch_close, catch) %>%
      arrange(fleet, year)
    }

## write catch data into new data files
  new_data$N_catch<-nrow(catch)
  new_data$catch<-catch


## ----- Get survey population number estimates -----
if(VAST){

    VAST_abundance<-data.table(VAST_abundance)[Fleet=="Both"]
    BIOM<-VAST_abundance
    if(ONE_FLEET){ BIOM$index <-2 
       }else{BIOM$index<- 4}

    names(BIOM)<-c("CATEGORY","YEAR","FLEET","Unit","BIOM","SD_mt","se_log","index")
    BIOM[YEAR==2020]$index<-BIOM[YEAR==2020]$index*-1
    CPUE<-data.frame(year=BIOM$YEAR,seas=7,index=BIOM$index,obs=BIOM$BIOM,se_log=BIOM$se_log)


  } else{

    BIOM<-get_survey_biom(area=fsh_sp_area,species=srv_sp_str, start_yr=srv_start_yr)

    if(ONE_FLEET){ BIOM$index <-2 
       }else{BIOM$index<- 4}

    CPUE<-data.frame(year=BIOM$YEAR,seas=7,index=BIOM$index,obs=BIOM$POPULATION,se_log=sqrt(BIOM$VARPOP)/BIOM$POPULATION)
  }

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

  ## Changing survey 2020 to 0 instead of NA
  CPUE$obs[CPUE$year==2020]<-0
  CPUE$se_log[CPUE$year==2020]<-0

## write to new data file
  new_data$N_cpue<-nrow(CPUE)
  new_data$CPUE<-CPUE

## ----- get size composition data -----
 
## bottom trawl survey size comp
  if(ONE_FLEET){flt <- 2} else {flt <- 4}

  SRV_LCOMP_SS <- data.frame(GET_SURVEY_LCOMP(species=srv_sp_str,bins=len_bins,sex=1,bin=TRUE,SS=TRUE,seas=7,flt=flt,gender=0,part=0))

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
      FISHLCOMP <- subset(FISHLCOMP,!is.na(data.table(FISHLCOMP)[,7]))
  
  }

    print("Fisheries LCOMP done")
       
## combine all the length comp data
  LCOMP<-rbind(FISHLCOMP,SRV_LCOMP_SS)
  LCOMP<-subset(LCOMP,!is.na(LCOMP['119.5']))

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
        left_join(areaview, by = c("area_code", "geographic_area_name", "council_sablefish_management_area")) %>%
        filter(exploitable == 1)

    LL_length <- lens %>% 
        group_by(year, length) %>% 
        summarize(FREQ = sum(rpn)) %>%
        ungroup()

    LL_LENGTHY <- LL_length %>%
        group_by(year) %>%
        summarize(TOT = sum(FREQ))

    LL_LENGTH <- LL_length %>%
        left_join(LL_LENGTHY, by = "year") %>%
        mutate(PROP = FREQ / TOT) %>%
        complete(year, length, fill = list(PROP = 0))

    SS3_LLL <- LL_LENGTH %>%
        pivot_wider(names_from = length, values_from = PROP, values_fill = 0)

    flt <- if (ONE_FLEET) -3 else -5

    LL_LENGTH <- data.frame(
        Year = SS3_LLL$year,
        Seas = 7,
        FltSrv = flt,
        Gender = 0,
        Part = 0,
        Nsamp = 32,
        SS3_LLL[, -1]
    )

    names(LL_LENGTH) <- c("Year", "Seas", "FltSrv", "Gender", "Part", "Nsamp", len_bins)

    LCOMP <- bind_rows(LCOMP, LL_LENGTH)

    }

## write into SS3 files
  new_data$lencomp<-LCOMP
  new_data$N_lencomp<-nrow(LCOMP)

  print("All LCOMP done")

## get age comp
  ACOMP <- GET_ACOMP(vast=TRUE)
  
  new_data$agebin_vector<-c(0:vmax_age)   ## Currently vast only has 12 age classes for pcod.


## Adding conditional age at length data, weighted by catch

    CAAL<-cond_length_age_cor(max_age1=vmax_age)
    CAAL<-data.table(CAAL$norm)
    names(CAAL)<-names(ACOMP)
    
    FSH_CAAL<-cond_length_age_corFISH(max_age1=vmax_age)
    FSH_CAAL<-data.table(FSH_CAAL$norm)
    names(FSH_CAAL)<-names(ACOMP)

    ACOMP<-rbind(ACOMP,CAAL)

    ACOMP<-rbind(ACOMP,FSH_CAAL)


    new_data$agecomp<-ACOMP
    new_data$N_agecomp<-nrow(ACOMP)

 print("All ACOMP done")

## Get all survey Age Data
     
    if(fsh_sp_area  == 'GOA') survey="47"
    if(fsh_sp_area  == 'AI') survey="52"
    if(fsh_sp_area  == 'BS') survey= c(98,143)
    if(fsh_sp_area  == 'SLOPE') survey= c(78)
# 
  Age = readLines('sql/survey_age.sql')
  Age = sql_filter(sql_precode = "in", x =survey , sql_code = Age, flag = '-- insert survey')
  Age = sql_filter(sql_precode = ">=", x =fsh_start_yr , sql_code = Age, flag = '-- insert start_year')
 # Age = sql_filter(sql_precode = "in", x =area , sql_code = Age, flag = '-- insert area')
  Age = sql_filter(sql_precode = "=", x =srv_sp_str , sql_code = Age, flag = '-- insert species')
  
  
  #   sname<- '%Slope%'

    
  # bsage = readLines('sql/survey_age.sql')
 	# bsage = sql_filter(sql_precode = "<=", x = new_year, sql_code = bsage, flag = '-- insert year')
 	# bsage = sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = bsage, flag = '-- insert survey')

  #   if(fsh_sp_area=='SLOPE'){
  #       bsage = sql_filter(sql_precode = "LIKE", x = sname, sql_code = bsage, flag = '-- insert sname') }
    
  #   if(fsh_sp_area!='SLOPE'){
  #       bsage = sql_filter(sql_precode = "NOT LIKE", x = sname, sql_code = bsage, flag = '-- insert sname') }

  #   bsage = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = bsage, flag = '-- insert species')

	Age_w <- sql_run(afsc, Age) %>% rename_all(toupper)
        Age_w$AGE1<-Age_w$AGE
        Age_w$AGE1[Age_w$AGE >= max_age]=max_age


    print("GET_SURV_AGE done")

  
## format survey mean size-at-age data for SS3
    if(ONE_FLEET){
          Sur <- 2
         }else{Sur <- 4} 

    AGE_LENGTH_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w,max_age=max_age,type="L",seas=7,flt=-Sur,gender=0,part=0))
    AGE_WEIGHT_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w,max_age=max_age,type="W",seas=7,flt=-Sur,gender=0,part=0))
  
    AGE_LW_SS<-rbind(AGE_LENGTH_SS,AGE_WEIGHT_SS)	
	
    if (is_new_SS_DAT_file)
    {
        names(AGE_LW_SS) <- c("Year","Seas","FltSrv","Gender","Part","Ageerr","Ignore",rep(seq(0,max_age,1),2))
    } else
    {
        names(AGE_LW_SS) <- names(old_data$MeanSize_at_Age_obs)
    }

## write size at age to new data file
  new_data$MeanSize_at_Age_obs<-AGE_LW_SS
  new_data$N_MeanSize_at_Age_obs<-nrow(AGE_LW_SS)

print("Mean sizes complete")
## Environmental data for length weight 
#  len_weight<-get_lengthweight(species=fsh_sp_str,area=fsh_sp_area,K=7,Alpha_series=2,Beta_series=3)

 # en1<-data.table(YEAR=1976,SERIES=1,VALUE=1)

 # new_data$envdat<-data.frame(rbind(en1,len_weight))

 # print("Length_weights are finished")


## format survey mean weight-at-age data for SS3
    AGE_WEIGHT_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=data.table(Age_w)[!is.na(WEIGHT_G)&!is.na(AGE)],max_age=max_age,type="W",seas=1,gender=3,growpattern=1,birthseas=1,flt=-1))
    names(AGE_WEIGHT_SS) <- c("#Year","Seas","Gender","GrowPattern","Birthseas","Fleet",seq(1,max_age,1))
    print("Formatting AGE Means done")

# write out empirical/survey mean weight-at-age data to file wtatage.ss
## this is not used in the current set of models
    waa.ss <- file("wtatage.ss","w")
    write(paste(nrow(AGE_WEIGHT_SS)," #N rows"),file=waa.ss,append=TRUE)
    write(paste(max_age," #N ages"),file=waa.ss,append=TRUE)
    write(paste0(names(AGE_WEIGHT_SS),collapse=" "),file=waa.ss,append=TRUE)
    write(t(AGE_WEIGHT_SS),file=waa.ss,ncolumns=ncol(AGE_WEIGHT_SS),append=TRUE)
    close(waa.ss)


    if(!ONE_FLEET){
        new_data$surveytiming<-c(-1,-1,-1,1)
        new_data$areas<-rep(1,4)
        new_data$fleetinfo<-data.frame(type=c(1,1,1,3),surveytiming=c(-1,-1,-1,1),area=rep(1,4),units=c(1,1,1,2),need_catch_mult=rep(0,4),fleetname=c('trawl','longline','pot','survey'))
        new_data$Nfleets<-4
        new_data$fleetnames<-c('trawl','longline','pot','survey')
        new_data$CPUEinfo<-data.frame(Fleet=c(1:4),Units=rep(0,4),Errtype=rep(0,4),SD_Report=rep(1,4))
        rownames(new_data$CPUEinfo)<-new_data$fleetnames
        new_data$units_of_catch<-c(1,1,1,2)
        new_data$len_info<-data.frame(mintailcomp=rep(-1,4),addtocomp=rep(1e-06,4),combine_M_F=rep(0,4),CompressBins=rep(0,4),CompError=rep(1,4),ParmSelect=c(1:4),minsamplesize=rep(1,4))
        rownames(new_data$len_info)<-new_data$fleetnames
        new_data$age_info<-data.frame(mintailcomp=rep(-1,4),addtocomp=rep(1e-06,4),combine_M_F=rep(0,4),CompressBins=rep(0,4),CompError=rep(1,4),ParmSelect=c(0,0,0,5),minsamplesize=rep(1,4))
        rownames(new_data$age_info)<-new_data$fleetnames
        new_data$Nfleet<-3
        new_data$fleetinfo1<-data.frame(trawl=c(-1,1,1),longline=c(-1,1,1),pot=c(-1,1,1),survey=c(1,1,3))
        rownames(new_data$fleetinfo1)<-c('surveytiming','areas','type')
        new_data$fleetinfo2<-data.frame(trawl=c(1,0),longline=c(1,0),pot=c(1,0),survey=c(2,0))
        rownames(new_data$fleetinfo2)<-c('units','need_catch_mult')
        new_data$comp_tail_compression<-rep(-1,4)
        new_data$add_to_comp<-rep(1e-06,4)
        new_data$max_combined_lbin<-rep(0,4)
    }

    if(ONE_FLEET){
        new_data$surveytiming<-c(-1,1)
        new_data$areas<-rep(1,2)
        new_data$fleetinfo<-data.frame(type=c(1,3),surveytiming=c(-1,1),area=rep(1,2),units=c(1,2),ned_catch_mult=rep(0,2),fleetname=c('fishery','survey'))
        new_data$Nfleets<-2
        new_data$fleetnames<-c('fishery','survey')
        new_data$CPUEinfo<-data.frame(Fleet=c(1:2),Units=rep(0,2),Errtype=rep(0,2),SD_Report=rep(1,2))
        rownames(new_data$CPUEinfo)<-new_data$fleetnames
        new_data$units_of_catch<-c(1,2)
        new_data$len_info<-data.frame(names=c('fishery','survey'),mintailcomp=rep(-1,2),addtocomp=rep(1e-06,2),combine_M_F=rep(0,2),CompressBins=rep(0,2),CompError=rep(1,2),ParmSelect=c(1:2),minsamplesize=rep(1,2))
        rownames(new_data$len_info)<-new_data$fleetnames
        new_data$age_info<-data.frame(names=c('fishery','survey'),mintailcomp=rep(-1,2),addtocomp=rep(1e-06,2),combine_M_F=rep(0,2),CompressBins=rep(0,2),CompError=rep(1,2),ParmSelect=c(0,3),minsamplesize=rep(1,2))
        rownames(new_data$age_info) <- new_data$fleetnames
        new_data$Nfleet<- 1
        new_data$fleetinfo1 <- data.frame(fishery=c(-1,1,1),survey=c(1,1,3))
        rownames(new_data$fleetinfo1)<-c('surveytiming','areas','type')
        new_data$fleetinfo2<-data.frame(fishery=c(1,0),survey=c(2,0))
        rownames(new_data$fleetinfo2)<-c('units','need_catch_mult')
        new_data$comp_tail_compression<-rep(-1,2)
        new_data$add_to_comp<-rep(1e-06,2)
        new_data$max_combined_lbin<-rep(0,2)
    }

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
