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

graph_ensemble_params<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),PLOT=FALSE){
	dis<-vector("list",length=length(WT))
	for ( i in 1:length(WT)){
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
