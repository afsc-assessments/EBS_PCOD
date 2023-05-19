
dir1 <- "C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/"
dir2 <- c("GRANT_MODELS/","NEW_MODELS/")
dir3 <- c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
nam1<-c("THOMPSON","NEW")
nam2.1<-c("M19.12","M19.12A","M21.1","M21.2")
nam2.2<-c("M22.1","M22.2","M22.3","M22.4")

for(i in 1:2){
   if(i==1){nam2<-nam2.1}else nam2<-nam2.2
  for(j in 1:4){
    setwd(paste0(dir1,dir2[i],dir3[j],"/retrospectives"))
 
 retroModels <- SSgetoutput(dirvec = paste("retro", 0:-10, sep = ""))
 retroSummary <- SSsummarize(retroModels)
 retroSummary$endyrs<-c(2022:2012)
 endyrvec <- retroModels[[1]][["endyr"]] - 0:10

 hccomps.sma = ss3diags::SSretroComps(retroModels)
 #make comparison plot
 pdf("retrospective_comparison_plots.pdf",width=10,height=6)
 print(SSplotComparisons(retroSummary, endyrvec = endyrvec, new = FALSE))
 dev.off()
 
 pdf("plots.pdf",width=10,height=6)
 par(mfrow=c(1,1))
 print(SSplotRetroRecruits(retroSummary, endyrvec = endyrvec, cohorts = 2011:2021, relative = TRUE, legend = FALSE))
 #second without scaling
 
 ss3sma<-retroModels[[1]]

 sspar(mfrow=c(4,1))
 if(j>3) { sspar(mfrow=c(5,1))}
 print(SSplotRunstest(ss3sma,add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='len',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 print(SSplotRunstest(ss3sma,subplots='age',add=T,legendcex=0.8,tickEndYr=F,xylabs=T))
 

 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",uncertainty = T,showrho = F,forecast = T,labels="SSB (t)",legendsp=0.9))
 print(SSplotRetro(retroSummary,add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",xmin=2011,uncertainty = T,legend = F,forecast = T,legendsp = 0.9))


 sspar(mfrow=c(2,1))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",uncertainty = T,showrho = F,forecast = T,labels="SSB (t)",legendsp=0.9))
 print(SSplotRetro(retroSummary,subplot="F",add=T,legendcex=0.8,tickEndYr=F,xylabs=F,legendloc = "bottomleft",xmin=2011,uncertainty = T,legend = F,forecast = T,legendsp = 0.9))
 dev.off()

 pdf("moreplots.pdf",width=6,height=10)
 

 sspar(mfrow=c(4,1))
 if(j>3) { sspar(mfrow=c(5,1))}

 print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=F,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="topright",indexselect=1))
 if(j>3){print(SSplotHCxval(retroSummary,add=T,legendcex=0.8,legend=F,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="topright",indexselect=2))}
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright",indexselect=1))
 print(SSplotHCxval(hccomps.sma,subplots = "len",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright",indexselect=2))
 
 print(SSplotHCxval(hccomps.sma,subplots = "age",add=T,legendcex=0.8,legend=T,legendsp = 0.8,legendindex = 1,tickEndYr=F,xylabs=T,legendloc="bottomright"))

 SSsettingsBratioF(ss3sma)
 sspar(mfrow=c(1,1))
 #print(SSdeltaMVLN(ss3sma,run="SMA",verbose=F))
 mvln=SSdeltaMVLN(ss3sma,run=paste0("EBS Pcod"," ",nam1[i]," ",nam2[j]),verbose=F)

 sspar(mfrow=c(3,2),plot.cex=0.7)
 print(SSplotEnsemble(mvln$kb,ylabs=mvln$lables,add=T,verbose=F))
 dev.off()
 }}





setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 22.1 (19.12)","Model 22.2 (19.12A)","Model 22.3 (21.1)", "Model 22.4 (21.2)")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)


x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2023']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)

x1<-matrix(ncol=4,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2023","ForeCatch_2024"),x1)
names(x2)<-names(x)
NEW_SUMMARY<-rbind(x,x2)
#write.csv(NEW_SUMMARY,"NEW_SUMMARY_TABLE.csv",row.names=F)

setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 19.12","Model 19.12A","Model 21.1", "Model 21.2")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)

x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2023']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)

x1<-matrix(ncol=4,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2023","ForeCatch_2024"),x1)
names(x2)<-names(x)
THOMPSOM_SUMMARY<-rbind(x,x2)


write.csv(THOMPSON_SUMMARY,"GRANT_SUMMARY_TABLE.csv",row.names=F)