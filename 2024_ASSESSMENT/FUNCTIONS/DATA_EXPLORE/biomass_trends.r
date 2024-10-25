
biomass_trends<-function(model=mods1[[1]],nam=nam1[1],syr=1977,eyr=2026,yr_label=c(1977,1984,2009,2026)){
	x<-data.table(model$sprseries)
	x$ratio<-x$Enc_Catch/x$Bio_all
	
	g1<-ggplot(x[Yr<=eyr],aes(x=Yr,y=ratio,color=Yr))+geom_point(size=2)+geom_line(linewidth=1)+theme_bw(base_size=16)+
	labs(x='Year',y='Catch (t) / total biomass (t)',title="  ")+
	scale_colour_gradientn(colours = c("dark blue", "light blue", "red", "dark red"))+geom_point(data=x[Yr %in% c((eyr-1):eyr)],aes(x=Yr,y=ratio),color='black',shape=17,size=2)
	
	x2<-data.table(model$timeseries)
	x3<-data.table(Yr=x[Yr%in%syr:eyr]$Yr,Catch=x[Yr%in%syr:eyr]$Enc_Catch,SSB=x2[Yr%in%syr:eyr]$SpawnBio/2)
	SSB_unfished<-data.table(model$derived_quants)[Label=='SSB_unfished']$Value/2
	

	g2<-ggplot(x3,aes(x=SSB,y=Catch,color=Yr))+geom_point(size=2)+geom_path(linewidth=1)+theme_bw(base_size=16)+
	labs(x='Female spawning biomass (t)',y='Catch (t)',title=nam)+
	geom_vline(xintercept=SSB_unfished*0.4,color='orange',linetype=3,linewidth=1.5)+geom_vline(xintercept=SSB_unfished*0.35,color='red',linetype=2,linewidth=1)+
	geom_vline(xintercept=SSB_unfished*0.2,color='black')+geom_vline(xintercept=SSB_unfished,color='gray20',linewidth=1,linetype=4)+
	scale_colour_gradientn(colours = c("dark blue", "light blue", "red", "dark red"))+xlim(0,SSB_unfished*1.1)+
	geom_label(data=x3[Yr%in%yr_label],aes(label=Yr),alpha=0.5)+geom_point(data=x3[Yr%in%c((eyr-1):eyr)],aes(x=SSB,y=Catch),color='black',shape=17,size=2)

	print(ggpubr::ggarrange(g2,g1,ncol=2,common.legend=T,legend='right'))
}


biomass_trends(mods1[[1]],nam=nam1[1])

## plotting all models
pdf("BIOMASS_TRENDS.pdf",width=10,height=4)

nam1<-c("Model 23.1.0.d","Model 24.0","Model 24.1","Model 24.2","Model 24.3")

for(i in 1:5){
	biomass_trends(mods1[[i]],nam=nam1[i])
}

dev.off()

