ensemble<-function(models=mods1,lab="ForeCatch_2023",weights=WT){
   nmods<-nrow(summary(models))
	MSY=array()
	for(j in 1:nmods){
		MSY[j]<-data.table(models[[j]]$derived_quants)[Label==lab]$Value*weights[j]
	}
       MSY<-sum(MSY)/sum(weights)
       MSY
   }

graph_ensemble<- function(models=mods1,label=" ",PLOT=T){
	dis<-list()
	for ( i in 1:length(models)){
		dis1=rnorm(100000,data.table(models[[i]]$derived_quants)[Label==label]$Value,data.table(models[[i]]$derived_quants)[Label==label]$StdDev)
		dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
	}

    dis<-do.call(rbind,dis)
        
    if(PLOT){
 		d<-ggplot(dis,aes(VALUE,color=MODEL,fill=MODEL,group=MODEL,linetype=MODEL))+geom_density(alpha=0.2,size=1)+theme_bw(base_size=16)+
		see::scale_fill_okabeito()+see::scale_color_okabeito()+labs(x=label,y="Density",title=label)+
		scale_linetype_manual(values=c(1,2,3,4,5))
		print(d)
	}

	x<-list(dist=dis)
	x
}


ensemble_param<-function(models=mods1,lab=" ",weights=WT){
   nmods<-nrow(summary(models))
	MSY=array()
	for(j in 1:nmods){
		if(label %in% data.table(models[[i]]$parameters)$Label){
		MSY[j]<-data.table(models[[j]]$parameters)[Label==lab]$Value*weights[j]
	} else MSY[J]<-NA }
       MSY<-sum(MSY)/sum(weights)
       MSY
   }


graph_ensemble_params<- function(models=mods1,label=" ",PLOT=FALSE){
    dis<-vector("list",length=length(WT))
    for ( i in 1:length(WT)){
        if(label %in% data.table(models[[i]]$parameters)$Label){
            dis1=rnorm(100000,data.table(models[[i]]$parameters)[Label==label]$Value,data.table(models[[i]]$parameters)[Label==label]$Parm_StDev)
            dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
        } else dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=NA,LABEL=label)
   }

    dis<-do.call(rbind,dis)
     
    if(PLOT){
		if(label %in% data.table(models[[i]]$parameters)$Label){
         d<-ggplot(dis,aes(VALUE,color=MODEL,fill=MODEL,group=MODEL,linetype=MODEL))+geom_density(alpha=0.2,size=1)+theme_bw(base_size=16)+
        see::scale_fill_okabeito()+see::scale_color_okabeito()+labs(x=label,y="Density",title=label)+
        scale_linetype_manual(values=c(1,2,3,4,5))
        print(d)
    }}

    x<-list(dist=dis)
    x
}

VIOLIN_PLOT_ENSEMBLE<-function(models=mods1,label="SSB",FY=2024,graph=1){

	LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
	YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
    LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
    LABEL<-LABEL[!is.na(YEAR)]

    values<-vector('list',length=nrow(LABEL))
	
	for(j in 1:nrow(LABEL)){
		dis<-vector('list',length=5)
    	for ( i in 1:length(models)){
			dis1=rnorm(100000,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$Value,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$StdDev)
		    dis[[i]]<-data.table(YEAR=LABEL$YEAR[j],MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
		}

        dis<-do.call(rbind,dis)
        #discomb<-data.table(YEAR=LABEL$YEAR[j],MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
        #dis<-rbind(dis,discomb)
        #values[[j]]=data.table(YEAR=LABEL$YEAR[j],LABEL=label,ENSEMBLE_MEAN=ensemble(lab=LABEL$LABEL[j]),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE))
		

		
		if(j==1){dis2=dis}else{dis2<-rbind(dis2,dis)}
	}
	
    MEANS<-dis2[,list(MEANS=mean(VALUE)),by=c("MODEL","YEAR")]

       
    par(mfrow=c(1,length(models)))    
    p <- ggplot(data=dis2[MODEL==unique(MODEL)[graph]&YEAR<=FY], aes(x=YEAR, y=VALUE, group=YEAR)) + geom_violin(fill="gray50") +theme_bw(base_size=16)
    p<- p+geom_line(data=MEANS[YEAR<=FY&MODEL==unique(MODEL)[graph]],aes(x=YEAR,y=MEANS,color=MODEL,group=MODEL),size=1)+see::scale_fill_okabeito()+see::scale_color_okabeito()+
		scale_linetype_manual(values=c(1,2,3,4,5))
    p<-p+labs(x='YEAR',y=label)
    print(p)
}










table_params<- function(models=mods1,label=" "){
    dis<-vector("list",length=length(models))
    for ( i in 1:length(models)){
        if(label %in% data.table(models[[i]]$parameters)$Label){
            dis1=data.table(models[[i]]$parameters)[Label==label]$Value
            dis2=data.table(models[[i]]$parameters)[Label==label]$Parm_StDev
            dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,SD=dis2,LABEL=label)
        } else dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=NA,SD=NA,LABEL=label)
   }

    dis<-do.call(rbind,dis)
    dis

}





