## Getting catch data

libs <- c("flextable","readxl","magrittr","scales","tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)


##<<<<<<< HEAD
afsc_user  = ""   ## enter afsc username
afsc_pwd   = ""    ## enter afsc password
akfin_user = ""  ## enter AKFIN username
akfin_pwd  = ""   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)

# this assumes that the FUNCTIONS subdirectory is in the working directory
working_dir <- "C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT"


# the most recent year of data to be used
new_SS_dat_year <- 2022
final_year <- new_SS_dat_year

# the FMP area for this stock
sp_area <- 'BSAI'

# the GOA FMP sub-areas in the COUNCIL.COMPREHENSIVE_BLEND_CA database table
fsh_sp_area <- 'BS'

LL_sp_region <- 'Bering Sea'

# species label for AKFIN
fsh_sp_label <- 'PCOD'

for_sp_label = 'PACIFIC COD'

# the fishery species code(s) for this stock/these stocks
fsh_sp_str <- 202

# year in which to start the fishery data
fsh_start_yr <- 1977
fsh_age_start_yr <- 2007

# fraction of the year that the fishery length- and weight-at-age calculations are done
fsh_frac <- 0.5

# the survey species code(s) for this stock/these stocks
srv_sp_str <- "21720"

# year in which to start the bottom trawl survey data
srv_start_yr <- 1980

# year in which to start the LL survey data
LLsrv_start_yr <- 1990

# fraction of the year that the survey takes place
srv_frac <- 0.5833333333

# length bins to use for fsh and srv length comp data
bin_width <- 1
min_size <- 3.5
max_size <- 119.5  # less than 1% of the fish in each year are 105 cm or larger (max less than 0.6%)
len_bins <- seq(min_size,max_size,bin_width)

# maximum age
max_age <- 20


## Get all the functions for pulling BS Pcod data

setwd(paste(working_dir,"\\Functions\\R",sep=""))

source_files=c("BIN_LEN_DATA.r","FORMAT_AGE_MEANS1.r", "GET_BS_ACOMP1.r","GET_BS_BIOM.r","GET_BS_LCOMP1.r",             
     "GET_SURV_AGE_cor.r", "LENGTH_BY_CATCH_BS.r","LENGTH_BY_CATCH_BS_short.r","Get_lengthweight.r","utils.r") 


lapply(source_files, source)

setwd(paste(working_dir,"\\Functions",sep=""))
## get catch data
 catch= readLines('sql/dom_catch_table.sql')
 catch = sql_filter(sql_precode = "<=", x = final_year, sql_code = catch, flag = '-- insert year')
 catch = sql_filter(sql_precode = "IN", x = fsh_sp_label, sql_code = catch, flag = '-- insert species_catch')
 catch = sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = catch, flag = '-- insert subarea')


CATCH=sql_run(akfin, catch) %>% 
         dplyr::rename_all(toupper)

  CATCH$GEAR1<-"TRAWL"
  CATCH$GEAR1[CATCH$GEAR=="POT"]<-"POT"
  CATCH$GEAR1[CATCH$GEAR=="HAL"]<-"LONGLINE"
  CATCH$GEAR1[CATCH$GEAR=="JIG"]<-"OTHER"
  CATCH_TOTAL<-data.table(CATCH)[,list(TONS=sum(round(TONS,0))),by=c('YEAR','GEAR1','RETAINED_OR_DISCARDED')]
  names(CATCH_TOTAL)<-c("YEAR","GEAR","RETAINED","TONS")


  CATCH_TOTAL_YEAR<-data.table(CATCH)[,list(TOTAL_TONS=sum(round(TONS,0))),by=c('YEAR','GEAR1')]
   names(CATCH_TOTAL_YEAR)<-c("YEAR","GEAR","TOTAL_TONS")
   CATCH_TOTAL<-merge(CATCH_TOTAL,CATCH_TOTAL_YEAR)
   CATCH_TOTAL$PROPORTION_RETAINED<-round(CATCH_TOTAL$TONS/CATCH_TOTAL$TOTAL_TONS,2)*100

 

GRID<-expand.grid(YEAR=unique(CATCH_TOTAL$YEAR),RETAINED=c('D','R'),GEAR=unique(CATCH_TOTAL$GEAR))
CATCH_TOTAL<-merge(CATCH_TOTAL,GRID,all.y=T,by=c('YEAR','RETAINED','GEAR'))
CATCH_TOTAL[is.na(TOTAL_TONS)]$TOTAL_TONS<-0
CATCH_TOTAL[is.na(PROPORTION_RETAINED)]$PROPORTION_RETAINED<-0


attr(CATCH_TOTAL$YEAR, "label") <- "Year"
attr(CATCH_TOTAL$GEAR, "label") <- "Gear Type"
attr(CATCH_TOTAL$RETAINED, "label") <- "Retained/Discarded"
attr(CATCH_TOTAL$TOTAL_TONS, "label") <- "Catch (t)"

CT1<-CATCH_TOTAL[RETAINED=='R'][,c(1,3,5,6)]
names(CT1)<-c("Year","Gear","Catch","Retained")

dt1 <- dcast(CT1, Year ~ Gear, value.var="Catch")
dt1$TOTAL<-rowSums(dt1[,2:5])
dt2 <- dcast(CT1, Year ~ Gear, value.var="Retained")

dt3<-cbind(dt1,dt2[,2:5])

set_flextable_defaults(
  font.size = 10, font.family = "Times New Roman",
  table.layout = "fixed",
  border.color = "gray",
  padding.top = 1, padding.bottom = 1,
  padding.left = 1, padding.right = 1)


ft <- flextable(data.frame(dt3))
ft <- set_header_labels(ft, Year = "Year", 
    LONGLINE = "Longline", POT = "Pot", TRAWL="Trawl",OTHER="Other",TOTAL="Total",
    LONGLINE.1 = "Longline", POT.1 = "Pot", TRAWL.1="Trawl",OTHER.1="Other")
 ft <- add_header_row(ft,
   values = c("    ", "Catch (t)","Percent retained (%)"),
   colwidths=c(1,5,4) 
 )
 ft <- theme_vanilla(ft)
 ft <- align(ft, align = "center", part = "header")
 ft <- fontsize(ft,part="all", size = 10)

 ft <- border_remove(x = ft)
ft<-hline_top(ft, part="all", border = big_border )
ft <- hline_bottom(ft, part="body", border = big_border )
 
