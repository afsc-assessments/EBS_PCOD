get_lengthweight <- function(species=202,area='BS',K=7, Alpha_series=2, Beta_series=3) {
  
     if(area=="BS") location <- "between 500 and 539"
     if(area=="AI") location <- "between 540 and 543"
     if(area=="GOA") location <- "between 600 and 700"
 
  dwt = readLines('sql/dom_age_wt.sql')
  dwt = sql_filter(sql_precode = "IN", x = species, sql_code = dwt, flag = '-- insert species')
  dwt = sql_add(x = location, sql_code = dwt, flag = '-- insert location')
  data_LW=sql_run(afsc, dwt) %>% data.table() %>%
    dplyr::rename_all(toupper)
   
  fwt = readLines('sql/for_age_wt.sql')
  fwt = sql_filter(sql_precode = "IN", x = species, sql_code = fwt, flag = '-- insert species')
  fwt = sql_add(x = location, sql_code = fwt, flag = '-- insert location')
  data_LW2=sql_run(afsc, fwt) %>% data.table() %>%
    dplyr::rename_all(toupper)
  
    names(data_LW2)<-names(data_LW)

    data_LW<-rbind(data_LW2,data_LW)
    data_LW<-data_LW[!is.na(LENGTH)]
    data_LW$WEIGHT<-as.numeric(data_LW$WEIGHT)
    data_LW$LENGTH<-as.numeric(data_LW$LENGTH)
    data_LW$YEAR<-factor(data_LW$YEAR)
    data_LW$WEEK<-factor(week(data_LW$HAUL_OFFLOAD_DATE))
    data_LW$logW<-log(data_LW$WEIGHT)
    data_LW$logL<-log(data_LW$LENGTH) 

## removing outliers 

    data_LW<-data_LW[WEIGHT > 0.01]   ## removing more outliers
    data_LW<-data_LW[WEIGHT < 40]

    if(species == 202 & area =='BS') {  ## Pcod in EBS
        data_LW<-data_LW[CRUISE!=1798]   ## cruises have severe outliers on weight at length
        data_LW<-data_LW[CRUISE!=14737]
        data_LW<-data_LW[CRUISE!=14874]
    }


## plot data for review 
   
    d<-ggplot(data_LW,aes(x=LENGTH,y=WEIGHT,color=YEAR))+geom_point()
    print(d)

## overall linear model for length weight

    lm1 <- lm(logW~logL,data=data_LW[as.numeric(as.character(YEAR))>=1977])

    alpha1<-coef(lm1)[1]
    beta1<-coef(lm1)[2]

## Gam for annual residuals while considering seasonal (weekly) changes in length weight
    library(mgcv)
    data_LW$YEAR1<-as.numeric(as.character(data_LW$YEAR))
    data_LW$WEEK1<-as.numeric(as.character(data_LW$WEEK))

    lm4 <- gam(logW~YEAR*logL+s(WEEK1,by=logL,bs="cc",k=K)+s(WEEK1,bs="cc",k=K),data=data_LW)

## plot results for review    
     windows()
     par(mfrow=c(2,2))
    ## plot(lm4,all.terms=T,resid=T,shade=T,shade.col="red")
     plot(lm4,all.terms=T,select=1,resid=T,shade=T,shade.col="red",scale=0,ylim=c(0,0.7))
     plot(lm4,all.terms=T,select=2,resid=T,shade=T,shade.col="red",scale=0,ylim=c(-2,2))
     plot(lm4,all.terms=T,select=3,resid=T,shade=T,shade.col="red")
     plot(lm4,all.terms=T,select=4,resid=T,shade=T,shade.col="red")

## harvest the annual alpha and beta residuals
    data2=data.frame(expand.grid(YEAR=unique(data_LW$YEAR),WEEK1=2:52,LENGTH=seq(10,120,1)))
    data2$logL<-log(data2$LENGTH)
    data2$pred=as.numeric(predict(lm1,newdata=data2))

    data3<-data.table(data2)
    
    syx <- sigma(lm4)

    ( cf <- (syx^2)/2 )  
    ( pred.log <- predict(lm4,newdata=data3))
    ( bias.pred.orig <- exp(pred.log+cf) )

    data3$pred2<-bias.pred.orig

    alpha<-vector("list",length=length(unique(data2$YEAR)))
    beta<-vector("list",length=length(unique(data2$YEAR)))
    sigma<-vector("list",length=length(unique(data2$YEAR)))

    years1=unique(data2$YEAR)

    for(i in 1:length(years1)){
    x=lm(log(pred2)~log(LENGTH),data=data3[YEAR==years1[i]])
    alpha[[i]]<-as.numeric(coef(x)[1])
    beta[[i]]<-as.numeric(coef(x)[2])
    sigma[[i]]<-as.numeric(summary(x)$sigma)
    }

    alpha<-do.call(rbind,alpha)
    beta <-do.call(rbind,beta)
    sigma<-do.call(rbind,sigma)

    env2 <- data.frame(YEAR=years1, SERIES=Alpha_series, VALUE=exp(alpha)-exp(alpha1))
    env3 <- data.frame(YEAR=years1, SERIES=Beta_series, VALUE=beta-beta1)
    environ <- data.table(rbind(env2,env3))
    environ
}