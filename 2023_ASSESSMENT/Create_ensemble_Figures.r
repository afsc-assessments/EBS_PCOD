
ensemble<-function(models=mods1,lab="ForeCatch_2024",weights=WT){
   nmods<-nrow(summary(models))
	MSY=array()
	for(j in 1:nmods){
		MSY[j]<-data.table(models[[j]]$derived_quants)[Label==lab]$Value*weights[j]
	}
       MSY<-sum(MSY)/sum(weights)
       MSY
   }

graph_ensemble<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),PLOT=T,ENSEMBLE=T){
	dis<-vector("list",length=(length(mods1)+1))
	for ( i in 1:length(mods1)){
		dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==label]$Value,data.table(models[[i]]$derived_quants)[Label==label]$StdDev)
		dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
	}

    dis<-do.call(rbind,dis)
    okabe <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442")
    
    if(ENSEMBLE){
    	discomb<-data.table(MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
    	dis<-rbind(dis,discomb)
    	okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
    }

 
    values=data.table(LABEL=label,ENSEMBLE_MEAN=ensemble(lab=label),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE),SD=sd(dis[MODEL=="ENSEMBLE"]$VALUE))
    
    
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

graph_ensemble_params<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),PLOT=T,ENSEMBLE=T){
	dis<-vector("list",length=(length(models)+1))
	for ( i in 1:length(models)){
		dis1=rnorm(100000*WT[i],data.table(models[[i]]$parameters)[Label==label]$Value,data.table(models[[i]]$parameters)[Label==label]$Parm_StDev)
		dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
	}

    dis<-do.call(rbind,dis)
    okabe <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442")
    
    if(ENSEMBLE){
    discomb<-data.table(MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
    dis<-rbind(dis,discomb)
     okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
    }

    values=data.table(LABEL=label,ENSEMBLE_MEAN=ensemble_param(lab=label),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE),SD=sd(dis[MODEL=="ENSEMBLE"]$VALUE))
     
    if(PLOT){
 		d<-ggplot(dis,aes(VALUE,color=MODEL,fill=MODEL,group=MODEL,linetype=MODEL))+geom_density(alpha=0.2,size=1)+theme_bw(base_size=16)+
		scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)+labs(x=label,y="Density",title=label)+
		scale_linetype_manual(values=c(1,2,3,4,5))
		print(d)
	}

	x<-list(dist=dis,values=values)
	x
}


VIOLIN_PLOT_ENSEMBLE<-function(models=mods1,label="SSB",FY=2023,WT=WT){

	LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
	YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
    LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
    LABEL<-LABEL[!is.na(YEAR)]

    values<-vector('list',length=nrow(LABEL))
	
	for(j in 1:nrow(LABEL)){
		dis<-vector('list',length=(length(models)+1))
    	for ( i in 1:length(models)){
			dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$Value,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$StdDev)
		    dis[[i]]<-data.table(YEAR=LABEL$YEAR[j],MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
		}

        dis<-do.call(rbind,dis)
       
        	discomb<-data.table(YEAR=LABEL$YEAR[j],MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
        	dis<-rbind(dis,discomb)
       
       values[[j]]=data.table(YEAR=LABEL$YEAR[j],LABEL=label,ENSEMBLE_MEAN=ensemble(lab=LABEL$LABEL[j]),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE))
		okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")

		
		if(j==1){dis2=dis}else{dis2<-rbind(dis2,dis)}
	}
	
    MEANS<-dis2[,list(MEANS=mean(VALUE)),by=c("MODEL","YEAR")]
           
    p <- ggplot(data=dis2[MODEL=='ENSEMBLE'&YEAR<=FY], aes(x=YEAR, y=VALUE, group=YEAR)) + geom_violin(fill="gray50") +theme_bw(base_size=16)
    p<- p+geom_line(data=MEANS[YEAR<=FY],aes(x=YEAR,y=MEANS,color=MODEL,group=MODEL),linewidth=1)+scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)+
		scale_linetype_manual(values=c(1,2,3,4,5))
    p<-p+labs(x='YEAR',y=label)
    print(p)
    output<-list(MEANS=MEANS)
    return(output)
}