setwd(paste0(working_dir,"/NOVEMBER_MODELS/TABLES",sep=""))
save_as_docx(ft,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/CATCH_TABLE1.docx"))

## TAC_CATCH TABLE
SPECS<-data.table(read.csv("BSAI_harvest_specs.csv"))
SPECS[YEAR>1990]$CATCH<-dt3$TOTAL
SPECS$YEAR<-as.character(SPECS$YEAR)

small_border = fp_border(color="gray", width = 1)
big_border = fp_border(color="black", width = 1.5)

ft2 <- flextable(data.frame(SPECS[,1:5]))
ft2 <- set_header_labels(ft2, Year = "Year", 
    CATCH = "Catch", TAC = "TAC", ABC="ABC",OFL="OFL")
ft2 <- theme_vanilla(ft2)
ft2 <- align(ft2, align = "center", part = "header")
ft2 <- border_remove(x = ft2)
ft2<-hline_top(ft2, part="all", border = big_border )
ft2 <- hline_bottom(ft2, part="body", border = big_border )

save_as_docx(ft2,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/CATCH_TABLE2.docx"))


## fishery and survey size composition sample sizes
setwd(paste(working_dir,"\\Functions",sep=""))

FISHLCOMP<-LENGTH_BY_CATCH_short(species=fsh_sp_str ,species_catch=fsh_sp_label, for_species_catch=for_sp_label,sp_area=fsh_sp_area ,ly=final_year, SEX=FALSE, PORT=TRUE)
FSH_LCOMP<-FISHLCOMP[[1]]
Nsamp<-FSH_LCOMP[,list(nsamp=max(NHAUL)),by=c("YEAR")]
names(Nsamp)<-c("YEAR","FISHERY")

cs= readLines('sql/count_EBS.sql')
cs = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = cs, flag = '-- insert species')

CS=sql_run(afsc, cs) %>% 
         dplyr::rename_all(toupper)

Nsamp2<-merge(Nsamp,CS[,c(2,3)],all=T)
Nsamp2$FISHERY_INPUT<-round((Nsamp$nsamp/mean(Nsamp$nsamp))*mean(CS$HAULS))
Nsamp3<-data.table(Year=Nsamp2$YEAR,Survey=Nsamp2$HAULS,Fishery=Nsamp2$nsamp,Fishery_I=nsamp2$FISHERY_INPUT)
Nsamp3$Year<-as.character(Nsamp3$Year)

ft3 <- flextable(data.frame(Nsamp3))
ft3 <- set_header_labels(ft3, Year = "Year", 
    Survey = "Survey hauls", Fishery = "Fishery hauls", Fishery_I='Fishery input')
ft3 <- theme_vanilla(ft3)
ft3 <- align(ft3, align = "center", part = "header")
ft3 <- border_remove(x = ft3)
ft3<-hline_top(ft3, part="all", border = big_border )
ft3 <- hline_bottom(ft3, part="body", border = big_border )


save_as_docx(ft3,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/HAULS_TABLE.docx"))






## VAST survey index


setwd(paste(working_dir,"\\Functions\\ALT_DATA\\VAST",sep=""))
test_file <- "Table_for_SS3.csv"
if (!file.access(test_file,mode=4))
   {
    VAST_abundance<-read.csv(test_file,header=T)
   }

test_file <- "proportions.csv"
if (!file.access(test_file,mode=4))
   {
    VAST_AGECOMP<-read.csv(test_file,header=T)
   }

test_file <- "CPUE_index.csv"
if (!file.access(test_file,mode=4))
   {
    VAST_CPUE_INDEX<-read.csv(test_file,header=T)
   }

V_CPUEINDEX<-data.table(YEAR=VAST_CPUE_INDEX$Time,CPUE_INDEX=round(VAST_CPUE_INDEX$Estimate),CPUE_INDEX_Sigma=round(VAST_CPUE_INDEX[,7],3))
VAST_abundance<-data.table(VAST_abundance)[Fleet=="Both"]
SURVEYS<-data.frame(YEAR=VAST_abundance$Year,VAST_BT=round(VAST_abundance$Estimate),VAST_BT_Sigma=round(VAST_abundance$SD_log,3))
SURVEYS<-merge(SURVEYS,V_CPUEINDEX, by="YEAR",all=T)
 
setwd(paste(working_dir,"\\Functions",sep=""))
db_EBS= readLines('sql/BS_srv_biom.sql')
db_EBS = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = db_EBS, flag = '-- insert species')
db_EBS=sql_run(afsc, db_EBS) %>% 
         dplyr::rename_all(toupper)

db_NBS= readLines('sql/NBS_srv_biom.sql')
db_NBS = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = db_NBS, flag = '-- insert species')


db_NBS=sql_run(afsc, db_NBS) %>% 
         dplyr::rename_all(toupper)

names(db_NBS)[3:8]<-paste0("NBS_",names(db_NBS)[3:8])

db_ALL<-data.table(merge(db_EBS,db_NBS,all=T))

db_ALL[is.na(NBS_POPULATION)]$NBS_POPULATION<-0
db_ALL[is.na(NBS_BIOMASS)]$NBS_BIOMASS<-0
db_ALL[is.na(NBS_VARBIO)]$NBS_VARBIO<-0
db_ALL[is.na(NBS_VARPOP)]$NBS_VARPOP<-0

db_ALL$TOTAL_POP<-round(rowSums(db_ALL[,c("POP","NBS_POPULATION")]))
db_ALL$TOTAL_BIOM<-rowSums(db_ALL[,c("BIOM","NBS_BIOMASS")])
db_ALL$TOTAL_BIOMVAR<-rowSums(db_ALL[,c("BIOMVAR","NBS_VARBIO")])
db_ALL$TOTAL_POPVAR<-rowSums(db_ALL[,c("POPVAR","NBS_VARPOP")])

db_ALL$POP_SIGMA<-round(sqrt(db_ALL$TOTAL_POPVAR)/db_ALL$TOTAL_POP,3)

DB_SURVEY<-db_ALL[,c("YEAR","TOTAL_POP","POP_SIGMA")]
TSURVEY<-merge(SURVEYS,DB_SURVEY,ALL=T)
TSURVEY$YEAR<-as.character(TSURVEY$YEAR)


ft4 <- flextable(data.frame(TSURVEY))
ft4 <- set_header_labels(ft4, YEAR = "Year", 
    VAST_BT = "Survey population", VAST_BT_Sigma = "Survey sigma", 
    CPUE_INDEX="CPUE Index",CPUE_INDEX_Sigma="CPUE index sigma",
    TOTAL_POP="Survey population",POP_SIGMA="Survey sigma")
 ft4 <- add_header_row(ft4,
   values = c("    ", "VAST","Design-based"),
   colwidths=c(1,4,2) 
 )
 ft4 <- theme_vanilla(ft4)
 ft4 <- align(ft4, align = "center", part = "header")
 ft4 <- fontsize(ft4,part="all", size = 10)

 ft4 <- border_remove(x = ft4)
