
## Recr, F, SSB, Bratio
TEST<-function(models=models,endyr=2022,lab='Recr'){

	ssb<-data.frame(YEAR=c(1977:2037),value=data.table(models[[1]]$derived_quants)[Label%like%paste0(lab,"_19")|Label%like%paste0(lab,"_20")]$Value,sd=data.table(models[[1]]$derived_quants)[Label%like%paste0(lab,"_19")|Label%like%paste0(lab,"_20")]$StdDev)
	ssb<-subset(ssb,YEAR%in%1977:endyr)
	N_SSB<-nrow(ssb)
	sab<-matrix(ncol=13,nrow=N_SSB)
	sab[,12]<-ssb$value
	sab[,13]<-ssb$sd
	sab[,1]<-ssb$YEAR
	j<-c(11:2)
	for(i in 1:10){
 		x<-data.table(models[[i+1]]$derived_quants)[Label%like%paste0(lab,"_19")|Label%like%paste0(lab,"_20")]
 		x$YEAR<-1977:2037
 		x<-x[YEAR%in%c(1977:(endyr-i))]
   		sab[1:(N_SSB-i),j[i]]<- x$Value

   }
	SAB=data.frame(sab)
	names(SAB)<-c("Year",paste0(lab,"_",seq(10,0,-1)),paste0(lab,"_0SD"))
	SAB
}



## Recr, F, SSB, Bratio
wt<-function(Models=Models1,e1=2022,lab1='SSB', weights=WT){
	require(data.table)
	require(ggplot2)
	rt<-vector("list",length=length(Models))
	for (i in 1:length(Models)){
		 rt[[i]]<-TEST(models=Models[[i]],endyr=e1,lab=lab1)

	 	if(i==1){
		 	BASE=rt[[i]][,12]
		 }

		rt[[i]][2:12]<-rt[[i]][2:12]*weights[i]
		rt[[i]]$MODEL<-Models[i]
		}
		x=rt[[1]][,2:12]+rt[[2]][,2:12]+rt[[3]][,2:12]+rt[[4]][,2:12]+rt[[5]][,2:12]
        x=x/sum(weights)
        rt2<-data.frame(YEAR=1977:e1,x,BASE=BASE)
        rt3<-data.table(rt2[,c(1,12,13)])
        names(rt3)<-c('Year','Ensemble','Base')
        rt3<-melt(rt3,'Year')
        d=ggplot(rt3,aes(x=Year,y=value,color=variable))+geom_line(size=1.25)+theme_bw(base_size=16)+labs(x='Year',y=paste(lab1),color='Model')
        pdf(paste0(lab1,".pdf"),width=10,height=5)
        	print(d)
        dev.off()
        windows()
        print(d)
        rt2
        
    }



## WT=c(0.2842,0.3158,0.2316,0.1684)
## calculating ensemble values for values in the derived quants file.

ensemble<-function(models=mods1,lab="ForeCatch_2023",weights=WT){
   nmods<-nrow(summary(models))
	MSY=array()
	for(j in 1:nmods){
		MSY[j]<-data.table(models[[j]]$derived_quants)[Label==lab]$Value*weights[j]
	}
       MSY<-sum(MSY)/sum(weights)
       MSY
   }

#ensemble_SD<-function(models=mods1,lab="ForeCatch_2023",weights=WT){
#   nmods<-nrow(summary(models))
#	MSY=array()
#	for(j in 1:nmods){
#		MSY[j]<-(data.table(models[[j]]$derived_quants)[Label==lab]$StdDev^2)*weights[j]
#	}
#      MSY<-sum(MSY)/sum(weights)
#      MSY
#   }
        


get_models<-function(dir="C:/WORKING_FOLDER/EBS_COD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS", retros=c('MODEL19_12/retrospectives','MODEL19_12A/retrospectives','MODEL_21_1/retrospectives','MODEL_21_2/retrospectives')){
	require(data.table)
	require(ggplot2)
		
	Models=vector("list",length=length(retros))
	for (i in 1:length(retros)){
		setwd(paste0(dir,"/",retros[i]))
		model_1<-c(paste(getwd(),"/retro0",sep=""),paste(getwd(),"/retro-1",sep=""),paste(getwd(),"/retro-2",sep=""),
    		paste(getwd(),"/retro-3",sep=""),paste(getwd(),"/retro-4",sep=""),paste(getwd(),"/retro-5",sep=""),
    		paste(getwd(),"/retro-6",sep=""),paste(getwd(),"/retro-7",sep=""),paste(getwd(),"/retro-8",sep=""),
    		paste(getwd(),"/retro-9",sep=""),paste(getwd(),"/retro-10",sep=""))
		Models[[i]]<-SSgetoutput(dirvec=model_1)
	 	
		 }

		Models
        
    }



