
devtools::install_github("r4ss/r4ss")
require(PBSadmb)
require(r4ss)


# test.retro<-function(n=10){
#     direct=getwd()
#     test<-array(dim=n)
#     for(i in 1:n){
#         setwd(paste(direct,"/retro-",i,sep=''))
#         test[i]<-file.exists("Report.sso")
#         if(file.exists("Report.sso")){ 
#              rephead <- readLines(con = "Report.sso", n = 88)
#              LL=as.numeric(substring(rephead[86], 12, 20))
#             test[i]<-!is.na(LL)}
#     }
#     test2<-data.frame(ID=c(1:n),test=ifelse(test==TRUE,1,0))
#     setwd(direct)
#     return(test2)
# }



# #==============
# setwd("B:/Stock_Assessments/GOA_PCOD_2015/Models/M27")
# setwd(paste(getwd(),"/Model16.7.3NE.retro",sep=""))  ## set the directory where the retrospectives reside.


# setwd("B:/Stock_Assessments/Greenland_Turbot_2016/November Models/Good_Models")
# setwd(paste(getwd(),"/Model15.1.retro",sep=""))  ## set the directory where the retrospectives reside.

# setwd("c:/Work Folder for DOCS/Final_Models")

# setwd(paste(getwd(),"/Model16.11.23NF.retro",sep=""))  ## set the directory where the retrospectives reside.