ft4<-hline_top(ft4, part="all", border = big_border )
ft4 <- hline_bottom(ft4, part="body", border = big_border )
save_as_docx(ft4,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/INDEX_TABLE.docx"))

## Design based biomass estimates.
db_BIOM<-data.table(YEAR=as.character(db_ALL$YEAR),EBS_BIOMASS=round(db_ALL$BIOM),
	EBS_BIOM_Sigma=round(sqrt(db_ALL$BIOMVAR)/db_ALL$BIOM,3),NBS_BIOM=round(db_ALL$NBS_BIOMASS),
	NBS_BIOM_Sigma=round(sqrt(db_ALL$NBS_VARBIO)/db_ALL$NBS_BIOMASS,3),
	TOTAL_BIOM=round(db_ALL$TOTAL_BIOM),TOTAL_BIOM_Sigma=round(sqrt(db_ALL$TOTAL_BIOMVAR)/db_ALL$TOTAL_BIOM,3))
db_BIOM[NBS_BIOM==0]$NBS_BIOM<-NaN

ft5 <- flextable(data.frame(db_BIOM))
ft5 <- set_header_labels(ft5, YEAR = "Year", 
    EBS_BIOMASS = "Biomass (t)", EBS_BIOM_Sigma = "sigma", 
    NBS_BIOM="Biomass (t)",NBS_BIOM_Sigma="sigma",
    TOTAL_BIOM="Biomass (t)",TOTAL_BIOM_Sigma="sigma")
 ft5 <- add_header_row(ft5,
   values = c("    ", "EBS","NBS","Total"),
   colwidths=c(1,2,2,2) 
 )
 ft5 <- theme_vanilla(ft5)
 ft5 <- align(ft5, align = "center", part = "header")
 ft5 <- fontsize(ft5,part="all", size = 10)

 ft5 <- border_remove(x = ft5)
ft5<-hline_top(ft5, part="all", border = big_border )
ft5 <- hline_bottom(ft5, part="body", border = big_border )

save_as_docx(ft5,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/SURVEY_BIOMASS_TABLE.docx"))

region=c(500:539)
## number of ages
setwd(paste(working_dir,"\\Functions",sep=""))
d_ages= readLines('sql/dom_age.sql')
d_ages = sql_filter(sql_precode = "IN", x = fsh_sp_str, sql_code = d_ages, flag = '-- insert species')
d_ages = sql_filter(sql_precode = "IN", x = region, sql_code = d_ages, flag = '-- insert region')
d_ages=sql_run(afsc, d_ages) %>% 
         dplyr::rename_all(toupper)

NOTOS_f<-data.table(d_ages)[,list(FISHERY_COL=length(LENGTH)),by="YEAR"]

D_ages<-data.table(d_ages)[!is.na(AGE)]         

NOTOS_F<-D_ages[,list(FISHERY_AGED=length(LENGTH)),by="YEAR"]
NOTOS_F<-merge(NOTOS_f,NOTOS_F,all=T)


s_ages= readLines('sql/survey_age.sql')
s_ages = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = s_ages, flag = '-- insert species')
s_ages = sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = s_ages, flag = '-- insert survey')
s_ages = sql_filter(sql_precode = ">=", x = srv_start_yr, sql_code = s_ages, flag = '-- insert year')
s_ages=sql_run(afsc, s_ages) %>% 
         dplyr::rename_all(toupper)

NOTOS_s<-data.table(s_ages)[,list(SURVEY_COL=length(AGE)),by="YEAR"]
S_ages<-data.table(s_ages)[!is.na(AGE)]
NOTOS_S<-S_ages[,list(SURVEY_AGED=length(AGE)),by="YEAR"]
NOTOS_S<-merge(NOTOS_s,NOTOS_S,all=T)


NOTOS_S$YEAR<-as.character(NOTOS_S$YEAR)
NOTOS_F$YEAR<-as.character(NOTOS_F$YEAR)

NOTOS=merge(NOTOS_S,NOTOS_F,all=T)


## number of fishery lengths
LEN_F<-data.table(YEAR=as.character(FISHLCOMP[[1]][LENGTH==1]$YEAR),FISH_LENGTH=FISHLCOMP[[1]][LENGTH==1]$NSAMP)

## number of survey lengths
s_len= readLines('sql/survey_length_number.sql')
s_len = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = s_len, flag = '-- insert species')
s_len = sql_filter(sql_precode = "IN", x = fsh_sp_area, sql_code = s_len, flag = '-- insert survey')
s_len=sql_run(afsc, s_len) %>% 
         dplyr::rename_all(toupper)
 s_len$YEAR<-as.character(s_len$YEAR)

 NOTOS<-merge(NOTOS,s_len,all=T)
 NOTOS<-merge(NOTOS,LEN_F,all=T)



ft6 <- flextable(data.frame(NOTOS))
ft6 <- set_header_labels(ft6, YEAR = "Year", 
    SURVEY_COL = "Survey Collected", SURVEY_AGED="Survey Aged",
    FISHERY_COL = "Fishery Collected",FISHERY_AGED="Fishery Aged", 
    SURVEY_LENGTH="Survey",FISH_LENGTH="Fishery"
    )
 ft6 <- add_header_row(ft6,
   values = c(" ", "Otoliths","Lengths"),
   colwidths=c(1,4,2) 
 )
 ft6 <- theme_vanilla(ft6)
 ft6 <- align(ft6, align = "center", part = "header")
 ft6 <- fontsize(ft6,part="all", size = 10)

 ft6 <- border_remove(x = ft6)
ft6<-hline_top(ft6, part="all", border = big_border )
ft6 <- hline_bottom(ft6, part="body", border = big_border )
save_as_docx(ft6,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/LEN_OTOS_NUMBER_TABLE.docx"))

## Annual weigtht length parameter offsets
## Environmental data for length weight 
  len_weight<-get_lengthweight(species=fsh_sp_str,area=fsh_sp_area,K=7,Alpha_series=2,Beta_series=3)

 len1<-len_weight[SERIES==2]

len2<-len_weight[SERIES==3]
len=data.table(YEAR=as.character(len_weight[SERIES==2]$YEAR),alpha=formatC(len_weight[SERIES==2]$VALUE, format = "e", digits = 3),space=" ",beta=formatC(len_weight[SERIES==3]$VALUE, format = "e", digits = 3))
 
  
ft7 <- flextable(data.frame(len))
ft7 <- set_header_labels(ft7, YEAR = "Year",space=" ")#,beta=expression(beta),alpha=expression(alpha))

 ft7 <- theme_vanilla(ft7)
 ft7 <- align(ft7, align = "center", part = "header")
 ft7 <- fontsize(ft7,part="all", size = 10)

 ft7 <- border_remove(x = ft7)
ft7<-hline_top(ft7, part="all", border = big_border )
ft7 <- hline_bottom(ft7, part="body", border = big_border )

save_as_docx(ft7,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/LEN_WEIGHT_PARAM_TABLE.docx"))

## MODEL results

source("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/FUNCTIONS/R/ENSEMBLE_FUNCTIONS.r")

WT=c(0.2842,0.3158,0.2316,0.1684)  ## ensemble weights


setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)

x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2023']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2023']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)
npars<-c(max(data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[2]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[3]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[4]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt))

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
NEW_SUMMARY<-rbind(npars,x,x2)

