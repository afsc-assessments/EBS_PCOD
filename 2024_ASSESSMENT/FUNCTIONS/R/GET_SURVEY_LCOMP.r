GET_SURVEY_LCOMP<-function(species="21720",bins=seq(3.5,119.5,1),bin=TRUE,area=fsh_sp_area,sex=1,SS=TRUE,seas=1,flt=3,gender=1,part=0){
    
    if(area == 'GOA') { survey="47"
                        area_id ="99903"
                        }
    if(area == 'AI') { survey="52"
                       area_id= "99904"
                       }
    if(area == 'BS') {survey= c(98,143)
                      area_id = c(99900,99901,99902)
                      }
    if(area == 'SLOPE') { survey = 78
                          print ("There are no size comp. worked up for the slope in the database")
                          area_id = c(99905)
                          stop()
                      }
  
    suppressWarnings({
      Count = readLines('sql/count_AKFIN.sql')
      Count = sql_filter(sql_precode = "IN", x =species , sql_code = Count, flag = '-- insert species')
      Count = sql_filter(sql_precode = "IN", x =survey , sql_code = Count, flag = '-- insert survey')
      Count = sql_run(afsc, Count) %>% data.table() %>%
         dplyr::rename_all(toupper)

      lcomp1 = readLines('sql/length_comp.sql')
      lcomp1 = sql_filter(sql_precode = "IN", x =srv_sp_str , sql_code = lcomp1, flag = '-- insert species')  
      lcomp1 = sql_filter(sql_precode = "IN", x =area_id , sql_code = lcomp1, flag = '-- insert area_id')  
   
      lcomp = sql_run(afsc, lcomp1) %>% data.table() %>% 
          dplyr::rename_all(toupper)
    })
   
  if (sex == 1) {
    lcomp <- lcomp %>%
      dplyr::group_by(YEAR, LENGTH) %>%
      dplyr::summarise(TOTAL = sum(TOTAL), .groups = "drop") %>%
      data.table()
  } else {
    lcomp$SEX <- case_when(
      lcomp$SEX == 1 ~ "male",
      lcomp$SEX == 2 ~ "female",
      lcomp$SEX == 3 ~ "unknown",
      TRUE ~ "unknown"  # Handle any other values not covered
    )
  }

  if(sex ==1){
   ## create grid for zero fill and merge with data 
   len<-c(0:max(bins)+1)
   YR<-unique(sort(lcomp$YEAR))
   grid<-expand.grid(LENGTH=len,YEAR=YR)
   lcomp<-merge(grid,lcomp,all=T)
   
   lcomp$TOTAL[is.na(lcomp$TOTAL)==T]<-0
   
   lcomp<-lcomp[order(lcomp$YEAR,lcomp$LENGTH),]
   
   ##optional data binning 
   if(bin){
      lcomp<-BIN_LEN_DATA(data=data.table(lcomp),len_bins=bins)
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
  } else print("Doh! not yet sex specific but here is the survey length comp data anyway")

  lcomp
}
   