test.retro<-function(dir=getwd(), folder=folds[5]){

setwd(paste0(dir,"/",folder))    

model1<-SS_output(paste(getwd(),"/retro0",sep=""))

mods<-c("retro0","retro-1","retro-2","retro-3","retro-4","retro-5","retro-6","retro-7","retro-8","retro-9","retro-10")

Models1<-SSgetoutput(dirvec=mods)
Models1_SS<-SSsummarize(Models1)

#SSplotComparisons(Models1_SS)

#==============================================================================
#============= Get Working Directories
#============================================================================================
#############

pathD<-getwd()
#============================================================================================
#============= Read in plot data
#============================================================================================

YEARS<-model1$timeseries$Yr
YEARS<-YEARS[1:(length(YEARS)-12)]

ssb<-data.frame(YEAR=YEARS[3:length(YEARS)],value=model1$derived_quants[3:length(YEARS),2],sd=model1$derived_quants[3:length(YEARS),3]) 
rec<-data.frame(YEAR=YEARS[3:length(YEARS)],value=model1$timeseries$Recruit_0[3:length(YEARS)],sd=subset(model1$derived_quants,strtrim(model1$derived_quants[,1],4)=="Recr")[3:length(YEARS),3]) 

N_SSB<-nrow(ssb)
sab<-matrix(ncol=13,nrow=N_SSB)
sab[,12]<-ssb$value
sab[,13]<-ssb$sd
sab[,1]<-ssb$YEAR
j<-c(11:2)
for(i in 1:10){
   sab[1:(N_SSB-i),j[i]]<- Models1[[(i+1)]]$timeseries$SpawnBio[Models1[[(i+1)]]$timeseries$Yr>=min(YEARS+2)& Models1[[(i+1)]]$timeseries$Yr<=(max(YEARS)-i)]
}


rac<-matrix(ncol=13,nrow=N_SSB)
rac[,12]<-rec$value
rac[,13]<- rec$sd
rac[,1]<-rec$YEAR
j<-c(11:2)
for(i in 1:10){
   rac[1:(N_SSB-i),j[i]]<- Models1[[(i+1)]]$timeseries$Recruit_0[Models1[[(i+1)]]$timeseries$Yr>=min(YEARS+2)& Models1[[(i+1)]]$timeseries$Yr<=(max(YEARS)-i)]
}

RAC=data.frame(rac)
names(RAC)<-c("Year",paste("M_",seq(10,0,-1)),"M_0SD")
RAC<-subset(RAC,RAC$Year>=1977)



	#y<-paste("testM_",i,sep="")
	#sab[1:(N_SSB-i),(j[i])]<-get(y)$SSB[,2]
#

SAB=data.frame(sab)
names(SAB)<-c("Year",paste("M_",seq(10,0,-1)),"M_0SD")

SAB<-subset(SAB,SAB$Year>=1977)
#SAB<-read.csv(paste(pathD,"/AIRETRO.csv",sep=""))
# If your data is in tons, not kilotons use line below
#SAB[,2:(length(SAB[1,]))]<-SAB[,2:(length(SAB[1,]))]/1000

#============================================================================================
#============= Plot it up... adjust start on rainbow if you don't like the colors
#============================================================================================

#colors<-rainbow(9,start=0.4)
windows()
ramp=colorRampPalette(c("indianred4","ivory2") )
colors= ramp(10)
layout(matrix(c(0,1,2,0), 4, 1, byrow = TRUE),heights=c(0.3,1,1,0.3))

par(mar=c(0.1,8,0.1,0.5))
l1<- length(SAB[1,])-1
LCI<- SAB[,l1]-(1.96*SAB[,length(SAB[1,])])
UCI<- SAB[,l1]+(1.96*SAB[,length(SAB[1,])])
plot(SAB$Year,SAB[,l1],type="l",lwd=3,xaxt="n",las=2,xlab="",ylab="",cex.axis=1.5,ylim=c(0,1100000),lty=3)
points(SAB$Year,LCI,type="l",lty=3,col="red",lwd=2)
points(SAB$Year,UCI,type="l",lty=3,col="red",lwd=2)

text(2004,1100000,"2021",pos=4,col="black")
for(i in 1:10) {
lines(SAB$Year,SAB[,(l1-i)],lwd=1.75,col=colors[i])
}
k=seq(2020,2010,-1)
for(j in 1:10){
text(2004,(1100000-j*50000),paste(k[j]),pos=4,col=colors[j])
}




mtext("Spawning biomass (t)",side=2,line=6,cex=1.)

plot(SAB$Year,100*(SAB[,(l1)]-SAB[,(l1)])/SAB[,(l1)],type="l",lwd=3,xaxt="n",las=2,xlab="",ylab="",
	cex.axis=1.4,ylim=c(-90,90),lty=2)
points(SAB$Year,100*(UCI-SAB[,(l1)])/SAB[,(l1)],type="l",lty=3,col="red",lwd=2 )
points(SAB$Year,100*(LCI-SAB[,(l1)])/SAB[,(l1)],type="l",lty=3,col="red",lwd=2 )
for(i in 1:10) {
lines(SAB$Year,100*(SAB[,(l1-i)]-SAB[,l1])/SAB[,l1],lwd=1.75,col=colors[i]) }

mtext("Percent differences",side=2,line=6,cex=1.)
mtext("from terminal year",side=2,line=4.5,cex=1.)

for(y in seq(1,length(SAB$Year),2)){
axis(side=1,at=SAB$Year[y],SAB$Year[y],cex.axis=1.2,las=2)}

mtext("Year",side=1,line=4.6,cex=1.)



S_N<-nrow(SAB)
x<-array(dim=10)
for(i in 1:10){
	x[i]<-(SAB[(S_N-i),(12-i)]-SAB[(S_N-i),12])/SAB[(S_N-i),12]
}
rho=sum(x)/10


x<-matrix(ncol=10,nrow=53)
for(i in 1:10){
	x[1:(54-i),i]<-(SAB[1:(54-i),(12-i)]-SAB[1:(54-i),12])/SAB[1:(54-i),12]
}
y<-array(dim=10)

for( i in 1:10){
	y[i]<-sum(x[,i][!is.na(x[,i])]/length(x[,i][!is.na(x[,i])]))
}

WH_rho<-sum(y)/10



x<-matrix(ncol=10,nrow=53)
for(i in 1:10){
	x[1:(54-i),i]<-(log(SAB[1:(54-i),(12-i)])-log(SAB[1:(54-i),12]))^2
}

RMSE=sqrt(sum(x[!is.na(x)])/length(x[!is.na(x)]))



windows()

ramp=colorRampPalette(c("indianred4","ivory2") )
colors= ramp(10)
layout(matrix(c(0,1,2,0), 4, 1, byrow = TRUE),heights=c(0.3,1,1,0.3))

par(mar=c(0.1,8,0.1,0.5))
l1<- length(RAC[1,])-1
LCI<- RAC[,l1]-(1.96*RAC[,length(RAC[1,])])
UCI<- RAC[,l1]+(1.96*RAC[,length(RAC[1,])])
plot(RAC$Year,RAC[,l1],type="l",lwd=3,xaxt="n",las=2,xlab="",ylab="",cex.axis=1.5,ylim=c(0,2000000),lty=3)
points(RAC$Year,LCI,type="l",lty=3,col="red",lwd=2)
points(RAC$Year,UCI,type="l",lty=3,col="red",lwd=2)

text(2015,2000000,"2021",pos=4,col="black")
for(i in 1:10) {
lines(RAC$Year,RAC[,(l1-i)],lwd=1.75,col=colors[i])
}
k=seq(2020,2010,-1)
for(j in 1:10){
text(2015,(2000000-j*75000),paste(k[j]),pos=4,col=colors[j])
}




mtext("Age-0 Recruitment",side=2,line=6,cex=1.)

plot(RAC$Year,100*(RAC[,(l1)]-RAC[,(l1)])/RAC[,(l1)],type="l",lwd=3,xaxt="n",las=2,xlab="",ylab="",
	cex.axis=1.4,ylim=c(-100,100),lty=2)
points(RAC$Year,100*(UCI-RAC[,(l1)])/RAC[,(l1)],type="l",lty=3,col="red",lwd=2 )
points(RAC$Year,100*(LCI-RAC[,(l1)])/RAC[,(l1)],type="l",lty=3,col="red",lwd=2 )
for(i in 1:10) {
lines(RAC$Year,100*(RAC[,(l1-i)]-RAC[,l1])/RAC[,l1],lwd=1.75,col=colors[i]) }

mtext("Percent differences",side=2,line=6,cex=1.)
mtext("from terminal year",side=2,line=4.5,cex=1.)

for(y in seq(1,length(RAC$Year),2)){
axis(side=1,at=RAC$Year[y],RAC$Year[y],cex.axis=1.2,las=2)}

mtext("Year",side=1,line=4.6,cex=1.)



S_N<-nrow(RAC)
x<-array(dim=10)
for(i in 1:10){
	x[i]<-(RAC[(S_N-i),(12-i)]-RAC[(S_N-i),12])/RAC[(S_N-i),12]
}
R_rho=sum(x)/10


x<-matrix(ncol=10,nrow=53)
for(i in 1:10){
	x[1:(54-i),i]<-(RAC[1:(54-i),(12-i)]-RAC[1:(54-i),12])/RAC[1:(54-i),12]
}
y<-array(dim=10)

for( i in 1:10){
	y[i]<-sum(x[,i][!is.na(x[,i])]/length(x[,i][!is.na(x[,i])]))
}

R_WH_rho<-sum(y)/10



x<-matrix(ncol=10,nrow=53)
for(i in 1:10){
	x[1:(54-i),i]<-(log(RAC[1:(54-i),(12-i)])-log(RAC[1:(54-i),12]))^2
}

R_RMSE=sqrt(sum(x[!is.na(x)])/length(x[!is.na(x)]))

Results<-c(rho,WH_rho,RMSE,R_rho,R_WH_rho,R_RMSE)
print(rho)
print(WH_rho)
print(RMSE)

print(R_rho)
print(R_WH_rho)
print(R_RMSE)
return(Results)
}