NEW_SUMMARY[2:20,2:5]<-round(NEW_SUMMARY[2:20,2:5],3)
#write.csv(NEW_SUMMARY,"NEW_SUMMARY_TABLE.csv",row.names=F)


x<-mods1[[2]]$derived_quants$Label
NEW_ENSEMBLE<-vector("list",length=length(x))
for(i in 1:length(x)){
NEW_ENSEMBLE[[i]]<-graph_ensemble(models=mods1,label=x[i], PLOT=FALSE)
}
NEW_ENSEMBLE2<-vector("list",length=length(x))
for(i in 1:length(NEW_ENSEMBLE)){
	NEW_ENSEMBLE2[[i]]<-NEW_ENSEMBLE[[i]]$values
}

NEW_ENSEMBLE_RESULTS<-do.call(rbind,NEW_ENSEMBLE2)



x<-data.table(mods1[[2]]$parameters)[!is.na(Active_Cnt)]$Label
NEW_ENSEMBLE_PARAS<-vector("list",length=length(x))

for(i in 1:length(x)){
NEW_ENSEMBLE_PARAS[[i]]<-graph_ensemble_params(models=mods1,label=x[i],PLOT=FALSE)
print(x[i])
}


NEW_ENSEMBLE2<-vector("list",length=length(x))
for(i in 1:length(NEW_ENSEMBLE_PARAS)){
	NEW_ENSEMBLE2[[i]]<-NEW_ENSEMBLE_PARAS[[i]]$values
}

NEW_ENSEMBLE_PARAMS<-do.call(rbind,NEW_ENSEMBLE2)
remove(NEW_ENSEMBLE2)

ENS_RES<-rbind(NEW_ENSEMBLE_RESULTS[LABEL%in%NEW_SUMMARY$Label][,1:2],
NEW_ENSEMBLE_PARAMS[LABEL%in%NEW_SUMMARY$Label][,1:2])
names(ENS_RES)<-c("Label","NEW_ENSEMBLE")

Q<-NEW_ENSEMBLE_PARAMS[LABEL%like%'Q']
Q$LABEL<-'Q'
ANNFMSY<-NEW_ENSEMBLE_RESULTS[LABEL%in%'annF_MSY']
ANNFMSY$LABEL<-'ann_F_MSY'
ssbVirg<-NEW_ENSEMBLE_RESULTS[LABEL%in%'SSB_unfished']
ssbVirg$LABEL<-'SSB_Virgin_thousand_mt'
ssbVirg[,2:3]<-ssbVirg[,2:3]/1000


extra_RES<-rbind(Q[,1:2],ANNFMSY[,1:2],ssbVirg[,1:2])
names(extra_RES)<-c("Label","NEW_ENSEMBLE")
ENS_RES<-rbind(ENS_RES,extra_RES)


NEW_SUMMARY2<-data.table(ID=1:nrow(NEW_SUMMARY),NEW_SUMMARY)

NEW_TABLE<-merge(NEW_SUMMARY2,ENS_RES,all=T,sort=FALSE)
NEW_TABLE[Label=='SR_BH_steep']$NEW_ENSEMBLE<-1.0

NEW_TABLE<-NEW_TABLE[,-2]

NEW_TABLE[2:18,2:6]<-round(NEW_TABLE[2:18,2:6],3)
NEW_TABLE[19:20,2:6]<-round(NEW_TABLE[19:20,2:6])


ft8 <- flextable(data.frame(NEW_TABLE))
ft8<-set_header_labels(ft8, NEW_ENSEMBLE = "Ensemble", Model.22.1="Model 22.1",
	Model.22.2="Model 22.2",Model.22.3= "Model 22.3", Model.22.4="Model 22.4")
ft8 <- theme_vanilla(ft8)
ft8 <- align(ft8, align = "center", part = "header")
ft8 <- fontsize(ft8,part="all", size = 10)

 ft8 <- border_remove(x = ft8)
ft8<-hline_top(ft8, part="all", border = big_border )
ft8 <- hline_bottom(ft8, part="body", border = big_border )

