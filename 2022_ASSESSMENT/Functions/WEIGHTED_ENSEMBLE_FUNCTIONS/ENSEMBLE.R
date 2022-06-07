
## Recr, F, SSB, Bratio
TEST<-function(models=models,endyr=2019,lab='Recr'){

	ssb<-data.frame(YEAR=c(1977:2031),value=data.table(models[[1]]$derived_quants)[Label%like%paste0(lab,"_19")|Label%like%paste0(lab,"_20")]$Value,sd=data.table(models[[1]]$derived_quants)[Label%like%paste0(lab,"_19")|Label%like%paste0(lab,"_20")]$StdDev)
	ssb<-subset(ssb,YEAR%in%1977:endyr)
	N_SSB<-nrow(ssb)
	sab<-matrix(ncol=13,nrow=N_SSB)
	sab[,12]<-ssb$value
	sab[,13]<-ssb$sd
	sab[,1]<-ssb$YEAR
	j<-c(11:2)
	for(i in 1:10){
 		x<-data.table(models[[i+1]]$derived_quants)[Label%like%paste0(lab,"_19")|Label%like%paste0(lab,"_20")]
 		x$YEAR<-1977:2031
 		x<-x[YEAR%in%c(1977:(endyr-i))]
   		sab[1:(N_SSB-i),j[i]]<- x$Value

   }
	SAB=data.frame(sab)
	names(SAB)<-c("Year",paste0(lab,"_",seq(10,0,-1)),paste0(lab,"_0SD"))
	SAB
}



## Recr, F, SSB, Bratio
wt<-function(Models=Models1,e1=2021,lab1='SSB', weights=WT){
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



## WT=c(0.2459,0.2213,0.1803,0.1311,0.2213)
## calculating ensemble values for values in the derived quants file.

ensemble<-function(models=Models1,lab="ForeCatch_2021",weights=WT){

	MSY=array()
	for(j in 1:5){
		models1<-models[[j]]
		MSY[j]<-data.table(models1[[1]]$derived_quants)[Label==lab]$Value*weights[j]
	}
       MSY<-sum(MSY)/sum(weights)
       MSY
   }


        


get_models<-function(dir="C:/WORKING_FOLDER/EBS_COD_CIE2021/2020_Models", retros=c('retrospectives19_12a','retrospectives19_12','retrospectives20_8a','retrospectives20_9VAST_NVQ','retrospectives21_CIE')){
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




Plot_ensembleRetro<-function(SAB=RW,lab="Recruit Age-0",CI=FALSE){

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

		text(2004,x,"2020",pos=4,col="black")
		for(i in 1:10) {
			lines(SAB$YEAR,SAB[,(l1-i)],lwd=1.75,col=colors[i])
		}
		k=seq(2019,2010,-1)
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

