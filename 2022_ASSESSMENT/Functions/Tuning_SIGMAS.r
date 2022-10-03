
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
	print(RMSE)
	test1<-list(RMSE=RMSE,TEST=test1)
	test1
}


do_tune<-function(direct=paste0(getwd(),"/MODEL19_12"), SUCCESS=0.001){
	
	test2<-get_Sigma(dire=direct)
	success <- test2$RMSE <= SUCCESS
    
    while(!success){
        SS_changepars(
  		dir = direct,
  		ctlfile = "control.ss_new",
  		newctlfile = "Model_19_12.ctl",
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
    	success <- test2$RMSE <= SUCCESS
		}
	test2
}


tuned19.12_new=do_tune()

