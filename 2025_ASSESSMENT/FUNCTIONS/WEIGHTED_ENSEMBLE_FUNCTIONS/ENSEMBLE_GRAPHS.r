

source("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/FUNCTIONS/R/ENSEMBLE_FUNCTIONS.r")



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model19_12","GRANT_MODELS/Model19_12A","GRANT_MODELS/Model_21_1","GRANT_MODELS/Model_21_2")
mods_nam<-c("Model 19.12","Model 19.12A","Model 21.1","Model 21.2")
mods1<-SSgetoutput(dirvec=mods)

WT=c(0.2842,0.3158,0.2316,0.1684)

x<-mods1[[1]]$derived_quants$Label
GRANT_ENSEMBLE<-vector("list",length=length(x))
pdf("GRANT_ENSEMBLE.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()



GRANT_ENSEMBLE<-do.call(rbind,GRANT_ENSEMBLE)


x<-data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Label

GRANT_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("GRANT_ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
GRANT_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()

GRANT_ENSEMBLE_PARAS<-do.call(rbind,GRANT_ENSEMBLE_PARAS)



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods_nam<-c("Model 22.1 (19.12)","Model 22.2 (19.12A)","Model 22.3 (21.1)","Model 22.4 (21.2)")
mods1<-SSgetoutput(dirvec=mods)

WT=c(0.2842,0.3158,0.2316,0.1684)

x<-mods1[[1]]$derived_quants$Label
NEW_ENSEMBLE<-vector("list",length=length(x))
pdf("NEW_ENSEMBLE.pdf",width=10,height=6)
for(i in 1:378){
NEW_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i])
}
dev.off()

NEW_ENSEMBLE<-do.call(rbind,NEW_ENSEMBLE)

x<-data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Label

NEW_ENSEMBLE_PARAS<-vector("list",length=length(x))
pdf("NEW_ENSEMBLE_PARAMETERS.pdf",width=10,height=6)
for(i in 1:length(x)){
NEW_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i])
}
dev.off()

NEW_ENSEMBLE_PARAS<-do.call(rbind,NEW_ENSEMBLE_PARAS)




setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("NEW_MODELS/Model19_12","NEW_MODELS/Model19_12A","NEW_MODELS/Model_21_1","NEW_MODELS/Model_21_2")
mods_nam<-c("Model 22.1 (19.12)","Model 22.2 (19.12A)","Model 22.3 (21.1)","Model 22.4 (21.2)")
mods2<-SSgetoutput(dirvec=mods)

WT=c(0.2842,0.3158,0.2316,0.1684)

plots=c("SSB", "Recr", "F", "SPRratio")

pdf("NEW_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2022,WT=WT)
 }
 dev.off()


setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS")
mods<-c("GRANT_MODELS/Model19_12","GRANT_MODELS/Model19_12A","GRANT_MODELS/Model_21_1","GRANT_MODELS/Model_21_2")
mods_nam<-c("Model 19.12","Model 19.12A","Model 21.1","Model 21.2")
mods1<-SSgetoutput(dirvec=mods)

pdf("GRANT_VIOLIN.pdf",width=10,height=6)
 for( h in 1:4){
 	VIOLIN_PLOT_ENSEMBLE(models=mods1,label=plots[h],FY=2022,WT=WT)
 }
 dev.off()



