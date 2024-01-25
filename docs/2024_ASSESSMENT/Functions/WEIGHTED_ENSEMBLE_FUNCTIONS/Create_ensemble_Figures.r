
ensemble<-function(models=mods1,lab="ForeCatch_2023",weights=WT){
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
	for ( i in 1:length(models)){
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

	x<-list(dist=dis,values=values)
	x
}


ensemble_param<-function(models=mods1,lab=" ",weights=WT){
   nmods<-nrow(summary(models))
	MSY=array()
	for(j in 1:nmods){
		MSY[j]<-data.table(models[[j]]$parameters)[Label==lab]$Value*weights[j]
	}
       MSY<-sum(MSY)/sum(weights)
       MSY
   }

graph_ensemble_params<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),PLOT=T){
	dis<-vector("list",length=5)
	for ( i in 1:length(models)){
		dis1=rnorm(100000*WT[i],data.table(models[[i]]$parameters)[Label==label]$Value,data.table(models[[i]]$parameters)[Label==label]$Parm_StDev)
		dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
	}

    dis<-do.call(rbind,dis)
    discomb<-data.table(MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
    dis<-rbind(dis,discomb)


    values=data.table(LABEL=label,ENSEMBLE_MEAN=ensemble_param(lab=label),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE),SD=sd(dis[MODEL=="ENSEMBLE"]$VALUE))
    okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
    
    if(PLOT){
 		d<-ggplot(dis,aes(VALUE,color=MODEL,fill=MODEL,group=MODEL,linetype=MODEL))+geom_density(alpha=0.2,size=1)+theme_bw(base_size=16)+
		scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)+labs(x=label,y="Density",title=label)+
		scale_linetype_manual(values=c(1,2,3,4,5))
		print(d)
	}

	x<-list(dist=dis,values=values)
	x
}


VIOLIN_PLOT_ENSEMBLE<-function(models=mods1,label="SSB",FY=2022,WT=WT){

	LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
	YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
    LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
    LABEL<-LABEL[!is.na(YEAR)]

    values<-vector('list',length=nrow(LABEL))
	
	for(j in 1:nrow(LABEL)){
		dis<-vector('list',length=5)
    	for ( i in 1:4){
			dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$Value,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$StdDev)
		    dis[[i]]<-data.table(YEAR=LABEL$YEAR[j],MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
		}

        dis<-do.call(rbind,dis)
        discomb<-data.table(YEAR=LABEL$YEAR[j],MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
        dis<-rbind(dis,discomb)
        values[[j]]=data.table(YEAR=LABEL$YEAR[j],LABEL=label,ENSEMBLE_MEAN=ensemble(lab=LABEL$LABEL[j]),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE))
		

		
		if(j==1){dis2=dis}else{dis2<-rbind(dis2,dis)}
	}
	
    MEANS<-dis2[,list(MEANS=mean(VALUE)),by=c("MODEL","YEAR")]

    okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
        
    p <- ggplot(data=dis2[MODEL=='ENSEMBLE'&YEAR<=FY], aes(x=YEAR, y=VALUE, group=YEAR)) + geom_violin(fill="gray50") +theme_bw(base_size=16)
    p<- p+geom_line(data=MEANS[YEAR<=FY],aes(x=YEAR,y=MEANS,color=MODEL,group=MODEL),size=1)+scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)+
		scale_linetype_manual(values=c(1,2,3,4,5))
    p<-p+labs(x='YEAR',y=label)
    print(p)
}



## Run ensemble functions to create plots and tables.

plots=c("SSB", "Recr", "F", "SPRratio")
WT=c(0.2842,0.3158,0.2316,0.1684)


setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model19_12","GRANT_MODELS/Model19_12A","GRANT_MODELS/Model_21_1","GRANT_MODELS/Model_21_2")
mods_nam<-c("Model 19.12","Model 19.12A","Model 21.1","Model 21.2")
mods1<-SSgetoutput(dirvec=mods)
for(i in 1:4){
	SS_plots(mods1[[i]],datplot=T)
}


