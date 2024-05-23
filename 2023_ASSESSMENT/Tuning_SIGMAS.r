## Function for extracting variance terms of the sigmas in a stock synthesis model based on Grant Thompson's method 
## for tuning the EBS Pacific cod model which is based on Method #3 from Methot and Taylor (2011).
# @dire = the directory for the model for which variance terms are to be calculated

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
	     para3[j]<-mean(data.table(mods1$parameters)[Label%like%parameters_short[j-1]&Pr_type=="dev"]$Parm_StDev)^2
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

## function for iterating through tuning of sigmas for stock synthesis model
# @mod = model for tuning
# @ctlfile1 = SS control file for model that is to be tuned
# @SUCCESS = objective function value at which to stop the iterations
# @ runs = number of runs to complete before stopping

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
  		verbose = TRUE
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
