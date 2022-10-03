GET_BS_LCOMP1<-function(species="21720",bins=seq(3.5,119.5,1),bin=TRUE,SS=TRUE,seas=1,flt=3,gender=1,part=0){

  Count = readLines('sql/count_EBS.sql')
  Count = sql_filter(sql_precode = "IN", x =species , sql_code = Count, flag = '-- insert species')
  Count = sql_run(afsc, Count) %>% data.table() %>%
      dplyr::rename_all(toupper)

 # Count2 = readLines('sql/count_NBS.sql')
 # Count2 = sql_filter(sql_precode = "IN", x =srv_sp_str , sql_code = Count2, flag = '-- insert species')
 # Count2 = sql_run(afsc, Count2) %>% data.table() %>% 
 #     dplyr::rename_all(toupper)

  #Count1$YEAR<-Count1$CRUISE
  # Count2$YEAR<-trunc(Count2$CRUISE/100)
  # Count1<- Count1[,list(EBS_HAULS=sum(HAULS)),by="YEAR"]
  # Count2<- Count2[,list(NBS_HAULS=sum(NBS_HAULS)),by="YEAR"]
  #Count <- merge(Count1,Count2,all=T)
  #Count[is.na(NBS_HAULS)]$NBS_HAULS<-0
  #Count$HAULS<-Count$EBS_HAULS+Count$NBS_HAULS



  lcomp1 = readLines('sql/EBS_length_comp.sql')
  lcomp1 = sql_filter(sql_precode = "IN", x =srv_sp_str , sql_code = lcomp1, flag = '-- insert species')  
  lcomp1 = sql_run(afsc, lcomp1) %>% data.table() %>% 
      dplyr::rename_all(toupper)

  lcomp2 = readLines('sql/NBS_length_comp.sql')
  lcomp2 = sql_filter(sql_precode = "IN", x =srv_sp_str , sql_code = lcomp2, flag = '-- insert species')
  lcomp2 = sql_run(afsc, lcomp2) %>% data.table() %>% 
      dplyr::rename_all(toupper)

  lcomp3 = readLines('sql/OLDER_EBS_length_comp.sql')
  lcomp3 = sql_filter(sql_precode = "<=", x = 1986, sql_code = lcomp3, flag = '-- insert year')
  lcomp3 = sql_filter(sql_precode = "IN", x =srv_sp_str , sql_code = lcomp3, flag = '-- insert species')  
  lcomp3=sql_run(afsc, lcomp3) %>% data.table() %>% 
      dplyr::rename_all(toupper)

 
  lcomp1<-rbind(lcomp3,lcomp1)
  lcomp<-merge(lcomp1,lcomp2,all=T)
   
  lcomp[is.na(NBS_TOTAL)]$NBS_TOTAL<-0
 lcomp$TOTAL<-lcomp$EBS_TOTAL+lcomp$NBS_TOTAL
   
 lcomp<-data.table(YEAR=lcomp$YEAR,LENGTH=lcomp$LENGTH,TOTAL=lcomp$TOTAL)
   
   
   ## create grid for zero fill and merge with data 
   len<-c(0:max(bins)+1)
   YR<-unique(sort(lcomp$YEAR))
   grid<-expand.grid(LENGTH=len,YEAR=YR)
   lcomp<-merge(grid,lcomp,all=T)
   
   lcomp$TOTAL[is.na(lcomp$TOTAL)==T]<-0
   
   lcomp<-lcomp[order(lcomp$YEAR,lcomp$LENGTH),]
   
   ##optional data binning 
   if(bin){
      lcomp<-BIN_LEN_DATA(data=lcomp,len_bins=bins)
      lcomp<-aggregate(list(TOTAL=lcomp$TOTAL),by=list(BIN=lcomp$BIN,YEAR=lcomp$YEAR),FUN=sum)
      N_TOTAL <- aggregate(list(T_NUMBER=lcomp$TOTAL),by=list(YEAR=lcomp$YEAR),FUN=sum)
      lcomp <- merge(lcomp,N_TOTAL)
      lcomp$TOTAL <- lcomp$TOTAL / lcomp$T_NUMBER
    } 

    ## optional format for ss3
    if(SS){
      years<-unique(lcomp$YEAR)
      Nsamp<-Count[YEAR%in%years]$HAULS
      
      #bins<-unique(lcomp$BIN)

      nbin=length(bins)
      nyr<-length(years)
      x<-matrix(ncol=((nbin)+6),nrow=nyr)
      x[,2]<-seas
      x[,3]<-flt
      x[,4]<-gender
      x[,5]<-part
      x[,6]<-Nsamp

      for(i in 1:nyr)
        {
            x[i,1]<-years[i]

            x[i,7:(nbin+6)]<-lcomp$TOTAL[lcomp$YEAR==years[i]]
        }
        lcomp<-x
    }
  lcomp
}



   
   
   

  
   