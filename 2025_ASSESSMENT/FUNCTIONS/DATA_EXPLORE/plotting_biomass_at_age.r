
library(ggpubr)


x<-data.table(mods1[[3]]$batage)[Yr-Time==0][,c(8,13:33)]
x=melt(x,'Yr')

names(x)<-c('Year','Age','Biomass')
x$Age<-as.numeric(as.character(x$Age))
x$Year<-as.numeric(x$Year)
x$COHORT=x$Year-x$Age


ggplot(x[Year>2009&Year<2026],aes(x=Age,y=Biomass,color=factor(COHORT),fill=factor(COHORT),group=factor(COHORT)))+geom_col(position='stack',alpha=0.35,binwidth=1)+theme_bw(base_size=16)+labs(x="Age",y='Biomass(t)',fill="Cohort",color="Cohort")+facet_wrap(~Year)


x<-data.table(mods1[[5]]$natage)[Yr-Time==0][,c(8,13:33)]
x=melt(x,'Yr')

names(x)<-c('Year','Age','Number')
x$Age<-as.numeric(as.character(x$Age))
x$Year<-as.numeric(x$Year)
x$COHORT=x$Year-x$Age


ggplot(x[Year>2009&Year<2026],aes(x=Age,y=Number,color=factor(COHORT),fill=factor(COHORT),group=factor(COHORT)))+geom_col(position='stack',alpha=0.35,binwidth=1)+theme_bw(base_size=16)+labs(x="Age",y='Number',fill="Cohort",color="Cohort")+facet_wrap(~Year)


x<-data.table(mods1[[3]]$catage)[,c(8,12:32)]
x=melt(x,'Yr')

names(x)<-c('Year','Age','Catch')
x$Age<-as.numeric(as.character(x$Age))
x$Year<-as.numeric(x$Year)
x$COHORT=x$Year-x$Age


ggplot(x[Year>2009&Year<2026],aes(x=Age,y=Catch,color=factor(COHORT),fill=factor(COHORT),group=factor(COHORT)))+geom_col(position='stack',alpha=0.35,binwidth=1)+theme_bw(base_size=16)+labs(x="Age",y='Catch (t)',fill="Cohort",color="Cohort")+facet_wrap(~Year)



mods1<-SSgetoutput(dirvec=mods)


biomass_trends<-function(model=mods1[[1]],nam=c("Model 23.1.0.d"),yr_label=c(1977,1984,2009,2024)){
	x<-data.table(model$sprseries)
	x$ratio<-x$Dead_Catch/x$Bio_all
	
	g1<-ggplot(x[Yr<2025],aes(x=Yr,y=ratio,color=Yr))+geom_point(size=2)+geom_line(linewidth=1)+theme_bw(base_size=16)+
	labs(x='Year',y='Catch (t) / total biomass (t)',title="  ")+
	scale_colour_gradientn(colours = c("dark blue", "light blue", "red", "dark red"))
	
	x2<-data.table(model$timeseries)
	x3<-data.table(Yr=x[Yr%in%1977:2024]$Yr,Catch=x[Yr%in%1977:2024]$Dead_Catch,SSB=x2[Yr%in%1977:2024]$SpawnBio/2)
	SSB_unfished<-data.table(model$derived_quants)[Label=='SSB_unfished']$Value/2
	

	g2<-ggplot(x3,aes(x=SSB,y=Catch,color=Yr))+geom_point(size=2)+geom_path(linewidth=1)+theme_bw(base_size=16)+
	labs(x='Female spawning biomass (t)',y='Catch (t)',title=nam[i])+
	geom_vline(xintercept=SSB_unfished*0.4,color='orange',linetype=3,linewidth=1.5)+geom_vline(xintercept=SSB_unfished*0.35,color='red',linetype=2,linewidth=1)+
	geom_vline(xintercept=SSB_unfished*0.2,color='black')+geom_vline(xintercept=SSB_unfished,color='gray20',linewidth=1,linetype=4)+
	scale_colour_gradientn(colours = c("dark blue", "light blue", "red", "dark red"))+xlim(0,SSB_unfished*1.1)+
	geom_label(data=x3[Yr%in%yr_label],aes(label=Yr),alpha=0.5)

	print(ggarrange(g2,g1,ncol=2,common.legend=T,legend='right'))
}





pdf("BIOMASS_TRENDS.pdf",width=10,height=4)

nam1<-c("Model 23.1.0.d","Model 24.0","Model 24.1","Model 24.2","Model 24.3")

for(i in 1:5{
	biomass_trend(mods1[[i]],nam=nam1[i])
}
dev.off()