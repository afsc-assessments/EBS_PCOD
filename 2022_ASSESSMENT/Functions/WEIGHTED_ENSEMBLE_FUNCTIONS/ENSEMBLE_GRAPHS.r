
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
	for ( i in 1:4){
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

setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model19_12","GRANT_MODELS/Model19_12A","GRANT_MODELS/Model_21_1","GRANT_MODELS/Model_21_2")
mods_nam<-c("Model 19.12","Model 19.12A","Model 21.1","Model 21.2")
mods1<-SSgetoutput(dirvec=mods)

WT=c(0.2842,0.3158,0.2316,0.1684)

x<-mods1[[1]]$derived_quants$Label
GRANT_ENSEMBLE<-vector("list",length=length(x))
pdf("GRANT_ENSEMBLE.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

GRANT_ENSEMBLE<-do.call(rbind,GRANT_ENSEMBLE)


x<-data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Label

GRANT_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("GRANT_ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()

GRANT_ENSEMBLE_PARAS<-do.call(rbind,GRANT_ENSEMBLE_PARAS)



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods_nam<-c("Model 22.1 (19.12)","Model 22.2 (19.12A)","Model 22.3 (21.1)","Model 22.4 (21.2)")
mods1<-SSgetoutput(dirvec=mods)

WT=c(0.2842,0.3158,0.2316,0.1684)

x<-mods1[[1]]$derived_quants$Label
NEW_ENSEMBLE<-vector("list",length=length(x))
pdf("NEW_ENSEMBLE.pdf",width=10,height=6)
for(i in 1:378){
NEW_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

NEW_ENSEMBLE<-do.call(rbind,NEW_ENSEMBLE)

x<-data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Label

NEW_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("NEW_ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
NEW_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()

NEW_ENSEMBLE_PARAS<-do.call(rbind,NEW_ENSEMBLE_PARAS)




VIOLIN_PLOT_ENSEMBLE<-function(models=mods1,label="SSB",FY=2022,WT=WT){

	LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
	YEAR=as.numeric(str_sub(LABEL,start=-4))
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

setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods_nam<-c("Model 22.1 (19.12)","Model 22.2 (19.12A)","Model 22.3 (21.1)","Model 22.4 (21.2)")
mods2<-SSgetoutput(dirvec=mods)

WT=c(0.2842,0.3158,0.2316,0.1684)

plots=c("SSB", "Recr", "F", "SPRratio")

pdf("NEW_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2022,WT=WT)
 }
 dev.off()


setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model19_12","GRANT_MODELS/Model19_12A","GRANT_MODELS/Model_21_1","GRANT_MODELS/Model_21_2")
mods_nam<-c("Model 19.12","Model 19.12A","Model 21.1","Model 21.2")
mods1<-SSgetoutput(dirvec=mods)

pdf("GRANT_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2022,WT=WT)
 }
 dev.off()