RESULTS<-vector("list",length=length(folds))

for(i in 15:length(folds)){
RESULTS[[i]]<-test.retro(folder=folds[i])
}

RES <- do.call(rbind,RESULTS)
RES$MODEL <- folds









x<-rownames(Models1[[10]]$estimated_non_dev_parameters)


Models1[[1]]$estimated_non_dev_parameters[c(x),1] #  [c(1:77,79,81,83,85,87),1]


parameters1<-data.frame(matrix(ncol=12,nrow=56))
parameters1[,1]<-x

for(i in 2:12)
    {
     parameters1[,i] <- Models1[[(i-1)]]$estimated_non_dev_parameters[c(x),1]

    }

    par(mfrow=c(4,5))

for(i in 1:20){
    plot(as.numeric(parameters1[i,2:12])~c(0:10),xlab="Years retro",ylab=paste(parameters1[i,1]))
}


Models1[[i]]$Param[,3]




 
params=c("Nat. Mort", "L0.5", "Linf", "K", "CV_young", "CV_old,LN(R0)", "Init F Trawl","Init F Longline", "Q")
 MODS=c("1","20","2.3","11","2.4","15","2.5","22")

parameters1<-data.frame(matrix(ncol=9,nrow=10))
parameters1[,1]<-MODS16[[1]]$param[c(1:6,17,84,85,87),2]

