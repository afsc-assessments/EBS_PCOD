
ensemble<-function(models=mods1,lab="ForeCatch_2024",weights=WT){
   nmods<-nrow(summary(models))
	MSY=array()
	for(j in 1:nmods){
		MSY[j]<-data.table(models[[j]]$derived_quants)[Label==lab]$Value*weights[j]
	}
       MSY<-sum(MSY)/sum(weights)
       MSY
   }

graph_ensemble<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),mods_nam=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),PLOT=T,ENSEMBLE=T){
	dis<-vector("list",length=(length(mods1)+1))
	for ( i in 1:length(models)){
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

	


pdf("Dual_plots.pdf",width=10,height=6)
Dual_PLOT(models1=mods1,models2=mods2,MODS_NAM=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),modN=2,label="SSB",FY=2023,WT=c(0.2842,0.3158,0.2316,0.1684))
Dual_PLOT(models1=mods1,models2=mods2,MODS_NAM=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),modN=2,label="SSB/USSB",FY=2023,WT=c(0.2842,0.3158,0.2316,0.1684))
Dual_PLOT(models1=mods1,models2=mods2,MODS_NAM=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),modN=2,label="F",FY=2023,WT=c(0.2842,0.3158,0.2316,0.1684))
Dual_PLOT(models1=mods1,models2=mods2,MODS_NAM=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2"),modN=2,label="Recr",FY=2023,WT=c(0.2842,0.3158,0.2316,0.1684))
dev.off()