Plot_ensembleRetro<-function(SAB=RW,lab="SSB",CI=FALSE){

	names(SAB)[1]<-'YEAR'
	x<-SAB[,2:13]
	x=max(x[!is.na(x)])

	ramp=colorRampPalette(c("indianred4","ivory2") )
	colors= ramp(10)
	layout(matrix(c(0,1,2,0), 4, 1, byrow = TRUE),heights=c(0.3,1,1,0.3))

	par(mar=c(0.1,8,0.1,0.5))
		l1<- length(SAB[1,])-1
		LCI<- SAB[,l1]-(1.96*SAB[,length(SAB[1,])])
		UCI<- SAB[,l1]+(1.96*SAB[,length(SAB[1,])])
		plot(SAB$YEAR,SAB[,l1],type="l",lwd=3,xaxt="n",las=2,xlab="",ylab="",cex.axis=1.5,ylim=c(0,x),lty=3)
		
		if(CI){
			points(SAB$YEAR,LCI,type="l",lty=3,col="red",lwd=2)
			points(SAB$YEAR,UCI,type="l",lty=3,col="red",lwd=2)
		}

		text(2004,x,"2022",pos=4,col="black")
		for(i in 1:10) {
			lines(SAB$YEAR,SAB[,(l1-i)],lwd=1.75,col=colors[i])
		}
		k=seq(2021,2012,-1)
		for(j in 1:10){
			text(2004,(x-j*(x/20)),paste(k[j]),pos=4,col=colors[j])
		}

	
		mtext(lab,side=2,line=6,cex=1.)

		plot(SAB$YEAR,100*(SAB[,(l1)]-SAB[,(l1)])/SAB[,(l1)],type="l",lwd=3,xaxt="n",las=2,xlab="",ylab="",
   			 cex.axis=1.4,ylim=c(-90,90),lty=2)
		if(CI){
			points(SAB$YEAR,100*(UCI-SAB[,(l1)])/SAB[,(l1)],type="l",lty=3,col="red",lwd=2 )
			points(SAB$YEAR,100*(LCI-SAB[,(l1)])/SAB[,(l1)],type="l",lty=3,col="red",lwd=2 )
	 	}
		for(i in 1:10) {
			lines(SAB$YEAR,100*(SAB[,(l1-i)]-SAB[,l1])/SAB[,l1],lwd=1.75,col=colors[i]) }

		mtext("Percent differences",side=2,line=6,cex=1.)
		mtext("from terminal year",side=2,line=4.5,cex=1.)

		for(y in seq(1,length(SAB$YEAR),2)){
			axis(side=1,at=SAB$YEAR[y],SAB$YEAR[y],cex.axis=1.2,las=2)}

			mtext("Year",side=1,line=4.6,cex=1.)
		}





library(stringr)
setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model19_12","GRANT_MODELS/Model19_12A","GRANT_MODELS/Model_21_1","GRANT_MODELS/Model_21_2")
mods1<-SSgetoutput(dirvec=mods)


	labels<-mods1[[1]]$derived_quants$Label
    EDQ<-matrix(ncol=3,nrow=length(labels))
    EDQ[,1]<-labels
  	
  	   for(j in 1:length(labels)){
		  EDQ[j,2]<- as.numeric(ensemble(mods1,lab=labels[j]))
		}

mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods1<-SSgetoutput(dirvec=mods)

for(j in 1:length(labels)){
		  EDQ[j,3]<- as.numeric(ensemble(mods1,lab=labels[j]))
		}


    nam=c("Thompson","New")

    EDQ_Thompson<-data.table(EDQ)
	names(EDQ_Thompson)<-c("Label",nam)
	EDQ<-melt(EDQ_Thompson,"Label")
     EDQ$value=as.numeric(EDQ$value)
	 EDQ$YEAR=as.numeric(stringr::str_sub(EDQ$Label,start=-4))
	 EDQ$ITEM=do.call(rbind,str_split(EDQ$Label,"_"))[,1]



    items<-unique(EDQ[!is.na(YEAR)]$ITEM)
    pdf("ensembles.pdf",width=10,height=6)
    for(i in 1:length(items)){
	d=ggplot(EDQ[ITEM==items[i]& !is.na(YEAR)],aes(x=YEAR,y=value,color=variable))+geom_line()+geom_point()+theme_bw(base_size=16)+labs(y=items[i],x='Year',title=items[i])
    print(d)
    }
    dev.off()

    SSB<-EDQ[ITEM=='SSB'&!is.na(YEAR)]
    SSB$PERC=0
    SSB_UN<-EDQ[Label=='SSB_unfished']
    SSB[variable=='New']$PERC<-SSB[variable=='New']$value/SSB_UN[variable=='New']$value
    SSB[variable=='Thompson']$PERC<-SSB[variable=='Thompson']$value/SSB_UN[variable=='Thompson']$value

    d=ggplot(SSB[YEAR<2025,aes(x=YEAR,y=PERC,color=variable))+geom_line()+geom_point()+theme_bw(base_size=16)+labs(y="SSB%",x='Year',title="SSB%")
    print(d)
 




profiles_19.12<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS/Model19_12/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)
profiles_19.12A<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS/Model19_12A/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)
profiles_21.1<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS/Model_21_1/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)
profiles_21.2<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS/Model_21_2/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)



