data=mods1;models=mods

sdata=data.table(read.csv(dir()[2]))
sdatax<-sdata
AGE1=i

plot_lengthage<-function(AGE1=1,data=mods1,models=mods,sdata=sdatax,syr=1990){
    lenage1<-list()
    lenage2<-list()
    for(i in 1:length(data)){
    	lenage1[[i]]<-data.table::data.table(data[[i]]$growthseries)[Yr%in%c(1977:2024), .SD, .SDcols = c("Yr",paste0(AGE1))]
    	endgrowth<-data.table(2024,data.table(mods1[[i]]$endgrowth)[Real_Age==AGE1]$Len_Beg)
        names(endgrowth)=names(lenage1[[i]])
    	lenage1[[i]]<-rbind(lenage1[[i]],endgrowth)

    	lenage2[[i]]<-data.table::data.table(data[[i]]$growthseries)[Yr%in%c(1977:2024), .SD, .SDcols = c("Yr",paste0(AGE1+1))]
    	endgrowth<-data.table(2024,data.table(mods1[[i]]$endgrowth)[Real_Age==AGE1+1]$Len_Beg)
        names(endgrowth)=names(lenage2[[i]])
    	lenage2[[i]]<-rbind(lenage2[[i]],endgrowth)



    	lenage1[[i]]$MODEL=models[i]
    	lenage2[[i]]$MODEL=models[i]


    }



    lenage1<-do.call(rbind,lenage1)
    lenage2<-do.call(rbind,lenage2)

    lenage=merge(lenage1,lenage2)
    lenage$Length_CM<-lenage[,3]+((lenage[,4]-lenage[,3])/ (12/7))
    lenage=lenage[,c(1,5,2)]

   
	sdata1<-sdata[AGE==AGE1&SURVEY_DEFINITION_ID==98]

	sdata1x<-sdata1[,c(1,5)]
	sdata1x$Model='SURVEY'
	names(lenage)<-names(sdata1x)

	sdata1x2<-rbind(lenage,sdata1x)
	sdata1x2<-sdata1x2[YEAR>syr]

	g1<-ggplot(sdata1x2,aes(x=YEAR,y=LENGTH_CM))+geom_violin(data=sdata1x2[Model=='SURVEY'],fill="gray50",aes(group=YEAR))+
		geom_line(data=sdata1x2[Model!='SURVEY'],aes(color=Model))+
		theme_bw()+labs(title=paste0("Data and Model results for age ",AGE1),x="Year",y="Length (CM)")
	print(g1)
}


 pdf("AGE_LENGTH1990.pdf",width=10,height=5)
 for(i in 1:8){
 plot_lengthage(AGE=i)
 }
 dev.off()


geom_smooth(data=sdata1x2[Model=='SURVEY'],aes(group=NA))+