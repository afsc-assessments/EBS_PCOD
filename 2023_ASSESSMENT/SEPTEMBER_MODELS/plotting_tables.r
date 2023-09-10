
small_border = flextable::fp_border_default(color="gray", width = 1)
big_border = flextable::fp_border_default(color="black", width = 1.5)


FL_LIKE<-vector("list",length=length(mods))
for(i in 1:length(mods)){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods[i]
}

THOMPSON_FL_LIKE<-do.call(rbind,FL_LIKE)

FL_LIKE<-rbind(THOMPSON_FL_LIKE)
FL_LIKE<-FL_LIKE[order(Label,MODEL),]
FL_LIKE<-data.table(FL_LIKE)
FL_LIKE[Label%in%c('Age_like','Length_like','Surv_like') ][,2:4]<-round(FL_LIKE[Label%in%c('Age_like','Length_like','Surv_like') ][,2:4],3)


format_scientific <- function(x) {
  formatC(x, format = "e", digits = 3)
}
format_scientific1 <- function(x) {
  formatC(x, format = "e", digits = 1)
}

FL_LIKE$ALL[9:24]<-format_scientific(FL_LIKE$ALL[9:24])
#FL_LIKE$Survey[9:24]<-format_scientific1(FL_LIKE$Survey[9:24])
FL_LIKE$Fishery[9:24]<-format_scientific(FL_LIKE$Fishery[9:24])


ft10 <- flextable(data.frame(FL_LIKE))
ft10<-colformat_double(ft10,i = c(1:8,25:40), j = 2:4, digits = 3)
ft10<-colformat_double(ft10,i = c(9:24), j = 4, digits = 0)
ft10<-set_header_labels(ft10, ALL = "All",MODEL="Model")
ft10 <- theme_vanilla(ft10)
ft10 <- align(ft10, align = "center", part = "header")
ft10 <- align(ft10, align = "right", part = "body")
ft10 <- fontsize(ft10,part="all", size = 10)
ft10 <- border_remove(x = ft10)
ft10<-hline_top(ft10, part="all", border = big_border )
ft10 <- hline_bottom(ft10, part="body", border = big_border )

ft10<-bg(ft10, i =c(1:4,9:12,17:20,25:28,33:36), bg="gray80", part = "body")


save_as_docx(ft10,path=paste0(working_dir,"/TABLES/LL_BYFLEET_TABLE.docx"))




## RUNS results table



runsBTT<-vector('list',length=length(mods))

for(i in 1:length(mods)){
  runsBTT[[i]]<-SSplotRunstest(mods1[[i]])
  runsBTT[[i]]$Model=mods[i]
}


runsBT<-do.call(rbind,runsBTT)

runsBTT<-vector('list',length=length(mods))

runsAGET<-vector('list',length=length(mods))
runsLENT<-vector('list',length=length(mods))
for(i in 1:length(mods)){
  runsBTT[[i]]<-SSplotRunstest(mods1[[i]])
  runsBTT[[i]]$Model=mods[i]
  runsLENT[[i]]<-SSplotRunstest(mods1[[i]],subplots='len')
  runsLENT[[i]]$Model=mods[i]
  runsAGET[[i]]<-SSplotRunstest(mods1[[i]],subplots='age')
  runsAGET[[i]]$Model=mods[i]

}

runsBT<-rbind(do.call(rbind,runsBTT),do.call(rbind,runsLENT),do.call(rbind,runsAGET))
runsBT[,c(4,5)]<-round(runsBT[,c(4,5)],3)

runsBT<-data.table(Model=runsBT$Model,Type=runsBT$type,Index=runsBT$Index, pvalue=runsBT$runs.p, Test=runsBT$test, slow=runsBT$sigma3.lo, shi=runsBT$sigma3.hi)



ft21 <- flextable(data.frame(runsBT))
ft21<-set_header_labels(ft21,pvalue="p-value",slow='Sigma3 lo',shi='Sigma3 hi')
ft21<- theme_vanilla(ft21)
ft21 <- align(ft21, align = "center", part = "header")
ft21 <- align(ft21, align = "right", part = "body")
ft21 <- fontsize(ft21,part="body", size = 10)
ft21 <- fontsize(ft21,part="header", size = 10)
ft21 <- border_remove(x = ft21)
#ftS<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
#ft21<-theme_zebra(ft21,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ft21 = bg(ft21, i = ~`Test`=='Failed', 
          j = 1:7,
          bg="gray80")
