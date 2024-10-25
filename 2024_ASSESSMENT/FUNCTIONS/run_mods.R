

SS_RunJitter("Model19.14.51_jitter", model = "ss", extras = "-nohess", 50)




setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models/Averaging")
mods<-c("Model19.14.47_Fish_oneselect","Model19.14.47_Fish_oneselect_survey_on","Model19.14.47_Fish_Block","Model19.14.47_Fish_Block_survey_on","Model19.14.47_Fish_Annual","Model19.14.47_Fish_Annual_survey_on")

mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)


models=dir()

 models=models[c(5,6,1,3,4,7,8,11,9)]

mods1<-SSgetoutput(dirvec=models)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=models)





setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/November 2019")
mods<-c("Model19.14.48c_T","Model19.14.48c_T_VAST")
mods2<-c("Model19.14.48c","Model19.14.48c_VAST")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods2)



setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
mods<-c("Model18.10.44","Model19.14.48d","Model19.14.51","Model19.14.52")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)


setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
mods<-c("Model19.14.48d","Model19.14.51")
mods1<-SSgetoutput(dirvec=mods)
#mods1[[1]]$timeseries$SpawnBio[69]
#mods1[[1]]$M_at_age


modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)


setwd("Z:/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")

mods<-c("Model19.14.51","Model19.14.51_C0.66","Model19.14.51_C1.02","Model19.14.51_C1.51","Model19.14.51_C1.93","Model19.14.51_C2.67")
mods1<-SSgetoutput(dirvec=mods)
#mods1[[1]]$timeseries$SpawnBio[69]
#mods1[[1]]$M_at_age


modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)


CATCH=data.table(B0=data.table(mods1[[3]]$timeseries)[Yr==2043]$SpawnBio,CATCH_MSY=data.table(mods1[[3]]$sprseries)[Yr==2043]$Enc_Catch)  #






setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
mods<-c("Model16.14.1","Model17.14.25","Model18.10.44","Model18.11.44","Model19.11.44","Model19.12.44",
  "Model19.14.44a","Model19.14.44b","Model19.14.47","Model19.14.48a","Model19.14.48b","Model19.14.48c",
  "Model19.14.48d","Model19.14.49","Model19.14.50")

mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS,modelnames=mods)
SSplotComparisons(modsS,legendlabels=mods)

exp(mods1[[1]]$estimated_non_dev_parameters["LnQ_base_Srv(4)",]$Value)

q<-array(dim=length(mods))
for( i in 1: length(mods)){
  q[i]<-exp(mods1[[i]]$estimated_non_dev_parameters["LnQ_base_Srv(4)",]$Value)
}



x=data.table(mods1[[3]]$ageselex)[Factor=="Asel"]

x=x[,c(2,3,8:18)]
x=melt(x,c("Fleet","Yr"))
names(x)<-c("Fleet","Yr","Age","Select")
x$Age<-as.numeric(as.character(x$Age))
x$Yr<-as.numeric(as.character(x$Yr))
x$Select<-as.numeric(as.character(x$Select))
x<-x[Fleet%in% c(1:6)&Yr %in%c(1974:2018)]


grid<-data.table(expand.grid(Fleet=unique(x$Fleet),Yr=1974:2018,Age=0:10))
grid<-grid[order(Fleet,Yr,Age),]
x=merge(x,grid,all=T)
x<-x[order(Fleet,Yr,Age),]

y<-vector("list",length=11)
for(i in 0:10){
  y[[i+1]]<-x[Age==i]  
  for(j in 1: nrow(y[[i+1]])){
    if(is.na(y[[i+1]]$Select[j])) y[[i+1]]$Select[j]<-y[[i+1]]$Select[j-1]
  }
}

x2=do.call(rbind,y)


fleet<-data.table(Fleet=c(1:6),Fleet_Name=c("Trawl","Longline","Pot","BT Survey","LL Survey","IPHC Survey"))
x2<-merge(x2,fleet)
x2=x2[order(Fleet,Yr,Age),]

select = ggplot(x2) +
  geom_raster(aes(x=Age,y=Yr,fill=Select),interpolate=F) +
  scale_y_continuous("Year",expand=c(0,0),breaks=seq(1978,2018,2), limits=c(1978,2018)) +
  scale_x_continuous("Age",expand=c(0,0),breaks=seq(0,10,1),limits=c(0,10))+
  theme_bw(base_size=12)+theme(axis.text.x = element_text(hjust=1, angle = 90))+
  scale_fill_gradientn(colours=c("yellow","red"))+labs(x="Age",y="Year",title="Model19.14.51")+facet_wrap(Fleet_Name~.)

plot_gg(select, multicore=TRUE,zoom=0.65,height=4,width=6,scale=100)


phivechalf = 30 + 60 * 1/(1 + exp(seq(-7, 20, length.out = 180)/2))
phivecfull = c(phivechalf, rev(phivechalf))
thetavec = 360 + 60 * sin(seq(0,359,length.out = 360) * pi/180)
zoomvec = 0.45 + 0.2 * 1/(1 + exp(seq(-5, 20, length.out = 180)))
zoomvecfull = c(zoomvec, rev(zoomvec))


render_movie(filename = "Select_51", type = "custom", 
             frames = 360,  phi = phivecfull, zoom = zoomvecfull, theta = thetavec)


"Model19.11.44_new_data",

setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
mods<-c("Model19.11.44_new_data","Model19.11.44_new_data_proj","Model19.14.48d","Model19.14.48d_forproj")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)





setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
mods<-c("Model19.14.48d","Model19.14.48d_asymtotic")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)



setwd("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
mods<-c("Model19.14.51_newdata","Model19.14.51_asymtotic")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)









x=data.table(mods1[[9]]$sizeselex)[Factor=="Lsel"]

x=x[,c(2,3,6:122)]
x=melt(x,c("Fleet","Yr"))
names(x)<-c("Fleet","Yr","Length","Select")
x$Length<-as.numeric(as.character(x$Length))
x$Yr<-as.numeric(as.character(x$Yr))
x$Select<-as.numeric(as.character(x$Select))
x<-x[Fleet%in% c(1:6)&Yr %in%c(1974:2018)]


grid<-data.table(expand.grid(Fleet=unique(x$Fleet),Yr=1974:2018,Length=1:117))
grid<-grid[order(Fleet,Yr,Length),]
x=merge(x,grid,all=T)
x<-x[order(Fleet,Yr,Length),]

y<-vector("list",length=117)
for(i in 1:117){
  y[[i+1]]<-x[Length==i]  
  for(j in 1: nrow(y[[i+1]])){
    if(is.na(y[[i+1]]$Select[j])) y[[i+1]]$Select[j]<-y[[i+1]]$Select[j-1]
  }
}

x2=do.call(rbind,y)


fleet<-data.table(Fleet=c(1:6),Fleet_Name=c("Trawl","Longline","Pot","BT Survey","LL Survey","IPHC Survey"))
x2<-merge(x2,fleet)
x2=x2[order(Fleet,Yr,Length),]

select = ggplot(x2) +
  geom_raster(aes(x=Length,y=Yr,fill=Select),interpolate=F) +
  scale_y_continuous("Year",expand=c(0,0),breaks=seq(1978,2018,2), limits=c(1978,2018)) +
  scale_x_continuous("Length",expand=c(0,0),breaks=seq(1,120,10),limits=c(1,117))+
  theme_bw(base_size=10)+theme(axis.text.x = element_text(hjust=1, angle = 90))+
  scale_fill_gradientn(colours=c("yellow","red"))+labs(x="Length (cm)",y="Year",title="Model19.14.47")+facet_wrap(Fleet_Name~.)

plot_gg(select, multicore=TRUE,zoom=0.65,height=4,width=6,scale=100)


phivechalf = 30 + 60 * 1/(1 + exp(seq(-7, 20, length.out = 180)/2))
phivecfull = c(phivechalf, rev(phivechalf))
thetavec = 360 + 60 * sin(seq(0,359,length.out = 360) * pi/180)
zoomvec = 0.45 + 0.2 * 1/(1 + exp(seq(-5, 20, length.out = 180)))
zoomvecfull = c(zoomvec, rev(zoomvec))