profiles_NEW_19.12<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS/Model19_12/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)
profiles_NEW_19.12A<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS/Model19_12A/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)
profiles_NEW_21.1<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS/Model_21_1/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)
profiles_NEW_21.2<-Do_AK_Scenarios(DIR="C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS/Model_21_2/PROJ",CYR=2022,SYR=1977,SEXES=1,FLEETS=c(1),Scenario2=1,S2_F=0.4,do_fig=TRUE)



WT=c(0.2842,0.3158,0.2316,0.1684)

SSB<-profiles_NEW_19.12$Tables$SSB[,2:8]*WT[1]+profiles_NEW_19.12A$Tables$SSB[,2:8]*WT[2]+profiles_NEW_21.1$Tables$SSB[,2:8]*WT[3]+profiles_NEW_21.2$Tables$SSB[,2:8]*WT[4]
Catch<-profiles_NEW_19.12$Tables$Catch[,2:8]*WT[1]+profiles_NEW_19.12A$Tables$Catch[,2:8]*WT[2]+profiles_NEW_21.1$Tables$Catch[,2:8]*WT[3]+profiles_NEW_21.2$Tables$Catch[,2:8]*WT[4]
F<-profiles_NEW_19.12$Tables$F[,2:8]*WT[1]+profiles_NEW_19.12A$Tables$F[,2:8]*WT[2]+profiles_NEW_21.1$Tables$F[,2:8]*WT[3]+profiles_NEW_21.2$Tables$F[,2:8]*WT[4]

SSB<-data.table(Yr=profiles_NEW_19.12$Tables$SSB$Yr,SSB)
F<-data.table(Yr=profiles_NEW_19.12$Tables$SSB$Yr,F)
Catch<-data.table(Yr=profiles_NEW_19.12$Tables$SSB$Yr,Catch)


Two_year<-profiles_NEW_19.12$Two_year[,2:10]*WT[1]+profiles_NEW_19.12A$Two_year[,2:10]*WT[2]+profiles_NEW_21.1$Two_year[,2:10]*WT[3]+profiles_NEW_21.2$Two_year[,2:10]*WT[4]
Two_year<-data.table(Yr=profiles_NEW_19.12$Two_year$Yr,Two_year)

profiles_Ensemble_NEW<-list(SSB=SSB,Catch=Catch,F=F,Two_year=Two_year)




SSB<-profiles_19.12$Tables$SSB[,2:8]*WT[1]+profiles_19.12A$Tables$SSB[,2:8]*WT[2]+profiles_21.1$Tables$SSB[,2:8]*WT[3]+profiles_21.2$Tables$SSB[,2:8]*WT[4]
Catch<-profiles_19.12$Tables$Catch[,2:8]*WT[1]+profiles_19.12A$Tables$Catch[,2:8]*WT[2]+profiles_21.1$Tables$Catch[,2:8]*WT[3]+profiles_21.2$Tables$Catch[,2:8]*WT[4]
F<-profiles_19.12$Tables$F[,2:8]*WT[1]+profiles_19.12A$Tables$F[,2:8]*WT[2]+profiles_21.1$Tables$F[,2:8]*WT[3]+profiles_21.2$Tables$F[,2:8]*WT[4]

SSB<-data.table(Yr=profiles_19.12$Tables$SSB$Yr,SSB)
F<-data.table(Yr=profiles_19.12$Tables$SSB$Yr,F)
Catch<-data.table(Yr=profiles_19.12$Tables$SSB$Yr,Catch)


Two_year<-profiles_19.12$Two_year[,2:10]*WT[1]+profiles_19.12A$Two_year[,2:10]*WT[2]+profiles_21.1$Two_year[,2:10]*WT[3]+profiles_21.2$Two_year[,2:10]*WT[4]
Two_year<-data.table(Yr=profiles_19.12$Two_year$Yr,Two_year)

profiles_Ensemble_GRANT<-list(SSB=SSB,Catch=Catch,F=F,Two_year=Two_year)




## ss -hess_step -binp ss.bar