ft21<-hline_top(ft21, part="all", border = big_border )
ft21 <- hline_bottom(ft21, part="body", border = big_border )
ft21<-set_table_properties(ft21, layout = "autofit")


save_as_docx(ft21,path=paste0(getwd(),"/TABLES/RUNS_TESTS_TABLE.docx"))



##



mods_nam=mods
#mods1<-SSgetoutput(dirvec=mods)
#modsS<-SSsummarize(mods1)

x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

x2<-data.table(M=rep(0,length(mods)),Q=rep(0,length(mods)),SSB_unfished=rep(0,length(mods)),ann_F_MSY=rep(0,length(mods)),ForeCatch_2023=rep(0,length(mods)),ForeCatch_2024=rep(0,length(mods)),Npars=rep(0,length(mods)),Model=rep("",length(mods)))

for (i in 1:length(mods)){
  x2$M[i]=              data.table(mods1[[i]]$parameters)[Label=='NatM_uniform_Fem_GP_1']$Value
  x2$Q[i]=              exp(data.table(mods1[[i]]$parameters)[Label=='LnQ_base_Survey(2)']$Value)
  x2$SSB_unfished[i]=   data.table(mods1[[i]]$derived_quants)[Label=='SSB_unfished']$Value/2000000
  x2$ann_F_MSY[i]=      data.table(mods1[[i]]$derived_quants)[Label=='annF_MSY']$Value
  x2$ForeCatch_2023[i]= data.table(mods1[[i]]$derived_quants)[Label=='ForeCatch_2023']$Value
  x2$ForeCatch_2024[i]= data.table(mods1[[i]]$derived_quants)[Label=='ForeCatch_2024']$Value
  x2$Npars[i]<-         max(data.table(mods1[[i]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt)
  x2$Model[i]=mods[i]
}



mods_nam2=mods2
mods1.2<-SSgetoutput(dirvec=mods2)
modsS2<-SSsummarize(mods1.2)

x=SStableComparisons(modsS2)
names(x)=c("Label",mods_nam2)

x2.2<-data.table(M=rep(0,length(mods2)),Q=rep(0,length(mods2)),SSB_unfished=rep(0,length(mods2)),ann_F_MSY=rep(0,length(mods2)),ForeCatch_2023=rep(0,length(mods2)),ForeCatch_2024=rep(0,length(mods2)),Npars=rep(0,length(mods2)),Model=rep("",length(mods2)))

for (i in 1:length(mods2)){
  x2.2$M[i]=              data.table(mods1.2[[i]]$parameters)[Label=='NatM_uniform_Fem_GP_1']$Value
  x2.2$Q[i]=              exp(data.table(mods1.2[[i]]$parameters)[Label%like%'LnQ']$Value)
  x2.2$SSB_unfished[i]=   data.table(mods1.2[[i]]$derived_quants)[Label=='SSB_unfished']$Value/2000000
  x2.2$ann_F_MSY[i]=      data.table(mods1.2[[i]]$derived_quants)[Label=='annF_MSY']$Value
  x2.2$ForeCatch_2023[i]= data.table(mods1.2[[i]]$derived_quants)[Label=='ForeCatch_2023']$Value
  x2.2$ForeCatch_2024[i]= data.table(mods1.2[[i]]$derived_quants)[Label=='ForeCatch_2024']$Value
  x2.2$Npars[i]<-         max(data.table(mods1.2[[i]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt)
  x2.2$Model[i]=mods2[i]
}





runsBTT2<-vector('list',length=length(mods2))

for(i in 1:length(mods2)){
  runsBTT2[[i]]<-SSplotRunstest(mods1.2[[i]])
  runsBTT2[[i]]$Model=mods2[i]
}


runsBT2<-do.call(rbind,runsBTT2)

runsBTT2<-vector('list',length=length(mods2))

runsAGET2<-vector('list',length=length(mods2))
runsLENT2<-vector('list',length=length(mods2))
for(i in 1:length(mods2)){
  runsBTT2[[i]]<-SSplotRunstest(mods1.2[[i]])
  runsBTT2[[i]]$Model=mods2[i]
  runsLENT2[[i]]<-SSplotRunstest(mods1.2[[i]],subplots='len')
  runsLENT2[[i]]$Model=mods2[i]
  runsAGET2[[i]]<-SSplotRunstest(mods1.2[[i]],subplots='age')
  runsAGET2[[i]]$Model=mods2[i]

}

runsBT2<-rbind(do.call(rbind,runsBTT2),do.call(rbind,runsLENT2),do.call(rbind,runsAGET2))
runsBT2[,c(4,5)]<-round(runsBT2[,c(4,5)],3)

runsBT2<-data.table(Model=runsBT2$Model,Type=runsBT2$type,Index=runsBT2$Index, pvalue=runsBT2$runs.p, Test=runsBT2$test, slow=runsBT2$sigma3.lo, shi=runsBT2$sigma3.hi)



ft21 <- flextable(data.frame(runsBT2))
ft21<-set_header_labels(ft21,pvalue="p-value",slow='Sigma3 lo',shi='Sigma3 hi')
ft21<- theme_vanilla(ft21)
ft21 <- align(ft21, align = "center", part = "header")
ft21 <- align(ft21, align = "right", part = "body")
ft21 <- fontsize(ft21,part="body", size = 10)
ft21 <- fontsize(ft21,part="header", size = 10)
ft21 <- border_remove(x = ft21)
#ftS<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
#ft21<-theme_zebra(ft21,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ft21 = bg(ft21, i = ~`Test`=='Failed', 
          j = 1:7,
          bg="gray80")
ft21<-hline_top(ft21, part="all", border = big_border )
ft21 <- hline_bottom(ft21, part="body", border = big_border )
ft21<-set_table_properties(ft21, layout = "autofit")


save_as_docx(ft21,path=paste0(getwd(),"/TABLES/RUNS_TESTS_TABLE2.docx"))







npars<-data.table(Label="Number_parameters",x1=npars[1],x2=npars[2],x3=npars[3],x4=npars[4])

names(npars)[2:5]<-mods_nam
npars[2:5]<-round(npars[,2:5])
x1<-matrix(ncol=4,nrow=5)
x1[1,]<-q1
x1[2,]<-ssb/1000000
x1[3,]<-F40
x1[4,]<-catch
x1[5,]<-catch2
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2023","ForeCatch_2024"),x1)
names(x2)<-names(x)
THOMPSON_SUMMARY<-rbind(npars,x,x2)

x<-mods1[[1]]$derived_quants$Label
THOMPSON_ENSEMBLE<-vector("list",length=length(x))
for(i in 1:length(x)){
THOMPSON_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i], PLOT=FALSE)
}

THOMPSON_ENSEMBLE2<-vector("list",length=length(x))
for(i in 1:length(THOMPSON_ENSEMBLE)){
  THOMPSON_ENSEMBLE2[[i]]<-THOMPSON_ENSEMBLE[[i]]$values
}

THOMPSON_ENSEMBLE_RESULTS<-do.call(rbind,THOMPSON_ENSEMBLE2)  ## ENSEBLE RESULTS

x<-data.table(mods1[[2]]$parameters)[!is.na(Active_Cnt)]$Label

THOMPSON_ENSEMBLE_PARAS<-vector("list",length=length(x))
for(i in 1:length(x)){
THOMPSON_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i],PLOT=F)
}
dev.off()