render_movie(filename = "Select_48", type = "custom", 
             frames = 360,  phi = phivecfull, zoom = zoomvecfull, theta = thetavec)





mods<-c("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/November 2019/Model19.11.44_T","C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/November 2019/Model19.14.51","Model19.14.51")#,"Model19.14.51")
mods2<-c("Model19.11.44","Model19.14.51_old","Model19.14.51_new")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
#SS_plots(mods1[[8]])
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods2)


 x<-data.table(Yr=mods1[[1]]$timeseries$Yr,M18.10.44_2018=mods1[[1]]$timeseries$Bio_all,M19.14.48c=data.table(mods1[[2]]$timeseries)[Yr%in%1975:2023]$Bio_all)
 x<-x[Yr%in%1977:2020]
 y<-data.table(Yr=mods1[[1]]$timeseries$Yr,M18.10.44_2018=mods1[[1]]$timeseries$SpawnBio/2,M19.14.48c=data.table(mods1[[2]]$timeseries)[Yr%in%1975:2023]$SpawnBio/2)
 y<-y[Yr%in%1977:2020]
 x<-melt(x,"Yr")
 x$Type<-"Total Biomass"
 y<-melt(y,"Yr")
 y$Type<-"Female Spawning Biomass"
 x<-rbind(x,y)
 
 g<-ggplot(x,aes(y=value,x=Yr,color=variable,shape=Type))+geom_point(size=2)+geom_line()+theme_bw(base_size=20)+ylim(0,1000000)+labs(y="Biomass (t)",x="Year",color="Model")
 g



setwd(paste(dir,mods,sep="/"))

MCMC<-read.table("derived_posteriors.sso",header=T)
MCMC$MODEL=mods
x=sample(1:nrow(MCMC),round(nrow(MCMC)/(1*10^5)))

MCMC.1<-MCMC[x,]




setwd(paste(dir,mods1,sep="/"))

MCMC1<-read.table("derived_posteriors.sso",header=T)
MCMC1$MODEL=mods1
x=sample(1:nrow(MCMC1),round(nrow(MCMC1)/4.353485))
MCMC1.1<-MCMC1[x,]


setwd(paste(dir,mods2,sep="/"))

MCMC2<-read.table("derived_posteriors.sso",header=T)
MCMC2$MODEL=mods2

x=sample(1:nrow(MCMC2),round(nrow(MCMC2)/1.298197))

MCMC2.1<-MCMC2[x,]


MCMC3<-rbind(MCMC.1,MCMC1.1,MCMC2.1)


SSgetMCMC(dir = mods2,writecsv = TRUE)
mcmc.out(directory = getwd(), run = mods, file = "keyposteriors.csv", namefile = "postplotnames.sso",numparams=10)


dir<-c("C:/WORKING_FOLDER/Steve WorkingFolders/2019_Assessments/PCOD/September_Models")
#mods48<-c("Model19.14.48")
#mods49<-c("Model19.14.49")
#mods47<-c("Model19.14.47_Fish_Annual/Posteriors")
#mods50<-c("Model19.14.50")

mods=c("Model19.14.47","Model19.14.48","Model19.14.49","Model19.14.50")


MCMC<-vector("list",length=4)
for(i in 1:4){
	setwd(paste(dir,mods[i],sep="/"))

	MCMC[[i]]<-read.table("derived_posteriors.sso",header=T)
	MCMC[[i]]$MODEL=mods[i]
 }

  MCMC[[2]]<-subset(MCMC[[2]],select=-c(B_MSY.SSB_unfished))
  MCMC[[3]]<-subset(MCMC[[3]],select=-c(B_MSY.SSB_unfished))
    MCMC[[4]]<-subset(MCMC[[4]],select=-c(B_MSY.SSB_unfished))

  MCMC<-rbind(MCMC[[1]],MCMC[[2]],MCMC[[3]],MCMC[[4]])

  SSB<-MCMC[,5:50]/2

  Yrs=as.numeric(do.call(rbind,str_split(names(SSB),"_"))[,2])

  SSB1<-data.frame(t(SSB))
  names(SSB1)<-MCMC$MODEL
  SSB1$YEAR=Yrs

  SSB1<-data.table(melt(SSB1,"YEAR"))
  names(SSB1)<-c("YEAR","MODEL","SSB")

  MEDIANS<-SSB1[,list(MED=median(SSB)),by=c("MODEL","YEAR")]



  mcmc<-subset(MCMC,select=-c(MODEL))

  SSB<-mcmc[,5:50]

SSB1<-data.frame(Yrs=rep(Yrs,each=nrow(SSB)),SSB=0,REC=0)
SSB1$SSB[1:nrow(SSB)]<-SSB[1:nrow(SSB),1]/2
SSB1$REC[1:nrow(REC)]<-REC[1:nrow(REC),1]

for(i in 1:45){
SSB1$SSB[((i*nrow(SSB))+1):((i+1)*nrow(SSB))]<-SSB[1:nrow(SSB),i+1]/2
SSB1$REC[((i*nrow(REC))+1):((i+1)*nrow(REC))]<-REC[1:nrow(SSB),i+1]
}

SSB1<-data.table(SSB1)
MEANS=SSB1[,list(MREC=median(REC),MSSB=median(SSB)),by="Yrs"]

Ribbon=SSB1[,list(SSB2=quantile(mcmc[,3],0.025)/2*0.2/10^5,SSB97=quantile(mcmc[,3],0.975)/2*0.2/10^5)]

Ribbon<-data.table(Yrs=Yrs,SSB2=Ribbon$SSB2,SSB97=Ribbon$SSB97)

d<-ggplot()+geom_ribbon(data=Ribbon,aes(x=Yrs,ymin=SSB2,ymax=SSB97),fill="orange",alpha=0.2)
d<-d+geom_violin(data=SSB1,aes(x=Yrs,y=SSB/10^5,group=Yrs),fill="gray50")+ylim(0,max(SSB1$SSB/10^5))+
geom_line(data=MEDIANS,aes(y=MED/10^5,x=YEAR,color=MODEL,group=MODEL),size=1)+geom_line(data=MEANS,aes(y=MSSB/10^5,x=Yrs,group=""),size=1)+
geom_point(data=MEANS,aes(y=MSSB/10^5,x=Yrs,group=""))

d<-d+theme_bw(base_size=18)+scale_x_continuous(limits=c(1976.5,2022.5),breaks=seq(1977,2022,by=1))+theme( axis.text.x = element_text(hjust=1, angle = 90))
d<-d+labs(y=expression(paste("Female spawning biomass ( ",1%*%10^5," t )")), x="")
d<-d+geom_hline(yintercept=median(mcmc[,3]/2*0.2)/10^5,linetype=2)
d











setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 19.12","Model 19.12A","Model 21.1", "Model 21.2")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods_nam)


q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2022']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2022']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2022']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2022']$Value)

q1
ssb/1000
F40
catch



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT_SE")
mods<-c("Model19_12A")
mods_nam=c("Model 19.12A")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods_nam)

i=1

p3.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Value)
p3.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p4.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Value)
p4.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p5.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Value)
p5.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p6.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Value)
p6.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p7.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Value)
p7.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p8.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Value)
p8.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Parm_StDev)^2
p9.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Value)
p9.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Parm_StDev^2)

data.table(p1=c(p9.1,p8.1,p3.1,p4.1,p5.1,p6.1),p2=c(p9.2,p8.2,p3.2,p4.2,p5.2,p6.2))




setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT_SE")
mods<-c("Model19_12")
mods_nam=c("Model 19.12")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods_nam)

i=1

p3.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Value)
p3.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p4.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Value)
p4.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p5.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Value)
p5.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p6.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Value)
p6.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p7.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Value)
p7.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p8.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Value)
p8.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Parm_StDev)^2
p9.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Value)
p9.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Parm_StDev^2)

data.table(p1=c(p9.1,p8.1,p3.1,p4.1,p5.1,p6.1),p2=c(p9.2,p8.2,p3.2,p4.2,p5.2,p6.2))



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT_SE")
mods<-c("Model_21_1")
mods_nam=c("Model 21.1")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods_nam)

i=1

p3.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Value)
p3.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p4.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Value)
p4.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p5.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Value)
p5.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p6.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Value)
p6.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p7.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Value)
p7.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p8.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Value)
p8.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Parm_StDev)^2
p9.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Value)
p9.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Parm_StDev^2)

