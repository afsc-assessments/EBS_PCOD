mods=dir()[c(2:3)]


mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)

SSplotComparisons(modsS,legendlabels =mods)

x=data.table(SStableComparisons(modsS,modelnames=mods))
x2<-melt(x,'Label')
x2$MODEL='Richards'
x2[variable%like%'Model_24.4']$MODEL='von Bert'

x3<-x2[Label=='TOTAL_like']
x3<-x3[order(MODEL,-value)]
variables=as.character(x3$variable)
x2$variable<-base::factor(x2$variable,levels=variables)


p1<-ggplot(x2[Label%in%unique(x2$Label)[1:4]],aes(x=variable,y=value,fill=MODEL,group=MODEL))+geom_col()+facet_wrap(~Label,scales='free_y')+theme_bw(base_size=16)+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

p1<-p1+labs(fill='Growth Curve', x='log likelihood',y='Model')




tune_comps(mods1[[1]],dir=paste0(getwd(),"/",mods[1]))



plotWTAGE<-function(x=1,mod=mods1,maxage=10){
wtage<-data.table(mod[[x]]$wtatage)[Fleet==0][,c(1,7:27)]
wtageM<-data.table(melt(wtage,'Yr'))
w1<-ggplot(wtageM[as.numeric(as.character(variable))<=maxage],aes(x=Yr,y=value,group=variable, color=variable))+geom_line()+
theme_bw(base_size=16)+labs(x='Weight (kg)',y='Year',color='Age class', title=mod)
w1
}




valuesC<-function(x=1){
SSB_unfished=data.table(mods1[[x]]$derived_quants)[Label=="SSB_unfished"]$Value/2
Catch24=data.table(mods1[[x]]$derived_quants)[Label=="ForeCatch_2024"]$Value
c(SSB_unfished,Catch24)
}

x1<-lapply(X=1:23,valuesC)
do.call(rbind,x1)




plotWTAGE2<-function(AGE=3,data=mods1,models=mods){
    wtage<-list()
    for(i in 1:length(data)){
    	wtage[[i]]<-data.table::data.table(data[[i]]$wtatage)[Fleet==0&Yr%in%c(1977:2024), .SD, .SDcols = c("Yr",paste0(AGE))]
    	wtage[[i]]$MODEL=models[i]
    }

    wtage<-do.call(rbind,wtage)
    names(wtage)<-c("Year","Weight","Model")
	
	n<-length(data)+2

	w1<-ggplot2::ggplot(wtage,aes(x=Year,y=Weight,group=Model, color=Model))+ggplot2::geom_line()+
	ggplot2::theme_bw(base_size=16)+labs(y='Weight (kg)',x='Year',color='Model',title=paste0("Weight at age ",AGE))+
	colorspace::scale_color_discrete_sequential(palette = "Blues", nmax = n, order = 3:n)
	
	w1
}


plotlenage2<-function(AGE=3,data=mods1,models=mods){
    lenage<-list()
    for(i in 1:length(data)){
    	lenage[[i]]<-data.table::data.table(data[[i]]$growthseries)[Yr%in%c(1977:2024), .SD, .SDcols = c("Yr",paste0(AGE))]
    	endgrowth<-data.table(2024,data.table(mods1[[i]]$endgrowth)[Real_Age==AGE]$Len_Beg)
        names(endgrowth)=names(lenage[[i]])
    	lenage[[i]]<-rbind(lenage[[i]],endgrowth)



    	lenage[[i]]$MODEL=models[i]
    }

    lenage<-do.call(rbind,lenage)

     names(lenage)<-c("Year","Length","Model")
    n<-length(data)+2
			
	L1<-ggplot2::ggplot(lenage,aes(x=Year,y=Length,group=Model, color=Model))+ggplot2::geom_line()+
	ggplot2::theme_bw(base_size=16)+ggplot2::labs(y='Length (cm)',x='Year',color='Model',title=paste0("Size at age ",AGE))+
	colorspace::scale_color_discrete_sequential(palette = "Blues", nmax = n, order = 3:n)
	
	L1
}