THOMPSON_ENSEMBLE2<-vector("list",length=length(x))
for(i in 1:length(THOMPSON_ENSEMBLE_PARAS)){
  THOMPSON_ENSEMBLE2[[i]]<-THOMPSON_ENSEMBLE_PARAS[[i]]$values
}

THOMPSON_ENSEMBLE_PARAMS<-do.call(rbind,THOMPSON_ENSEMBLE2)  ## ENSEBLE PARAMETERS



ENS_RES<-rbind(THOMPSON_ENSEMBLE_RESULTS[LABEL%in%THOMPSON_SUMMARY$Label][,1:2],
THOMPSON_ENSEMBLE_PARAMS[LABEL%in%THOMPSON_SUMMARY$Label][,1:2])
names(ENS_RES)<-c("Label","THOMPSON_ENSEMBLE")

Q<-THOMPSON_ENSEMBLE_PARAMS[LABEL%like%'Q']
Q$LABEL<-'Q'
Q[,2]<-exp(Q[,2])
ANNFMSY<-THOMPSON_ENSEMBLE_RESULTS[LABEL%in%'annF_MSY']
ANNFMSY$LABEL<-'ann_F_MSY'
ssbVirg<-THOMPSON_ENSEMBLE_RESULTS[LABEL%in%'SSB_unfished']
ssbVirg$LABEL<-'SSB_Virgin_thousand_mt'
ssbVirg[,2:3]<-ssbVirg[,2:3]/1000