VIOLIN_PLOT_ENSEMBLE<-function(models=mods1,label="SSB",FY=2027,graph=1,mods_nam=nams){

	LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
	YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
    LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
    LABEL<-LABEL[!is.na(YEAR)]

    values<-vector('list',length=nrow(LABEL))
	
	for(j in 1:nrow(LABEL)){
		dis<-vector('list',length=length(models))
    	for ( i in 1:length(models)){
			dis1=rnorm(100000,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$Value,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$StdDev)
		    dis[[i]]<-data.table(YEAR=LABEL$YEAR[j],MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
		}

        dis<-do.call(rbind,dis)
        #discomb<-data.table(YEAR=LABEL$YEAR[j],MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
        #dis<-rbind(dis,discomb)
        #values[[j]]=data.table(YEAR=LABEL$YEAR[j],LABEL=label,ENSEMBLE_MEAN=ensemble(lab=LABEL$LABEL[j]),MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE))
		
   
		
		if(j==1){dis2=dis}else{dis2<-rbind(dis2,dis)}
	}
	

	if(label=='SSB')lab1<-'Female spawning biomass (t)'
	if(label=='Bratio')lab1<-'SSB/SSB unfished'
	if(label=='F')lab1<-'Sum(apical fishing mortality)'
	if(label=='Recr')lab1<-'Age-0 recruits (1000s)'

    MEANS<-dis2[,list(MEANS=mean(VALUE)),by=c("MODEL","YEAR")]
        
    par(mfrow=c(1,length(models)))    
    p <- ggplot(data=dis2[MODEL==unique(MODEL)[graph]&YEAR<=FY], aes(x=YEAR, y=VALUE, group=YEAR)) + geom_violin(fill="gray50") +theme_bw(base_size=16)
    p<- p+geom_line(data=MEANS[YEAR<=FY&MODEL==unique(MODEL)[graph]],aes(x=YEAR,y=MEANS,color=MODEL,group=MODEL),size=1)+see::scale_fill_okabeito()+see::scale_color_okabeito()+
		scale_linetype_manual(values=c(1,2,3,4,5))
    p<-p+labs(x='YEAR',y=lab1)
    print(p)
}

nams=c("Model 24.3","Model 24.3 w/ 24.1 Catch")
pdf("violin_plots.pdf",width=10,height=8)
for(i in 1:5){

	VIOLIN_PLOT_ENSEMBLE(models=mods1,label="SSB",FY=2027,graph=i)
	VIOLIN_PLOT_ENSEMBLE(models=mods1,label="Bratio",FY=2027,graph=i)
	VIOLIN_PLOT_ENSEMBLE(models=mods1,label="Recr",FY=2027,graph=i)
	VIOLIN_PLOT_ENSEMBLE(models=mods1,label="F",FY=2024,graph=i)
}
dev.off()
