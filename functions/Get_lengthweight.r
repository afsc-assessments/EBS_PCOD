 ## Function to calculate annual alpha and beta residuals for length weight relationship from observer data which incorporates seasonal variation
 ## species is the observer species code, area is EBS, AI, or GOA, K is the degrees of freedom for the GAM splines, Alpha_series 
 ##  is the environmental series number for Stock Synthesis and Beta_series is the environmental series number
 ##  Based on method used by Thompson et al. 2021 BS Pacific cod assessment. 
 ## 


get_lengthweight <- function(species=202,area='EBS',K=12, Alpha_series=2, Beta_series=3) {
 
    require(data.table)
    require(ggplot2)
    require(reshape2)
    require(rgdal)
    require(dplyr)
    require(lubridate)
    require(reshape)
     
     if(area=="EBS") location <- "500 and 539"
     if(area=="AI") location <- "540 and 543"
     if(area=="GOA") location <- "600 and 700"
 

    LW1<-paste0("SELECT
        obsint.debriefed_age.species,
        obsint.debriefed_age.year,
        TO_CHAR(obsint.debriefed_age.haul_offload_date, 'mm') AS month,
        obsint.debriefed_age.haul_offload_date,
        obsint.debriefed_age.cruise,
        obsint.debriefed_age.vessel,
        obsint.debriefed_age.gear,
        obsint.debriefed_age.sex,
        obsint.debriefed_age.length,
        obsint.debriefed_age.weight
    FROM
        obsint.debriefed_age
    WHERE
        obsint.debriefed_age.species =",species,
        "AND obsint.debriefed_age.length IS NOT NULL
        AND obsint.debriefed_age.weight IS NOT NULL
        AND obsint.debriefed_age.nmfs_area BETWEEN ",location,
    "ORDER BY
        obsint.debriefed_age.year,
        obsint.debriefed_age.cruise,
        obsint.debriefed_age.vessel,
        obsint.debriefed_age.length,
        obsint.debriefed_age.weight")



    LW2<-paste0("SELECT
        norpac.foreign_age.species,
        norpac.foreign_age.year,
        TO_CHAR(norpac.foreign_age.dt, 'mm') AS month,
        norpac.foreign_age.dt,
        norpac.foreign_age.cruise,
        norpac.foreign_age.vessel,
        norpac.foreign_fishing_operation.vessel_type_code,
        norpac.foreign_age.sex,
        norpac.foreign_age.length,
        norpac.foreign_age.indiv_weight
    FROM
        norpac.foreign_age
        INNER JOIN norpac.foreign_haul ON norpac.foreign_age.haul_join = norpac.foreign_haul.haul_join
        AND norpac.foreign_age.cruise = norpac.foreign_haul.cruise
        AND norpac.foreign_age.vessel = norpac.foreign_haul.vessel
        INNER JOIN norpac.foreign_fishing_operation ON norpac.foreign_haul.cruise = norpac.foreign_fishing_operation.cruise
        AND norpac.foreign_haul.vessel = norpac.foreign_fishing_operation.vessel
    WHERE
        norpac.foreign_age.species = ",species,
        "AND norpac.foreign_haul.generic_area BETWEEN ", location,
    "ORDER BY
        norpac.foreign_age.year,
        norpac.foreign_age.cruise,
        norpac.foreign_age.vessel,
        norpac.foreign_age.length,
        norpac.foreign_age.indiv_weight")

    data_LW<- data.table(sqlQuery(AFSC,LW1,as.is=T))
    data_LW2<- data.table(sqlQuery(AFSC,LW2,as.is=T))
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

    if(species == 202 & area =='EBS') {  ## Pcod in EBS
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
    #windows()
    #par(mfrow=c(2,2))
    #plot(lm4,all.terms=T,resid=T,shade=T,shade.col="red")

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