extra_RES<-rbind(Q[,1:2],ANNFMSY[,1:2],ssbVirg[,1:2])
names(extra_RES)<-c("Label","THOMPSON_ENSEMBLE")
ENS_RES<-rbind(ENS_RES,extra_RES)


THOMPSON_SUMMARY2<-data.table(ID=1:nrow(THOMPSON_SUMMARY),THOMPSON_SUMMARY)

THOMPSON_TABLE<-merge(THOMPSON_SUMMARY2,ENS_RES,all=T,sort=FALSE)
THOMPSON_TABLE[Label=='SR_BH_steep']$THOMPSON_ENSEMBLE<-1.0

THOMPSON_TABLE<-THOMPSON_TABLE[,-2]


THOMPSON_TABLE[2:18,2:6]<-round(THOMPSON_TABLE[2:18,2:6],3)
THOMPSON_TABLE[19:20,2:6]<-round(THOMPSON_TABLE[19:20,2:6])


ft9 <- flextable(data.frame(THOMPSON_TABLE))
ft9<-set_header_labels(ft9, THOMPSON_ENSEMBLE = "Ensemble", Model.19.12="Model 19.12",
  Model.19.12A="Model 19.12A",Model.21.1= "Model 21.1", Model.21.2="Model 21.2")
ft9 <- theme_vanilla(ft9)
ft9 <- align(ft9, align = "center", part = "header")
ft9 <- fontsize(ft9,part="all", size = 10)

 ft9 <- border_remove(x = ft9)
ft9<-hline_top(ft9, part="all", border = big_border )
ft9 <- hline_bottom(ft9, part="body", border = big_border )

save_as_docx(ft9,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/THOMPSON_SUMMARY_TABLE.docx"))




x<-vector('list',length=length(mods1))
for(i in 1:length(mods1)){
    x[[i]]<-data.table(mods1[[i]]$parameters)[Active_Cnt>0][,c(2,3)]
    x[[i]]$Q_ITER=h.vec[i]
  }

  x<-do.call(rbind,x)

  ggplot(x[Label%in% x$Label[c(1:6,73:81)]],aes(x=Q_ITER,y=Value))+geom_point()+facet_wrap(~Label,scales="free_y")+theme_bw()+labs(x="log(Q)")


  ggplot(x[Label%in% x$Label[c(1:6,66:82)]],aes(x=Q_ITER,y=Value))+geom_point()+facet_wrap(~Label,scales="free_y")+theme_bw()+labs(x="log(Q)")





windows()
SSplotProfile(
  summaryoutput=profilesummary,
  plot = TRUE,
  print = FALSE,
  models = "all",
  profile.string = "LnQ_base",
  profile.label = expression(log(italic(Q))),
   ylab = "Change in -log-likelihood",
  components = c("TOTAL", "Catch", "Equil_catch", "Survey", "Discard", "Mean_body_wt",
    "Length_comp", "Age_comp", "Size_at_age", "SizeFreq", "Morphcomp", "Tag_comp",
    "Tag_negbin", "Recruitment", "InitEQ_Regime", "Forecast_Recruitment", "Parm_priors",
    "Parm_softbounds", "Parm_devs", "F_Ballpark", "Crash_Pen"),
  component.labels = c("Total", "Catch", "Equilibrium catch", "Index data", "Discard",
    "Mean body weight", "Length data", "Age data", "Size-at-age data",
    "Generalized size data", "Morph composition data", "Tag recapture distribution",
    "Tag recapture total", "Recruitment", "Initital equilibrium recruitment",
    "Forecast recruitment", "Priors", "Soft bounds", "Parameter deviations",
    "F Ballpark", "Crash penalty"),
 )