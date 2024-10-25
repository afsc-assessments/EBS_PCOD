
require(dplyr)
require(lubridate)
library(reshape)
library(FSA)
library(nlstools)
library(data.table)
library(sizeMat)
library(keyring)

 


afsc=connect("afsc")

test<-paste0("SELECT
    obsint.debriefed_age.cruise,
    obsint.debriefed_age.permit,
    obsint.debriefed_age.vessel,
    obsint.debriefed_age.gear,
    obsint.debriefed_age.nmfs_area,
    obsint.debriefed_age.length,
    obsint.debriefed_age.weight,
    obsint.debriefed_age.species,
    obsint.debriefed_age.specimen_number,
    obsint.debriefed_age.specimen_type,
    obsint.debriefed_age.year,
    obsint.debriefed_age.barcode,
    obsint.debriefed_age.haul_offload
FROM
    obsint.debriefed_age
WHERE
    obsint.debriefed_age.nmfs_area BETWEEN 500 AND 539
    AND obsint.debriefed_age.specimen_type = 1
    AND obsint.debriefed_age.species = 202
    AND obsint.debriefed_age.year = 2023")


#datax<- data.table(sqlQuery(AFSC,test,as.is=c(F,F,F,F,F,F,F,F,F,F,F,F,F)))
datax <- sql_run(afsc,test)

report_sample<-function(data,nsamp){
	require(data.table)
	data<-data.table(data)
	

    data$AREA<-520
    data[NMFS_AREA<520]$AREA<-500
    data<-data[GEAR!=2]

    data<-data[order(YEAR,NMFS_AREA,GEAR),]
	data$INDEX <- 1:nrow(data)
	sdata<-setNames(data.table(matrix(nrow=0,ncol=ncol(data))),names(data))

   yr<-unique(data$YEAR)

   for(i in 1:length(yr)){
		data1<-data[YEAR==yr[i]]
		ar<-unique(data1$AREA)
		for(j in 1:length(ar)){
			data2<-data1[AREA==ar[j]]
			if(nrow(data2) > nsamp){
				samp  <- sample(data2$INDEX,nsamp)
				data3 <- data2[INDEX%in%samp]
				sdata <- rbind(sdata,data3)}
			else { 
				if(nrow(data2)>=50){sdata<-rbind(sdata,data2)}
			}
		} 	
	}



Jdata<-sdata[,c("YEAR","CRUISE","PERMIT","HAUL_OFFLOAD","SPECIMEN_NUMBER","BARCODE")]
Jdata<-Jdata[YEAR!=2007]

write.csv(Jdata,"Jdata.csv")

}
report_sample(datax,200)

sampled<-data.table(read.csv("Jdata.csv"))


datax<-data.table(datax)
datax$AREA<-520
datax[NMFS_AREA<520]$AREA<-500

sampled$PERMIT<-as.numeric(sampled$PERMIT)
datax$PERMIT<-as.numeric(datax$PERMIT)

datax1<-merge(sampled,datax,all.x=T)
datax3<-merge(sampled,datax,all=T)
datax3$SAMPLED<-1
datax3[is.na(X)]$SAMPLED<-0

datax3.1<-datax3[,list(tot=length(SPECIMEN_NUMBER)),by="YEAR,AREA,SAMPLED,LENGTH"]
#datax3.1<-datax3[,list(tot=length(SPECIMEN_NUMBER)),by="YEAR,GEAR,SAMPLED,LENGTH"]
datax3.2<-datax3[,list(tot_year=length(SPECIMEN_NUMBER)),by="YEAR,AREA,SAMPLED"]
datax3.1<-merge(datax3.1,datax3.2,all=T)
datax3.1$PROP<-datax3.1$tot/datax3.1$tot_year

d<-ggplot(datax3.1,aes(x=LENGTH,y=PROP,group=factor(SAMPLED),color=factor(SAMPLED)))
 d<-d+geom_line()
 d<-d+facet_wrap(~AREA)
 d




datax1.1<-datax1[,list(tot=length(SPECIMEN_NUMBER)),by="YEAR,AREA,LENGTH"]

datax1.2<-datax1[,list(tot=length(SPECIMEN_NUMBER)),by="YEAR,AREA,GEAR,LENGTH"]

grid<-expand.grid(YEAR=unique(datax1.1$YEAR),AREA=unique(datax1.1$AREA),LENGTH=c(1:max(datax1.1$LENGTH)))

datax2=merge(grid,datax1.1,by=c("YEAR","AREA","LENGTH"),all=T)
datax2[is.na(datax2)]<-0

 d<-ggplot(datax2,aes(x=LENGTH,y=tot,group=factor(AREA),color=factor(AREA)))
 d<-d+geom_line()
 d<-d+facet_wrap(~YEAR)
 d

datar<-datax[,list(tot=length(SPECIMEN_NUMBER)),by="YEAR,AREA,LENGTH"]
grid<-expand.grid(YEAR=unique(datar$YEAR),AREA=unique(datar$AREA),LENGTH=c(1:max(datar$LENGTH)))

datar=merge(grid,datar,by=c("YEAR","AREA","LENGTH"),all=T)
datar[is.na(datar)]<-0
datar<-data.table(datar)


 d<-ggplot(datar,aes(x=LENGTH,y=tot,group=factor(AREA),color=factor(AREA)))
 d<-d+geom_line()
 d<-d+facet_wrap(~YEAR)
 d

 datar1<-data[,list(tot=length(INDEX)),by="YEAR,AREA"]
 datas1<-sdata[,list(tot=length(INDEX)),by="YEAR,AREA"]