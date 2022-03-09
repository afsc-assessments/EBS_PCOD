GET_BS_LCOMP1<-function(species="99999",bins=seq(3.5,119.5,1),bin=TRUE,SS=TRUE,seas=1,flt=3,gender=1,part=0){
  ## create sql query
 EBS_Count<-paste0("
		SELECT
    			haehnr.length_ebsshelf.species_code,
    			COUNT(DISTINCT haehnr.length_ebsshelf.hauljoin) AS HAULS,
    			haehnr.length_ebsshelf.cruise
		FROM
    			haehnr.length_ebsshelf
		WHERE
    			haehnr.length_ebsshelf.species_code = ",srv_sp_str,
		"GROUP BY
    			haehnr.length_ebsshelf.species_code,
    			haehnr.length_ebsshelf.cruise
		ORDER BY
    			haehnr.length_ebsshelf.cruise")

  
	NBS_Count<-paste0("
		SELECT
    			haehnr.length_nbs.species_code,
    			COUNT(DISTINCT haehnr.length_nbs.hauljoin) AS nbs_hauls,
    			haehnr.length_nbs.cruise
		FROM
    			haehnr.length_nbs
		WHERE
   			 haehnr.length_nbs.species_code = ",srv_sp_str,
		"GROUP BY
   			 haehnr.length_nbs.species_code,
    			haehnr.length_nbs.cruise
		ORDER BY
   			 haehnr.length_nbs.cruise")
		

  Count1 = data.table(sqlQuery(AFSC,EBS_Count))
  Count2 = data.table(sqlQuery(AFSC,NBS_Count))
         
	

  Count1$YEAR<-trunc(Count1$CRUISE/100)
  Count2$YEAR<-trunc(Count2$CRUISE/100)
  Count1<- Count1[,list(EBS_HAULS=sum(HAULS)),by="YEAR"]
  Count2<- Count2[,list(NBS_HAULS=sum(NBS_HAULS)),by="YEAR"]
  Count <- merge(Count1,Count2,all=T)
  Count[is.na(NBS_HAULS)]$NBS_HAULS<-0
  Count$HAULS<-Count$EBS_HAULS+Count$NBS_HAULS





	EBS_test1<-paste0("SELECT
    			haehnr.sizecomp_ebs_plusnw.year,
    			haehnr.sizecomp_ebs_plusnw.length / 10 AS length,
    			haehnr.sizecomp_ebs_plusnw.total AS EBS_TOTAL
		FROM
    			haehnr.sizecomp_ebs_plusnw
		WHERE
    			haehnr.sizecomp_ebs_plusnw.species_code = ",species,
    			"AND haehnr.sizecomp_ebs_plusnw.subarea > 999
		ORDER BY
    			haehnr.sizecomp_ebs_plusnw.year,
    			length")

	EBS_test2<-paste0("
		SELECT
    			haehnr.sizecomp_ebs_standard_stratum.year,
    			haehnr.sizecomp_ebs_standard_stratum.length / 10 AS length,
    			SUM(haehnr.sizecomp_ebs_standard_stratum.total) AS EBS_TOTAL
		FROM
    			haehnr.sizecomp_ebs_standard_stratum
		WHERE
    			haehnr.sizecomp_ebs_standard_stratum.year < 1987
    			AND haehnr.sizecomp_ebs_standard_stratum.species_code = ", species,
    			"AND haehnr.sizecomp_ebs_standard_stratum.stratum > 9999
		GROUP BY
   			haehnr.sizecomp_ebs_standard_stratum.year,
    			haehnr.sizecomp_ebs_standard_stratum.length / 10
		ORDER BY
   			haehnr.sizecomp_ebs_standard_stratum.year,
    			length")


       NBS_test<-paste0("SELECT
    			haehnr.nbs_sizecomp.year,
    			haehnr.nbs_sizecomp.length / 10 AS length,
    			haehnr.nbs_sizecomp.total AS NBS_TOTAL
		FROM
    			haehnr.nbs_sizecomp
		WHERE
    			haehnr.nbs_sizecomp.species_code = ",species,
    			"AND haehnr.nbs_sizecomp.stratum > 9999
		ORDER BY
   			haehnr.nbs_sizecomp.year,
    			length")



   
   ## run database query
   lcomp1=data.table(sqlQuery(AFSC,EBS_test1))
   lcomp3=data.table(sqlQuery(AFSC,EBS_test2))
   lcomp1<-rbind(lcomp3,lcomp1)
   lcomp2=data.table(sqlQuery(AFSC,NBS_test))
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



   
   
   

  
   