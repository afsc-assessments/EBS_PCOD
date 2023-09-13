
libs <- c("mgcv","dplyr","RODBC","data.table","ggplot2","devtools","lubridate","rgdal","reshape","reshape2")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

source('R/utils.r')  ## this file can be found in the EBS Pcod github in the functions folder

afsc=connect("afsc")  ## these are defined in the keyring library
akfin=connect("akfin")


## Survey EWAA
species=21720
region= 'BS'

ageS= readLines('sql/srv_ages.sql') ## this file can be found in the EBS Pcod github in the functions folder
ageS = sql_filter(sql_precode = "IN", x = species, sql_code = ageS, flag = '-- insert species')
ageS = sql_filter(sql_precode = "IN", x = region, sql_code = ageS, flag = '-- insert region')

S_data=sql_run(afsc, ageS) %>% 
         data.table()

S_data[Weight_kg==0]$Weight_kg <- NA

SW_data<-S_data[!is.na(Weight_kg)]
SW2_data<-S_data[is.na(Weight_kg)]

x<-lm(log(Weight_kg)~log(Length_cm),data=SW_data)

SW2_data$Weight_kg<-exp(predict(x,newdata=SW2_data))

S_data2<-rbind(SW_data,SW2_data)


S_WTAGE<-weight_at_age_wide(S_data2,value = "weight",maxage = 10)

names(S_WTAGE)[1]<-'Year'
S_WTAGE<-arrange(S_WTAGE,Year)
names(S_WTAGE)[1]<-'#Yr'

S_WTAGE<-fill_wtage_matrix(S_WTAGE,option="row")


S_NAGE<-weight_at_age_wide(S_data2,value = "count",maxage = 10)
names(S_NAGE)[1]<-'Year'
S_NAGE<-arrange(S_NAGE,Year)
names(S_NAGE)[1]<-'#Yr'


make_wtatage_plots (plots = 1:6, data=S_WTAGE2, counts=S_NAGE, lengths = NULL,
                               dir = getwd(), year = as.numeric(format(Sys.Date(), "%Y")), maxage = 10)

## Fishery EWAA
species=202
area= (500:539)

agew= readLines('sql/dom_age_wt2.sql') ## this file can be found in the EBS Pcod github in the functions folder
agew = sql_filter(sql_precode = "IN", x = species, sql_code = agew, flag = '-- insert species')
agew = sql_filter(sql_precode = "IN", x = area, sql_code = agew, flag = '-- insert location')

Fish_data=sql_run(akfin, agew) %>% 
         dplyr::rename_all(toupper)%>% data.table()


Fish_data$GEAR<-as.factor(Fish_data$GEAR)
Fish_data<-Fish_data[YEAR>2006]
Fish_data$YEAR<-as.factor(Fish_data$YEAR)
Fish_data$AREA<-trunc(Fish_data$NMFS_AREA/10)
Fish_data$NMFS_AREA<-as.factor(Fish_data$NMFS_AREA)
Fish_data$MONTH<-as.numeric(as.character(Fish_data$MONTH))

Fish_data$QUARTER=4
Fish_data[MONTH<3]$QUARTER=1
Fish_data[MONTH>6&MONTH<10]$QUARTER=3
Fish_data[MONTH>3&MONTH<7]$QUARTER=2
Fish_data$QUARTER<-as.factor(Fish_data$QUARTER)

Fish_data[WEIGHT>50]$WEIGHT<-NA
Fish_data[WEIGHT==0]$WEIGHT<-NA


Fish_data[AREA==50]$AREA<-51
Fish_data$AREA<-as.factor(Fish_data$AREA)

Fish_data$COHORT<-as.numeric(as.character(Fish_data$YEAR))-as.numeric(as.character(Fish_data$AGE))


WEIGHT<-Fish_data[!is.na(WEIGHT)]
WEIGHT<-WEIGHT[WEIGHT!=0.01]
AGE<-Fish_data[!is.na(AGE)]

WEIGHT$logW<-log(WEIGHT$WEIGHT)
WEIGHT$logL<-log(WEIGHT$LENGTH)

test_W2 <- gam(logW~YEAR*logL+s(MONTH,by=logL,bs="cc",k=7)+s(MONTH,bs="cc",k=7)+GEAR+AREA,data=WEIGHT)

AGE$logL<-log(AGE$LENGTH)

AGE$WEIGHTP<-exp(predict(object=test_W2,newdata=AGE,type='response'))
AGE[AGE>10]$AGE<-10


F_data=data.table(Source='Fishery',Weight_kg=AGE$WEIGHTP,Sex=AGE$SEX,Age_yrs=AGE$AGE,Length_cm=AGE$LENGTH,Month=AGE$MONTH,Year=AGE$YEAR)


F_WTAGE<-weight_at_age_wide(F_data,value = "weight",maxage = 10)

names(F_WTAGE)[1]<-'Year'
F_WTAGE<-arrange(F_WTAGE,Year)
names(F_WTAGE)[1]<-'#Yr'

F_WTAGE<-fill_wtage_matrix(F_WTAGE,option="row")


F_NAGE<-weight_at_age_wide(F_data,value = "count",maxage = 10)
names(F_NAGE)[1]<-'Year'
F_NAGE<-arrange(F_NAGE,Year)
names(F_NAGE)[1]<-'#Yr'