TOT_ENSEMBLE<-function(models=mods1,FY=2023,Weight=WT){
	nr=nrow(data.table(models[[1]]$sprseries))
   x<-matrix(ncol=length(Weight),nrow=nr)
	for(i in 1:length(Weight)){
	   x[,i]=Weight[i]*data.table(models[[i]]$sprseries)$Bio_all
	}
		x<-rowSums(x)
		Total<-data.table(Yr=data.table(models[[1]]$sprseries)$Yr,TOT=x)
		return(Total)
}







VIOLIN_PLOT_single<-function(models=mods1,label="SSB",FY=2023,mods_nam=c("Model 23.1.0.a","Model 23.1.0.d","Model23.2"),modelN=1){
   label2<-label

   USSB=data.table(models[[modelN]]$derived_quants)[Label=='SSB_unfished']$Value
	if(label=='Recr') laby<-"Age-0 recruits 1000s"
   if(label=='SSB') laby<-"Female spawning biomass (t)"
   if(label=='SPR') laby<-"SPR"
   if(label=='F') laby<-"Sum(apical fishing mortality)"

   if(label=='SSB/USSB') { 
    	 laby<-"SSB/SSB unfished"
    	 label='SSB'
    	 }
    	 
    

	LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
	YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
    LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
    LABEL<-LABEL[!is.na(YEAR)]


   
    values<-vector('list',length=nrow(LABEL))
	
	for(j in 1:nrow(LABEL)){
		dis<-vector('list',length=(length(models)+1))
    	for ( i in 1:length(models)){
			dis1=rnorm(100000,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$Value,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$StdDev)
		    dis[[i]]<-data.table(YEAR=LABEL$YEAR[j],MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
		}

        dis<-do.call(rbind,dis)
        if(label2=='SSB/USSB'){dis$VALUE<-dis$VALUE/USSB}
       
        	#discomb<-data.table(YEAR=LABEL$YEAR[j],MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
        	#dis<-rbind(dis,discomb)
       
       #values[[j]]=data.table(YEAR=LABEL$YEAR[j],LABEL=label,ENSEMBLE_MEAN=ensemble(lab=LABEL$LABEL[j]),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE))
		 okabe <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442")

		
		if(j==1){dis2=dis}else{dis2<-rbind(dis2,dis)}
	}
	
    MEANS<-dis2[,list(MEANS=mean(VALUE)),by=c("MODEL","YEAR")]
           
    p <- ggplot(data=dis2[YEAR<=FY&MODEL==mods_nam[modelN]], aes(x=YEAR, y=VALUE, group=YEAR)) + geom_violin(fill="gray50") +theme_bw(base_size=16)
    p<- p+geom_line(data=MEANS[YEAR<=FY&MODEL==mods_nam[modelN]],aes(x=YEAR,y=MEANS,color=MODEL,group=MODEL),size=1)+scale_fill_manual(values=okabe[modelN])+scale_color_manual(values=okabe[modelN])+
		scale_linetype_manual(values=c(1,2,3,4))
    p<-p+labs(x='YEAR',y=laby)
    print(p)
}












Dual_PLOT<-function(models1=mods1,models2=mods2,MODS_NAM=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),modN=2,label="SSB",FY=2023,WT=c(0.2842,0.3158,0.2316,0.1684)){
	
	USSB1=ensemble(models1,lab='SSB_unfished',weights=WT)
	USSB2=data.table(models2[[modN]]$derived_quants)[Label=='SSB_unfished']$Value
	
	if(label=='Recr') laby<-"Age-0 recruits 1000s"
   if(label=='SSB') laby<-"Female spawning biomass (t)"
   if(label=='SPR') laby<-"SPR"
   if(label=='F'){
   	laby<-"Sum(apical fishing mortality)"
   	label="F_"}

   if(label=='SSB/USSB') { 
    	 laby<-"SSB/SSB unfished"
    	 label='SSB'
    	 }
    	 
	
	LABEL=data.table(models1[[1]]$derived_quants)[Label%like%label]$Label
	if(label=='F_'){subset(LABEL,!LABEL%like%'ann')}
	YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
   LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
   LABEL<-LABEL[!is.na(YEAR)]

    values<-vector('list',length=nrow(LABEL))
	
	for(j in 1:nrow(LABEL)){
	      values[[j]]=data.table(YEAR=LABEL$YEAR[j],LABEL=label,ENSEMBLE_MEAN=ensemble(models=mods1,lab=LABEL$LABEL[j]),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE))
	 }

	 ENSEMBLE<-do.call(rbind,values)[,c(1:3)]
	 ENSEMBLE$MODEL="ENSEMBLE"
	 names(ENSEMBLE)[3]<-'MEAN'
	 
    Model_value<-subset(models2[[modN]]$derived_quants,Label%in%LABEL$LABEL)[,1:2]
    Model_value<-data.frame(YEAR=LABEL$YEAR,LABEL=label,MEAN=Model_value$Value,MODEL=MODS_NAM[modN])
    names(Model_value)<-names(ENSEMBLE)
    if(laby=="SSB/SSB unfished"){
     		ENSEMBLE$MEAN<-ENSEMBLE$MEAN/USSB1
     	   Model_value$MEAN<-Model_value$MEAN/USSB2
     	}
    
    MODS=rbind(Model_value, ENSEMBLE)
    
    d<-ggplot(data=MODS,aes(y=MEAN,x=YEAR,color=MODEL,linetype=MODEL,shape=MODEL))+geom_line()+geom_point()+labs(x="Year",y=laby)+theme_bw(base_size=16)
    print(d)
 }

	