d<-data.table(p1=c(p9.1,p8.1,p3.1,p4.1,p5.1,p6.1),p2=c(p9.2,p8.2,p3.2,p4.2,p5.2,p6.2))
print(d)



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT_SE")
mods<-c("Model_21_2")
mods_nam=c("Model 21.2")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods_nam)

i=1

p3.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Value)
p3.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p4.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Value)
p4.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_end_logit_Fishery"&Pr_type=="dev"]$Parm_StDev)^2
p5.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Value)
p5.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_peak_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p6.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Value)
p6.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Size_DblN_ascend_se_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p7.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Value)
p7.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"LnQ_base_Survey"&Pr_type=="dev"]$Parm_StDev)^2
p8.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Value)
p8.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"L_at_Amin"&Pr_type=="dev"]$Parm_StDev)^2
p9.1<-var(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Value)
p9.2<-mean(data.table(mods1[[i]]$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Parm_StDev^2)

data.table(p1=c(p9.1,p8.1,p3.1,p4.1,p5.1,p6.1),p2=c(p9.2,p8.2,p3.2,p4.2,p5.2,p6.2))



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT_SE")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 19.12","Model 19.12A","Model 21.1", "Model 21.2")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods_nam)


q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2022']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2022']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2022']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2022']$Value)
qSE=c((data.table(mods1[[1]]$parameters)[Label=='Q_extraSD_Survey(2)']$Value),(data.table(mods1[[2]]$parameters)[Label=='Q_extraSD_Survey(2)']$Value),(data.table(mods1[[3]]$parameters)[Label=='Q_extraSD_Survey(2)']$Value),(data.table(mods1[[4]]$parameters)[Label=='Q_extraSD_Survey(2)']$Value))



q1
ssb/1000000
F40
catch






ggplot(data2[Label=="BTS Q"],aes(x=VERSION,y=as.numeric(value),color=variable,group=variable))+geom_point(size=2)+geom_line()+theme_bw(base_size=16)+labs(y='Catchability(Q)')
ggplot(data2[Label=="BTS Q"],aes(x=VERSION,y=as.numeric(value),color=variable,group=variable))+geom_point(size=2)+geom_line()+theme_bw(base_size=16)+labs(y='Catchability(Q)')



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/GRANT_MODELS_NOWL_AGE_WEIGHT_SE")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 19.12","Model 19.12A","Model 21.1", "Model 21.2")
mods1<-SSgetoutput(dirvec=mods)

values=matrix(ncol=4,nrow=3)
for(i in 1:4){
 values[,i]=data.table(mods1[[i]]$Dirichlet_Multinomial_pars)$Value
}
values




dir1 <- "C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/"
dir2 <- c("2022_MODELS/","2023_MODELS/")
dir3 <- c("Model_22.1","Model_22.2","Model_22.3","Model_22.4","Model_23.1.0.a","Model_23.1.0.d","Model_23.2")
nam1<-c("ENSEMBLE","2023")
nam2.1<-c("M22.1","M22.2","M22.3","M22.4")
nam2.2<-c("M23.1.0.a","M23.1.0.d","M23.2")


for(i in 1:2){
   if(i==1){nam2<-nam2.1}else nam2<-nam2.2
  for(j in 1:6){
    if(file.exists(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))){ setwd(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))
    } else {next}
 
 retroModels <- SSgetoutput(dirvec = paste("retro", 0:-10, sep = ""))
 retroSummary <- SSsummarize(retroModels)
 retroSummary$endyrs<-c(2022:2012)
 endyrvec <- retroModels[[1]][["endyr"]] - 0:10

 hccomps.sma = ss3diags::SSretroComps(retroModels)
 #make comparison plot
 pdf("retrospective_comparison_plots.pdf",width=10,height=6)
 print(SSplotComparisons(retroSummary, endyrvec = endyrvec, new = FALSE))
 dev.off()
 
 pdf("plots.pdf",width=10,height=6)
 par(mfrow=c(1,1))
 print(SSplotRetroRecruits(retroSummary, endyrvec = endyrvec, cohorts = 2012:2022, relative = TRUE, legend = FALSE))
 #second without scaling
 
 ss3sma<-mods1[[11]]

 sspar(mfrow=c(4,1))
 if(j==4) { sspar(mfrow=c(5,1))}
 print(SSplotRunstest(ss3sma,add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='len',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 if(j!=7){print(SSplotRunstest(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))}
 

 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",uncertainty = T,showrho = F,forecast = T,labels="SSB (t)",legendsp=0.9))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",xmin=2011,uncertainty = T,legend = F,forecast = T,legendsp = 0.9))


 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",uncertainty = T,showrho = F,forecast = T,labels="SSB (t)",legendsp=0.9))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",xmin=2011,uncertainty = T,legend = F,forecast = T,legendsp = 0.9))
 dev.off()


 pdf("moreplots.pdf",width=6,height=10)
 

 sspar(mfrow=c(4,1))
 if(j>3) { sspar(mfrow=c(5,1))}

 print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=F,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="topright",indexselect=1))
 if(j>3){print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=F,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="topright",indexselect=2))}
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright",indexselect=1))
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright",indexselect=2))
 
 if(j!=7){print(SSplotHCxval(hccomps.sma,subplots = "age",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright"))}

 SSsettingsBratioF(ss3sma)
 sspar(mfrow=c(1,1))
 #print(SSdeltaMVLN(ss3sma,run="SMA",verbose=F))
 mvln=SSdeltaMVLN(ss3sma,run="EBS Pcod",verbose=F)

 sspar(mfrow=c(3,2),plot.cex=0.7)
 print(SSplotEnsemble(mvln$kb,ylabs=mvln$lables,add=T,verbose=F))
 dev.off()
 }}




dir1 <- "C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/SEPTEMBER_MODELS/"
dir2 <- c("GRANT_MODELS/","GRANT_MODELS_NOWL/","GRANT_MODELS_NOWL_AGE/","GRANT_MODELS_NOWL_AGE_WEIGHT/","GRANT_MODELS_NOWL_AGE_WEIGHT_SE/")
dir3 <- c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
nam1<-c("2021","NOWL","NOWL+AGE","NOWL+AGE+WT","NOWL+AGE+WT+SE")
nam2<-c("M19.12","M19.12A","M21.1","M21.2")
for(i in 1:5){
  for(j in 1:4){
    setwd(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))
    retroModels <- SSgetoutput(dirvec = paste("retro", 0, sep = ""))
    ss3sma<-retroModels[[1]]

   x1=SSplotRunstest(ss3sma,add=T,legendcex=0.8,tickEndYr=F,xylabs=T)
   x2=SSplotRunstest(ss3sma,subplots='len',add=T,legendcex=0.8,tickEndYr=F,xylabs=T)
   x3=SSplotRunstest(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T)
   x4<-rbind(x1,x2,x3)
   x4$Model=paste0(nam1[i],"_",nam2[j])
 
   if(i==1&j==1){x5<-x4} else {x5<-rbind(x5,x4)}
    }}



dir1 <- "C:/WORKING_FOLDER/EBS_PCOD/2023_ASSESSMENT/NOVEMBER_MODELS/"
dir2 <- c("2022_MODELS/","2023_MODELS")
dir3 <- c("Model_22.1","Model_22.2","Model_22.3","Model_22.4","Model_23.1.0.a","Model_23.1.0.d","Model_23.2")
nam1<-c("ENSEMBLER","2023")
nam2<-c("M22.1","M22.2","M22.3","M22.4","M23.1.0.a","M23.1.0.d","M23.2")
#nam2.2<-c("M23.1.0.a","M23.1.0.d","M23.2")
mods=c("retro0",paste0("retro-",1:10))

for(i in 1:2){
  
  for(j in 1:7){
     
     if(file.exists(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))){ setwd(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))
     } else {next}
 
  retroModels <- SSgetoutput(dirvec=mods)
  retroSummary <- SSsummarize(retroModels)
  retroSummary$endyrs<-c(2022:2012)
 

dir1 <- "C:/WORKING_FOLDER/EBS_PCOD/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS"
setwd(dir1)
mods=dir()[2:5]
Models <- SSgetoutput(dirvec=mods)

