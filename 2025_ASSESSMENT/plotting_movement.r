library(r4ss)
library(data.table)
library(dplyr)

mods=dir()[1:5]
mods1<-SSgetoutput(dirvec=mods)
batage<-data.table(mods1[[1]]$batage)
names(batage)[11]<-'Beg_Mid'
batage1<-batage[Beg_Mid=='M'&Era=='TIME'][,c(1,2,8,13:33)]
move=data.table(mods1[[1]]$movement)
move=move[,c(2:4,7:27)]
names(move)[4:24]=names(batage1)[4:24]

#names(batage1)[4:24]<-names(move)[4:24]
names(batage1)[1:2]<-c("Source_area","GP")
batage2<-melt(batage1,c('Source_area','GP','Yr'))
names(batage2)<-c('Source_area','GP','Yr','Age','Biomass')

move2<-melt(move,c('GP','Source_area','Dest_area'))

names(move2)[4]<-'Age'
names(move2)[5]<-'Prob1'
move2$Dest_area<-as.numeric(move2$Dest_area)


devs=data.table(mods1[[1]]$parameters)[Label%like%'MoveParm_A_seas_1_'&Label%like%'DEV'][,1:3]
dev_parm=data.table(mods1[[1]]$parameters)[Label%like%'MoveParm_A_seas_1_'&Label%like%'DEV'][,1:3]
dev_parm$Yr<-do.call(rbind,strsplit(devs$Label, split='_'))[,10]
dev_parm$Dest_area<-do.call(rbind,strsplit(devs$Label, split='_'))[,8]
dev_parm$Source_area<-do.call(rbind,strsplit(devs$Label, split='_'))[,7]
dev_parm[Source_area=='2to']$Source_area<-2
dev_parm[Source_area=='1to']$Source_area<-1
dev_parm$GP<-do.call(rbind,strsplit(devs$Label, split='_'))[,6]
dev_parm[GP=='2from']$GP<-2
dev_parm[GP=='1from']$GP<-1
dev_parm=dev_parm[,-c('Num','Label')]
names(dev_parm)[1]<-'Prob2'


dev_parm$Dest_area<-as.numeric(dev_parm$Dest_area)
dev_parm$Source_area<-as.numeric(dev_parm$Source_area)
dev_parm$GP<-as.numeric(dev_parm$GP)
dev_parm$Yr<-as.numeric(dev_parm$Yr)
dev_parm<-dev_parm[Yr<2025]

names(batage2)<-c('Source_area','GP','Yr','Age','Biomass')
batage3<-merge(dev_parm,batage2, all=T)

batage3[is.na(Prob2)]$Prob2<-0
batage3[GP!=Source_area]$Dest_area <-batage3[GP!=Source_area]$GP



batage4<-merge(move2,batage3)



batage4$prob<-batage4$Prob1+batage4$Prob2

#batage4[Age=='age2']$prob<-0
#batage4[Age=='age0']$prob<-0
#batage4[Age=='age1']$prob<-0
#batage4$B_move<-batage4$Biomass*batage4$Prob2


batage5=batage4[,list(BIOMASS_MOVE=sum(Biomass)),by=c('GP','Source_area','Dest_area','Yr')]



#batage5[is.na(Group)]$Dest_area<-batage5[is.na(Group)]$GP

batage5$Group <- "test"
batage5[GP==1&Source_area==1&Dest_area==2]$Group<-'EBS/NBS+WGOA source move from EBS/NBS+WGOA to WBS'
batage5[GP==2&Source_area==2&Dest_area==1]$Group<-'WBS source move from WBS to EBS/NBS+WGOA'
batage5[GP==1&Source_area==2&Dest_area==1]$Group<-'EBS/NBS+WGOA source move from WBS to EBS/NBS+WGOA'
batage5[GP==2&Source_area==1&Dest_area==2]$Group<-'WBS source move from EBS/NBS+WGOA to WBS'

batage5<-batage5[Group!='test']

ggplot(batage5,aes(x=Yr,y=BIOMASS_MOVE,color=Group, shape=Group))+geom_point()+geom_line()+theme_bw(base_size=16)+labs(y='Movement (t)',color="Source and movement",shape='Source and movement')

batage6<- batage5[,(TOTAL_MOVE=sum(BIOMASS_MOVE),by=c('Yr','Source_area','Dest_area')]


ggplot(batage6,aes(x=Yr,y=Biomass,color=GROUP,shape=GROUP))+geom_line()+geom_point()+theme_bw(base_size=16)+labs(y="Biomass (t)",color="Movement",shape="Movement")


net_move<-data.table(Yr=unique(batage6$Yr),Net_movement1_2=batage6[GROUP==unique(batage6$GROUP)[1]]$Biomass - batage6[GROUP==unique(batage6$GROUP)[2]]$Biomass)
net_move$GROUP="Net Movement from EBS/NBS+WGOA to WBS"


ggplot(net_move,aes(x=Yr,y=Net_movement1_2,color=GROUP,shape=GROUP))+geom_line()+geom_point()+theme_bw(base_size=16)+labs(y="Biomass (t)",color="Movement",shape="Movement")