plotlenage3<-function(maxage=20,Year=2022,data=mods1,models=mods){
    lenage<-list()
    for(i in 1:length(data)){
    	lenage[[i]]<-data.table(data[[i]]$growthseries)[Yr%in%Year, .SD, .SDcols = c("Yr",paste0(0:maxage))]
    	
    	if(Year==2024){
    		endgrowth<-c(2024,data.table(mods1[[i]]$endgrowth)[Real_Age%in%(0:maxage)]$Len_Beg)
        	endgrowth<-data.table(matrix(endgrowth,nrow=1))
        	names(endgrowth)=names(lenage[[i]])
    		lenage[[i]]<-endgrowth
       	}


    	lenage[[i]]$MODEL=models[i]
    }

    lenage<-do.call(rbind,lenage)
    lenage<-melt(lenage,c("Yr","MODEL"))

    names(lenage)<-c("Year","Model","Age","Length")
    mlen<-lenage[,list(mlen=mean(Length)),by='Age']
    lenage<-merge(lenage,mlen)
    lenage$Dif<-lenage$Length-lenage$mlen/lenage$mlen


	n<-length(data)+2		
	L1<-ggplot(lenage,aes(x=Age,y=Length,group=Model, color=Model))+geom_line()+
	theme_bw(base_size=16)+labs(y='Length (cm)',x='Age',color='Model',title=paste0("Size at age in ",Year))+
	colorspace::scale_color_discrete_sequential(palette = "Blues", nmax = n, order = 3:n)
	
	L1
}


plotlenage4<-function(maxage=20,Year=2022,data=mods1,models=mods){
    lenage<-list()
    for(i in 1:length(data)){
    	lenage[[i]]<-data.table(data[[i]]$growthseries)[Yr%in%Year, .SD, .SDcols = c("Yr",paste0(0:maxage))]
    	if(Year==2024){
    		endgrowth<-c(2024,data.table(mods1[[i]]$endgrowth)[Real_Age%in%(0:maxage)]$Len_Beg)
        	endgrowth<-data.table(matrix(endgrowth,nrow=1))
        	names(endgrowth)=names(lenage[[i]])
    		lenage[[i]]<-endgrowth
       	}

    	lenage[[i]]$MODEL=models[i]
    }

    lenage<-do.call(rbind,lenage)
    lenage<-melt(lenage,c("Yr","MODEL"))

    names(lenage)<-c("Year","Model","Age","Length")
    mlen<-lenage[,list(mlen=mean(Length)),by='Age']
    lenage<-merge(lenage,mlen)
    lenage$Dif<-(lenage$Length-lenage$mlen)/lenage$mlen*100


	n<-length(data)+2		
	L1<-ggplot(lenage,aes(x=Age,y=Dif,group=Model, color=Model))+geom_line()+
	theme_bw(base_size=16)+labs(y='% difference in length (cm) from mean',x='Age',color='Model',title=paste0("% difference in size at age in ",Year))+
	colorspace::scale_color_discrete_sequential(palette = "Blues", nmax = n, order = 3:n)
	
	L1
}




 pdf("plotlenage2.pdf",width=10,height=6)

 for(i in 1:12){

 print(plotlenage2(AGE=i,data=mods1,models=nam))
 print(plotWTAGE2(AGE=i,data=mods1,models=nam))
 }
 plotlenage3(maxage=20,Year=2024,data=mods1,models=mods)
 plotlenage3(maxage=20,Year=2010,data=mods1,models=mods)
 plotlenage4(maxage=20,Year=2024,data=mods1,models=mods)
 plotlenage4(maxage=20,Year=2010,data=mods1,models=mods)
 dev.off()






mods=dir()[c(11,1,3:10,2)]

mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)
retroC<-SSretroComps(mods1)


#mods_MVLN<-SSdeltaMVLN(mods1[[1]])


windows(height=4,width=5.75)
sspar(mfrow=c(2,2),plot.cex=0.8)
SSplotRunstest(mods1[[3]],subplot="cpue",add=T)
SSplotRunstest(mods1[[3]],subplot="len",add=T)
SSplotRunstest(mods1[[3]],subplot="age",add=T)

windows(height=4,width=5.75)
sspar(mfrow=c(1,2),plot.cex=0.8)
SSplotRetro(modsS,add=T)
SSplotRetro(modsS,subplot="F",add=T)

windows(height=4,width=5.75)
sspar(mfrow=c(1,2),plot.cex=0.8)
SSplotHCxval(modsS,endyrvec=c(2023:2013),add=T)
SSplotHCxval(retroC,subplots="len",add=T,endyrvec=c(2023:1990),indexselect=1)

windows(height=4,width=5.75)
sspar(mfrow=c(1,2),plot.cex=0.8)
SSplotHCxval(retroC,subplots="len",add=T,endyrvec=c(1999:1982),indexselect=2)
SSplotHCxval(retroC,subplots="age",add=T,endyrvec=c(2023:2013))

windows(height=4,width=5.75)
sspar(mfrow=c(2,2),plot.cex=0.8)

SSplotJABBAres(mods1[[1]])

SSplotKobe(mods_MVLN$kb)


SSplotRetro(modsS,subplot="F",add=T)