library(r4ss)
library(data.table)
library(dplyr)

setwd("C:/Users/steve.barbeaux/Work/GitHub/EBS_PCOD/2025_ASSESSMENT/RUSSIAN_MODELS")

mods=dir()[2]
mods1<-r4ss::SSgetoutput(dirvec=mods)



batage<-data.table(mods1[[1]]$batage)
names(batage)[11]<-'Beg_Mid'
batage1<-batage[Beg_Mid=='B'&Era=='TIME'][,c(1,2,8,13:33)]
names(batage1)[1:2]<-c("Source_area","GP")
batage2<-melt(batage1,c('Source_area','GP','Yr'))
names(batage2)<-c('Source_area','GP','Yr','Age','Biomass')


devs1=data.table(mods1[[i]]$parameters)[Label%like%'MoveParm_A_seas_1_'&!Label%like%'DEV'&!Label%like%'dev'][,c(1:3,11)]
dev_parm1=data.table(mods1[[i]]$parameters)[Label%like%'MoveParm_A_seas_1_'&!Label%like%'DEV'&!Label%like%'dev'][,c(1:3,11)]
dev_parm1$Dest_area<-do.call(rbind,strsplit(devs1$Label, split='_'))[,8]
dev_parm1$Source_area<-do.call(rbind,strsplit(devs1$Label, split='_'))[,7]
dev_parm1[Source_area=='2to']$Source_area<-2
dev_parm1[Source_area=='1to']$Source_area<-1
dev_parm1$GP<-do.call(rbind,strsplit(devs1$Label, split='_'))[,6]
dev_parm1[GP=='2from']$GP<-2
dev_parm1[GP=='1from']$GP<-1
dev_parm1=dev_parm1[,-c('Num','Label')]
names(dev_parm1)[1:2]<-c('Prob1','Prob1_stdev')
dev_parm1$Dest_area<-as.numeric(as.character(dev_parm1$Dest_area))
dev_parm1$Source_area<-as.numeric(as.character(dev_parm1$Source_area))
dev_parm1$GP<-as.numeric(as.character(dev_parm1$GP))

devs=data.table(mods1[[i]]$parameters)[Label%like%'MoveParm_A_seas_1_'&Label%like%'DEV'][,c(1:3,11)]
dev_parm=data.table(mods1[[i]]$parameters)[Label%like%'MoveParm_A_seas_1_'&Label%like%'DEV'][,c(1:3,11)]
dev_parm$Yr<-do.call(rbind,strsplit(devs$Label, split='_'))[,10]
dev_parm$Dest_area<-do.call(rbind,strsplit(devs$Label, split='_'))[,8]
dev_parm$Source_area<-do.call(rbind,strsplit(devs$Label, split='_'))[,7]
dev_parm[Source_area=='2to']$Source_area<-2
dev_parm[Source_area=='1to']$Source_area<-1
dev_parm$GP<-do.call(rbind,strsplit(devs$Label, split='_'))[,6]
dev_parm[GP=='2from']$GP<-2
dev_parm[GP=='1from']$GP<-1
dev_parm=dev_parm[,-c('Num','Label')]
names(dev_parm)[1:2]<-c('Prob2','Prob2_stdev')
dev_parm$Dest_area<-as.numeric(as.character(dev_parm$Dest_area))
dev_parm$Source_area<-as.numeric(as.character(dev_parm$Source_area))
dev_parm$GP<-as.numeric(as.character(dev_parm$GP))
dev_parm$Yr<-as.numeric(as.character(dev_parm$Yr))
dev_parm<-dev_parm[Yr<2025]

dev_parm2<-merge(dev_parm1,dev_parm)

batage3<-merge(dev_parm2,batage2,by=c('Source_area','GP','Yr'))

batage3$logit2<-batage3$Prob1*exp(batage3$Prob2*batage3$Prob2_stdev)
batage3$Prob3<-exp(batage3$logit2)/(1+exp(batage3$logit2))
batage3$biomass_move<-batage3$Biomass*exp(-batage3$Prob3-1)


batage5=batage3[,list(BIOMASS_MOVE=sum(biomass_move)),by=c('GP','Source_area','Dest_area','Yr')]

batage5$Group <- "test"
batage5[GP==1&Source_area==1&Dest_area==2]$Group<-'EBS/NBS+WGOA source move from EBS/NBS+WGOA to WBS'
batage5[GP==2&Source_area==2&Dest_area==1]$Group<-'WBS source move from WBS to EBS/NBS+WGOA'
batage5[GP==1&Source_area==2&Dest_area==1]$Group<-'EBS/NBS+WGOA source move from WBS to EBS/NBS+WGOA'
batage5[GP==2&Source_area==1&Dest_area==2]$Group<-'WBS source move from EBS/NBS+WGOA to WBS'

batage5<-batage5[Group!='test']

fig1=ggplot(batage5,aes(x=Yr,y=BIOMASS_MOVE,color=Group, shape=Group))+geom_point()+geom_line()+theme_bw(base_size=16)+labs(y='Movement (t)',color="Source and movement",shape='Source and movement')

batage6<- batage5[,(TOTAL_MOVE=sum(BIOMASS_MOVE)),by=c('Yr','Source_area','Dest_area')]
names(batage6)[4]<-'TOTAL_MOVE'
batage6$GROUP<- 'From EBS/NBS+WGOA'
batage6[Source_area==2]$GROUP<-'From WBS'

fig2=ggplot(batage6,aes(x=Yr,y=TOTAL_MOVE,color=GROUP,shape=GROUP))+geom_line()+geom_point()+theme_bw(base_size=16)+labs(y="Biomass (t)",color="Movement",shape="Movement")


net_move<-data.table(Yr=unique(batage6$Yr),Net_movement1_2=batage6[GROUP==unique(batage6$GROUP)[1]]$TOTAL_MOVE - batage6[GROUP==unique(batage6$GROUP)[2]]$TOTAL_MOVE)
net_move$GROUP="Net Movement from EBS/NBS+WGOA to WBS"


fig3=ggplot(net_move,aes(x=Yr,y=Net_movement1_2,color=GROUP,shape=GROUP))+geom_line()+geom_point()+theme_bw(base_size=16)+labs(y="Biomass (t)",color="Movement",shape="Movement")

print(fig1)
print(fig2)
pring(fig3)