for(i in 1:4){

 
 pdf(paste0("JABBA",mods[[i]],"plots.pdf"),width=6,height=10)
 ss3sma<-Models[[i]]

 sspar(mfrow=c(3,1))
 print(SSplotJABBAres(ss3sma,add=T,legendcex=0.8,tickEndYr=T,xylabs=T))
 print(SSplotJABBAres(ss3sma,subplots = "len", add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotJABBAres(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 dev.off()
 }




setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model_21_1","NEW_MODELS/Model_21_1")#,"NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods_nam=c("Model 21.1","Model 22.3 (21.1)")#,"Model 22.2 (19.12A)","Model 22.3 (21.1)","Model 22.4 (21.2)")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)

SSplotComparisons(modsS,legendlabels=mods_nam)

ensemble<-function(models=mods1,lab="ForeCatch_2024",weights=WT){
   nmods<-nrow(summary(models))
  MSY=array()
  for(j in 1:nmods){
    MSY[j]<-data.table(models[[j]]$derived_quants)[Label==lab]$Value*weights[j]
  }
       MSY<-sum(MSY)/sum(weights)
       MSY
   }

graph_ensemble<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),PLOT=T){
  dis<-vector("list",length=5)
  for ( i in 1:4){
    dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==label]$Value,data.table(models[[i]]$derived_quants)[Label==label]$StdDev)
    dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
  }

    dis<-do.call(rbind,dis)
    discomb<-data.table(MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
    dis<-rbind(dis,discomb)


    values=data.table(LABEL=label,ENSEMBLE_MEAN=ensemble(lab=label),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE),SD=sd(dis[MODEL=="ENSEMBLE"]$VALUE))
    okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
    
    if(PLOT){
    d<-ggplot(dis,aes(VALUE,color=MODEL,fill=MODEL,group=MODEL,linetype=MODEL))+geom_density(alpha=0.2,size=1)+theme_bw(base_size=16)+
    scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)+labs(x=label,y="Density",title=label)+
    scale_linetype_manual(values=c(1,2,3,4,5))
    print(d)
  }

  x<-values
  x
}



setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2022_Assessments/NOVEMBER_MODELS/NEW_MODELS")
mods<-dir()
mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
mods1<-SSgetoutput(dirvec=mods)

x<-mods1[[1]]$derived_quants$Label

ENSEMBLE_2022<-vector("list",length=length(x))
pdf("ENSEMBLE_2022.pdf",width=10,height=6)

for(i in 1:372){
ENSEMBLE_2022[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

ENSEMBLED_2022<-do.call(rbind,ENSEMBLE_2022)



#mods=dir()

mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS,legendlabels=mods)




library(r4ss)
library(data.table)
library(ss3diags)
library(ggplot2)
setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")



mods=dir()[c(4:6)]

mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS, legendlabels=mods)


SSplotProfile(
  summaryoutput=modsS,
  plot = TRUE,
  print = FALSE,
  models = "all",
  profile.string = "LnQ_base_Survey",
  profile.label = expression(log(italic(Q))),
   ylab = "Change in -log-likelihood",
  components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
    "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
    "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
    "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
  component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
    "Mean body weight", "Length data", "Age data", "Size-at-age data",
    "Generalized size data", "Morph composition data", "Tag recapture distribution",
    "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
    "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
    "F Ballpark", "Crash penalty"),
 )

windows()


 ss3sma<-mods1[[2]]

 
 sspar(mfrow=c(2,2))
 print(SSplotRunstest(ss3sma,add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='len',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))




h.vec <- seq(-0.5,0.5 ,0.05 )
Nprofile <- length(h.vec)
mydir=getwd()


# run profile command
profile <- profile(
  dir = mydir,
  oldctlfile = "control.ss_new",
  newctlfile = "control_modified.ss",
  string = "LnQ_", # subset of parameter label
  profilevec = h.vec,
  overwrite=TRUE
  )







library(r4ss)
library(data.table)
library(ss3diags)
library(ggplot2)

dir<-("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")
setwd(dir)

mods1=dir()[c(16,17,19)]

h.vec <- seq(-0.5,0.5 ,0.05 )
Nprofile <- length(h.vec)

for(i in 1:length (mods1)){
   setwd(paste0(dir,"/",mods1[[i]]))
   mydir=getwd()

# read the output files (with names like Report1.sso, Report2.sso, etc.)
profilemodels <- SSgetoutput(dirvec = mydir, keyvec = c(1:Nprofile))

#mods1=profilemodels# summarize output
profilesummary <- SSsummarize(profilemodels)

# SStableComparisons(profilesummary)
# SSplotComparisons(profilesummary, legendlabels=paste0("Q_",round(exp(h.vec),2)))

 pdf(paste0("Q_Profile_",mods1[[i]],".pdf"))

 SSplotProfile(
   summaryoutput=profilesummary,
   plot = TRUE,
   print = FALSE,
   models = "all",
   profile.string = "LnQ_base_Survey",
   profile.label = expression(log(italic(Q))),
    ylab = "Change in -log-likelihood",
   components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
     "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
     "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
     "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
   component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
     "Mean body weight", "Length data", "Age data", "Size-at-age data",
     "Generalized size data", "Morph composition data", "Tag recapture distribution",
     "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
     "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
     "F Ballpark", "Crash penalty"),
  )

 PinerPlot(  summaryoutput=profilesummary, component = "Age_like",
   main = "Changes in length-composition likelihoods by fleet",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "LnQ_base_Survey",
   profile.label = expression(log(italic(Q))),
 )
 dev.off()
}



# M23.1.0.d_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)
# M23.1.0.a_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)
# M23.2_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)


# library(r4ss)
# setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS/zJITTER_Model_22.1")
# M22.1_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)

# setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS/zJITTER_Model_22.2")
# M22.2_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)

# setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS/zJITTER_Model_22.3")
# M22.3_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)

# setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS/zJITTER_Model_22.4")
# M22.4_jit<-jitter(dir = getwd(),Njitter=50, jitter_fraction = 0.1, init_values_src = 0)




# tune_comps(mods1[[1]],dir=paste0(getwd(),"/",mods[1]),option='Francis')

dir<-("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")
setwd(dir)

mods1=dir()[c(16,17,19)]

h.vec <- seq(-0.5,0.5 ,0.05 )
Nprofile <- length(h.vec)

pm23<-vector('list')
dm23<-vector('list')


for(i in 1:length (mods1)){
   setwd(paste0(dir,"/",mods1[[i]]))
   mydir=getwd()

# read the output files (with names like Report1.sso, Report2.sso, etc.)
  profilemodels <- SSgetoutput(dirvec = mydir, keyvec = c(1:Nprofile))

#mods1=profilemodels# summarize output
  profilesummary <- SSsummarize(profilemodels)


  params=vector(mode='list')
  derived=vector(mode='list')

  for(j in 1:Nprofile){

    params[[j]]<-data.table(profilemodels[[j]]$parameters)[Active_Cnt>0][,c(1:3,11)]
    params[[j]]$catchability <- h.vec[j]
    derived[[j]]<-data.table(profilemodels[[j]]$derived)[Label%in%c('annF_Btgt','SSB_unfished','ForeCatch_2024','ForeCatch_2025','SSB_2024')][,c(1:3)]
    derived[[j]]$catchability <- h.vec[j]
    derived[[j]]$LL<-profilemodels[[j]]$likelihoods_used$values[1]
    params[[j]]$LL<-profilemodels[[j]]$likelihoods_used$values[1]
        

  }

  pm23[[i]]       <-do.call(rbind,params)
  pm23[[i]]$model <-mods1[[i]]
  dm23[[i]]       <-do.call(rbind,derived)
  dm23[[i]]$model <-mods1[[i]]
}


all_pm23<-do.call(rbind,pm23)
all_dm23<-do.call(rbind,dm23)