for(i in 2:9)
    {
     parameters1[,i] <- MODS16[[(i-1)]]$param[c(1:6,17,84,85,87),3]
    }

    par(mfrow=c(2,5),mar=c(4,4,0.25,0.25))

for(i in 1:10){
    plot(as.numeric(parameters1[i,2:9])~c(1:8),xaxt="n",xlab="Model",ylab=paste(params[i]),pch=c(16,17),cex=1.75,col=c("red","blue"))
    axis(1, at=1:8, labels=MODS[1:8],cex=0.25)
}


params=c("Nat. Mort", "L0.5", "Linf", "K", "CV_young", "CV_old","LN(R0)", "Init F Trawl","Init F Longline", "LN(Q)")
 #MODS=c("1","20","2.3","11","2.4","15","2.5","22")
 #MODS=c("6","7","6.0","7.0","6.1","7.1","6.3","7.2","20","7.3")

 MODS=c("-","0","1","2.1","2.2","3","11","15","20","22")

all.m<-c("M15","M16.6","M16.6.0","M16.6.1","M16.6.2.1Q","M16.6.2.2M","M16.6.2.3S","M16.6.2.4QM","M16.6.5QMS","M16.6.3","M16.6.4.1","M16.6.4.2","M16.6.11","M16.6.15","M16.6.20","M16.6.22","M16.7","M16.7.0","M16.7.1","M16.7.2","M16.7.3")

mods1=c(2:4,10:16)


parameters1<-data.frame(matrix(ncol=21,nrow=10))
parameters1[,1]<-MODS16[[2]]$param[c(1:6,17,84,85,87),2]

for(i in 3:22)
    {
     parameters1[,i-1] <- MODS16[[(i-1)]]$param[c(1:6,17,84,85,87),3]
    }

MODS=c("-","0","1","3","4.1","4.2","11","15","20","22")
mods1=c(2:4,10:16)
    par(mfrow=c(2,5),mar=c(1,4,1,0.2),oma=c(2,0,0,0))

for(i in 1:10){
    plot(as.numeric(parameters1[i,mods1])~c(1:10),xaxt="n",xlab="Model",ylab=paste(params[i]),pch=c(16),cex=1.75,col=ramp(10)[i])
    axis(1, at=1:10, labels=MODS[1:10],cex.axis=0.67)
}


MODS=c("1","20","2.3","11","2.4","15","2.5","22")
mods1=c(4,17,7,13,8,14,9,16)
    par(mfrow=c(2,4),mar=c(1,4,1,0.2),oma=c(2,0,0,0))

for(i in 1:8){
    plot(as.numeric(parameters1[i,mods1])~c(1:8),xaxt="n",xlab="Model",ylab=paste(params[i]),pch=c(16,17),cex=1.75,col=c("red","blue"))
    axis(1, at=1:8, labels=MODS[1:8],cex.axis=0.75)
}


MODS=c("6","7","6.0","7.0","6.1","7.1","6.3","7.2","20","7.3")
mods1=c(2,17,3,18,4,19,10,20,15,21)
    par(mfrow=c(2,5),mar=c(1,4,1,0.2),oma=c(2,0,0,0))

for(i in 1:10){
    plot(as.numeric(parameters1[i,mods1])~c(1:10),xaxt="n",xlab="Model",ylab=paste(params[i]),pch=c(16,17),cex=1.75,col=c("red","blue"))
    axis(1, at=1:10, labels=MODS[1:10],cex.axis=0.67)
}







Models1[[1]]$estimated_non_rec_devparameters[c(1:27),1]
parameters1<-data.frame(matrix(ncol=12,nrow=27))
parameters1[,1]<-Models1[[1]]$estimated_non_rec_devparameters[c(1:27),1]

for(i in 2:12)
    {
     parameters1[,i] <- Models1[[(i-1)]]$estimated_non_rec_devparameters[c(1:27),2]

    }

    par(mfrow=c(4,5))

for(i in 1:20){
    plot(as.numeric(parameters1[i,2:12])~c(0:10),xlab="Years retro",ylab=paste(parameters1[i,1]))
}
