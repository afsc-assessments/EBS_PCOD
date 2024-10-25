
get_Sigma<-function(dire=paste0(getwd(),"/MODEL19_12")) {

	mods1<-SS_output(dire,verbose = FALSE)

	parameters=data.table(mods1$parameters)[Label %like% "_dev_se"]$Label
	parameters_short<-substr(parameters,1,nchar(parameters)-10)

	para1<-array(dim=length(parameters)+1)
    para2<-array(dim=length(parameters)+1)
    para3<-array(dim=length(parameters)+1)

    para1[1]<-data.table(mods1$parameters)[Label=="SR_sigmaR"]$Value
    para2[1]<-var(data.table(mods1$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Value)
    para3[1]<-mean(data.table(mods1$parameters)[Label%like%"Main_RecrDev"&Pr_type=="dev"]$Parm_StDev^2)

	for(j in 2:length(para1)){
		 para1[j]<-data.table(mods1$parameters)[Label==parameters[j-1]]$Value
         para2[j]<-var(data.table(mods1$parameters)[Label%like%parameters_short[j-1]&Pr_type=="dev"]$Value)
	     para3[j]<-mean(data.table(mods1$parameters)[Label%like%parameters_short[j-1]&Pr_type=="dev"]$Parm_StDev^2)
	 }
	 

	test1<- data.frame(OLD=para1,VAR1=para2,VAR2=para3)
	t1<-(sum(test1[1,2:3])/(test1[1,1]^2)-1)
	t2<-rowSums(test1[(2:(length(para1))),2:3])-1
	test1$OBJ_FUNC<-c(t1,t2)
	test1$NEW<-round(test1$OLD*(1+(1-0.5)*test1$OBJ_FUNC),4)
	test1$PARAMETERS<-c("SR_sigmaR",parameters)
	RMSE <- sqrt(crossprod(test1$OBJ_FUNC)/length(para1))
	print(paste0("RMSE = ",RMSE))
	test1<-list(RMSE=RMSE,TEST=test1)
	test1
}


do_tune<-function(mod="MODEL19_12a", ctlfile1="Model_19_12a.ctl", SUCCESS=0.001, runs=20){
	require(r4ss)
	require(data.table)
	test3<-vector("list",length=runs)
	direct<-paste0(getwd(),"/",mod)
	test2<-get_Sigma(dire=direct)
	success <- test2$RMSE <= SUCCESS
    count=1
    while(!success){
    	print(paste0("This is run ",count))
        SS_changepars(
  		dir = direct,
  		ctlfile = "control.ss_new",
  		newctlfile = ctlfile1,
  		strings = test2$TEST$PARAMETERS,
  		newvals = test2$TEST$NEW,
 	 	)

		run(
  		dir = direct,
  		skipfinished = FALSE,
  		show_in_console = FALSE,
  		console_output_file = "console.output.txt",
  		verbose = TRUE,
  		exe = "ss"
		)

    	test2<-get_Sigma(dire=direct)
    	print(test2$TEST)
    	test3[[count]]<-test2
    	count<-count+1
    	success <- test2$RMSE <= SUCCESS
    	success <- count == runs
		}
	test3
}

#tuned23.2=do_tune(mod="MODEL_23.2_tune",ctlfile="Model_22.3A.ctl")

tuned24.1=do_tune(mod="Model_24.1",ctlfile="Model_24.1.ctl")

tuned24.4=do_tune(mod="Model_24.4.0",ctlfile="Model_24.1.ctl")

tuned23.1.0.d=do_tune(mod="Model_23.1.0.d_Tuned",ctlfile="Model_22.3A.ctl")

tuned24.4=do_tune(mod="Model_24.4.0",ctlfile="Model_24.2.ctl")

Model_23.1.0.d_Tuned


#setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS")
#models=c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
#x2<-vector("list",length=4)
#for(i in 1:length(models)){
#   x<-get_Sigma(dire=paste0(getwd(),"/",models[i]))
#   x2[[i]]<-data.table(MODEL=models[i],RMSE=x$RMSE,SIGMA=x$TEST$OLD,PARAMETER=x$TEST$PARAMETERS)
# }
# x3<-do.call(rbind,x2)
# x3$MODEL<-paste0(X3$MODEL,"_THOMPSON")
#setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS")
#models=c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
#models2<-c("Model 22.1","Model 22.2","Model 22.3","Model 22.4",)
#x2<-vector("list",length=4)
#for(i in 1:length(models)){
#    x<-get_Sigma(dire=paste0(getwd(),"/",models[i]))
#    x2[[i]]<-data.table(MODEL=models2[i],RMSE=x$RMSE,SIGMA=x$TEST$OLD,PARAMETER=x$TEST$PARAMETERS)
# }
# x4<-do.call(rbind,x2)
# x4$MODEL<-paste0(X4$MODEL,"_NEW")
# SIGMAS= rbind(x3,x4)