pdf("PROFILES.pdf",width=10,height=10)
ggplot(all_pm23[model=='PROFQ_Model_23.1.0.a'&Label%in%unique(all_pm23$Label)[c(2:7,72:78)]&catchability<0.5],aes(x=Value,y=LL,color=exp(catchability)))+geom_point(size=2)+facet_wrap(~Label,scales='free_x',ncol=3)+theme_bw()+labs(y='Likelihood',x='Parameter values',color="Survey catchability",title="Model 23.1.0.a")+geom_path()
ggplot(all_pm23[model=='PROFQ_Model_23.1.0.d'&Label%in%unique(all_pm23$Label)[c(2:7,72:78)]],aes(x=Value,y=LL,color=exp(catchability)))+geom_point(size=2)+facet_wrap(~Label,scales='free_x',ncol=3)+theme_bw()+labs(y='Likelihood',x='Parameter values',color="Survey catchability",title="Model 23.1.0.d")+geom_path()
ggplot(all_pm23[model=='PROFQ_Model_23.2'&Label%in%unique(all_pm23$Label)[c(2:7,72:78)]],aes(x=Value,y=LL,color=exp(catchability)))+geom_point(size=2)+facet_wrap(~Label,scales='free_x',ncol=3)+theme_bw()+labs(y='Likelihood',x='Parameter values',color="Survey catchability",title="Model 23.2")+geom_path()

#ggplot(all_pm23[model=='PROFQ_Model_23.1.0.d'&Label%in%unique(all_pm23$Label)[c(2:7,72:78)]],aes(y=Value,x=exp(catchability),color=exp(catchability)))+geom_point()+facet_wrap(~Label,scales='free_y',ncol=3)+theme_bw()+labs(x='Survey Catchability',y='Parameter values',color="Survey catchability")


ggplot(all_dm23[model=='PROFQ_Model_23.1.0.a'&catchability<0.5],aes(x=Value,y=LL,color=exp(catchability)))+geom_point()+facet_wrap(~Label,scales='free_x')+theme_bw()+labs(y='Likelihood',x='Value',color="Survey catchability",title="Model 23.1.0.a")+geom_path()
ggplot(all_dm23[model=='PROFQ_Model_23.1.0.d'],aes(x=Value,y=LL,color=exp(catchability)))+geom_point()+facet_wrap(~Label,scales='free_x')+theme_bw()+labs(y='Likelihood',x='Value',color="Survey catchability",title="Model 23.1.0.d")+geom_path()
ggplot(all_dm23[model=='PROFQ_Model_23.2'],aes(x=Value,y=LL,color=exp(catchability)))+geom_point()+facet_wrap(~Label,scales='free_x')+theme_bw()+labs(y='Likelihood',x='Value',color="Survey catchability",title="Model 23.2")+geom_path()
#ggplot(all_dm23[model=='PROFQ_Model_23.1.0.d'],aes(x=Value,y=LL,color=exp(catchability)))+geom_point()+facet_wrap(~Label,scales='free_x')+theme_bw()+labs(y='Likelihood',x='Value',color="Survey catchability")
dev.off()




pdf("PROFILESM23.2tuned.pdf",width=10,height=10)

SSplotProfile(
   summaryoutput=profilesummary,
   plot = TRUE,
   print = FALSE,
   models = "all",
   profile.string = "LnQ_base_Survey",
   profile.label = expression(log(italic(Q))),
    ylab = "Change in -log-likelihood",
   components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
     "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
     "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
     "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
   component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
     "Mean body weight", "Length data", "Age data", "Size-at-age data",
     "Generalized size data", "Morph composition data", "Tag recapture distribution",
     "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
     "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
     "F Ballpark", "Crash penalty"),
  )

PinerPlot(  summaryoutput=profilesummary, component = "Surv_like",
   main = "Changes in index likelihoods",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "LnQ_base_Survey",
   profile.label = expression(log(italic(Q))),
 )

 PinerPlot(  summaryoutput=profilesummary, component = "Age_like",
   main = "Changes in age-composition likelihoods by fleet",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "LnQ_base_Survey",
   profile.label = expression(log(italic(Q))),
 )

 PinerPlot(  summaryoutput=profilesummary, component = "Length_like",
   main = "Changes in length-composition likelihoods by fleet",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "LnQ_base_Survey",
   profile.label = expression(log(italic(Q))),
 )


ggplot(all_pm23[model=='Model 23.2 tuned'&Label%in%unique(all_pm23$Label)[c(2:7,72:78)]],aes(x=Value,y=LL,color=exp(catchability)))+geom_point(size=2)+facet_wrap(~Label,scales='free_x',ncol=3)+theme_bw()+labs(y='Likelihood',x='Parameter values',color="Survey catchability",title="Model 23.2")+geom_path()
ggplot(all_dm23[model=='Model 23.2 tuned'],aes(x=Value,y=LL,color=exp(catchability)))+geom_point()+facet_wrap(~Label,scales='free_x')+theme_bw()+labs(y='Likelihood',x='Value',color="Survey catchability",title="Model 23.2")+geom_path()
dev.off()





dtab1<-data.table(Q=exp(h.vec),SSB_unfished=derived[Label=="SSB_unfished"]$Value,ann_F_MSY=derived[Label=="annF_Btgt"]$Value,
  ForeCatch_2023=derived[Label=="ForeCatch_2023"]$Value,ForeCatch_2023=derived[Label=="ForeCatch_2024"]$Value,MODEL="MODEL",Q=h.vec,like=ll)




ggplot(params[Label%in%unique(params$Label)[c(1:5,10,77:82)]],aes(y=Value,x=catchability))+geom_point()+facet_wrap(~Label,scales='free_y')+theme_bw()+labs(x='log(Q)')


ggplot(derived,aes(y=Value,x=catchability))+geom_point()+facet_wrap(~Label,scales='free_y')+theme_bw()






h.vec <- seq(-0.5,0.5 ,0.05 )
Nprofile <- length(h.vec)
mydir=getwd()

profilemodels <- SSgetoutput(dirvec = mydir, keyvec = 1:Nprofile)

#mods1=profilemodels# summarize output
profilesummary <- SSsummarize(profilemodels)

SStableComparisons(profilesummary)
SSplotComparisons(profilesummary, legendlabels=paste0("Q_",round(exp(h.vec),2)))

windows()
SSplotProfile(
  summaryoutput=profilesummary,
  plot = TRUE,
  print = FALSE,
  models = "all",
  profile.string = "LnQ_base_Survey",
  profile.label = expression(log(italic(Q))),
   ylab = "Change in -log-likelihood",
  components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
    "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
    "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
    "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
  component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
    "Mean body weight", "Length data", "Age data", "Size-at-age data",
    "Generalized size data", "Morph composition data", "Tag recapture distribution",
    "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
    "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
    "F Ballpark", "Crash penalty"),
 )



nprofile=length(profilemodels)
params=vector(mode='list')
derived=vector(mode='list')
ll=vector(mode='list')
L.vec=c(0.0,0.01,0.05,0.1,0.2,0.5,0.8,1.0)

for(i in 1:nprofile){

  params[[i]]<-data.table(profilemodels[[i]]$parameters)[Active_Cnt>0][,1:3]
  params[[i]]$Lambda <- L.vec[i]
  derived[[i]]<-data.table(profilemodels[[i]]$derived)[Label%in%c('annF_Btgt','SSB_unfished','ForeCatch_2024','ForeCatch_2025','SSB_2024')]
  ll[[i]]<-profilemodels[[i]]$likelihoods_used$values[1]
  derived[[i]]$Lambda <- L.vec[i]

}

params<-do.call(rbind,params)
derived<-do.call(rbind,derived)
ll<-do.call(rbind,ll)
windows()
ggplot(params[Label%in%unique(params$Label)[c(1:6,71:78)]],aes(y=Value,x=Lambda))+geom_point()+facet_wrap(~Label,scales='free_y',ncol=4)+theme_bw()+labs(x='Lambda on mean length at age',y='Parameter values')
#windows()
#ggplot(params[Label%in%unique(params$Label)[c(75:80)]],aes(y=Value,x=Lambda))+geom_point()+facet_wrap(~Label,scales='free_y')+theme_bw()+labs(x='Lambda on mean length at age',y='Parameter values')
windows()
ggplot(derived,aes(y=Value,x=Lambda))+geom_point()+facet_wrap(~Label,scales='free_y')+theme_bw()+labs(x='Lambda on mean length at age',y='Parameter values')
#windows()
#ggplot(params[Label%in%unique(params$Label)[c(29:72)]],aes(y=Value,x=Lambda,color=Label))+geom_point()+theme_bw()+labs(x='Lambda on mean length at age',y='Parameter values')




