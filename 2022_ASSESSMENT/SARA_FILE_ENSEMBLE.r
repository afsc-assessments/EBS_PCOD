WT=c(0.2842,0.3158,0.2316,0.1684)
 mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
## mods_nam<-c("Model 19.12","Model 19.12A","Model 21.1","Model 21.2")


GET_SARA_ENSEMBLE<-function(dir=getwd(),models=mods, WEIGHT=WT,Enter_Data=FALSE,STOCK="Pacific cod",REGION="EBS",TIER="3b",T2="none",UPDATE="benchmark",LH=2,AF=3,AL=4,CD=5,AD=2,MFR=1000,NOTES="2022 New Series Ensemble.",stryr=1977)
{
  require(r4ss)
  require(stringr)
  setwd(dir)
  ##data<-SS_output(dir=dir,forecast=F,covar=T)
  data<-SSgetoutput(dirvec=mods)
  input<-SS_readdat(paste0(models[1],"/data_echo.ss_new"),version="3.30")
  starter=SS_readstarter(paste0(models[1],"/starter.ss_new"))




for(i in 1:length(models)){
  names(data[[i]]$timeseries)<-str_replace_all(names(data[[i]]$timeseries),"\\(",".")
    names(data[[i]]$timeseries)<-str_replace_all(names(data[[i]]$timeseries),"\\)",".")
  names(data[[i]]$timeseries)<-str_replace_all(names(data[[i]]$timeseries),":",".")
  names(data[[i]]$endgrowth)<-str_replace_all(names(data[[i]]$endgrowth),":",".")
  names(data[[i]]$sprseries)<-str_replace_all(names(data[[i]]$sprseries),"=",".")
  names(data[[i]]$sprseries)<-str_replace_all(names(data[[i]]$sprseries),"-",".")
}



  fish_name<-as.character(data[[1]]$definitions[,9])[1:(data[[1]]$nfishfleets)]
  survey_name<-as.character(data[[1]]$definitions[2,])[(data[[1]]$nfishfleets+2):ncol(data[[1]]$definitions)]
    
  if(Enter_Data){

    STOCK  <-readline("Enter Stock Name: " )
    REGION <- readline("Enter Region (AI AK BOG BSAI EBS GOA SEO WCWYK): ")
    TIER <- readline("Enter Tier TIER (1a 1b 2a 2b 3a 3b 4 5 6): " )
    T2<- readline("Enter if mixed tiers (none 1a 1b 2a 2b 3a 3b 4 5 6): ")
    NOTES<-readline("Enter any notes on the assessment: ")
    MFR<- readline("Enter multiplier for recruitment data, N at age, and survey number (1,1000,1000000): ")
}

  prolog=paste(
    STOCK,"     # stock \n",
    REGION,"       # region     (AI AK BOG BSAI EBS GOA SEO WCWYK)\n",
    data[[1]]$endyr, "       # ASSESS_YEAR - year assessment is presented to the SSC \n",
    TIER, "         # TIER  (1a 1b 2a 2b 3a 3b 4 5 6) \n",
    T2, "       # TIER2  if mixed (none 1a 1b 2a 2b 3a 3b 4 5 6) \n",
    sep="")

  write(noquote(prolog),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=45, append=F)

minb<-vector('list',length=length(models))
maxb<-vector('list',length=length(models))
ssb_unfished<-vector('list',length=length(models))
spwnbio<-vector('list',length=length(models))
bio_sum<-vector('list',length=length(models))
F_ap<-vector('list',length=length(models))
recr<-vector('list',length=length(models))

for(i in 1:length(models)){
 minb[[i]]<-(data[[i]]$derived_quants$Value[data[[i]]$derived_quants$Label==paste("SSB_",data[[i]]$endyr,sep="")]-(1.96*data[[i]]$derived_quants$StdDev[data[[i]]$derived_quants$Label==paste("SSB_",data[[i]]$endyr,sep="")]))*WEIGHT[i]
 maxb[[i]]<- (data[[i]]$derived_quants$Value[data[[i]]$derived_quants$Label==paste("SSB_",data[[i]]$endyr,sep="")]+(1.96*data[[i]]$derived_quants$StdDev[data[[i]]$derived_quants$Label==paste("SSB_",data[[i]]$endyr,sep="")]))*WEIGHT[i]
 ssb_unfished[[i]]<-(data[[i]]$derived_quants$Value[data[[i]]$derived_quants$Label=="SSB_unfished"]/2)*WEIGHT[i]
 recr[[i]]<-(data[[i]]$recruit$pred_recr[data[[i]]$recruit$era!="Forecast"&data[[i]]$recruit$Yr>=stryr & data[[i]]$recruit$Yr<=data[[i]]$endyr])*WEIGHT[i]
 spwnbio[[i]]<-(data[[i]]$recruit$SpawnBio[data[[i]]$recruit$era!="Forecast"&data[[i]]$recruit$Yr>=stryr & data[[i]]$recruit$Yr<=data[[i]]$endyr]/2)*WEIGHT[i]
 bio_sum[[i]]<-(data[[i]]$timeseries$Bio_smry[data[[i]]$timeseries$Era=="TIME"&data[[i]]$timeseries$Yr>=stryr & data[[i]]$timeseries$Yr<=data[[i]]$endyr])*WEIGHT[i]
 F_ap[[i]]<-(data[[i]]$sprseries$sum_Apical_F[data[[i]]$sprseries$Yr>=stryr & data[[i]]$sprseries$Yr<=data[[i]]$endyr])*WEIGHT[i] 

}

minb<-do.call(rbind,minb)
maxb<-do.call(rbind,maxb)
ssb_unfished<-do.call(rbind,ssb_unfished)
spwnbio<-do.call(rbind,spwnbio)
bio_sum<-do.call(rbind,bio_sum)
F_ap<-do.call(rbind,F_ap)
recr<-do.call(rbind,recr)

minb<-sum(minb)
maxb<-sum(maxb)
ssb_unfished<-sum(ssb_unfished)
recr<-colSums(recr)
F_ap<-colSums(F_ap)
bio_sum<-colSums(bio_sum)
spwnbio<-colSums(spwnbio)


  data1<-paste(
  round(minb),  "      # Minimum B  Lower 95% confidence interval for spawning biomass in assessment year \n",
  round(maxb),  "      # Maximum B  Upper 95% confidence interval for spawning biomass in assessment year \n",
  round(ssb_unfished*0.35),  "      # BMSY  is equilibrium spawning biomass at MSY (Tiers 1-2) or 7/8 x B40% (Tier 3) \n",
  "SS         # MODEL - Required only if NMFS toolbox software used; optional otherwise \n",
  data[[1]]$SS_versionshort, "   # VERSION - Required only if NMFS toolbox software used; optional otherwise \n",
  data[[1]]$nsexes,"          # number of sexes  if 1 sex=ALL elseif 2 sex=(FEMALE, MALE) \n",
  data[[1]]$nfishfleets, "          # number of fisheries \n",
  MFR, "       # multiplier for recruitment, N at age, and survey number (1,1000,1000000)\n",
  "0          # recruitment age used by model \n",
  starter$min_age_summary_bio, "          # age+ used for biomass estimate \n",
  "Sum Apical F          # Fishing mortality type such as Single age or exploitation rate \n",
  "Age model          # Fishing mortality source such as Model or (total catch (t))/(survey biomass (t)) \n",
  "Age at Maximum F         # Fishing mortality range such as: Age of maximum F \n",
  "#FISHERYDESC -list of fisheries (ALL TWL LGL POT FIX FOR DOM TWLJAN LGLMAY POTAUG ...) \n",
  paste(fish_name,collapse=" ")," \n",
  "#FISHERYYEAR -list years used in model \n",
  paste(data[[1]]$recruit$Yr[data[[1]]$recruit$era!="Forecast"&data[[1]]$recruit$Yr>=stryr&data[[1]]$recruit$Yr<=data[[1]]$endyr],collapse=" ") ," \n",
  "#AGE -list ages used in model \n",
  paste(data[[1]]$agebins,collapse=" ") ," \n",
  "#RECRUITMENT -Number of recruits by year (see multiplier above) \n",
  paste(recr,collapse=" ") ," \n",
  "#SPAWNBIOMASS -Spawning biomass by year in metric tons \n",
  paste(spwnbio,collapse=" ") ," \n",
  "#TOTALBIOMASS -Total biomass by year in metric tons (see age+ above) \n",
  paste(bio_sum,collapse=" ") ," \n",
  "#TOTFSHRYMORT -Fishing mortality rate by year \n",
  paste(F_ap,collapse=" ")," \n",
  "#TOTALCATCH -Total catch by year in metric tons \n",
  paste(subset(data[[1]]$timeseries,data[[1]]$timeseries$Yr>=stryr&data[[1]]$timeseries$Yr<=data[[1]]$endyr)$dead.B.._1,collapse=" ")," \n",
  "#FISHERYMORT -Fishing mortality rates by year (a line for each fishery) only if multiple fisheries",
  sep="")

  write(noquote(data1),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=100, append=T)



  for( j in 1: max(data[[1]]$timeseries$Seas)){
    for ( i in 1:data[[1]]$nfishfleets){
      F_L<-vector('list',length=length(models))
      for(l in 1:length(models)){
        F_L[[l]]<-(get(noquote(paste("F._",i,sep="")),pos=data[[l]]$timeseries)[data[[l]]$timeseries$Era=="TIME"&data[[l]]$timeseries$Seas==j & data[[l]]$timeseries$Yr>=stryr & data[[l]]$timeseries$Yr<=data[[l]]$endyr])*WEIGHT[l]
        }

    F_L<-do.call(rbind,F_L)
    F_L<-colSums(F_L)

      write(paste(paste(F_L,collapse=" "),paste(" # ",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }}

  write("#FISHERYCATCH -Catches by year (a line for each fishery) only if multiple fisheries",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)

  for( j in 1: max(data[[1]]$timeseries$Seas)){
    for ( i in 1:data[[1]]$nfishfleets){
      x<-get(noquote(paste("obs_cat._",i,sep="")),pos=data[[1]]$timeseries)[data[[1]]$timeseries$Era=="TIME"&data[[1]]$timeseries$Seas==j & data[[1]]$timeseries$Yr>=stryr & data[[1]]$timeseries$Yr<=data[[1]]$endyr]
      write(paste(paste(x,collapse=" "),paste(" # ",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }}

  write("#MATURITY -Maturity ratio by age",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
  

  for( i in 1:max(data[[1]]$endgrowth$Seas)){
   
    A_M<-vector('list',length=length(models))

      for(l in 1:length(models)){
      A_M[[l]]=(data[[l]]$endgrowth$Age_Mat[data[[l]]$endgrowth$Sex==1&data[[l]]$endgrowth$Real_Age>0 & data[[l]]$endgrowth$Seas==i]*data[[l]]$endgrowth$Len_Mat[data[[l]]$endgrowth$Sex==1&data[[l]]$endgrowth$Real_Age>0&data[[l]]$endgrowth$Seas==i])*WEIGHT[l]
    }

    A_M<-do.call(rbind,A_M)
    A_M<-colSums(A_M)

   write(paste(paste(A_M,collapse=" "),paste(" # Season ",i,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
  }

  write("#SPAWNWT -Average Spawning weight (in kg) by age",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
  

  for( i in 1:max(data[[1]]$endgrowth$Seas)){
    MID_WT<- vector('list',length=length(models))   
    for(l in 1:length(models)){
          MID_WT[[l]]<-(data[[l]]$endgrowth$Wt_Mid[data[[l]]$endgrowth$Sex==1&data[[l]]$endgrowth$Real_Age>0&data[[l]]$endgrowth$Seas==i])*WEIGHT[l]
          }
    MID_WT<-do.call(rbind,MID_WT)
    MID_WT<-colSums(MID_WT)
    write(paste(paste(MID_WT,collapse=" "),paste(" # Season ",i,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }

  write("#NATMORT -Natural mortality rate by age (a line for each sex)",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)

  for(j in 1 : max(data[[1]]$endgrowth$Seas)){
    for ( i in 1:data[[1]]$nsexes){
      M_L<-vector('list',length=length(models))
      for(l in 1:length(models)){
         M_L[[l]]=(data[[l]]$endgrowth$M[data[[l]]$endgrowth$Sex==i&data[[l]]$endgrowth$Real_Age>0&data[[l]]$endgrowth$Seas==j])*WEIGHT[l]
        }
       
       M_L<-do.call(rbind,M_L)
       M_L<-colSums(M_L)
       write(paste(paste(M_L,collapse=" "),paste(" # Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }}


  write("#N_AT_AGE -N at age by age (see number multiplier above)(a line for each sex)",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
  for( j in 1:max(data[[1]]$natage$Seas)){
    for(i in 1:data[[1]]$nsexes){

       Nage<-vector('list',length=length(models))
      for(l in 1: length(models)){
         Nage[[l]]<-(subset(data[[l]]$natage,data[[l]]$natage[,11]=="B"&data[[l]]$natage$Yr==data[[l]]$endyr&data[[l]]$natage$Seas==j))[,(13:ncol(data[[l]]$natage))]*WEIGHT[l]
        }

      Nage<-do.call(rbind,Nage)
      Nage<-colSums(Nage)
      
      write(paste(paste(Nage,collapse=" "),paste(" # Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
  }}

  
  write("#FSHRY_WT_KG -Fishery weight at age (in kg) first FEMALES/ALL (a line for each fishery) then MALES (a line for each fishery)",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)

  if(data[[1]]$nsexes>1){
    for(j in 1:max(data[[1]]$ageselex$Seas)){
    for ( i in 1:data[[1]]$nfishfleets){
      sel<-vector('list',length=length(models))
      for(l in 1: length(models)){
        sel[[l]]<-(get(noquote(paste("SelWt._",i,sep="")),pos=data[[l]]$endgrowth)[data[[l]]$endgrowth$Real_Age>0&data[[l]]$endgrowth$Sex==1&data[[l]]$endgrowth$Seas==j])*WEIGHT[l]
      }       

      sel<-do.call(rbind,sel)
      sel<-colSums(sel)
       write(paste(paste(sel,collapse=" "),paste(" # Females",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }
  
    for ( i in 1:data[[1]]$nfishfleets){
       sel<-vector('list',length=length(models))
      for(l in 1: length(models)){
        sel[[l]]<-(get(noquote(paste("SelWt._",i,sep="")),pos=data$endgrowth)[data$endgrowth$Real_Age>0&data$endgrowth$Sex==2&data$endgrowth$Seas==j])*WEIGHT[l]
       }
       sel<-do.call(rbind,sel)
       sel<-colSums(sel)

       write(paste(paste(sel,collapse=" "),paste(" # Males",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }}}

  if(data[[1]]$nsexes==1){
    for(j in 1:max(data[[1]]$ageselex$Seas)){
    for ( i in 1:data[[1]]$nfishfleets){
    sel<-vector('list',length=length(models))
      for(l in 1: length(models)){
        sel[[l]]<-(get(noquote(paste("SelWt._",i,sep="")),pos=data[[l]]$endgrowth)[data[[l]]$endgrowth$Real_Age>0&data[[l]]$endgrowth$Seas==j])*WEIGHT[l]
          }
      sel<-do.call(rbind,sel)
      sel<-colSums(sel)


      write(paste(paste(sel,collapse=" "),paste(" # ",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }}}


 write("#SELECTIVITY -Fishery selectivity first FEMALES/ALL (a line for each fishery) then MALES (a line for each fishery)",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
      if(data[[1]]$nsexes>1){
        
        for(j in 1:max(data[[1]]$ageselex$Seas)){
         
         for ( i in 1:data[[1]]$nfishfleets){
             sel<-vector('list',length=length(models))
        
              for(l in 1: length(models)){
                sel[[l]]<-(subset(data[[l]]$ageselex,data[[l]]$ageselex$Yr==data[[l]]$endyr&data[[l]]$ageselex$Sex==1&data[[l]]$ageselex$Fleet==i&data[[l]]$ageselex$Factor=="Asel2"&data[[l]]$ageselex$Seas==j)[,(8:ncol(data[[l]]$ageselex))])*WEIGHT[l]
              }
            sel<-do.call(rbind,sel)
            sel<-colSums(sel)
            write(paste(paste(sel,collapse=" "),paste(" # Females",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
          }


    for ( i in 1:data[[1]]$nfishfleets){
      sel<-vector('list',length=length(models))
          for(l in 1: length(models)){
            sel[[l]]<-(subset(data[[l]]$ageselex,data[[l]]$ageselex$Yr==data[[l]]$endyr&data[[l]]$ageselex$Sex==2&data[[l]]$ageselex$Fleet==i&data[[l]]$ageselex$Factor=="Asel2"&data[[l]]$ageselex$Seas==j)[,(8:ncol(data[[l]]$ageselex))])*WEIGHT[l]
       }
       sel<-do.call(rbind,sel)
       sel<-colSums(sel)      


       write(paste(paste(sel,collapse=" "),paste(" # Males",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }
   }
 }

  if(data[[1]]$nsexes==1){
  for(j in 1:max(data[[1]]$ageselex$Seas)){
    for ( i in 1:data[[1]]$nfishfleets){

       sel<-vector('list',length=length(models))
          for(l in 1: length(models)){
            sel[[l]]<-(subset(data[[l]]$ageselex,data[[l]]$ageselex$Yr==data[[l]]$endyr&data[[l]]$ageselex$Fleet==i&data[[l]]$ageselex$Factor=="Asel2"&data[[l]]$ageselex$Seas==j)[,(8:ncol(data[[l]]$ageselex))])*WEIGHT[l]
       }
       sel<-do.call(rbind,sel)
      sel<-colSums(sel)      
       write(paste(paste(sel,collapse=" "),paste(" # ",fish_name[i]," - Season ",j,sep="")),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
    }} }

  write("# set of survey names - none EBS_trawl_biomass_mtons BS_slope_trawl_biomass_mtons AI_trawl_biomass_mtons GOA_trawl_biomass_mtons Acoustic_trawl_biomass_mtons AFSC_longline_relative_numbers Coop_longline_relative_numbers not_listed",paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500,append=T)
  write("#SURVEYDESC",paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500,append=T)
  write(noquote(paste(input$fleetnames[sort(unique(input$CPUE$index[input$CPUE$index>0]))])),paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
  write("#SURVEYMULT",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
  write(noquote( paste(paste(input$CPUEinfo$Units[sort(unique(input$CPUE$index[input$CPUE$index>0]))],collapse=" "),paste(" # survey units multipliers"))),paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=500)

   surveys<-sort(unique(input$CPUE$index[input$CPUE$index>0]))
   for( j in 1:max(input$CPUE$seas)){
    for (i in surveys){

       x<-input$CPUE$year[input$CPUE$index==i&input$CPUE$seas==j]
       y<-input$CPUE$obs[input$CPUE$index==i&input$CPUE$seas==j]
       if(length(x)>0){
       write(paste("#",input$fleetnames[i]," - Season ",j,sep=""),paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
       write(x,paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
       write(y,paste(getwd(),"/",STOCK,".dat",sep=""),ncolumns=500, append=T)
       remove(x)
       remove(y)
       }}}
  write("#STOCKNOTES",paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=50)
  write(paste("",NOTES,"",sep='"'),paste(getwd(),"/",STOCK,".dat",sep=""),append=T,ncolumns=100)
  }




GET_SARA_ENSEMBLE()