save_as_docx(ft8,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/NEW_SUMMARY_TABLE.docx"))

FL_LIKE<-vector("list",length=4)
for(i in 1:4){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}

NEW_FL_LIKE<-do.call(rbind,FL_LIKE)





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
npars<-c(max(data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[2]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[3]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[4]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt))
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


FL_LIKE<-vector("list",length=4)
for(i in 1:4){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}

THOMPSON_FL_LIKE<-do.call(rbind,FL_LIKE)

FL_LIKE<-rbind(NEW_FL_LIKE,THOMPSON_FL_LIKE)
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


save_as_docx(ft10,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/LL_BYFLEET_TABLE.docx"))
FL_LIKE_PLOT<-FL_LIKE
models=unique(FL_LIKE_PLOT$MODEL)
FL_LIKE_PLOT$SERIES<-"THOMPSON"
FL_LIKE_PLOT[MODEL%in%models[5:8]]$SERIES<-"NEW"

FL_LIKE_PLOT[SERIES=='NEW']$MODEL<-FL_LIKE_PLOT[SERIES=='THOMPSON']$MODEL
FL_LIKE_PLOT2<-ggplot(FL_LIKE_PLOT,aes(x=MODEL,y=as.numeric(ALL),group=SERIES,color=SERIES,linetype=SERIES))+geom_line(size=1.25)+geom_point(shape=18,size=4)+facet_wrap(~Label,scale='free_y')+theme_bw(base_size=16)+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
 print(FL_LIKE_PLOT2)

dataT=read_xlsx("ENSEMBLE_RESULTS.xlsx","THOMPSON_RETROSPECTIVES")
dataN=read_xlsx("ENSEMBLE_RESULTS.xlsx","NEW_RETROSPECTIVES")

THOMSON_RHO<-data.table(dataT)[1:4,]
THOMPSON_RHO2<-melt(THOMPSON_RHO,"Thompson")
THOMPSON_RHO2$SERIES='Thompson'
names(THOMPSON_RHO2)[1]<-"QUANT"
NEW_RHO<-data.table(dataN)[1:4,]
NEW_RHO2<-melt(NEW_RHO,"NEW")
NEW_RHO2$SERIES='New'
names(NEW_RHO2)[1]<-"QUANT"

RHO2<-data.table(rbind(THOMPSON_RHO2,NEW_RHO2))
RHO2$variable<-as.character(RHO2$variable)
RHO2[QUANT=='BR']$QUANT<- 'B Ratio'

RHO2$QUANT<-factor(x=as.character(RHO2$QUANT),levels=c('SSB','R','F','B Ratio'))
names(RHO2)<-c("QUANT","MODEL","RHO","SERIES")

RHO2<-RHO2[order(QUANT,SERIES,MODEL),]
RHO3<-RHO2
RHO2$SERIES<-factor(x=RHO2$SERIES,levels=c('Thompson','New'))

RHO2[MODEL=='Ensemble'&SERIES=='New']$MODEL<- 'New Ensemble'
RHO2[MODEL=='Ensemble'&SERIES=='Thompson']$MODEL<- 'Thompson Ensemble'


RHO2$MODEL<-factor(x=as.character(RHO2$MODEL))



RHO2<-RHO2[order(QUANT,SERIES,MODEL),]

ft11 <- flextable(data.frame(RHO2))
ft11<-colformat_double(ft11,i = c(1:40), j = 2:3, digits = 3)
ft11<-set_header_labels(ft11, QUANT = "Value",MODEL="Model",RHO="Mohn's Rho",SERIES='Series')
ft11 <- theme_vanilla(ft11)
ft11 <- align(ft11, align = "center", part = "header")
ft11 <- align(ft11, align = "right", part = "body")
ft11 <- fontsize(ft11,part="all", size = 10)
ft11 <- border_remove(x = ft11)
ft11<-hline_top(ft11, part="all", border = big_border )
ft11 <- hline_bottom(ft11, part="body", border = big_border )
ft11<-bg(ft11, i =c(1:5,11:15,21:25,31:35), bg="gray80", part = "body")

save_as_docx(ft11,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/RHO_TABLE.docx"))

x<-RHO3[SERIES=='Thompson']$MODEL
RHO3[SERIES=='New']$MODEL<-x

RHO_PLOT<-ggplot(data.table(RHO3),aes(x=MODEL,y=RHO,color=SERIES,group=SERIES,linetype=SERIES))+geom_point(size=4)+geom_line(size=1.25)+theme_bw(base_size=16)+labs(x="Model",y="Mohn's Rho",color="Series",linetype="Series")+facet_wrap(~QUANT,scale="free_y")+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
print(RHO_PLOT)


## MASE
THOM_MASE=data.table(dataT[10:14,1:5])
NEW_MASE=data.table(dataN[10:14,1:5])

MASE<-cbind(THOM_MASE,NEW_MASE[,2:5])
MASE2<-data.frame(t(MASE[1:5,2:9]))
MASE2<-data.frame(Model=rownames(MASE2),MASE2)
rownames(MASE2)<-NULL
names(MASE2)<-c("Model",MASE$Thompson)

ft12 <- flextable(data.frame(MASE2))
ft12<-set_header_labels(ft12, Fishery.Index = "Fishery",Survey.index="Survey",Fishery.Length="Fishery",Survey.Length="Survey",Survey.Age="Survey")
ft12 <- add_header_row(ft12,
   values = c(" ", "Index","Lengths","Age"),
   colwidths=c(1,2,2,1) 
 )
ft12 <- theme_vanilla(ft12)
ft12 <- align(ft12, align = "center", part = "header")
ft12 <- align(ft12, align = "right", part = "body")
ft12 <- fontsize(ft12,part="all", size = 10)
ft12 <- border_remove(x = ft12)
ft12<-hline_top(ft12, part="all", border = big_border )
ft12 <- hline_bottom(ft12, part="body", border = big_border )

save_as_docx(ft12,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/MASE_TABLE.docx"))



setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/GRANT_MODELS")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 19.12","Model 19.12A","Model 21.1", "Model 21.2")
mods1<-SSgetoutput(dirvec=mods)

DM<-vector('list',length=length(mods))
for(i in 1:length(mods)){
x<-mods1[[i]]$Dirichlet_Multinomial_pars
DM[[i]]<-data.frame(MODEL=mods_nam[i],Fleet=c("Fishery Length","Survey Length","Survey Age"),DM=round(x$Value,3),NAVE=0,NeffH=0,NeffDM=0)

x<-mods1[[i]]$Length_Comp_Fit_Summary
DM[[i]]$NAVE[1:2]<-round(x$mean_Nsamp_in)
DM[[i]]$NeffH[1:2]<-round(x$HarMean)
DM[[i]]$NeffDM[1:2]<-round(x$mean_Nsamp_DM)

x<-mods1[[i]]$Age_Comp_Fit_Summary
DM[[i]]$NAVE[3]<-round(x$mean_Nsamp_in)
DM[[i]]$NeffH[3]<-round(x$HarMean)
DM[[i]]$NeffDM[3]<-round(x$mean_Nsamp_DM)
}
THOMPSON_DM<-do.call(rbind,DM)


setwd("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/NEW_MODELS")
mods<-c("Model19_12","Model19_12A","Model_21_1","Model_21_2")
mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
mods1<-SSgetoutput(dirvec=mods)

DM<-vector('list',length=length(mods))

for(i in 1:length(mods)){
x<-mods1[[i]]$Dirichlet_Multinomial_pars
DM[[i]]<-data.frame(MODEL=mods_nam[i],Fleet=c("Fishery Length","Survey Length","Survey Age"),DM=round(x$Value,3),NAVE=0,NeffH=0,NeffDM=0)

x<-mods1[[i]]$Length_Comp_Fit_Summary
DM[[i]]$NAVE[1:2]<-round(x$mean_Nsamp_in)
DM[[i]]$NeffH[1:2]<-round(x$HarMean)
DM[[i]]$NeffDM[1:2]<-round(x$mean_Nsamp_DM)

x<-mods1[[i]]$Age_Comp_Fit_Summary
DM[[i]]$NAVE[3]<-round(x$mean_Nsamp_in)
DM[[i]]$NeffH[3]<-round(x$HarMean)
DM[[i]]$NeffDM[3]<-round(x$mean_Nsamp_DM)
}
NEW_DM<-do.call(rbind,DM)
COMB_DM<-rbind(THOMPSON_DM,NEW_DM)

COMB_DM$RATIO_IANELLI<-round(COMB_DM$NeffH/COMB_DM$NAVE,2)
COMB_DM$RATIO_DM<-round(COMB_DM$NeffDM/COMB_DM$NAVE,2)
COMB_DM<-data.table(COMB_DM)[order(Fleet,MODEL),]

COMB_DM$MODEL<-factor(COMB_DM$MODEL)
COMB_DM$Fleet<-factor(COMB_DM$Fleet,levels=c("Fishery Length","Survey Length","Survey Age"))
COMB_DM<-COMB_DM[order(Fleet,MODEL),]

ft13 <- flextable(data.frame(COMB_DM))
ft13<-set_header_labels(ft13, MODEL = "Model",Fleet="Data",DM="log(theta)",NAVE="Nave",
	                    NeffH="Harmonic mean",NeffDM="Dirichlet",RATIO_DM="Dirichlet",RATIO_IANELLI="McAllister-Ianelli")
ft13 <- add_header_row(ft13,
   values = c(" ","Effective N","Ratios"),
   colwidths=c(4,2,2) 
 )
ft13 <- theme_vanilla(ft13)
ft13 <- align(ft13, align = "center", part = "header")
ft13 <- align(ft13, align = "right", part = "body")
ft13 <- fontsize(ft13,part="all", size = 10)
ft13 <- border_remove(x = ft13)
ft13<-hline_top(ft13, part="all", border = big_border )
ft13 <- hline_bottom(ft13, part="body", border = big_border )
ft13<-bg(ft13, i =c(1:4,9:12,17:20), bg="gray80", part = "body")

save_as_docx(ft13,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/EFFN_TABLE.docx"))

#INDEx
mods1[[1]]$index_variance_tuning_check



dataPART=data.table(read_xlsx("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/ENSEMBLE_RESULTS.xlsx","THOMPSON_ENSEMBLE_PARAMETERS"))
dataPARN=data.table(read_xlsx("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/ENSEMBLE_RESULTS.xlsx","NEW_ENSEMBLE_PARAMETERS"))

dataPART<-data.table(dataPART[,c(1,2,4)])
dataPARN<-data.table(dataPARN[,c(1,2,4)])
names(dataPART)<-c('Label','THOMPSON_MEAN','THOMPSON_SD')
names(dataPARn)<-c('Label','NEW_MEAN','NEW_SD')
dataPAR<-merge(dataPART,dataPARN)

dataPAR[,2]<-round(dataPAR[,2],3)
dataPAR[,3]<-round(as.numeric(dataPAR$THOMPSON_SD),3)
dataPAR[,4]<-round(dataPAR[,4],3)
dataPAR[,5]<-round(as.numeric(dataPAR$NEW_SD),3)
unique(dataPAR$Label)
dataPAR$Label<-factor(dataPAR$Label,levels=unique(dataPARN$Label))
dataPAR<-dataPAR[order(Label),]

ft14 <- flextable(data.frame(dataPAR))
ft14<-set_header_labels(ft14,THOMPSON_MEAN='Est.',THOMPSON_SD='Stdev.',NEW_MEAN='Est.',NEW_SD='Stdev.')
ft14 <- add_header_row(ft14,
   values = c(" ","Thompson Ensemble","New Ensemble"),
   colwidths=c(1,2,2) 
 )
ft14 <- theme_vanilla(ft14)
ft14 <- align(ft14, align = "center", part = "header")
ft14 <- align(ft14, align = "right", part = "body")
ft14 <- fontsize(ft14,part="all", size = 10)
ft14 <- border_remove(x = ft14)
ft14<-hline_top(ft14, part="all", border = big_border )
ft14 <- hline_bottom(ft14, part="body", border = big_border )


save_as_docx(ft14,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/ENS_PARAMS_TABLE.docx"))

## R, SSB, TOTAL_BIOM tables
dataPART=data.table(read_xlsx("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/ENSEMBLE_RESULTS.xlsx","THOMPSON_ENSEMBLE_RESULTS"))
dataPARN=data.table(read_xlsx("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/ENSEMBLE_RESULTS.xlsx","NEW_ENSEMBLE_RESULTS"))
RESULTS_2021<-data.table(read.csv('C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/RESULTS_2021.csv'))
RESULTS_2021<-RESULTS_2021[,c(1,2)]

dataPART<-data.table(dataPART[,c(1,2,4)])
dataPARN<-data.table(dataPARN[,c(1,2,4)])

names(dataPART)<-c('Label','THOMPSON_MEAN','THOMPSON_SD')
names(dataPARN)<-c('Label','NEW_MEAN','NEW_SD')
names(RESULTS_2021)<-c('Label','LYR')
dataPAR<-merge(dataPART,dataPARN,all=T)
dataPAR<-merge(RESULTS_2021,dataPAR,by='Label',all.y=T)
#dataPAR<-dataPAR[!is.na(THOMPSON_MEAN)]

dataPAR[,2]<-round(dataPAR[,2],3)
dataPAR[,3]<-round(dataPAR[,3],3)
dataPAR[,4]<-round(as.numeric(dataPAR$THOMPSON_SD),3)
dataPAR[,5]<-round(dataPAR[,5],3)
dataPAR[,6]<-round(as.numeric(dataPAR$NEW_SD),3)
dataPAR<-dataPAR[Label%in%dataPARN$Label]
dataPAR$Label<-factor(dataPAR$Label,levels=unique(dataPARN$Label))
dataPAR<-dataPAR[order(Label),]
dataPAR$YEAR<-as.numeric(do.call(rbind,strsplit(as.character(dataPAR$Label),"_"))[,2])

SSB <-dataPAR[Label%like%'SSB'&!is.na(YEAR)&YEAR<2024&YEAR>1977]
SSB<-data.table(Year=SSB$YEAR,SSB[,2:6])
SSB[,c(2,3,5)]<-round(SSB[,c(2,3,5)]/2)
SSB[,c(4,6)]<-round(sqrt(SSB[,c(4,6)]^2/2))

SSB$Year<-as.character(SSB$Year)

ft15 <- flextable(data.frame(SSB))
ft15<-set_header_labels(ft15,LYR='Last Year Est.',THOMPSON_MEAN='Est.',THOMPSON_SD='Stdev.',NEW_MEAN='Est.',NEW_SD='Stdev.')
ft15 <- add_header_row(ft15,
   values = c(" ","Thompson Ensemble","New Ensemble"),
   colwidths=c(2,2,2) 
 )
ft15 <- theme_vanilla(ft15)
ft15 <- align(ft15, align = "center", part = "header")
ft15 <- align(ft15, align = "right", part = "body")
ft15 <- fontsize(ft15,part="all", size = 10)
ft15 <- border_remove(x = ft15)
ft15<-hline_top(ft15, part="all", border = big_border )
ft15 <- hline_bottom(ft15, part="body", border = big_border )
ft15<-bg(ft15, j=2 ,bg="gray80", part = "body")


save_as_docx(ft15,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/SSB_TABLE.docx"))


Recr <-dataPAR[Label%like%'Recr'&!is.na(YEAR)&YEAR<2023&YEAR>1977]
Recr<-data.table(Year=Recr$YEAR,Recr[,2:6])
Recr[,c(2,3,5)]<-round(Recr[,c(2,3,5)])
Recr[,c(4,6)]<-round(Recr[,c(4,6)])

Recr$Year<-as.character(Recr$Year)


ft16 <- flextable(data.frame(Recr))
ft16<-set_header_labels(ft16,LYR='Last Year Est.',THOMPSON_MEAN='Est.',THOMPSON_SD='Stdev.',NEW_MEAN='Est.',NEW_SD='Stdev.')
ft16 <- add_header_row(ft16,
   values = c(" ","Thompson Ensemble","New Ensemble"),
   colwidths=c(2,2,2) 
 )
ft16 <- theme_vanilla(ft16)
ft16 <- align(ft16, align = "center", part = "header")
ft16 <- align(ft16, align = "right", part = "body")
ft16 <- fontsize(ft16,part="all", size = 10)
ft16 <- border_remove(x = ft16)
ft16<-hline_top(ft16, part="all", border = big_border )
ft16 <- hline_bottom(ft16, part="body", border = big_border )
ft16<-bg(ft16, j=2 ,bg="gray80", part = "body")

save_as_docx(ft15,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/Recr_TABLE.docx"))





F1 <-dataPAR[Label%like%'F_'&!is.na(YEAR)&YEAR<2023&YEAR>1977]
F1<-data.table(Year=F1$YEAR,F1[,2:6])
F1[,c(2,3,5)]<-round(F1[,c(2,3,5)],3)
F1[,c(4,6)]<-round(F1[,c(4,6)],4)

F1$Year<-as.character(F1$Year)


ft17 <- flextable(data.frame(F1))
ft17<-set_header_labels(ft17,LYR='Last Year Est.',THOMPSON_MEAN='Est.',THOMPSON_SD='Stdev.',NEW_MEAN='Est.',NEW_SD='Stdev.')
ft17 <- add_header_row(ft17,
   values = c(" ","Thompson Ensemble","New Ensemble"),
   colwidths=c(2,2,2) 
 )
ft17 <- theme_vanilla(ft17)
ft17 <- align(ft17, align = "center", part = "header")
ft17 <- align(ft17, align = "right", part = "body")
ft17 <- fontsize(ft17,part="all", size = 10)
ft17 <- border_remove(x = ft17)
ft17<-hline_top(ft17, part="all", border = big_border )
ft17 <- hline_bottom(ft17, part="body", border = big_border )
ft17<-bg(ft17, j=2 ,bg="gray80", part = "body")

save_as_docx(ft17,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/F_TABLE.docx"))



dataNAGET=data.table(read_xlsx("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/ENSEMBLE_RESULTS.xlsx","THOMPSON_ENSEMBLE_NAGE"))
dataNAGEN=data.table(read_xlsx("C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/ENSEMBLE_RESULTS.xlsx","NEW_ENSEMBLE_NAGE"))
names(dataNAGEN)[4]<-'BM'
names(dataNAGET)[4]<-'BM'

dataNAGEN<-dataNAGEN[BM=='B'][,c(1,2,5:25)]
dataNAGET<-dataNAGET[BM=='B'][,c(1,2,5:25)]

dataNAGEN[,3:23]<-round(dataNAGEN[,3:23])
dataNAGET[,3:23]<-round(dataNAGET[,3:23])

dataNAGEN<-dataNAGEN[,2:21]
dataNAGET<-dataNAGET[,2:21]

dataNAGEN$Yr<-as.character(dataNAGEN$Yr)
dataNAGET$Yr<-as.character(dataNAGET$Yr)

names(dataNAGEN)[2:20]<-paste0("Age ",names(dataNAGEN)[2:20])
names(dataNAGET)[2:20]<-paste0("Age ",names(dataNAGET)[2:20])

sect_properties <- prop_section(
  page_size = page_size(orient = "landscape",
                        width = 8.3, height = 11.7),
  type = "continuous",
  page_margins = page_mar()
)


colourer <- col_numeric(
  palette = c("transparent", "gray60"),
  domain = c(min(dataNAGEN[,2:20]), max(dataNAGEN[,2:20])))

ft18 <- flextable(data.frame(dataNAGEN))
ft18 <- theme_vanilla(ft18)
ft18 <- align(ft18, align = "center", part = "header")
ft18 <- align(ft18, align = "right", part = "body")
ft18 <- fontsize(ft18,part="body", size = 8)
ft18 <- fontsize(ft18,part="header", size = 10)
ft18 <- border_remove(x = ft18)
ft18<-bg(ft18, bg = colourer, j = ~ . -Yr, part = "body")
#ft18<-theme_zebra(ft18,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ft18<-hline_top(ft18, part="all", border = big_border )
ft18 <- hline_bottom(ft18, part="body", border = big_border )
ft18<-set_table_properties(ft18, layout = "autofit")


colourer <- col_numeric(
  palette = c("transparent", "gray60"),
  domain = c(min(dataNAGET[,2:20]), max(dataNAGET[,2:20])))

ft19 <- flextable(data.frame(dataNAGET))
ft19 <- theme_vanilla(ft19)
ft19 <- align(ft19, align = "center", part = "header")
ft19 <- align(ft19, align = "right", part = "body")
ft19 <- fontsize(ft19,part="body", size = 8)
ft19 <- fontsize(ft19,part="header", size = 10)
ft19 <- border_remove(x = ft19)
ft19<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
#ft19<-theme_zebra(ft19,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ft19<-hline_top(ft19, part="all", border = big_border )
ft19 <- hline_bottom(ft19, part="body", border = big_border )
ft19<-set_table_properties(ft19, layout = "autofit")
#ft18<-bg(ft18, j=2 ,bg="gray80", part = "body")
save_as_docx(ft18,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/NEW_NAGE_TABLE.docx"),pr_section = sect_properties)
save_as_docx(ft19,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/THOMPSON_NAGE_TABLE.docx"),pr_section = sect_properties)


## summary table

PROFILE_2022<-data.table(read.csv('C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/TABLES/NEW_Two_year.csv'))
PROFILE_2022T<-data.table(read.csv('C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT/NOVEMBER_MODELS/TABLES/THOMPSON_Two_year.csv'))


NER<-NEW_ENSEMBLE_RESULTS[,c(1,2)]
TER<-THOMPSON_ENSEMBLE_RESULTS[,c(1,2)]

SSB_UNFISHED<-PROFILE_2022$SB100[1]
SSB_40<-SSB_UNFISHED*0.4
SSB_35<-SSB_UNFISHED*0.35
F40<-NER[LABEL=='annF_MSY']$ENSEMBLE_MEAN
F35<-NER[LABEL=='annF_Btgt']$ENSEMBLE_MEAN
SSB_2022<-PROFILE_2022$SSB[1]
SSB2022rel<-SSB_2022/SSB_UNFISHED
PRB_2<-0.00
Fabc_max_2022<-PROFILE_2022$F40[1]
Fofl_max_2022<-PROFILE_2022$F35[1]
abc_2022<-PROFILE_2022$C_ABC[1]
ofl_2022<-PROFILE_2022$C_OFL[1]

SSB_2023<-PROFILE_2022$SSB[2]
SSB2023rel<-SSB_2023/SSB_UNFISHED
Fabc_max_2023<-PROFILE_2022$F40[2]
Fofl_max_2023<-PROFILE_2022$F35[2]
abc_2023<-PROFILE_2022$C_ABC[2]
ofl_2023<-PROFILE_2022$C_OFL[2]






TSSB_UNFISHED<-PROFILE_2022T$SB100[1]
TSSB_40<-SSB_UNFISHED*0.4
TSSB_35<-SSB_UNFISHED*0.35
TF40<-TER[LABEL=='annF_MSY']$ENSEMBLE_MEAN
TF35<-TER[LABEL=='annF_Btgt']$ENSEMBLE_MEAN
TSSB_2022<-PROFILE_2022T$SSB[1]
TSSB2022rel<-SSB_2022/SSB_UNFISHED
TPRB_2<-0.00
TFabc_max_2022<-PROFILE_2022T$F40[1]
TFofl_max_2022<-PROFILE_2022T$F35[1]
Tabc_2022<-PROFILE_2022T$C_ABC[1]
Tofl_2022<-PROFILE_2022T$C_OFL[1]

TSSB_2023<-PROFILE_2022T$SSB[2]
TSSB2023rel<-SSB_2023/SSB_UNFISHED
TFabc_max_2023<-PROFILE_2022T$F40[2]
TFofl_max_2023<-PROFILE_2022T$F35[2]
Tabc_2023<-PROFILE_2022T$C_ABC[2]
Tofl_2023<-PROFILE_2022T$C_OFL[2]


sumtab<-data.table(Year=c(rep("",5),rep(2022,8),rep(2023,8)),Quantity=c("B100%","B40%","B35%","F40%","F35%",
	"Female spawning biomass","Relative spawning biomass","Pr(B/B100%<0.2)","maxFABC","maxABC","Catch",
	"FOLF","OFL","Female spawning biomass","Relative spawning biomass","Pr(B/B100%<0.2)","maxFABC","maxABC","Catch",
	"FOLF","OFL"),Thompson_Ensemble=c(
round(TSSB_UNFISHED),
round(TSSB_40),
round(TSSB_35),
round(TF40,3),
round(TF35,3),
round(TSSB_2022),
round(TSSB2022rel,3),
TPRB_2,
round(TFabc_max_2022,3),
round(Tabc_2022),
round(Tabc_2022),
round(TFofl_max_2022,3),
round(Tofl_2022),
round(TSSB_2023),
round(TSSB2023rel,3),
TPRB_2,
round(TFabc_max_2023,3),
round(Tabc_2023),
round(Tabc_2023),
round(TFofl_max_2023,3),
round(Tofl_2023)),NEW_Ensemble=c(
round(SSB_UNFISHED),
round(SSB_40),
round(SSB_35),
round(F40,3),
round(F35,3),
round(SSB_2022),
round(SSB2022rel,3),
PRB_2,
round(Fabc_max_2022,3),
round(abc_2022),
round(abc_2022),
round(Fofl_max_2022,3),
round(ofl_2022),
round(SSB_2023),
round(SSB2023rel,3),
PRB_2,
round(Fabc_max_2023,3),
round(abc_2023),
round(abc_2023),
round(Fofl_max_2023,3),
round(ofl_2023)))

ft20 <- flextable(data.frame(sumtab))
ft20<- theme_vanilla(ft20)
ft20 <- align(ft20, align = "center", part = "header")
ft20 <- align(ft20, align = "right", part = "body")
ft20 <- fontsize(ft20,part="body", size = 10)
ft20 <- fontsize(ft20,part="header", size = 10)
ft20 <- border_remove(x = ft20)
#ftS<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
#ft20<-theme_zebra(ftS,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ft20<-hline_top(ft20, part="all", border = big_border )
ft20 <- hline_bottom(ft20, part="body", border = big_border )
ft20<-set_table_properties(ft20, layout = "autofit")



## Load profiles .Rdata files C:\WORKING_FOLDER\2022 Stock Assessments\EBS Pcod\NOVEMBER_PROJECTION_FILES_2022
libs <- c("flextable","readxl","magrittr","scales","tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

working_dir <- "C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT"

set_flextable_defaults(
  font.size = 10, font.family = "Times New Roman",
  table.layout = "fixed",
  border.color = "gray",
  padding.top = 1, padding.bottom = 1,
  padding.left = 1, padding.right = 1)


small_border = flextable::fp_border_default(color="gray", width = 1)
big_border = flextable::fp_border_default(color="black", width = 1.5)

SSB$Yr<-as.character(SSB$Yr)
SSB[,2:8]<-round(SSB[,2:8])

ftS <- flextable(data.frame(SSB))
ftS<- theme_vanilla(ftS)
ftS <- align(ftS, align = "center", part = "header")
ftS <- align(ftS, align = "right", part = "body")
ftS <- fontsize(ftS,part="body", size = 10)
ftS <- fontsize(ftS,part="header", size = 10)
ftS <- border_remove(x = ftS)
#ftS<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
ftS<-theme_zebra(ftS,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ftS<-hline_top(ftS, part="all", border = big_border )
ftS <- hline_bottom(ftS, part="body", border = big_border )
ftS<-set_table_properties(ftS, layout = "autofit")

F$Yr<-as.character(F$Yr)
F[,2:8]<-round(F[,2:8],3)


ftF <- flextable(data.frame(F))
ftF<- theme_vanilla(ftF)
ftF <- align(ftF, align = "center", part = "header")
ftF <- align(ftF, align = "right", part = "body")
ftF <- fontsize(ftF,part="body", size = 10)
ftF <- fontsize(ftF,part="header", size = 10)
ftF <- border_remove(x = ftF)
#ftS<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
ftF<-theme_zebra(ftF,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ftF<-hline_top(ftF, part="all", border = big_border )
ftF <- hline_bottom(ftF, part="body", border = big_border )
ftF<-set_table_properties(ftF, layout = "autofit")

Catch$Yr<-as.character(Catch$Yr)
Catch[,2:8]<-round(Catch[,2:8])


ftC <- flextable(data.frame(Catch))
ftC<- theme_vanilla(ftC)
ftC <- align(ftC, align = "center", part = "header")
ftC <- align(ftC, align = "right", part = "body")
ftC <- fontsize(ftC,part="body", size = 10)
ftC <- fontsize(ftC,part="header", size = 10)
ftC <- border_remove(x = ftC)
#ftS<-bg(ft19, bg = colourer, j = ~ . -Yr, part = "body")
ftC<-theme_zebra(ftC,odd_header = "transparent", odd_body = "transparent",  even_header = "gray95", even_body = "gray95")
ftC<-hline_top(ftC, part="all", border = big_border )
ftC <- hline_bottom(ftC, part="body", border = big_border )
ftC<-set_table_properties(ftC, layout = "autofit")


save_as_docx(ftS,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/THOMPSON_PROF_SSB.docx"))
save_as_docx(ftF,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/THOMPSON_PROF_F.docx"))
save_as_docx(ftC,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/THOMPSON_PROF_CATCH.docx"))










print(RHO_PLOT)
print(FL_LIKE_PLOT2)































## Create single document of tables.
doc=read_docx(path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/CATCH_TABLE1.docx"))

fp_t <- fp_text(font.size = 12, bold = TRUE)
an_fpar <- fpar( run_linebreak(),"let's add a line break", run_linebreak())

doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft2)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft3)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft4)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft5)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft6)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft7)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft8)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft9)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft10)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft11)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft12)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft13)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft14)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft15)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft16)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft17)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft18)
doc <- body_add(doc, an_fpar)
doc <- body_add_flextable(doc, value = ft19)
doc <- body_add(doc, an_fpar)

print(doc, target = fileout)