dtab1<-data.table(M=params[Label=="NatM_uniform_Fem_GP_1"]$Value,Q=exp(h.vec),SSB_unfished=derived[Label=="SSB_unfished"]$Value,ann_F_MSY=derived[Label=="annF_Btgt"]$Value,
  ForeCatch_2023=derived[Label=="ForeCatch_2023"]$Value,ForeCatch_2023=derived[Label=="ForeCatch_2024"]$Value,MODEL="MODEL",Q=h.vec,like=ll)

SSplotComparisons(modsS, legendlabels=mods,pdf=TRUE,plotdir=getwd(),btarg=0.4,sprtarg=0.4)




mods=dir()[c(7:28)]
mods1<-SSgetoutput(dirvec=mods)


for(i in 1:length(mods)){
  ss3sma<-mods1[[i]]
  pdf(paste0("JABBA_",mods[i],".pdf"))
   sspar(mfrow=c(3,1))
  print(SSplotJABBAres(ss3sma,add=T,legendcex=0.8,tickEndYr=T,xylabs=T))
  print(SSplotJABBAres(ss3sma,subplots = "len", add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
  print(SSplotJABBAres(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
  dev.off()
}


for (i in 1:length(mods)){
  pdf(paste0("OSA_",mods[i],".pdf"))
  OSA_run_SS(model=mods[i],ages=1:12, fleet=2, sx=1,stck='EBS_COD',surv='EBSSHELF')
  OSA_run_SS_length(model=mods[i],lengths=seq(20.5,100.5,by=1), fleet=2, sx=1, stck='EBS_COD',surv='EBSSHELF')
  OSA_run_SS_length(model=mods[i],lengths=seq(20.5,100.5,by=1), fleet=1, sx=1, stck='EBS_COD',surv='Fishery')
  dev.off()
}




mods1<-SSgetoutput(dirvec=mods)
for (i in 1:length(mods)){
  OSA_run_SS(model=modsT[[i]],ages=1:12, fleet=2, sx=1,stck='EBS_COD',surv='EBSSHELF')
  OSA_run_SS_length(model=modsT[[i]],lengths=seq(20.5,100.5,by=1), fleet=2, sx=1, stck='EBS_COD',surv='EBSSHELF')
  OSA_run_SS_length(model=modsT[[i]],lengths=seq(20.5,100.5,by=1), fleet=1, sx=1, stck='EBS_COD',surv='Fishery')
}




mods1<-SSgetoutput(dirvec=mods)

for(i in 1:length(mods)){
  SS_plots(mods1[[i]])
}



M23.1.0.d_ret<-retro( dir = getwd(), oldsubdir = "", newsubdir = "retrospectives", subdirstart = "retro", years = 0:-10, verbose = TRUE, exe = "ss")





mcmc.df <- SSgetMCMC(
  dir = "Z_mcmc_MODEL23.1.0.g", writecsv = T,
  keystrings = c("NatM", "R0", "steep", "Q_extraSD"),
  nuisancestrings = c("Objective_function", "SSB_", "InitAge", "RecrDev")
)


mcmc.out("Z_mcmc_MODEL23.1.0.g", run = "", numparams = 4, closeall = F)






SSB_P <- ggplot() +
    geom_violin(data = SSB1,
                aes(x = Yrs, y = SSB , group = Yrs),
                fill = "gray75", alpha=0.5) +
    ylim(0, max(SSB1$SSB )) +
    #geom_line(data = MEANS, aes(y = MSSB , x = Yrs, group = ""), size = 1) +
    geom_line(data = MEANS, aes(y = MLE_SSB , x = Yrs, group = ""), color="red",size = 1) +
    theme_bw(base_size = 21) +
    scale_x_continuous(limits = c((SYR-0.5), (CYR + 15 + 0.5)), breaks = seq(SYR, (CYR + 15), by = 2)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    labs(y = expression(paste("Female spawning biomass ( t)")), x = NULL)


FM <- ggplot() +
    geom_violin(data = SSB1,
                aes(x = Yrs, y = FM , group = Yrs),
                fill = "gray75", alpha=0.5) +
    geom_line(data = MEANS, aes(y = MLE_F , x = Yrs, group = ""), color="red",size = 1) +
    theme_bw(base_size = 21) +
    scale_x_continuous(limits = c((SYR-0.5), (CYR + 15 + 0.5)), breaks = seq(SYR, (CYR + 15), by = 2)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    labs(y = expression(paste("F_reported")), x = NULL)

REC <- ggplot() +
    geom_violin(data = SSB1,
                aes(x = Yrs, y = REC , group = Yrs),
                fill = "gray75", alpha=0.5) +
    geom_line(data = MEANS, aes(y = MLE_REC , x = Yrs, group = ""), color="red",size = 1) +
    theme_bw(base_size = 21) +
    scale_x_continuous(limits = c((SYR-0.5), (CYR + 15 + 0.5)), breaks = seq(SYR, (CYR + 15), by = 2)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    labs(y = expression(paste("Recruits")), x = NULL)



direct<-"C:/Users/steve.barbeaux/Work/GitHub/EBS_PCOD/2023_ASSESSMENT/SEPTEMBER_MODELS"
setwd(direct)
mods_nam<-dir()[14:33]
mods=c("retro0",paste0("retro-",c(1:10)))

for(i in 1:length(mods_nam)){

  if(!dir.exists(paste0(direct,"/",mods_nam[i],"/retrospectives"))){next}
  setwd(paste0(direct,"/",mods_nam[i],"/retrospectives"))
  mods1<-SSgetoutput(dirvec=mods)
  modsS<-SSsummarize(mods1)
  modsC = SSretroComps(mods1)

  pdf(paste0(mods_nam[i],"_retro.pdf"),width=10,height=8)
    sspar(mfrow = c(2, 2), plot.cex = 0.8)
    rb = SSplotRetro(modsS, add = T, forecast = F, legend = F, verbose = F)
    rf = SSplotRetro(modsS, add = T, subplots = "F", ylim = c(0, 1.2), forecast = F, legendloc = "topleft", legendcex = 0.8, verbose = F)

    rb2 = SSplotRetro(modsS, add = T, forecast = T, legend = F, verbose = F, xmin = 2000)
    rf2 = SSplotRetro(modsS, add = T, subplots = "F", ylim = c(0, 1.2), forecast = T,
    legendloc = "topleft", legendcex = 0.8, verbose = F, xmin = 2000)
    dev.off()
    
    pdf(paste0(mods_nam[i],"_MACE.pdf"),width=10,height=10)
     sspar(mfrow = c(2, 2), plot.cex = 0.8)
     hci = SSplotHCxval(modsS, add = T, verbose = F, ylimAdj = 1.3, legendcex = 0.7)
     hcl = SSplotHCxval(modsC, subplots = "len", add = T, verbose = F, ylimAdj = 1.3,legendcex = 0.7)
     hca = SSplotHCxval(modsC, subplots = "age", add = T, verbose = F, ylimAdj = 1.3,legendcex = 0.7)
     mvln = SSdeltaMVLN(mods1[[1]], run = "SMA")
     dev.off()

   pdf(paste0(mods_nam[i],"_MVLN.pdf"),width=10,height=10)
     sspar(mfrow = c(3, 2), plot.cex = 0.7)
     SSplotEnsemble(mvln$kb, ylabs = mvln$labels, add = T, verbose = F)
     dev.off()

   }

     










mods=dir()[c(12,13,14)]
mods1<-SSgetoutput(dirvec=mods)
mods_nam=c("Model22.2 old","Model22.2 Update","Model23.1.0.A")
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)

SSplotComparisons(modsS,legendlabels=mods)


mods=dir()[c(12:21,23:33)]
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
SStableComparisons(modsS)
SSplotComparisons(modsS, legendlabels=mods)

parms=data.table(mods1[[3]]$parameters)$Label[c(1:5,25,113)]


sum1<-vector(mode='list')
for(i in 1:length(models)){
  sum1[[i]]<-data.table(mods1[[i]]$parameters)[Label%in%parms][,c(2,3,11)]
  sum1[[i]]$Model=mods[i]
}




parms=mods1[[1]]$derived_quants$Label[c(310,49,323,328)]
sum4<-vector(mode='list')
for(i in 1:length(models)){
  sum4[[i]]<-data.table(mods1[[i]]$derived_quants)[Label%in%parms][,c(1:3)]
  sum4[[i]]$Model=mods[i]
}

sum4<-do.call(rbind,sum4)


RMSE1<-matrix(ncol=6,nrow=length(models))
for(i in 1:length(models)){
RMSE1[i,1]<- as.numeric(mods1[[i]]$index$RMSE)
RMSE1[i,2]<- mods1[[i]]$rmse$RMSE_over_sigmaR[1]
RMSE1[i,3]<-mods1[[i]]$Length_Comp_Fit_Summary$mean_effN[1]
RMSE1[i,4]<-mods1[[i]]$Length_Comp_Fit_Summary$mean_effN[2]
RMSE1[i,5]<-mods1[[i]]$Age_Comp_Fit_Summary$mean_effN[1]
RMSE1[i,6]<- as.character(mods[i])
}

mods2<-mods[11:13]
RMSE2<-matrix(ncol=8,nrow=3)
for(i in 11:13){
RMSE2[(i-10),1]<- as.numeric(mods1[[i]]$index$RMSE)
RMSE2[(i-10),2]<- mods1[[i]]$rmse$RMSE_over_sigmaR[1]
RMSE2[(i-10),3]<-mods1[[i]]$Length_Comp_Fit_Summary$mean_effN[1]
RMSE2[(i-10),4]<-mods1[[i]]$Length_Comp_Fit_Summary$mean_effN[2]
RMSE2[(i-10),5]<-mods1[[i]]$Length_Comp_Fit_Summary$mean_effN[3]
RMSE2[(i-10),6]<-mods1[[i]]$Length_Comp_Fit_Summary$mean_effN[4]
RMSE2[(i-10),7]<-mods1[[i]]$Age_Comp_Fit_Summary$mean_effN[1]
RMSE2[(i-10),8]<- as.character(mods[i])
}

LAGE<-vector(mode='list')
for(i in 1:length(mods)){
LAGE[[i]]<-data.table(mods1[[i]]$endgrowth)[,c(9,12,16)]
LAGE[[i]]$Model<-mods[i]
}

LAGE<-do.call(rbind,LAGE)

ggplot(LAGE,aes(y=Len_Beg,x=Age_Beg,color=Model))+geom_line(size=1)+theme_bw()+labs(y="Length (cm)",x="Age")


ggplot(LAGE,aes(y=Len_Beg,x=Age_Beg,color=Model))+geom_line(size=1)+theme_bw()+labs(y="Length (cm)",x="Age")


ggplot(LAGE[Model%in%mods[c(1:3,14)]],aes(y=Wt_Beg,x=Age_Beg,color=Model))+geom_line(size=1)+theme_bw()+labs(y="Weight (kg)",x="Age")












numage<-vector(mode="list")
wtage<-vector(mode="list")

for(i in 1:length(mods)){
  NCOL1<-ncol(mods1[[i]]$natage)
numage[[i]]<-data.table(mods1[[i]]$natage)[,c(8,11,13:NCOL1)]
names(numage[[i]])[2]<-"BegMid"
numage[[i]]<-numage[[i]][BegMid=='B'& Yr%in% 1977:2023]
wtage[[i]]<-data.table(mods1[[i]]$wtatage)[Yr%in% 1977:2023&Fleet==0][,c(1,7:27)]
numage[[i]]$Model<-mods[i]
wtage[[i]]$Model<-mods[i]

}








direct<-"C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS"
setwd(direct)
mods_nam<-dir()[4:6]
mods=c("retro0",paste0("retro-",c(1:10)))

rb<-vector('list',length=length(mods_nam))
rf<-vector('list',length=length(mods_nam))
rb2<-vector('list',length=length(mods_nam))
rf2<-vector('list',length=length(mods_nam))
hci<-vector('list',length=length(mods_nam))
hcl1<-vector('list',length=length(mods_nam))
hcl2<-vector('list',length=length(mods_nam))
hca<-vector('list',length=length(mods_nam))

for(i in 1:length(mods_nam)){

  if(!dir.exists(paste0(direct,"/",mods_nam[i],"/retrospectives"))){next}
  setwd(paste0(direct,"/",mods_nam[i],"/retrospectives"))
  mods1<-SSgetoutput(dirvec=mods)
  modsS<-SSsummarize(mods1)

 
  modsC = SSretroComps(mods1)


  pdf(paste0(mods_nam[i],"_retro.pdf"),width=10,height=8)
    sspar(mfrow = c(2, 2), plot.cex = 0.8)
    rb[[i]] = SSplotRetro(modsS, add = T)
    rf[[i]] = SSplotRetro(modsS, add = T, subplots = "F", ylim = c(0, 1.2),legendloc = "topleft", legendcex = 0.8)
    rb2 = SSplotRetro(modsS, add = T, forecast = T, legend = T, xmin = 2000)
    rf2 = SSplotRetro(modsS, add = T, subplots = "F", ylim = c(0, 1.2), forecast = T,
    legendloc = "topleft", legendcex = 0.8, xmin = 2000)
    dev.off()
    
    pdf(paste0(mods_nam[i],"_MACE.pdf"),width=10,height=10)
     sspar(mfrow = c(2, 2), plot.cex = 0.8)
     hci[[i]] = SSplotHCxval(modsS, subplots='cpue', ylimAdj = 1.3, legendcex = 0.7,endyrvec=2022:1982)
     hcl1[[i]] = SSplotHCxval(modsC, subplots = "len", indexselect =1,add = T,  ylimAdj = 1.3,legendcex = 0.7,endyrvec=2022:1990)
     hcl2[[i]] = SSplotHCxval(modsC, subplots = "len", indexselect =2,  ylimAdj = 1.3,legendcex = 0.7,endyrvec=1994:1982)
     hca[[i]] = SSplotHCxval(modsC, subplots = "age", add = T, ylimAdj = 1.3,legendcex = 0.7,endyrvec=2022:2008)
     sspar(mfrow = c(1, 1), plot.cex = 0.8)
     mvln = SSdeltaMVLN(mods1[[i]], run = mods_nam[i])
     dev.off()

   pdf(paste0(mods_nam[i],"_MVLN.pdf"),width=10,height=10)
     sspar(mfrow = c(3, 2), plot.cex = 0.7)
     SSplotEnsemble(mvln$kb, ylabs = mvln$labels, add = T)
     dev.off()

   }

     






dir<-("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS/PROFMCV_Model_23.1.0.d")
setwd(dir)
mods1<-dir()[1:11]

# read the output files (with names like Report1.sso, Report2.sso, etc.)
profilemodels <- SSgetoutput(dirvec = mods1)

#mods1=profilemodels# summarize output
profilesummary <- SSsummarize(profilemodels)

# SStableComparisons(profilesummary)
# SSplotComparisons(profilesummary, legendlabels=paste0("Q_",round(exp(h.vec),2)))

pdf(paste0("M_CV_Profile.pdf"))

SSplotProfile(
  summaryoutput=profilesummary,
  plot = TRUE,
  print = FALSE,
  models = "all",
  profile.string = "NatM_uniform_Fem_GP_1",
  profile.label = "Natural mortality (M)",
   ylab = "Change in -log-likelihood",
  components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
    "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
    "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
    "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
  component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
    "Mean body weight", "Length data", "Age data", "Size-at-age data",
    "Generalized size data", "Morph composition data", "Tag recapture distribution",
    "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
    "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
    "F Ballpark", "Crash penalty"),
 )

PinerPlot(  summaryoutput=profilesummary, component = "Surv_like",
  main = "Changes in survey likelihoods by fleet",
  models = "all",
  fleets = "all",
  fleetnames = "default",
  profile.string = "NatM_uniform_Fem_GP_1",
  profile.label = "Natural mortality (M)"
)

PinerPlot(  summaryoutput=profilesummary, component = "Age_like",
  main = "Changes in age-composition likelihoods by fleet",
  models = "all",
  fleets = "all",
  fleetnames = "default",
  profile.string = "NatM_uniform_Fem_GP_1",
  profile.label = "Natural mortality (M)"
)


PinerPlot(  summaryoutput=profilesummary, component = "Length_like",
  main = "Changes in length-composition likelihoods by fleet",
  models = "all",
  fleets = "all",
  fleetnames = "default",
  profile.string = "NatM_uniform_Fem_GP_1",
  profile.label = "Natural mortality (M)"
)

dev.off()


nprofile=length(profilemodels)
params=vector(mode='list')
derived=vector(mode='list')
#ll=vector(mode='list')
L.vec=c(0.001,0.01,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.99)

for(i in 1:nprofile){

  params[[i]]<-data.table(profilemodels[[i]]$parameters)[Active_Cnt>0][,1:3]
  params[[i]]$LL<-profilemodels[[i]]$likelihoods_used$values[1]
  params[[i]]$Lambda <- L.vec[i]
  derived[[i]]<-data.table(profilemodels[[i]]$derived)[Label%in%c('annF_Btgt','SSB_unfished','ForeCatch_2024','ForeCatch_2025','SSB_2024')][,1:3]
  derived[[i]]$LL<-profilemodels[[i]]$likelihoods_used$values[1]
  derived[[i]]$Lambda <- L.vec[i]

}

params<-do.call(rbind,params)
derived<-do.call(rbind,derived)
ll<-do.call(rbind,ll)
#windows()

pdf("ProfCVM_PND.pdf",width=14,height=12)
ggplot(params[Label%in%unique(params$Label)[c(1:7,72:79)]],aes(y=Value,x=Lambda))+geom_point()+geom_line(color="blue")+facet_wrap(~Label,scales='free_y',ncol=3)+theme_bw(base_size=16)+labs(x='SE on Log (M)',y='Parameter values')

#windows()
#ggplot(params[Label%in%unique(params$Label)[c(75:80)]],aes(y=Value,x=Lambda))+geom_point()+facet_wrap(~Label,scales='free_y')+theme_bw()+labs(x='Lambda on mean length at age',y='Parameter values')
#windows()
ggplot(derived,aes(y=Value,x=Lambda))+geom_point()+geom_line(color="blue")+facet_wrap(~Label,scales='free_y')+theme_bw(base_size=16)+labs(x='SE on Log (M)',y='Derived quantities')
#windows()
#ggplot(params[Label%in%unique(params$Label)[c(29:72)]],aes(y=Value,x=Lambda,color=Label))+geom_point()+theme_bw()+labs(x='Lambda on mean length at age',y='Parameter values')
dev.off()


RMSSR= sqrt(mean((data.table(mods1[[1]]$cpue)[Fleet==2]$Dev/data.table(mods1[[1]]$cpue)[Fleet==2]$SE)^2))  ## root mean squared standardized residual



 mods_nam2=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2")
 x2<-vector('list')
 for(i in 1:3){
 x2[[i]]<-data.table(mods2[[i]]$wtatage)[Fleet==0][,c(1,7:27)]
 x2[[i]]$MODEL<-mods_nam2[i]
 }

 mods_nam1=c("Model 22.1","Model 22.2","Model 22.3","Model 22.4")
 x1<-vector('list')
 for(i in 1:4){
 x1[[i]]<-data.table(mods1[[i]]$wtatage)[Fleet==0][,c(1,7:27)]
 x1[[i]]$MODEL<-mods_nam1[i]
 }

 x1<-do.call(rbind,x1)
 x2<-do.call(rbind,x2)
 x3<-rbind(x1,x2)
names(x3)[2:22]<-paste0("Age_",0:20)

x4<-melt(x3,c('Yr','MODEL'))

ggplot(x4[MODEL=='Model 23.1.0.d'],aes(x=Yr, y=value,color=variable))+geom_line()+theme_bw(base_size=16)+labs(x='Year',y='Weight (kg)',color='Age')




dis<-vector('list')
for ( i in 1:length(L.vec)){
    dis1=rnorm(100000, derived[Label=="ForeCatch_2024"&Lambda==L.vec[i]]$Value,derived[Label=="ForeCatch_2024" & Lambda==L.vec[i]]$StdDev)
    dis[[i]]<-data.table(VALUE=dis1,SE_M=L.vec[i],LL=derived[Label=="ForeCatch_2024"&Lambda==L.vec[i]]$LL)
  }

    dis<-do.call(rbind,dis)






h.vec <- seq(0.26,0.42 ,0.02 )
Nprofile <- length(h.vec)
mydir=getwd()


# run profile command
profile <- profile(
  dir = mydir,
  oldctlfile = "control.ss_new",
  newctlfile = "control_modified.ss",
  string = "NatM_", # subset of parameter label
  profilevec = h.vec,
  overwrite=TRUE
  )


dir<-("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")
setwd(dir)


# read the output files (with names like Report1.sso, Report2.sso, etc.)
profilemodels <- SSgetoutput(dirvec = mydir, keyvec = c(1:Nprofile))

#mods1=profilemodels# summarize output
profilesummary <- SSsummarize(profilemodels)

# SStableComparisons(profilesummary)
SSplotComparisons(profilesummary, legendlabels=paste0("M_",h.vec))

 pdf(paste0("M_Profile_Model23.1.0.d.pdf"))

 SSplotProfile(
   summaryoutput=profilesummary,
   plot = TRUE,
   print = FALSE,
   models = "all",
   profile.string = "NatM_uniform_Fem_GP_1",
   profile.label = 'Natural mortality (M)',
    ylab = "Change in -log-likelihood",
   components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
     "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
     "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
     "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
   component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
     "Mean body weight", "Length data", "Age data", "Size-at-age data",
     "Generalized size data", "Morph composition data", "Tag recapture distribution",
     "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
     "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
     "F Ballpark", "Crash penalty"),
  )

 PinerPlot(  summaryoutput=profilesummary, component = "Length_like",
   main = "Changes in length-composition likelihoods by fleet",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "NatM_uniform_Fem_GP_1",
   profile.label = 'Natural Mortality (M)'
 )

PinerPlot(  summaryoutput=profilesummary, component = "Age_like",
   main = "Changes in age-composition likelihoods by fleet",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "NatM_uniform_Fem_GP_1",
   profile.label = 'Natural Mortality (M)'
 )


PinerPlot(  summaryoutput=profilesummary, component = "Surv_like",
   main = "Changes in Index likelihoods",
   models = "all",
   fleets = "all",
   fleetnames = "default",
   profile.string = "NatM_uniform_Fem_GP_1",
   profile.label = 'Natural Mortality (M)'
 )

 dev.off()
}


all_pm23<-vector('list')
all_dm23<-vector('list')

  params=vector(mode='list')
  derived=vector(mode='list')

  for(j in 1:Nprofile){

    params[[j]]<-data.table(profilemodels[[j]]$parameters)[Active_Cnt>0][,c(1:3,11)]
    params[[j]]$catchability <- h.vec[j]
    derived[[j]]<-data.table(profilemodels[[j]]$derived)[Label%in%c('annF_Btgt','SSB_unfished','ForeCatch_2024','ForeCatch_2025','SSB_2024')][,c(1:3)]
    derived[[j]]$catchability <- h.vec[j]
    derived[[j]]$LL<-profilemodels[[j]]$likelihoods_used$values[1]
    params[[j]]$LL<-profilemodels[[j]]$likelihoods_used$values[1]
        

  }

  all_pm23[[1]]       <-do.call(rbind,params)
  all_pm23[[1]]$model <-'Model 23.1.0.d'
  all_dm23[[1]]       <-do.call(rbind,derived)
  all_dm23[[1]]$model <-'Model 23.1.0.d'



pdf("M_PROFILES.pdf",width=10,height=10)
 ggplot(all_pm23[[1]][Label%in%unique(all_pm23[[1]]$Label)[c(1:6,72:77)]],aes(x=Value,y=LL,color=catchability))+geom_point(size=2)+theme_bw()+facet_wrap(~Label,scales='free_x',ncol=3)+labs(y='Likelihood',x='Parameter values',color="Natural Mortality (M)",title="Model 23.1.0.d")+geom_path()
 ggplot(all_dm23[[1]],aes(x=Value,y=LL,color=catchability))+geom_point()+facet_wrap(~Label,scales='free_x')+theme_bw()+labs(y='Likelihood',x='Value',color="Natural Mortality (M)",title="Model 23.1.0.d")+geom_path()
dev.off()