## Run ensemble functions to create plots and tables.

plots=c("SSB", "Recr", "F", "SPRratio")
WT=c(0.2842,0.3158,0.2316,0.1684)


setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("2022_MODELS/Model_22.1","2022_MODELS/Model_22.2","2022_MODELS/Model_22.3","2022_MODELS/Model_22.4")
mods_nam<-c("Model 22.1","Model 22.2","Model 22.3","Model 22.4")
mods1<-SSgetoutput(dirvec=mods)







for(i in 1:4){
	SS_plots(mods1[[i]],datplot=T)
}


x<-mods1[[1]]$derived_quants$Label
GRANT_ENSEMBLE<-vector("list",length=length(x))



pdf("ENSEMBLE.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

GE<-vector("list",length=length(GRANT_ENSEMBLE))
for(i in 1:length(GRANT_ENSEMBLE)){
	GE[[i]]<-GRANT_ENSEMBLE[[i]]$values
}


GRANT_ENSEMBLE<-do.call(rbind,GE)
write.csv(GRANT_ENSEMBLE,"ENSEMBLE.csv",row.names=F)


x<-data.table(mods1[[2]]$parameters)[!is.na(Active_Cnt)]$Label
GRANT_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()

GE<-vector("list",length=length(GRANT_ENSEMBLE_PARAS))
for(i in 1:length(GRANT_ENSEMBLE_PARAS)){
	GE[[i]]<-GRANT_ENSEMBLE_PARAS[[i]]$values
}

GRANT_ENSEMBLE_PARAS<-do.call(rbind,GE)
write.csv(GRANT_ENSEMBLE_PARAS,"ENSEMBLE_PARAS.csv",row.names=F)

pdf("ENSEMBLE_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2023,WT=WT)
 }
 dev.off()

modsS<-SSsummarize(mods1)
x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2025']$Value)

x1<-matrix(ncol=4,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ABC_2024","ABC_2025"),x1)
names(x2)<-names(x)
x<-rbind(x,x2)
write.csv(x,"ENSEMBLE_SUMMARY_TABLE.csv",row.names=F)

FL_LIKE<-vector("list",length=4)
for(i in 1:4){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}
FL_LIKE<-do.call(rbind,FL_LIKE)
write.csv(FL_LIKE,"ENSEMBLE_FL_LIKE.csv",row.names=F)

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
    ASEL[[i]]<-data.table(mods1[[i]]$ageselex)[Factor=='Asel2'&Yr<2024][,c(2,3,8:28)]
    ASEL[[i]]$MODEL<-mods_nam[i]
    SSEL[[i]]<-data.table(mods1[[i]]$sizeselex)[Factor=='Lsel'&Yr<2024][,c(2,3,6:126)]
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
write.csv(NAGE,"ENSEMBLE_NAGE.csv",row.names=F)
write.csv(NLEN,"ENSEMBLE_NLEN.csv",row.names=F)
write.csv(ASEL,"ENSEMBLE_ASEL.csv",row.names=F)
write.csv(SSEL,"ENSEMBLE_SSEL.csv",row.names=F)
write.csv(PARAMS,"ENSEMBLE_PARAMS.csv",row.names=F)
write.csv(RESULTS,"ENSEMBLE_RESULTS.csv",row.names=F)


plots=c("SSB", "Recr", "F", "SSB/USSB")

setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("2023_MODELS/Model_23.1.0.a","2023_MODELS/Model_23.1.0.d","2023_MODELS/Model_23.2")
mods_nam<-c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2")
mods2<-SSgetoutput(dirvec=mods)

for(i in 1:3){
	SS_plots(mods2[[i]],datplot=T)
}


NEW_ENSEMBLE<-vector("list")
pdf("M23.pdf",width=10,height=6)
x<-mods2[[2]]$derived_quants$Label
for(i in 1:length(x)){
NEW_ENSEMBLE[[i]]<-graph_ensemble(models=mods2,label=x[i], ENSEMBLE=F)
}
dev.off()

#NE<-vector("list",length=length(NEW_ENSEMBLE))
#for(i in 1:length(NEW_ENSEMBLE)){
#	NE[[i]]<-NEW_ENSEMBLE[[i]]$values
# }

#NEd<-vector("list",length=length(NEW_ENSEMBLE))
#for(i in 1:length(NEW_ENSEMBLE)){
#	NEd[[i]]<-NEW_ENSEMBLE[[i]]$dist
#}

#NEd<-do.call(rbind,NEd)

#NEW_ENSEMBLE<-do.call(rbind,NE)
#write.csv(NEd,"M23_RESULTS.csv",row.names=F)


x<-data.table(mods2[[1]]$parameters)[!is.na(Active_Cnt)]$Label

NEW_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("M23_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
NEW_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods2,label=x[i],ENSEMBLE=F)
}
dev.off()


#NEd<-vector("list",length=length(NEW_ENSEMBLE_PARAS))
#for(i in 1:length(NEW_ENSEMBLE_PARAS)){
#	NEd[[i]]<-NEW_ENSEMBLE_PARAS[[i]]$dist
#}
#NEd_ENSEMBLE_PARAS<-do.call(rbind,NEd)
#write.csv(NEd_ENSEMBLE_PARAS,"M23_PARAS.csv",row.names=F)




#NE<-vector("list",length=length(NEW_ENSEMBLE_PARAS))
#for(i in 1:length(NEW_ENSEMBLE_PARAS)){
#	NE[[i]]<-NEW_ENSEMBLE_PARAS[[i]]$values
#}
#NEW_ENSEMBLE_PARAS<-do.call(rbind,NE)
#write.csv(NEW_ENSEMBLE_PARAS,"M23_PARAS.csv",row.names=F)

pdf("M23_VIOLIN.pdf",width=10,height=6)
 
for(g in 1:3){
 for( h in 1:4){
 	VIOLIN_PLOT_single(models=mods2,label=plots[h],FY=2023,mods_nam=c("Model 23.1.0.a","Model 23.1.0.d","Model23.2"),modelN=g)
 }
}
 dev.off()

pdf("M23_Dual_plots.pdf",width=10,height=6)
for(i in 1:3){
	for(j in 1:4){
   Dual_PLOT(models1=mods1,models2=mods2,MODS_NAM=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),modN=i,label=plots[j],FY=2023)
   }
}
 dev.off()