x<-mods1[[1]]$derived_quants$Label
GRANT_ENSEMBLE<-vector("list",length=length(x))
pdf("GRANT_ENSEMBLE.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

GE<-vector("list",length=length(GRANT_ENSEMBLE))
for(i in 1:length(GRANT_ENSEMBLE)){
	GE[[i]]<-GRANT_ENSEMBLE[[i]]$values
}


GRANT_ENSEMBLE<-do.call(rbind,GE)
write.csv(GRANT_ENSEMBLE,"GRANT_ENSEMBLE.csv",row.names=F)


x<-data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Label
GRANT_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("GRANT_ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()

GE<-vector("list",length=length(GRANT_ENSEMBLE_PARAS))
for(i in 1:length(GRANT_ENSEMBLE_PARAS)){
	GE[[i]]<-GRANT_ENSEMBLE_PARAS[[i]]$values
}

GRANT_ENSEMBLE_PARAS<-do.call(rbind,GE)
write.csv(GRANT_ENSEMBLE_PARAS,"GRANT_ENSEMBLE_PARAS.csv",row.names=F)

pdf("GRANT_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2022,WT=WT)
 }
 dev.off()

modsS<-SSsummarize(mods1)
x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2023']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)

x1<-matrix(ncol=4,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ABC_2023","ABC_2024"),x1)
names(x2)<-names(x)
x<-rbind(x,x2)
write.csv(x,"GRANT_SUMMARY_TABLE.csv",row.names=F)

FL_LIKE<-vector("list",length=4)
for(i in 1:4){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}
FL_LIKE<-do.call(rbind,FL_LIKE)
write.csv(FL_LIKE,"GRANT_FL_LIKE.csv",row.names=F)

RESULTS<-vector("list",length=4)
PARAMS<-vector("list",length=4)
NAGE<-vector("list",length=4)
NLEN<-vector("list",length=4)
ASEL<-vector("list",length=4)
SSEL<-vector("list",length=4)
for(i in 1:4){
	NAGE[[i]]<-data.table(mods1[[i]]$natage[,8:ncol(mods1[[i]]$natage)])[Era %in% c("INIT","TIME")]
    NAGE[[i]]$MODEL<-mods_nam[i]
    NLEN[[i]]<-data.table(mods1[[i]]$natlen[,8:ncol(mods1[[i]]$natlen)])[Era %in% c("INIT","TIME")]
    NLEN[[i]]$MODEL<-mods_nam[i]
    ASEL[[i]]<-data.table(mods1[[i]]$ageselex)[Factor=='Asel2'&Yr<2023][,c(2,3,8:28)]
    ASEL[[i]]$MODEL<-mods_nam[i]
    SSEL[[i]]<-data.table(mods1[[i]]$sizeselex)[Factor=='Lsel'&Yr<2023][,c(2,3,6:126)]
    SSEL[[i]]$MODEL<-mods_nam[i]
	PARAMS[[i]]<-data.table(MODEL=mods_nam[i],data.table(mods1[[i]]$parameters)[!is.na(Active_Cnt)][,c(2,3,11)])
	RESULTS[[i]]<-data.table(MODEL=mods_nam[i],data.table(mods1[[i]]$derived_quants)[,1:3])
}

PARAMS<-do.call(rbind,PARAMS)
RESULTS<-do.call(rbind,RESULTS)
NAGE<-do.call(rbind,NAGE)
NLEN<-do.call(rbind,NLEN)
ASEL<-do.call(rbind,ASEL)
SSEL<-do.call(rbind,SSEL)
write.csv(NAGE,"GRANT_NAGE.csv",row.names=F)
write.csv(NLEN,"GRANT_NLEN.csv",row.names=F)
write.csv(ASEL,"GRANT_ASEL.csv",row.names=F)
write.csv(SSEL,"GRANT_SSEL.csv",row.names=F)
write.csv(PARAMS,"GRANT_PARAMS.csv",row.names=F)
write.csv(RESULTS,"GRANT_RESULTS.csv",row.names=F)


plots=c("SSB", "Recr", "F", "SPRratio")
WT=c(0.2842,0.3158,0.2316,0.1684)


setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods_nam<-c("Model 22.1 (19.12)","Model 22.2 (19.12A)","Model 22.3 (21.1)","Model 22.4 (21.2)")
mods1<-SSgetoutput(dirvec=mods)

for(i in 1:4){
	SS_plots(mods1[[i]],datplot=T)
}



x<-mods1[[1]]$derived_quants$Label
NEW_ENSEMBLE<-vector("list",length=length(x))
pdf("NEW_ENSEMBLE.pdf",width=10,height=6)
for(i in 1:378){
NEW_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

NE<-vector("list",length=length(NEW_ENSEMBLE))
for(i in 1:length(NEW_ENSEMBLE)){
	NE[[i]]<-NEW_ENSEMBLE[[i]]$values
}


NEW_ENSEMBLE<-do.call(rbind,NE)
write.csv(NEW_ENSEMBLE,"NEW_ENSEMBLE.csv",row.names=F)


x<-data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Label

NEW_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("NEW_ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
NEW_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()


NE<-vector("list",length=length(NEW_ENSEMBLE_PARAS))
for(i in 1:length(NEW_ENSEMBLE_PARAS)){
	NE[[i]]<-NEW_ENSEMBLE_PARAS[[i]]$values
}
NEW_ENSEMBLE_PARAS<-do.call(rbind,NE)
write.csv(NEW_ENSEMBLE_PARAS,"NEW_ENSEMBLE_PARAS.csv",row.names=F)


pdf("NEW_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2022,WT=WT)
 }
 dev.off()

modsS<-SSsummarize(mods1)
x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2023']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)

x1<-matrix(ncol=4,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2023","ForeCatch_2024"),x1)
names(x2)<-names(x)
x<-rbind(x,x2)
write.csv(x,"NEW_SUMMARY_TABLE.csv",row.names=F)

FL_LIKE<-vector("list",length=4)
for(i in 1:4){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}
FL_LIKE<-do.call(rbind,FL_LIKE)
write.csv(FL_LIKE,"NEW_FL_LIKE.csv",row.names=F)

RESULTS<-vector("list",length=4)
PARAMS<-vector("list",length=4)
NAGE<-vector("list",length=4)
NLEN<-vector("list",length=4)
ASEL<-vector("list",length=4)
SSEL<-vector("list",length=4)
for(i in 1:4){
	NAGE[[i]]<-data.table(mods1[[i]]$natage[,8:ncol(mods1[[i]]$natage)])[Era %in% c("INIT","TIME")]
    NAGE[[i]]$MODEL<-mods_nam[i]
    NLEN[[i]]<-data.table(mods1[[i]]$natlen[,8:ncol(mods1[[i]]$natlen)])[Era %in% c("INIT","TIME")]
    NLEN[[i]]$MODEL<-mods_nam[i]
    ASEL[[i]]<-data.table(mods1[[i]]$ageselex)[Factor=='Asel2'&Yr<2023][,c(2,3,8:28)]
    ASEL[[i]]$MODEL<-mods_nam[i]
    SSEL[[i]]<-data.table(mods1[[i]]$sizeselex)[Factor=='Lsel'&Yr<2023][,c(2,3,6:126)]
    SSEL[[i]]$MODEL<-mods_nam[i]
    PARAMS[[i]]<-data.table(MODEL=mods_nam[i],data.table(mods1[[i]]$parameters)[!is.na(Active_Cnt)][,c(2,3,11)])
	RESULTS[[i]]<-data.table(MODEL=mods_nam[i],data.table(mods1[[i]]$derived_quants)[,1:3])
}

PARAMS<-do.call(rbind,PARAMS)
RESULTS<-do.call(rbind,RESULTS)
NAGE<-do.call(rbind,NAGE)
NLEN<-do.call(rbind,NLEN)
ASEL<-do.call(rbind,ASEL)
SSEL<-do.call(rbind,SSEL)

write.csv(NAGE,"NEW_NAGE.csv",row.names=F)
write.csv(NLEN,"NEW_NLEN.csv",row.names=F)
write.csv(ASEL,"NEW_ASEL.csv",row.names=F)
write.csv(SSEL,"NEW_SSEL.csv",row.names=F)
write.csv(PARAMS,"NEW_PARAMS.csv",row.names=F)
write.csv(RESULTS,"NEW_RESULTS.csv",row.names=F)




## Ensemble Projection figures and tables.

##NEW MODELS projections

SSB<-profiles_NEW_19.12$Tables$SSB[,2:8]*WT[1]+profiles_NEW_19.12A$Tables$SSB[,2:8]*WT[2]+profiles_NEW_21.1$Tables$SSB[,2:8]*WT[3]+profiles_NEW_21.2$Tables$SSB[,2:8]*WT[4]
Catch<-profiles_NEW_19.12$Tables$Catch[,2:8]*WT[1]+profiles_NEW_19.12A$Tables$Catch[,2:8]*WT[2]+profiles_NEW_21.1$Tables$Catch[,2:8]*WT[3]+profiles_NEW_21.2$Tables$Catch[,2:8]*WT[4]
F<-profiles_NEW_19.12$Tables$F[,2:8]*WT[1]+profiles_NEW_19.12A$Tables$F[,2:8]*WT[2]+profiles_NEW_21.1$Tables$F[,2:8]*WT[3]+profiles_NEW_21.2$Tables$F[,2:8]*WT[4]
SSB<-data.table(Yr=profiles_NEW_19.12$Tables$SSB$Yr,SSB)
F<-data.table(Yr=profiles_NEW_19.12$Tables$SSB$Yr,F)
Catch<-data.table(Yr=profiles_NEW_19.12$Tables$SSB$Yr,Catch)
Two_year<-profiles_NEW_19.12$Two_year[,2:10]*WT[1]+profiles_NEW_19.12A$Two_year[,2:10]*WT[2]+profiles_NEW_21.1$Two_year[,2:10]*WT[3]+profiles_NEW_21.2$Two_year[,2:10]*WT[4]
Two_year<-data.table(Yr=profiles_NEW_19.12$Two_year$Yr,Two_year)

profiles_Ensemble_NEW<-list(SSB=SSB,Catch=Catch,F=F,Two_year=Two_year)


pdf("NEW_MODEL_PROJ_19.12.pdf" ,width=10,height=6)
profiles_NEW_19.12$FIGS
dev.off()
pdf("NEW_MODEL_PROJ_19.12A.pdf" ,width=10,height=6)
profiles_NEW_19.122A$FIGS
dev.off()
pdf("NEW_MODEL_PROJ_21.1.pdf" ,width=10,height=6)
profiles_NEW_21.1$FIGS
dev.off()
pdf("NEW_MODEL_PROJ_21.2.pdf" ,width=10,height=6)
profiles_NEW_21.2$FIGS
dev.off()


##GRANT projections
SSB<-profiles_19.12$Tables$SSB[,2:8]*WT[1]+profiles_19.12A$Tables$SSB[,2:8]*WT[2]+profiles_21.1$Tables$SSB[,2:8]*WT[3]+profiles_21.2$Tables$SSB[,2:8]*WT[4]
Catch<-profiles_19.12$Tables$Catch[,2:8]*WT[1]+profiles_19.12A$Tables$Catch[,2:8]*WT[2]+profiles_21.1$Tables$Catch[,2:8]*WT[3]+profiles_21.2$Tables$Catch[,2:8]*WT[4]
F<-profiles_19.12$Tables$F[,2:8]*WT[1]+profiles_19.12A$Tables$F[,2:8]*WT[2]+profiles_21.1$Tables$F[,2:8]*WT[3]+profiles_21.2$Tables$F[,2:8]*WT[4]
SSB<-data.table(Yr=profiles_19.12$Tables$SSB$Yr,SSB)
F<-data.table(Yr=profiles_19.12$Tables$SSB$Yr,F)
Catch<-data.table(Yr=profiles_19.12$Tables$SSB$Yr,Catch)
Two_year<-profiles_19.12$Two_year[,2:10]*WT[1]+profiles_19.12A$Two_year[,2:10]*WT[2]+profiles_21.1$Two_year[,2:10]*WT[3]+profiles_21.2$Two_year[,2:10]*WT[4]
Two_year<-data.table(Yr=profiles_19.12$Two_year$Yr,Two_year)

profiles_Ensemble_GRANT<-list(SSB=SSB,Catch=Catch,F=F,Two_year=Two_year)

pdf("GRANT_MODEL_PROJ_19.12.pdf" ,width=10,height=6)
profiles_19.12$FIGS
dev.off()
pdf("GRANT_MODEL_PROJ_19.12A.pdf" ,width=10,height=6)
profiles_19.12A$FIGS
dev.off()
pdf("GRANT_MODEL_PROJ_21.1.pdf" ,width=10,height=6)
profiles_21.1$FIGS
dev.off()
pdf("GRANT_MODEL_PROJ_21.2.pdf" ,width=10,height=6)
profiles_21.2$FIGS
dev.off()



## ss3diags plots


dir1 <- "C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/"
dir2 <- c("GRANT_MODELS/","NEW_MODELS/")
dir3 <- c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
nam1<-c("THOMPSON","NEW")
nam2.1<-c("M19.12","M19.12A","M21.1","M21.2")
nam2.2<-c("M22.1","M22.2","M22.3","M22.4")


for(i in 1:2){
   if(i==1){nam2<-nam2.1}else nam2<-nam2.2
  for(j in 1:4){
    setwd(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))
 
 retroModels <- SSgetoutput(dirvec = paste("retro", 0:-10, sep = ""))
 retroSummary <- SSsummarize(retroModels)
 retroSummary$endyrs<-c(2022:2012)
 endyrvec <- retroModels[[1]][["endyr"]] - 0:10

 hccomps.sma = ss3diags::SSretroComps(retroModels)
 #make comparison plot
 pdf(paste0(nam1[i],"_",nam2[j],"_retrospective_comparison_plots.pdf"),width=10,height=6)
 print(SSplotComparisons(retroSummary, endyrvec = endyrvec, new = FALSE))
 dev.off()
 
 pdf(paste0(nam1[i],"_",nam2[j],"_plots.pdf"),width=10,height=6)
 par(mfrow=c(1,1))
 print(SSplotRetroRecruits(retroSummary, endyrvec = endyrvec, cohorts = 2012:2022, relative = TRUE, legend = FALSE))
 #second without scaling
 
 ss3sma<-retroModels[[1]]

 sspar(mfrow=c(4,1))
 if(j>3) { sspar(mfrow=c(5,1))}
 print(SSplotRunstest(ss3sma,add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='len',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 

 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",uncertainty = T,showrho = F,forecast = T,labels="SSB (t)",legendsp=0.9))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",xmin=2012,uncertainty = T,legend = F,forecast = T,legendsp = 0.9))


 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",uncertainty = T,showrho = F,forecast = T,labels="SSB (t)",legendsp=0.9))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",xmin=2012,uncertainty = T,legend = F,forecast = T,legendsp = 0.9))
 dev.off()

 pdf(paste0(nam1[i],"_",nam2[j],"_moreplots.pdf"),width=6,height=10)
 

 sspar(mfrow=c(4,1))
 if(j>3) { sspar(mfrow=c(5,1))}

 print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=F,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="topright",indexselect=1))
 if(j>3){print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=F,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="topright",indexselect=2))}
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright",indexselect=1))
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright",indexselect=2))
 
 print(SSplotHCxval(hccomps.sma,subplots = "age",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright"))

 SSsettingsBratioF(ss3sma)
 sspar(mfrow=c(1,1))
 #print(SSdeltaMVLN(ss3sma,run="SMA",verbose=F))
 mvln=SSdeltaMVLN(ss3sma,run=paste0("EBS Pcod"," ",nam1[i]," ",nam2[j]),verbose=F)

 sspar(mfrow=c(3,2),plot.cex=0.7)
 print(SSplotEnsemble(mvln$kb,ylabs=mvln$lables,add=T,verbose=F))
 dev.off()
 }}