modsS<-SSsummarize(mods2)
x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods2[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods2[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods2[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods2[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods2[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods2[[3]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods2[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods2[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods2[[3]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods2[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods2[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods2[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value)
catch2=c(data.table(mods2[[1]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods2[[2]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods2[[3]]$derived_quants)[Label=='ForeCatch_2025']$Value)

x1<-matrix(ncol=3,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2024","ForeCatch_2025"),x1)
names(x2)<-names(x)
x<-rbind(x,x2)
write.csv(x,"M23_SUMMARY_TABLE.csv",row.names=F)

FL_LIKE<-vector("list",length=3)
for(i in 1:3){
	FL_LIKE[[i]]<-data.table(mods2[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}
FL_LIKE<-do.call(rbind,FL_LIKE)
write.csv(FL_LIKE,"M23_FL_LIKE.csv",row.names=F)

RESULTS<-vector("list",length=3)
PARAMS<-vector("list",length=3)
NAGE<-vector("list",length=3)
NLEN<-vector("list",length=3)
ASEL<-vector("list",length=3)
SSEL<-vector("list",length=3)
for(i in 1:3){
	NAGE[[i]]<-data.table(mods2[[i]]$natage[,8:ncol(mods2[[i]]$natage)])[Era %in% c("INIT","TIME")]
    NAGE[[i]]$MODEL<-mods_nam[i]
    NLEN[[i]]<-data.table(mods2[[i]]$natlen[,8:ncol(mods2[[i]]$natlen)])[Era %in% c("INIT","TIME")]
    NLEN[[i]]$MODEL<-mods_nam[i]
    ASEL[[i]]<-data.table(mods2[[i]]$ageselex)[Factor=='Asel2'&Yr<2024][,c(2,3,8:28)]
    ASEL[[i]]$MODEL<-mods_nam[i]
    SSEL[[i]]<-data.table(mods2[[i]]$sizeselex)[Factor=='Lsel'&Yr<2024][,c(2,3,6:126)]
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

write.csv(NAGE,"M23_NAGE.csv",row.names=F)
write.csv(NLEN,"M23_NLEN.csv",row.names=F)
write.csv(ASEL,"M23_ASEL.csv",row.names=F)
write.csv(SSEL,"M23_SSEL.csv",row.names=F)
write.csv(PARAMS,"M23_PARAMS.csv",row.names=F)
write.csv(RESULTS,"M23_RESULTS.csv",row.names=F)




## Ensemble Projection figures and tables.

##NEW MODELS projections

SSB<-profiles_M23.1.0.d$Tables$SSB[,2:8]
Catch<-profiles_M23.1.0.d$Tables$Catch[,2:8]
F<-profiles_M23.1.0.d$Tables$F[,2:8]
SSB<-data.table(Yr=profiles_M23.1.0.d$Tables$SSB$Yr,SSB)
F<-data.table(Yr=profiles_M23.1.0.d$Tables$SSB$Yr,F)
Catch<-data.table(Yr=profiles_M23.1.0.d$Tables$SSB$Yr,Catch)
Two_year<-profiles_M23.1.0.d$Two_year[,2:10]
Two_year<-data.table(Yr=profiles_M23.1.0.d$Two_year$Yr,Two_year)

profiles_M23<-list(SSB=SSB,Catch=Catch,F=F,Two_year=Two_year)


pdf("MODEL_PROJ_23.1.0.a.pdf" ,width=10,height=6)
profiles_M23.1.0.a$FIGS
dev.off()
pdf("MODEL_PROJ_23.1.0.d.pdf" ,width=10,height=6)
profiles_M23.1.0.d$FIGS
dev.off()
pdf("MODEL_PROJ_23.2.pdf" ,width=10,height=6)
profiles_M23.2$FIGS
dev.off()


WT=c(0.2842,0.3158,0.2316,0.1684) 
##Ensemble projections
SSB<-profiles_M22.1$Tables$SSB[,2:8]*WT[1]+profiles_M22.2$Tables$SSB[,2:8]*WT[2]+profiles_M22.3$Tables$SSB[,2:8]*WT[3]+profiles_M22.4$Tables$SSB[,2:8]*WT[4]
Catch<-profiles_M22.1$Tables$Catch[,2:8]*WT[1]+profiles_M22.2$Tables$Catch[,2:8]*WT[2]+profiles_M22.3$Tables$Catch[,2:8]*WT[3]+profiles_M22.4$Tables$Catch[,2:8]*WT[4]
F<-profiles_M22.1$Tables$F[,2:8]*WT[1]+profiles_M22.2$Tables$F[,2:8]*WT[2]+profiles_M22.3$Tables$F[,2:8]*WT[3]+profiles_M22.4$Tables$F[,2:8]*WT[4]
SSB<-data.table(Yr=profiles_M22.1$Tables$SSB$Yr,SSB)
F<-data.table(Yr=profiles_M22.1$Tables$SSB$Yr,F)
Catch<-data.table(Yr=profiles_M22.1$Tables$SSB$Yr,Catch)
Two_year<-profiles_M22.1$Two_year[,2:10]*WT[1]+profiles_M22.2$Two_year[,2:10]*WT[2]+profiles_M22.3$Two_year[,2:10]*WT[3]+profiles_M22.4$Two_year[,2:10]*WT[4]
Two_year<-data.table(Yr=profiles_M22.1$Two_year$Yr,Two_year)

profiles_Ensemble<-list(SSB=SSB,Catch=Catch,F=F,Two_year=Two_year)

pdf("MODEL_PROJ_22.1.pdf" ,width=10,height=6)
profiles_M22.1$FIGS
dev.off()
pdf("MODEL_PROJ_22.2.pdf" ,width=10,height=6)
profiles_M22.2$FIGS
dev.off()
pdf("MODEL_PROJ_22.3.pdf" ,width=10,height=6)
profiles_M22.3$FIGS
dev.off()
pdf("MODEL_PROJ_22.4.pdf" ,width=10,height=6)
profiles_M22.4$FIGS
dev.off()



## ss3diags plots


dir1 <- "C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/"
dir2 <- c("2022_MODELS/","2023_MODELS/")
dir3 <- c("Model_22.1","Model_22.2","Model_22.3","Model_22.4","Model_23.1.0.a","Model_23.1.0.d","Model_23.2")
nam1<-c("ENSEMBLE","2023")
nam2.1<-c("M22.1","M22.2","M22.3","M22.4","M23.1.0.a","M23.1.0.d","M23.2")
#nam2.2<-c("M23.1.0.a","M23.1.0.d","M23.2")


for(i in 1:2){
   nam2<-nam2.1
  for(j in 1:7){

  	if(file.exists(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))){ setwd(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))
    } else {next}
 

 
 retroModels <- SSgetoutput(dirvec = paste("retro", 0:-10, sep = ""))
 retroSummary <- SSsummarize(retroModels)
 retroSummary$endyrs<-c(2023:2013)
 endyrvec <- retroModels[[1]][["endyr"]] - 0:10

 hccomps.sma = ss3diags::SSretroComps(retroModels)
 hccomps.sma$endyrs<-c(2023:2013)
 #make comparison plot
 pdf(paste0(nam1[i],"_",nam2[j],"_retrospective_comparison_plots.pdf"),width=10,height=6)
 print(SSplotComparisons(retroSummary, endyrvec = endyrvec, new = FALSE))
 dev.off()
 
 pdf(paste0(nam1[i],"_",nam2[j],"_plots.pdf"),width=10,height=6)
 par(mfrow=c(1,1))
 print(SSplotRetroRecruits(retroSummary, endyrvec = endyrvec, cohorts = 2013:2023, relative = TRUE, legend = FALSE))
 #second without scaling
 
 ss3sma<-retroModels[[1]]

 sspar(mfrow=c(4,1))
 if(j==4) { sspar(mfrow=c(5,1))}
 if(j==7) { sspar(mfrow=c(3,1))}
 
 print(SSplotRunstest(ss3sma,add=T,legendcex=0.8,tickEndYr=T,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='len',add=T,legendcex=0.8,tickEndYr=T,xylabs=T))
 if(j!=7){ print(SSplotRunstest(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=T,xylabs=T))}
 

 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=T,xylabs=T,legendloc = "bottomleft",uncertainty = T,showrho = T,forecast = T,legendsp=0.9))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=T,xylabs=T,legendloc = "bottomleft",xmin=2013,uncertainty = T,legend = T,forecast = T,legendsp = 0.9))


 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=T,xylabs=T,legendloc = "bottomleft",uncertainty = T,showrho = T,forecast = T,legendsp=0.9))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=T,xylabs=T,legendloc = "bottomleft",xmin=2013,uncertainty = T,legend = T,forecast = T,legendsp = 0.9))
 dev.off()

 pdf(paste0(nam1[i],"_",nam2[j],"_moreplots.pdf"),width=6,height=10)
 

 sspar(mfrow=c(4,1))
 if(j==4) { sspar(mfrow=c(5,1))}
 if(j==7) { sspar(mfrow=c(3,1))}

 print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=T,xylabs=T,legendloc="topright",indexselect=1))
 if(j==4){print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=T,xylabs=T,legendloc="topright",indexselect=2))}
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=T,xylabs=T,legendloc="bottomright",indexselect=1))
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=T,xylabs=T,legendloc="bottomright",indexselect=2))
 
 if(j!=7){print(SSplotHCxval(hccomps.sma,subplots = "age",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=T,xylabs=T,legendloc="bottomright"))}

 SSsettingsBratioF(ss3sma)
 sspar(mfrow=c(1,1))
 #print(SSdeltaMVLN(ss3sma,run="SMA",verbose=F))
 mvln=SSdeltaMVLN(ss3sma,run=paste0("EBS Pcod"," ",nam1[i]," ",nam2[j]),verbose=T)

 sspar(mfrow=c(3,2),plot.cex=0.7)
 print(SSplotEnsemble(mvln$kb,ylabs=mvln$lables,add=T,verbose=T))
 dev.off()
 }}

