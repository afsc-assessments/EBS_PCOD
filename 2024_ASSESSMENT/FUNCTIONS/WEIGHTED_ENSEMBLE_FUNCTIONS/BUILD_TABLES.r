## Getting catch data

libs=c("ss3diags", "r4ss","ggplot2","data.table","scales", "magrittr", "readxl", "gt", "officer", "flextable", 
 "pivottabler", "misty","vcdExtra","gnm","vcd","grid","swo","reshape2", 
 "fishmethods", "rgdal", "sp", "lubridate", "r4ss", "devtools", "usethis",
 "sizeMat", "data.table", "nlstools", "FSA", "mgcv", "nlme", "RODBC", "forcats",
 "stringr", "dplyr", "purrr", "readr", "tidyr", "tibble", "ggplot2",
"tidyverse", "stats", "graphics", "grDevices", "utils", "datasets", "methods") 


#libs <- c("flextable","readxl","magrittr","scales","tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)


##<<<<<<< HEAD
afsc_user  = "sbarb"   ## enter afsc username
afsc_pwd   = "RedFsh!!2345"    ## enter afsc password
akfin_user = "sbarbeaux"  ## enter AKFIN username
akfin_pwd  = "$tockmen12"   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)

# this assumes that the FUNCTIONS subdirectory is in the working directory
working_dir <- "C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT"


# the most recent year of data to be used
new_SS_dat_year <- 2023
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

 


OLD_CATCH<-data.table(read.csv("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/TABLES/OLD_CATCH_GEAR.csv"))
CATCH_T<-data.table(data.table(CATCH)[,list(TONS=sum(round(TONS,0))),by=c('YEAR','GEAR1')])
CATCHT2<-data.table(data.table(CATCH)[,list(TONS=sum(round(TONS,0)),GEAR1='TOTAL'),by=c('YEAR')])
CATCH1<-rbind(OLD_CATCH,CATCH_T,CATCHT2)
 okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
CATCH1$GEAR1<-factor(CATCH1$GEAR1,levels=c("TOTAL","TRAWL","LONGLINE","POT",'OTHER')) 
CATCHP<-ggplot(CATCH1,aes(x=YEAR,y=TONS,color=GEAR1,group=GEAR1))+geom_line(size=1)+theme_bw(base_size=16)+labs(x='Year',y='Total catch (t)',color='Gear type')+
scale_color_manual(values=okabe)+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
print(CATCHP)




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

small_border = fp_border(color="gray", width = 1)
big_border = fp_border(color="black", width = 1.5)

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
Nsamp2$FISHERY_INPUT<-round((Nsamp$FISHERY/mean(Nsamp$FISHERY))*mean(CS$HAULS))
Nsamp3<-data.table(Year=Nsamp2$YEAR,Survey=Nsamp2$HAULS,Fishery=Nsamp2$FISHERY,Fishery_I=Nsamp2$FISHERY_INPUT)
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
d_ages=sql_run(akfin, d_ages) %>% 
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

# ## Annual weigtht length parameter offsets
# ## Environmental data for length weight 
#   len_weight<-get_lengthweight(species=fsh_sp_str,area=fsh_sp_area,K=7,Alpha_series=2,Beta_series=3)

#  len1<-len_weight[SERIES==2]

# len2<-len_weight[SERIES==3]
# len=data.table(YEAR=as.character(len_weight[SERIES==2]$YEAR),alpha=formatC(len_weight[SERIES==2]$VALUE, format = "e", digits = 3),space=" ",beta=formatC(len_weight[SERIES==3]$VALUE, format = "e", digits = 3))
 
  
# ft7 <- flextable(data.frame(len))
# ft7 <- set_header_labels(ft7, YEAR = "Year",space=" ")#,beta=expression(beta),alpha=expression(alpha))

#  ft7 <- theme_vanilla(ft7)
#  ft7 <- align(ft7, align = "center", part = "header")
#  ft7 <- fontsize(ft7,part="all", size = 10)

#  ft7 <- border_remove(x = ft7)
# ft7<-hline_top(ft7, part="all", border = big_border )
# ft7 <- hline_bottom(ft7, part="body", border = big_border )

# save_as_docx(ft7,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/LEN_WEIGHT_PARAM_TABLE.docx"))

## MODEL results

source("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/FUNCTIONS/R/ENSEMBLE_FUNCTIONS.r")

WT=c(0.2842,0.3158,0.2316,0.1684)  ## ensemble weights


setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS")
mods<-c("Model_22.1","Model_22.2","Model_22.3","Model_22.4")
mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)

x=SStableComparisons(modsS)
names(x)=c("Label",mods_nam)

q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[4]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[4]]$derived_quants)[Label=='SSB_unfished']$Value)
F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[4]]$derived_quants)[Label=='annF_MSY']$Value)
catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2024']$Value)
catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[4]]$derived_quants)[Label=='ForeCatch_2025']$Value)
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
x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2024","ForeCatch_2025"),x1)
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

save_as_docx(ft8,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/ENSEMBLE_SUMMARY_TABLE2.docx"))

FL_LIKE<-vector("list",length=4)
for(i in 1:4){
	FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}

NEW_FL_LIKE<-do.call(rbind,FL_LIKE)


## 2023 models

setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")

mods<-c("Model_23.1.0.a","Model_23.1.0.d","Model_23.2")
mods_nam=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)

x=SStableComparisons(modsS)
 names(x)=c("Label",mods_nam)

 q1=c(exp(data.table(mods1[[1]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[2]]$parameters)[Label=='LnQ_base_Survey(2)']$Value),exp(data.table(mods1[[3]]$parameters)[Label=='LnQ_base_Survey(2)']$Value))
 ssb=c(data.table(mods1[[1]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[2]]$derived_quants)[Label=='SSB_unfished']$Value,data.table(mods1[[3]]$derived_quants)[Label=='SSB_unfished']$Value)
 F40=c(data.table(mods1[[1]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[2]]$derived_quants)[Label=='annF_MSY']$Value,data.table(mods1[[3]]$derived_quants)[Label=='annF_MSY']$Value)
 catch=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2024']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2024']$Value)
 catch2=c(data.table(mods1[[1]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[2]]$derived_quants)[Label=='ForeCatch_2025']$Value,data.table(mods1[[3]]$derived_quants)[Label=='ForeCatch_2025']$Value)
 npars<-c(max(data.table(mods1[[1]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[2]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt),max(data.table(mods1[[3]]$parameters)[!is.na(Active_Cnt)]$Active_Cnt))

 npars<-data.table(Label="Number_parameters",x1=npars[1],x2=npars[2],x3=npars[3])
 names(npars)[2:4]<-mods_nam
 npars[2:4]<-round(npars[,2:4])
 x1<-matrix(ncol=3,nrow=5)
 x1[1,]<-q1
 x1[2,]<-ssb/1000000
 x1[3,]<-F40
 x1[4,]<-catch
 x1[5,]<-catch2
 x2<-data.table(Label=c("Q","SSB_unfished","ann_F_MSY","ForeCatch_2024","ForeCatch_2025"),x1)
 names(x2)<-names(x)
 M23_SUMMARY<-rbind(npars,x,x2)

 M23_SUMMARY[2:20,2:4]<-round(M23_SUMMARY[2:20,2:4],3)
 write.csv(M23_SUMMARY,"M23_SUMMARY_TABLE.csv",row.names=F)


## using results from Model 23.1.0.d as base.

M23_ENSEMBLE_RESULTS<-data.table(mods1[[2]]$derived_quants[1:3])
M23_ENSEMBLE_RESULTS<-data.table(LABEL=M23_ENSEMBLE_RESULTS$Label,ENSEMBLE_MEAN=M23_ENSEMBLE_RESULTS$Value,MEAN=M23_ENSEMBLE_RESULTS$Value,SD=M23_ENSEMBLE_RESULTS$StdDev)


M23_ENSEMBLE_PARAMS<-data.table(mods1[[2]]$parameters[,c(2,3,11)])
M23_ENSEMBLE_PARAMS<-data.table(LABEL=M23_ENSEMBLE_PARAMS$Label,ENSEMBLE_MEAN=M23_ENSEMBLE_PARAMS$Value,MEAN=M23_ENSEMBLE_PARAMS$Value,SD=M23_ENSEMBLE_PARAMS$Parm_StDev)

M23_ENS_RES<-rbind(M23_ENSEMBLE_RESULTS[,c(1,2)],M23_ENSEMBLE_PARAMS[,c(1,2)])


#23_ENS_RES<-rbind(M23_ENSEMBLE_RESULTS,M23_ENSEMBLE_PARAMS)

names(M23_ENS_RES)<-c("Label","2023 Models")

Q<-M23_ENSEMBLE_PARAMS[LABEL%like%'Q']
Q$LABEL<-'Q'
M23_ANNFMSY<-M23_ENSEMBLE_RESULTS[LABEL%in%'annF_MSY']
M23_ANNFMSY$LABEL<-'ann_F_MSY'
M23_ssbVirg<-M23_ENSEMBLE_RESULTS[LABEL%in%'SSB_unfished']
M23_ssbVirg$LABEL<-'SSB_Virgin_thousand_mt'
M23_ssbVirg[,2:3]<-M23_ssbVirg[,2:3]/1000


M23_extra_RES<-rbind(Q[,1:2],M23_ANNFMSY[,1:2],M23_ssbVirg[,1:2])
names(M23_extra_RES)<-c("Label","2023 Models")
M23_ENS_RES<-rbind(M23_ENS_RES[,1:2],M23_extra_RES)


M23_SUMMARY2<-data.table(ID=1:nrow(M23_SUMMARY),M23_SUMMARY)

M23_TABLE<-merge(M23_SUMMARY2,M23_ENS_RES,all=T,sort=FALSE)
M23_TABLE[Label=='SR_BH_steep'][,6]<-1.0

M23_TABLE<-M23_TABLE[,-2]

M23_TABLE[2:18,2:5]<-round(M23_TABLE[2:18,2:5],3)
M23_TABLE[19:20,2:5]<-round(M23_TABLE[19:20,2:5])


ft8 <- flextable(data.frame(M23_TABLE))
ft8<-set_header_labels(ft8, NEW_ENSEMBLE = "Ensemble", Model.23.1="Model 23.1",
    Model.23.2="Model 23.2")
ft8 <- theme_vanilla(ft8)
ft8 <- align(ft8, align = "center", part = "header")
ft8 <- fontsize(ft8,part="all", size = 10)

 ft8 <- border_remove(x = ft8)
ft8<-hline_top(ft8, part="all", border = big_border )
ft8 <- hline_bottom(ft8, part="body", border = big_border )

save_as_docx(ft8,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/2023_SUMMARY_TABLE.docx"))

FL_LIKE<-vector("list",length=length(mods1))
for(i in 1:length(mods1)){
    FL_LIKE[[i]]<-data.table(mods1[[i]]$likelihoods_by_fleet)[!is.na(ALL)]
    FL_LIKE[[i]]$MODEL<-mods_nam[i]
}

M23_FL_LIKE<-do.call(rbind,FL_LIKE)






FL_LIKE<-rbind(NEW_FL_LIKE,M23_FL_LIKE)
FL_LIKE<-FL_LIKE[order(Label,MODEL),]
FL_LIKE<-data.table(FL_LIKE)
FL_LIKE[Label%in%c('Age_like','Length_like','Surv_like') ][,2:4]<-round(FL_LIKE[Label%in%c('Age_like','Length_like','Surv_like') ][,2:4],3)


format_scientific <- function(x) {
  formatC(x, format = "e", digits = 3)
}
format_scientific1 <- function(x) {
  formatC(x, format = "e", digits = 1)
}

FL_LIKE$ALL[8:21]<-format_scientific(FL_LIKE$ALL[8:21])
#FL_LIKE$Survey[9:24]<-format_scientific1(FL_LIKE$Survey[9:24])
FL_LIKE$Fishery[8:21]<-format_scientific(FL_LIKE$Fishery[8:21])


ft10 <- flextable(data.frame(FL_LIKE))
ft10<-colformat_double(ft10,i = c(1:7,22:35), j = 2:4, digits = 3)
ft10<-colformat_double(ft10,i = c(9:24), j = 4, digits = 0)
ft10<-set_header_labels(ft10, ALL = "All",MODEL="Model")
ft10 <- theme_vanilla(ft10)
ft10 <- align(ft10, align = "center", part = "header")
ft10 <- align(ft10, align = "right", part = "body")
ft10 <- fontsize(ft10,part="all", size = 10)
ft10 <- border_remove(x = ft10)
ft10<-hline_top(ft10, part="all", border = big_border )
ft10 <- hline_bottom(ft10, part="body", border = big_border )

ft10<-bg(ft10, i =c(1:4,8:11,15:18,22:25,29:32), bg="gray80", part = "body")


save_as_docx(ft10,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/LL_BYFLEET_TABLE.docx"))

FL_LIKE_PLOT<-FL_LIKE
models=unique(FL_LIKE_PLOT$MODEL)
FL_LIKE_PLOT$SERIES<-"M2023"
FL_LIKE_PLOT[MODEL%in%models[1:4]]$SERIES<-"Ensemble"

#FL_LIKE_PLOT[SERIES=='Ensemble']$MODEL<-FL_LIKE_PLOT[SERIES=='M2023']$MODEL


MODELNAM<-data.table(MODEL=unique(FL_LIKE_PLOT$MODEL),MODEL2=unique(FL_LIKE_PLOT$MODEL))
FL_LIKE_PLOTx<-merge(FL_LIKE_PLOT,MODELNAM,by='MODEL')

FL_LIKE_PLOTx$SERIES<-factor(FL_LIKE_PLOTx$SERIES,levels=c("M2023","Ensemble"))


FL_LIKE_PLOT2<-ggplot(FL_LIKE_PLOTx,aes(x=MODEL2,y=as.numeric(ALL),group=SERIES,color=SERIES,linetype=SERIES))+
geom_line(size=1.25)+geom_point(shape=18,size=4)+facet_wrap(~Label,scale='free_y')+
theme_bw(base_size=16)+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
labs(x="Models",y='-log likelihood',color='Series',linetype='Series')+scale_linetype_manual(values=c(2,1))
 print(FL_LIKE_PLOT2)

setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS")
dataM=readxl::read_excel("Appendix_2.5_Data_and_results.xlsx","M2023_RETROSPECTIVES")
dataN=readxl::read_excel("Appendix_2.5_Data_and_results.xlsx","ENSEMBLE_RETROSPECTIVES")

E_RHO<-data.table(dataN)[1:4,]
E_RHO2<-melt(E_RHO,"NEW")
E_RHO2$SERIES='Ensemble'
names(E_RHO2)[1]<-"QUANT"
M_RHO<-data.table(dataM)[1:4,]
M_RHO2<-melt(M_RHO,"NEW")
M_RHO2$SERIES='M2023'
names(M_RHO2)[1]<-"QUANT"

RHO2<-data.table(rbind(E_RHO2,M_RHO2))
RHO2$variable<-as.character(RHO2$variable)
RHO2[QUANT=='BR']$QUANT<- 'B Ratio'

RHO2<-RHO2[!is.na(value)]

RHO2$QUANT<-factor(x=as.character(RHO2$QUANT),levels=c('SSB','R','F','B Ratio'))
names(RHO2)<-c("QUANT","MODEL","RHO","SERIES")

RHO2<-RHO2[order(QUANT,SERIES,MODEL),]
RHO3<-RHO2
RHO2$SERIES<-factor(x=RHO2$SERIES,levels=c('Ensemble','M2023'))

RHO2[MODEL=='Ensemble'&SERIES=='Ensemble']$MODEL<- 'Ensemble'
#RHO2[MODEL=='Ensemble'&SERIES=='Thompson']$MODEL<- 'Thompson Ensemble'


RHO2$MODEL<-factor(x=as.character(RHO2$MODEL))



RHO2<-RHO2[order(QUANT,SERIES,MODEL),]

ft11 <- flextable(data.frame(RHO2))
ft11<-colformat_double(ft11,i = c(1:32), j = 2:3, digits = 3)
ft11<-set_header_labels(ft11, QUANT = "Value",MODEL="Model",RHO="Mohn's Rho",SERIES='Series')
ft11 <- theme_vanilla(ft11)
ft11 <- align(ft11, align = "center", part = "header")
ft11 <- align(ft11, align = "right", part = "body")
ft11 <- fontsize(ft11,part="all", size = 10)
ft11 <- border_remove(x = ft11)
ft11<-hline_top(ft11, part="all", border = big_border )
ft11 <- hline_bottom(ft11, part="body", border = big_border )
ft11<-bg(ft11, i =c(1:5,9:13,17:21,25:29), bg="gray80", part = "body")

save_as_docx(ft11,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/RHO_TABLE.docx"))

#x<-RHO3[SERIES=='M2023']$MODEL
#RHO3[SERIES=='Ensemble']$MODEL<-x

MODELNAM<-data.table(MODEL=unique(RHO3$MODEL),MODEL2=c('Ensemble','Model 22.1','Model 22.2','Model 22.3','Model 22.4','Model 23.1.0.a','Model 23.1.0.d','Model 23.2'))
RHO3<-merge(data.table(RHO3),MODELNAM,by='MODEL')
RHO3$SERIES<-factor(RHO3$SERIES,levels=c("Ensemble","M2023"))
RHO3$MODEL2<-factor(RHO3$MODEL2,levels=c('Model 23.1.0.a','Model 23.1.0.a','Model 23.2','Model 22.1','Model 22.2','Model 22.3','Model 22.4','Ensemble'))

RHO3$RHO<-as.numeric(RHO3$RHO)

RHO_PLOT<-ggplot(data.table(RHO3),aes(x=MODEL2,y=RHO,color=SERIES,group=SERIES,linetype=SERIES))+geom_point(size=4)+geom_line(size=1.25)+
theme_bw(base_size=16)+labs(x="Model",y="Mohn's Rho",color="Series",linetype="Series")+facet_wrap(~QUANT,scale="free_y")+
theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+scale_linetype_manual(values=c(2,1))
print(RHO_PLOT)


## MASE
M_MASE=data.table(dataM[10:14,1:4])
E_MASE=data.table(dataN[10:14,1:5])

MASE<-cbind(M_MASE,E_MASE[,2:5])
MASE2<-data.frame(t(MASE[1:5,2:7]))
MASE2<-data.frame(Model=rownames(MASE2),MASE2)
rownames(MASE2)<-NULL
names(MASE2)<-c("Model",MASE$NEW)

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



setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")
mods<-c("Model_23.1.0.a","Model_23.1.0.d","Model_23.2")
mods_nam=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2")
mods1<-SSgetoutput(dirvec=mods)

DM<-vector('list',length=length(mods))
for(i in 1:length(mods)){
#x<-mods1[[i]]$Dirichlet_Multinomial_pars
DM[[i]]<-data.frame(MODEL=mods_nam[i],Fleet=c("Fishery Length","Survey Length","Survey Age"),DM=NA,NAVE=0,NeffH=0,NeffDM=0)

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


setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS")
mods<-c("Model_22.1","Model_22.2","Model_22.3","Model_22.4")
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



dataPART=data.table(read_excel("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/Appendix_2.5_Data_and_results.xlsx","M23.1.0.d_PARAMETERS"))
dataPARN=data.table(read_excel("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/Appendix_2.5_Data_and_results.xlsx","ENSEMBLE_PARAMETERS"))

dataPART<-data.table(dataPART[,c(1,2,3)])
dataPARN<-data.table(dataPARN[,c(1,2,4)])
names(dataPART)<-c('Label','Model23.1.0.d_MEAN','Model23.1.0.d_SD')
names(dataPARN)<-c('Label','ENS_MEAN','ENS_SD')
dataPAR<-merge(dataPART,dataPARN, all=T)

dataPAR[,2]<-round(dataPAR[,2],3)
dataPAR[,3]<-round(as.numeric(dataPAR$Model23.1.0.d_SD),3)
dataPAR[,4]<-round(dataPAR[,4],3)
dataPAR[,5]<-round(as.numeric(dataPAR$ENS_SD),3)
unique(dataPAR$Label)
dataPAR$Label<-factor(dataPAR$Label,levels=unique(dataPARN$Label))
dataPAR<-dataPAR[order(Label),]

ft14 <- flextable(data.frame(dataPAR))
ft14<-set_header_labels(ft14,M23.1.0.d_MEAN='Est.',M23.1.0.d_SD='Stdev.',ENS_MEAN='Est.',ENS_SD='Stdev.')
ft14 <- add_header_row(ft14,
   values = c(" ","Model 23.1.0.d","Ensemble"),
   colwidths=c(1,3,3) 
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
dataPART=data.table(readxl::read_excel("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/Appendix_2.5_Data_and_results.xlsx","M23.1.0.d_RESULTS"))
dataPARN=data.table(readxl::read_excel("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/Appendix_2.5_Data_and_results.xlsx","ENSEMBLE_RESULTS"))
RESULTS_2022<-data.table(read.csv('C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/RESULTS_2022.csv'))
RESULTS_2022<-RESULTS_2022[,c(1,2)]

dataPART<-data.table(dataPART[,c(1,2,3)])
dataPARN<-data.table(dataPARN[,c(1,2,4)])

names(dataPART)<-c('Label','MODEL_23.1.0.d_MEAN','MODEL_23.1.0.d_SD')
names(dataPARN)<-c('Label','ENSEMBLE_MEAN','ENSEMBLE_SD')
names(RESULTS_2022)<-c('Label','LYR')
dataPAR<-merge(dataPART,dataPARN,all=T)
dataPAR<-merge(RESULTS_2022,dataPAR,by='Label',all.y=T)
#dataPAR<-dataPAR[!is.na(THOMPSON_MEAN)]

dataPAR[,2]<-round(dataPAR[,2],3)
dataPAR[,3]<-round(dataPAR[,3],3)
dataPAR[,4]<-round(as.numeric(dataPAR$MODEL_23.1.0.d_SD),3)
dataPAR[,5]<-round(dataPAR[,5],3)
dataPAR[,6]<-round(as.numeric(dataPAR$ENSEMBLE_SD),3)
dataPAR<-dataPAR[Label%in%dataPARN$Label]
dataPAR$Label<-factor(dataPAR$Label,levels=unique(dataPARN$Label))
dataPAR<-dataPAR[order(Label),]
dataPAR$YEAR<-as.numeric(do.call(rbind,strsplit(as.character(dataPAR$Label),"_"))[,2])

SSB <-dataPAR[Label%like%'SSB'&!is.na(YEAR)&YEAR<2025&YEAR>1977]
SSB<-data.table(Year=SSB$YEAR,SSB[,2:6])
SSB[,c(2,3,5)]<-round(SSB[,c(2,3,5)]/2)
SSB[,c(4,6)]<-round(sqrt(SSB[,c(4,6)]^2/2))

SSB$Year<-as.character(SSB$Year)

ft15 <- flextable(data.frame(SSB))
ft15<-set_header_labels(ft15,LYR='Last Year Est.',MODEL23.1.0.d_MEAN='Est.',MODEL23.1.0.d_SD='Stdev.',ENSEMBLE_MEAN='Est.',ENSEMBLE_SD='Stdev.')
ft15 <- add_header_row(ft15,
   values = c(" ","MODEL23.1.0.d","Ensemble"),
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


Recr <-dataPAR[Label%like%'Recr'&!is.na(YEAR)&YEAR<2025&YEAR>1977]
Recr<-data.table(Year=Recr$YEAR,Recr[,2:6])
Recr[,c(2,3,5)]<-round(Recr[,c(2,3,5)])
Recr[,c(4,6)]<-round(Recr[,c(4,6)])

Recr$Year<-as.character(Recr$Year)


ft16 <- flextable(data.frame(Recr))
ft16<-set_header_labels(ft16,LYR='Last Year Est.',MODEL23.1.0.d_MEAN='Est.',MODEL23.1.0.d_SD='Stdev.',ENSEMBLE_MEAN='Est.',ENSEMBLE_SD='Stdev.')
ft16 <- add_header_row(ft16,
   values = c(" ","MODEL23.1.0.d","Ensemble"),
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

save_as_docx(ft16,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/Recr_TABLE.docx"))





F1 <-dataPAR[Label%like%'F_'&!is.na(YEAR)&YEAR<2025&YEAR>1977]
F1<-data.table(Year=F1$YEAR,F1[,2:6])
F1[,c(2,3,5)]<-round(F1[,c(2,3,5)],3)
F1[,c(4,6)]<-round(F1[,c(4,6)],4)

F1$Year<-as.character(F1$Year)


ft17 <- flextable(data.frame(F1))
ft17<-set_header_labels(ft17,LYR='Last Year Est.',MODEL23.1.0.d_MEAN='Est.',MODEL23.1.0.d_SD='Stdev.',ENSEMBLE_MEAN='Est.',ENSEMBLE_SD='Stdev.')
ft17 <- add_header_row(ft17,
   values = c(" ","MODEL23.1.0.d","Ensemble"),
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



dataNAGET=data.table(read_excel("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/Appendix_2.5_Data_and_results.xlsx","M23.1.0.d_NAGE"))
dataNAGEN=data.table(read_excel("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/ENSEMBLE_RESULTS/Appendix_2.5_Data_and_results.xlsx","ENSEMBLE_NAGE"))
names(dataNAGEN)[4]<-'BM'
names(dataNAGET)[4]<-'BM'

dataNAGEN<-dataNAGEN[BM=='B'][,c(1,2,5:25)]
dataNAGET<-dataNAGET[BM=='B'][,c(1,2,5:25)]

dataNAGEN[,3:23]<-round(dataNAGEN[,3:23])
dataNAGET[,3:23]<-round(dataNAGET[,3:23])

dataNAGEN<-dataNAGEN[,2:23]
dataNAGET<-dataNAGET[,2:23]

dataNAGEN$Yr<-as.character(dataNAGEN$Yr)
dataNAGET$Yr<-as.character(dataNAGET$Yr)

names(dataNAGEN)[2:22]<-paste0("Age ",names(dataNAGEN)[2:22])
names(dataNAGET)[2:22]<-paste0("Age ",names(dataNAGET)[2:22])

sect_properties <- prop_section(
  page_size = page_size(orient = "landscape",
                        width = 8.3, height = 11.7),
  type = "continuous",
  page_margins = page_mar()
)


colourer <- col_numeric(
  palette = c("transparent", "gray60"),
  domain = c(min(dataNAGEN[,2:22]), max(dataNAGEN[,2:22])))

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
  domain = c(min(dataNAGET[,2:22]), max(dataNAGET[,2:22])))

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
save_as_docx(ft18,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/ENSEMBLE_NAGE_TABLE.docx"),pr_section = sect_properties)
save_as_docx(ft19,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/MODEL23.1.0.d_NAGE_TABLE.docx"),pr_section = sect_properties)


## summary table
## need all profiles in single file.

 xm<-c("profiles_M22.1", "profiles_M22.2", "profiles_M22.3", "profiles_M22.4")
 WT=c(0.2842,0.3158,0.2316,0.1684)
 x<-vector('list',length=4)

for(i in 1:4){
 x[[i]]<-data.frame(get(xm[i])$Two_year[,2:10]*WT[i])
 }
 x<-Reduce('+', x)
 y=get(xm[1])$Two_year
 y[,2:10]<-x
write.csv(y,'ENSEMBLE_Two_year.csv')
write.csv(profiles_M23.1.0.d$Two_year,'Model23.1.0.d_Two_year.csv')

PROFILE_2023<-data.table(read.csv('C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/TABLES/ENSEMBLE_Two_year.csv'))
PROFILE_2023T<-data.table(read.csv('C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/TABLES/MODEL23.1.0.d_Two_year.csv'))


NER<-NEW_ENSEMBLE_RESULTS[,c(1,2)]
TER<-M23_ENSEMBLE_RESULTS[,c(1,2)]

SSB_UNFISHED<-PROFILE_2023$SB100[1]
SSB_40<-SSB_UNFISHED*0.4
SSB_35<-SSB_UNFISHED*0.35
F40<-NER[LABEL=='annF_MSY']$ENSEMBLE_MEAN
F35<-NER[LABEL=='annF_Btgt']$ENSEMBLE_MEAN
SSB_2024<-PROFILE_2023$SSB[1]
SSB2024rel<-SSB_2024/SSB_UNFISHED
PRB_2<-0.00
Fabc_max_2024<-PROFILE_2023$F40[1]
Fofl_max_2024<-PROFILE_2023$F35[1]
abc_2024<-PROFILE_2023$C_ABC[1]
ofl_2024<-PROFILE_2023$C_OFL[1]

SSB_2025<-PROFILE_2023$SSB[2]
SSB2025rel<-SSB_2025/SSB_UNFISHED
Fabc_max_2025<-PROFILE_2023$F40[2]
Fofl_max_2025<-PROFILE_2023$F35[2]
abc_2025<-PROFILE_2023$C_ABC[2]
ofl_2025<-PROFILE_2023$C_OFL[2]


TSSB_UNFISHED<-PROFILE_2023T$SB100[1]
TSSB_40<-TSSB_UNFISHED*0.4
TSSB_35<-TSSB_UNFISHED*0.35
TF40<-TER[LABEL=='annF_MSY']$ENSEMBLE_MEAN
TF35<-TER[LABEL=='annF_Btgt']$ENSEMBLE_MEAN
TSSB_2024<-PROFILE_2023T$SSB[1]
TSSB2024rel<-TSSB_2024/TSSB_UNFISHED
TPRB_2<-0.00
TFabc_max_2024<-PROFILE_2023T$F40[1]
TFofl_max_2024<-PROFILE_2023T$F35[1]
Tabc_2024<-PROFILE_2023T$C_ABC[1]
Tofl_2024<-PROFILE_2023T$C_OFL[1]

TSSB_2025<-PROFILE_2023T$SSB[2]
TSSB2025rel<-SSB_2025/SSB_UNFISHED
TFabc_max_2025<-PROFILE_2023T$F40[2]
TFofl_max_2025<-PROFILE_2023T$F35[2]
Tabc_2025<-PROFILE_2023T$C_ABC[2]
Tofl_2025<-PROFILE_2023T$C_OFL[2]


sumtab<-data.table(Year=c(rep("",5),rep(2024,8),rep(2025,8)),Quantity=c("B100%","B40%","B35%","F40%","F35%",
	"Female spawning biomass","Relative spawning biomass","Pr(B/B100%<0.2)","maxFABC","maxABC","Catch",
	"FOLF","OFL","Female spawning biomass","Relative spawning biomass","Pr(B/B100%<0.2)","maxFABC","maxABC","Catch",
	"FOLF","OFL"),
MODEL23.1.0.d=c(
round(TSSB_UNFISHED),
round(TSSB_40),
round(TSSB_35),
round(TF40,3),
round(TF35,3),
round(TSSB_2024),
round(TSSB2024rel,3),
TPRB_2,
round(TFabc_max_2024,3),
round(Tabc_2024),
round(Tabc_2024),
round(TFofl_max_2024,3),
round(Tofl_2024),
round(TSSB_2025),
round(TSSB2025rel,3),
TPRB_2,
round(TFabc_max_2025,3),
round(Tabc_2025),
round(Tabc_2025),
round(TFofl_max_2025,3),
round(Tofl_2025)),
Ensemble=c(
round(SSB_UNFISHED),
round(SSB_40),
round(SSB_35),
round(F40,3),
round(F35,3),
round(SSB_2024),
round(SSB2024rel,3),
PRB_2,
round(Fabc_max_2024,3),
round(abc_2024),
round(abc_2024),
round(Fofl_max_2024,3),
round(ofl_2024),
round(SSB_2025),
round(SSB2025rel,3),
PRB_2,
round(Fabc_max_2025,3),
round(abc_2025),
round(abc_2025),
round(Fofl_max_2025,3),
round(ofl_2025)))


format_normal <- function(x) {
  formatC(x, format = "d", digits = 1,big.mark = ",")
}

sumtab$MODEL23.1.0.d[c(1:3,6,10,11,13,14,18,19,21)]<-format_normal(sumtab$MODEL23.1.0.d[c(1:3,6,10,11,13,14,18,19,21)])
sumtab$Ensemble[c(1:3,6,10,11,13,14,18,19,21)]<-format_normal(sumtab$Ensemble[c(1:3,6,10,11,13,14,18,19,21)])

ft20 <- flextable(data.frame(sumtab))
ft20<-set_header_labels(ft20, MODEL23.1.0.d="M23.1.0.d",Ensemble="Ensemble")
ft20 <- add_header_row(ft20,
   values = c(" ","MODEL23.1.0.d","ENSEMBLE"),
   colwidths=c(2,1,1) 
 )
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

save_as_docx(ft20,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/SUMMARY_TABLE.docx"))


## Load profiles .Rdata files C:\WORKING_FOLDER\2023 Stock Assessments\EBS Pcod_work_folder\NOVEMBER_PROJECTION_FILES_2023
libs <- c("flextable","readxl","magrittr","scales","tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)

working_dir <- "C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT"

set_flextable_defaults(
  font.size = 10, font.family = "Times New Roman",
  table.layout = "fixed",
  border.color = "gray",
  padding.top = 1, padding.bottom = 1,
  padding.left = 1, padding.right = 1)


small_border = flextable::fp_border_default(color="gray", width = 1)
big_border = flextable::fp_border_default(color="black", width = 1.5)

SSB$Yr<-as.character(SSB$Yr)
SSB[,2:7]<-round(SSB[,2:7])

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

## total biomass table...

setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS")
mods<-c("Model_22.1","Model_22.2","Model_22.3","Model_22.4")
mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
modsN<-SSgetoutput(dirvec=mods)

setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2023_MODELS")
mods<-c("Model_23.1.0.a","Model_23.1.0.d","Model_23.2")
mods_nam=c("Model 23.1.0.a","Model 23.1.0.d","Model 23.2")
modsT<-SSgetoutput(dirvec=mods)

 TOT_BIOM<-data.table(YEAR=mods1[[1]]$timeseries$Yr,MODEL23.1.0.d=modsT[[2]]$timeseries$Bio_all,
 	Ensemble=modsN[[1]]$timeseries$Bio_all*WT[1]+modsN[[2]]$timeseries$Bio_all*WT[2]+modsN[[3]]$timeseries$Bio_all*WT[3]+modsN[[4]]$timeseries$Bio_all*WT[4])





## RUNS results table


nam2.1<-c("M23.1.0.a","M23.1.0.d","M23.2")
nam2.2<-c("M22.1","M22.2","M22.3","M22.4")

runsBTT<-vector('list',length=3)
runsBTN<-vector('list',length=4)
for(i in 1:4){
  runsBTN[[i]]<-SSplotRunstest(modsN[[i]])
  runsBTN[[i]]$Model=nam2.2[i]
}

for(i in 1:3){
  runsBTT[[i]]<-SSplotRunstest(modsT[[i]])
  runsBTT[[i]]$Model=nam2.1[i]
  }



runsBT<-rbind(do.call(rbind,runsBTT),do.call(rbind,runsBTN))

runsBTT<-vector('list',length=3)
runsBTN<-vector('list',length=4)
runsAGET<-vector('list',length=3)
runsAGEN<-vector('list',length=4)
runsLENT<-vector('list',length=3)
runsLENN<-vector('list',length=4)
for(i in 1:4){
  runsBTN[[i]]<-SSplotRunstest(modsN[[i]])
  runsBTN[[i]]$Model=nam2.2[i]
  runsLENN[[i]]<-SSplotRunstest(modsN[[i]],subplots='len')
  runsLENN[[i]]$Model=nam2.2[i]
  runsAGEN[[i]]<-SSplotRunstest(modsN[[i]],subplots='age')
  runsAGEN[[i]]$Model=nam2.2[i]
}

for(i in 1:3){
  runsBTT[[i]]<-SSplotRunstest(modsT[[i]])
  runsBTT[[i]]$Model=nam2.1[i]
  runsLENT[[i]]<-SSplotRunstest(modsT[[i]],subplots='len')
  runsLENT[[i]]$Model=nam2.1[i]
  runsAGET[[i]]<-SSplotRunstest(modsT[[i]],subplots='age')
  runsAGET[[i]]$Model=nam2.1[i]
}



runsBT<-rbind(do.call(rbind,runsBTT),do.call(rbind,runsBTN),do.call(rbind,runsLENT),do.call(rbind,runsLENN),do.call(rbind,runsAGET),do.call(rbind,runsAGEN))
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


save_as_docx(ft21,path=paste0(working_dir,"/NOVEMBER_MODELS/TABLES/RUNS_TESTS_TABLE.docx"))


AGE_FIT<-vector('list',length=4)
for(i in 1:4){
 AGE_FIT[[i]]=data.table(YEAR=modsN[[i]]$age_comp_fit_table$Yr,Real=modsN[[i]]$age_comp_fit_table$All_obs_mean,Pred=modsN[[i]]$age_comp_fit_table$All_exp_mean, MODEL=nam2.2[i])
}

AGE_FIT2<-vector('list',length=3)
for(i in 1:3){
 AGE_FIT2[[i]]=data.table(YEAR=modsT[[i]]$age_comp_fit_table$Yr,Real=modsT[[i]]$age_comp_fit_table$All_obs_mean, Pred=modsT[[i]]$age_comp_fit_table$All_exp_mean, MODEL=nam2.1[i])
}



AGE_FIT2<-data.table(do.call(rbind,AGE_FIT2))
AGE_FIT<-data.table(do.call(rbind,AGE_FIT))

AGE_FIT<-rbind(AGE_FIT,AGE_FIT2)


#MODELNAM<-data.table(MODEL=c(1:6),MODEL2=c('Model 19.12 (22.1)','Model 19.12A (22.2)','Model 21.1 (22.3)','Model 21.2 (22.4)'))

#AGE_FIT<-data.table(merge(AGE_FIT,MODELNAM))
#AGE_FIT<-AGE_FIT[,-'MODEL']
AGE_FIT<-data.table(melt(AGE_FIT,c('YEAR','MODEL')))




dage<-ggplot(AGE_FIT[MODEL!='M23.2'],aes(x=YEAR,y=value))+
geom_point(data=AGE_FIT[variable=="Real"&MODEL!='M23.2'],size=2,color="black")+
geom_line(data=AGE_FIT[variable!="Real"&MODEL!='M23.2'],aes(,color=MODEL),linetype=1,size=1)+
theme_bw(base_size=16)+labs(x="Year",y="Mean age",color='Model')+
scale_linetype_manual(values=c(2,1))+
facet_wrap(~MODEL)
 




LEN_FIT<-vector('list',length=4)
for(i in 1:4){
 LEN_FIT[[i]]=data.table(YEAR=modsN[[i]]$len_comp_fit_table$Yr,Real=modsN[[i]]$len_comp_fit_table$All_obs_mean, Pred=modsN[[i]]$len_comp_fit_table$All_exp_mean, Fleet=modsN[[i]]$len_comp_fit_table$Fleet_Name,MODEL=nam2.2[i])
}

LEN_FIT2<-vector('list',length=3)
for(i in 1:3){
 LEN_FIT2[[i]]=data.table(YEAR=modsT[[i]]$len_comp_fit_table$Yr,Real=modsT[[i]]$len_comp_fit_table$All_obs_mean, Pred=modsT[[i]]$len_comp_fit_table$All_exp_mean, Fleet=modsN[[i]]$len_comp_fit_table$Fleet_Name,MODEL=nam2.1[i])
}

LEN_FIT<-data.table(do.call(rbind,LEN_FIT))
LEN_FIT2<-data.table(do.call(rbind,LEN_FIT2))


LEN_FIT<-rbind(LEN_FIT,LEN_FIT2)

#MODELNAM<-data.table(MODEL=c(1:4),MODEL2=c('Model 19.12 (22.1)','Model 19.12A (22.2)','Model 21.1 (22.3)','Model 21.2 (22.4)'))

#LEN_FIT<-data.table(merge(LEN_FIT,MODELNAM))
#LEN_FIT<-LEN_FIT[,-'MODEL']
LEN_FIT<-data.table(melt(LEN_FIT,c('YEAR','MODEL','Fleet')))


dlen<-ggplot(LEN_FIT,aes(x=YEAR,y=value))+
geom_point(data=LEN_FIT[variable=="Real"],size=2,color="black")+
geom_line(data=LEN_FIT[variable!="Real"],aes(color=MODEL, linetype=Fleet),size=1)+
theme_bw(base_size=16)+labs(x="Year",y="Mean length (cm)",color='Model',linetype='Fleet')+
scale_linetype_manual(values=c(2,1))+
facet_wrap(MODEL~Fleet,scale='free_y',ncol=2)
 


SUR_FIT<-vector('list',length=4)
for(i in 1:4){
  CPUEN=data.table(modsN[[i]]$cpue)[Fleet_name=='Survey']
 SUR_FIT[[i]]=data.table(YEAR=CPUEN$Yr,Real=CPUEN$Obs, Pred=CPUEN$Exp, MODEL=nam2.2[i])
}

SUR_FIT2<-vector('list',length=3)
for(i in 1:3){
  CPUET=data.table(modsT[[i]]$cpue)[Fleet_name=='Survey']
  SUR_FIT2[[i]]=data.table(YEAR=CPUET$Yr,Real=CPUET$Obs, Pred=CPUET$Exp, MODEL=nam2.1[i])
}



SUR_FIT<-data.table(do.call(rbind,SUR_FIT))
SUR_FIT2<-data.table(do.call(rbind,SUR_FIT2))
SUR_FIT<-rbind(SUR_FIT,SUR_FIT2)

SUR_FIT<-data.table(melt(SUR_FIT,c('YEAR','MODEL')))


dsur<-ggplot(SUR_FIT,aes(x=YEAR,y=value))+
geom_point(data=SUR_FIT[variable=="Real"],size=2,color="black")+
geom_line(data=SUR_FIT[variable!="Real"],aes(color=MODEL),size=1)+
theme_bw(base_size=16)+labs(x="Year",y="Population number",color='Model')+
scale_linetype_manual(values=c(2,1))+
facet_wrap(~MODEL,scale='free_y',ncol=2)


CPUE_FIT<-vector('list',length=4)
for(i in 1:3){
  CPUET=data.table(modsT[[i]]$cpue)[Fleet_name=='Fishery']
 }
 for(i in 1:4){
  CPUEN=data.table(modsN[[i]]$cpue)[Fleet_name=='Fishery']
  }

  CPUE_FIT[[i]]=data.table(YEAR=CPUET$Yr,Real=CPUET$Obs, M23=CPUET$Exp,ENSEMBLE=CPUEN$Exp, MODEL=i)
}

CPUE_FIT<-data.table(do.call(rbind,CPUE_FIT))
CPUE_FIT<-CPUE_FIT[!is.na(YEAR)]

MODELNAM<-data.table(MODEL=c(1:4),MODEL2=c('Model 22.1','Model 22.2','Model 22.3','Model 22.4'))

CPUE_FIT<-data.table(merge(CPUE_FIT,MODELNAM,all.x=T))
CPUE_FIT<-CPUE_FIT[,-'MODEL']
CPUE_FIT<-data.table(melt(CPUE_FIT,c('YEAR','MODEL2')))

dcpue<-ggplot(CPUE_FIT,aes(x=YEAR,y=value))+
geom_point(data=CPUE_FIT[variable=="Real"],size=2,color="black")+
geom_line(data=CPUE_FIT[variable!="Real"],aes(color=variable, linetype=variable),size=1)+
theme_bw(base_size=16)+labs(x="Year",y="CPUE index",color='Series',linetype='Series')+
scale_linetype_manual(values=c(2,1))+
facet_wrap(~MODEL2,scale='free_y',ncol=2)
 




## longline RPN

setwd(paste(working_dir,"\\Functions",sep=""))
 llrpn= readLines('sql/AFSC_LL_RPN.sql')
 llrpn = sql_filter(sql_precode = "IN", x = srv_sp_str, sql_code = llrpn, flag = '-- insert species')
 llrpn = sql_filter(sql_precode = "IN", x = LL_sp_region, sql_code = llrpn, flag = '-- insert area')


LLRPN=sql_run(akfin, llrpn) %>% 
         dplyr::rename_all(toupper)

LLRPN$CI<-1.96*sqrt(LLRPN$RPN_VAR)


LLRPN_GRAPH<-ggplot(data.table(LLRPN), aes(x=YEAR, y=RPN)) + 
    geom_errorbar(aes(ymin=RPN-CI, ymax=RPN+CI), colour="black", width=.25) +
    geom_line() +
    geom_point(size=3)+theme_bw(base_size=16)


## 2024 spawning biomass graph
 #   graph_ensemble<- function(models=mods1,label=" ",WT=c(0.2842,0.3158,0.2316,0.1684),PLOT=T){
  
label="SSB_unfished"
models<-modsN
  SSB_U<-ensemble(models=models,lab='SSB_unfished')

  dis<-vector("list",length=5)
  for ( i in 1:4){
    dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==label]$Value,data.table(models[[i]]$derived_quants)[Label==label]$StdDev)
    dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
     }


    dis<-do.call(rbind,dis)
    disE<-data.table(MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
    disE$VALUE<-disE$VALUE
    

models<-modsT

  SSB_U<-ensemble(models=models,lab='SSB_unfished')
  #SSB_OFL<-ensemble(models=modsN,lab='OFLCatch_2024')

  dis<-vector("list",length=5)
  for ( i in 1:3){
    dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==label]$Value,data.table(models[[i]]$derived_quants)[Label==label]$StdDev)
    dis[[i]]<-data.table(MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
     }

    dis<-do.call(rbind,dis)
    dis$VALUE<-dis$VALUE
    discomb=disE
    dis<-rbind(dis,discomb)
   
length(dis[MODEL=='ENSEMBLE'&VALUE>=1.0]$VALUE)/ length(dis[MODEL=='ENSEMBLE']$VALUE)


    values=data.table(LABEL=label,MEAN=mean(dis[MODEL=="ENSEMBLE"]$VALUE),SD=sd(dis[MODEL=="ENSEMBLE"]$VALUE))
    okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")

    d<-ggplot(dis,aes(VALUE,color=MODEL,fill=MODEL,group=MODEL))+geom_density(alpha=0.2,size=1)+theme_bw(base_size=16)+
    scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)
    d<-d+labs(title="Unfished female spawning biomass (t)",y="Density",x=bquote(B['100%']))
    d<-d+scale_linetype_manual(values=c(1,2,3,4,5))
    print(d)
  

#VIOLIN_PLOT_ENSEMBLE<-function(models=mods1,label="SSB",FY=2022,WT=WT){

mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
models<-modsN
label="SSB"

SSB_U<-ensemble(models=modsN,lab='SSB_unfished')


  LABEL=data.table(models[[1]]$derived_quants)[Label%like%label]$Label
  YEAR=as.numeric(stringr::str_sub(LABEL,start=-4))
    LABEL<-data.table(YEAR=YEAR,LABEL=LABEL)
    LABEL<-LABEL[!is.na(YEAR)]

    values<-vector('list',length=nrow(LABEL))
  
  for(j in 1:nrow(LABEL)){
    dis<-vector('list',length=5)
      for ( i in 1:4){
      dis1=rnorm(100000*WT[i],data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$Value,data.table(models[[i]]$derived_quants)[Label==LABEL$LABEL[j]]$StdDev)/SSB_U
        dis[[i]]<-data.table(YEAR=LABEL$YEAR[j],MODEL=mods_nam[i],VALUE=dis1,LABEL=label)
    }

        dis<-do.call(rbind,dis)
        discomb<-data.table(YEAR=LABEL$YEAR[j],MODEL="ENSEMBLE",VALUE=dis$VALUE,LABEL=label)
        dis<-rbind(dis,discomb)
        
    
    if(j==1){dis2=dis}else{dis2<-rbind(dis2,dis)}
  }
  
    MEANS<-dis2[,list(MEANS=mean(VALUE)),by=c("MODEL","YEAR")]

    okabe <- c("black","#E69F00", "#56B4E9", "#009E73", "#F0E442")
        
    p <- ggplot(data=dis2[MODEL=='ENSEMBLE'&YEAR<=FY], aes(x=YEAR, y=VALUE, group=YEAR)) + geom_violin(fill="gray50") +theme_bw(base_size=16)
    p<- p+geom_line(data=MEANS[YEAR<=FY],aes(x=YEAR,y=MEANS,color=MODEL,group=MODEL),size=1)+scale_fill_manual(values=okabe)+scale_color_manual(values=okabe)+
    scale_linetype_manual(values=c(1,2,3,4,5))
    p<-p+labs(x='YEAR',y='SSB/SSB unfished')
    print(p)








pdf("other_plots1.pdf",width=12,height=6)
print(CATCHP)
print(RHO_PLOT)
print(FL_LIKE_PLOT2)
dev.off()


pdf("other_plots2.pdf",width=10,height=10)
print(dpue)
print(dsur)
print(dage)
print(dlen)
print(LLRPN_GRAPH)
dev.off()


SB100=Two_year$SB100[1]
F40_1=F40
F35_1=F35
cABC=C_40
cOFL=C35

F40<-Two_year$F40
 F35<-Two_year$F35
 C_40<-Two_year$C_ABC
 C35<-Two_year$C_OFL
 F40_1=F40
 F35_1=F35
 cABC=C_40
 cOFL=C35




    
F40_2=summ[[1]][Yr==CYR+2]$F
F35_2=summ8[Yr==CYR+2]$F
catchABC_2=Pcatch[[1]][Yr==CYR+2]$Catch
catchOFL_2=Pcatch8[Yr==CYR+2]$Catch
SSB_1<-summ[[1]][Yr==CYR+1]$SSB
SSB_2<-summ[[1]][Yr==CYR+2]$SSB



## after loading new profiles Rdata file.

x=melt(SSB,'Yr')
sb<-data.table(Yr=c(2023,2036,2023,2036),variable=c('B40','B40','B35','B35'),value=c(SB40,SB40,SB35,SB35))
x<-rbind(x,sb)

colo=c("#d73027","#f46d43","#fdae61","#fee090","#abd9e9","#74add1","#4575b4","black",'gray40')
#colo <- c("#b35806","#f1a340","#fee0b6","#f7f7f7","#d8daeb","#998ec3","#542788","black","gray40")
d<-ggplot(x,aes(x=Yr,y=value,color=variable, linetype=variable,size=variable,group=variable))+geom_line()+theme_bw(base_size=16)
d<-d+scale_linetype_manual(values=c(rep(1,7),2,3))+scale_color_manual(values=colo)+scale_size_manual(values=c(rep(0.75,7),1,1))
d<-d+labs(x='Year',y='Spawning biomass (t)',color='Scenario',linetype="Scenario",size="Scenario",title="M23.1.0.d projections") #+scale_y_continuous(labels = comma)
ENS_PROJ<-d
print(ENS_PROJ)


filled.contour.TAB <- function (x = seq(0, 1, length.out = nrow(z)), y = seq(0, 1,
    length.out = ncol(z)), z, xlim = range(x, finite = TRUE),
    ylim = range(y, finite = TRUE), zlim = range(z, finite = TRUE),
    levels = pretty(zlim, nlevels), nlevels = 20, color.palette = cm.colors,
    col = color.palette(length(levels) - 1), plot.title, plot.axes,
    key.title, key.axes, asp = NA, xaxs = "i", yaxs = "i", las = 1,
    axes = TRUE, frame.plot = axes, ...)
{
    if (missing(z)) {
        if (!missing(x)) {
            if (is.list(x)) {
                z <- x$z
                y <- x$y
                x <- x$x
            }
            else {
                z <- x
                x <- seq.int(0, 1, length.out = nrow(z))
            }
        }
        else stop("no 'z' matrix specified")
    }
    else if (is.list(x)) {
        y <- x$y
        x <- x$x
    }
    if (any(diff(x) <= 0) || any(diff(y) <= 0))
        stop("increasing 'x' and 'y' values expected")
     plot.new()
    plot.window(xlim, ylim, "", xaxs = xaxs, yaxs = yaxs, asp = asp)
    if (!is.matrix(z) || nrow(z) <= 1 || ncol(z) <= 1)
        stop("no proper 'z' matrix specified")
    if (!is.double(z))
        storage.mode(z) <- "double"
    .Internal(filledcontour(as.double(x), as.double(y), z, as.double(levels),
        col = col))
    invisible()
}

#######################################################################
#Plot of B/Bmsy against F/Fmsy for the most recent year
#Trevor A. Branch  10 September 2009  tbranch@gmail.com
#######################################################################
plot.phase.plane <- function(SSB0,Fabc,Fmsy,BoverBmsy, FoverFmsy,xlim=c(0,6),ylim=c(0,1.5),header,bw.mult=1,jitter.fac=0,eyr=2016) {
   #plot(x=BoverBmsy,y=FoverFmsy,xlim=xlim,ylim=ylim,las=1,
   #       yaxs="i",xaxs="i",xlab="",ylab="")
   require(KernSmooth)
   crosshair.data.uncen <- cbind(BoverBmsy,FoverFmsy)
   #APRIL 22 version: References in Scott 1992 and Bowman and Azzalini 1997
   d<-2 # the bandwidth dimension
   bmsy.bw<-sqrt(var(crosshair.data.uncen[,1]))*(4/((d+2)*length(crosshair.data.uncen[,1])))^(1/(d+4))
   umsy.bw<-sqrt(var(crosshair.data.uncen[,2]))*(4/((d+2)*length(crosshair.data.uncen[,2])))^(1/(d+4))
   # please note the range restrictions at 2.01 to include the points that line up at the boundaries
   kernel.dens <- bkde2D(crosshair.data.uncen[,c(1,2)], bandwidth=c(bmsy.bw*bw.mult,umsy.bw*bw.mult), range.x=list(xlim,ylim))

   # generate color palette
   paletteable.egg<-colorRampPalette(c("#BFEFFF","white","white", "yellow","#FFC125"))
   

   par(oma=c(0.5,0.5,0.5, 0.5))
   filled.contour.TAB(kernel.dens$x1, kernel.dens$x2, kernel.dens$fhat, nlevels=15, color.palette =paletteable.egg,
               xlab="", ylab="", xlim=xlim, ylim=ylim, cex.lab=1.3)
   par(new=T)

   plot(x=jitter(BoverBmsy,jitter.fac),y=jitter(FoverFmsy,jitter.fac),type="l",xlim=xlim,ylim=ylim,las=1,
          yaxs="i",xaxs="i",xlab="",ylab="",col="gray50",pch=20)

  yr<-c((eyr-length(BoverBmsy)+1):eyr)-1900
  yr[yr>=100]<-yr[yr>=100]-100

  for(i in 1:length(BoverBmsy)){
    text(BoverBmsy[i],FoverFmsy[i],paste(yr[i]),cex=0.85)
    }

    k=Fabc/Fmsy*(((SSB0*0.05)/(SSB0*0.40))-0.05)/(1-0.05)
    k2<-0.05
    k3<-(0.05*SSB0)/(SSB0*0.40)
    ##points(c(k3,k3),c(0,10),type="l",lty=3)
    points(c((0.4/0.35),xlim[2]),c(Fabc/Fmsy,Fabc/Fmsy),type="l",lwd=2)
    points(c((0.4/0.35),xlim[2]),c(1,1),type="l",lwd=2,col="red")
    #points(c(k2,1.0),c(0,Fabc/Fmsy),type="l",lwd=2)
    points(c(k3,(0.4/0.35)),c(k,Fabc/Fmsy),type="l",lwd=2)
    points(c(k3,k3),c(0,k),type="l",lwd=2)
    points(c(0,(0.4/0.35)),c(0,1),type="l",lwd=2,col="red")

    text(xlim[2]-1,ylim[2]-0.1,"OFL Definition",pos=4)
    text(xlim[2]-1,ylim[2]-0.2,"ABC Control Rule",pos=4)
    text (xlim[2]-1,ylim[2]-0.3,"B20%",pos=4)

    points(c(xlim[2]-1.2,xlim[2]-1),c(ylim[2]-0.1,ylim[2]-0.1),lwd=2,type="l",col="red")
    points(c(xlim[2]-1.2,xlim[2]-1),c(ylim[2]-0.2,ylim[2]-0.2),lwd=2,type="l")
    points(c(xlim[2]-1.2,xlim[2]-1),c(ylim[2]-0.3,ylim[2]-0.3),type="l",lwd=2,col="brown")

   mtext(side=1,line=3.2,text=expression(B/B[MSY]),cex=1.3)
   mtext(side=2,line=3,expression(F/F[MSY]),cex=1.3)
   mtext(side=3,line=0.5,header,cex=1.3)
   abline(h=1,lty=2)
   abline(v=1,lty=2)
   abline(v=(0.2/0.35),col="brown",lwd=2)
}





test1_SSB<-M23_ENSEMBLE_RESULTS[LABEL%like%'SSB']
test1_SSB$YEAR<-as.numeric(do.call(rbind,strsplit(test1_SSB$LABEL,"_"))[,2])
 test1_SSB<-test1_SSB[!is.na(YEAR)]

test1_SSB<-test1_SSB[YEAR%in%1977:2025]

test1_F<-M23_ENSEMBLE_RESULTS[LABEL%like%'F_']
test1_F$YEAR<-as.numeric(do.call(rbind,strsplit(test1_F$LABEL,"_"))[,2])
test1_F<-test1_F[!is.na(YEAR)]
test1_F<-test1_F[YEAR%in%1977:2025]


BoverBmsy=test1_SSB$ENSEMBLE_MEAN/(SB100*0.35)
FoverFmsy=test1_F$ENSEMBLE_MEAN/F35
 
plot.phase.plane(data=test1_SSB,SSB0=SB100,Fabc=F40,Fmsy=F35,BoverBmsy=BoverBmsy,FoverFmsy=FoverFmsy,xlim=c(0,2),ylim=c(0,1.6),header="EBS Pcod Ensemble",bw.mult=1,jitter.fac=0)





test1_SSB<-M23_ENSEMBLE_RESULTS[LABEL%like%'SSB']
test1_SSB$YEAR<-as.numeric(do.call(rbind,strsplit(test1_SSB$LABEL,"_"))[,2])
 test1_SSB<-test1_SSB[!is.na(YEAR)]

test1_SSB<-test1_SSB[YEAR%in%1977:2025]

test1_F<-M23_ENSEMBLE_RESULTS[LABEL%like%'F_']
test1_F$YEAR<-as.numeric(do.call(rbind,strsplit(test1_F$LABEL,"_"))[,2])
test1_F<-test1_F[!is.na(YEAR)]
test1_F<-test1_F[YEAR%in%1977:2025]


BoverBmsy=test1_SSB$ENSEMBLE_MEAN/(SB100*0.35)
FoverFmsy=test1_F$ENSEMBLE_MEAN/F35
 
plot.phase.plane(data=test1_SSB,SSB0=SB100,Fabc=F40,Fmsy=F35,BoverBmsy=BoverBmsy,FoverFmsy=FoverFmsy,xlim=c(0,2),ylim=c(0,1.6),header="EBS Pcod Model 23.1.0.d",bw.mult=1,jitter.fac=0)














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
doc <- body_add_flextable(doc, value = ft20)
doc <- body_add(doc, an_fpar)

print(doc, target = fileout)

set<-c("profiles_M22.1","profiles_M22.2","profiles_M22.3","profiles_M22.4","profiles_M23.1.0.a","profiles_M23.1.0.d","profiles_M23.2")
mod_nam=c("Model 22.1","Model 22.2","Model 22.3","Model 22.4","Model 23.1.0.a","Model 23.1.0.d", "Model23.2")

pdf("CATCH_BIOMASS.pdf",width=12,height=6)
for(i in 1:length(set)){
scen1<-data.table(get(set[i])[[1]])[model=='scenario_1']
bm2=ggplot(scen1[Yr<2026],aes(x=SSB,y=Catch,color=Yr))+geom_point(size=3)+geom_path()+theme_bw(base_size=16)
bm2<-bm2+scico::scale_color_scico(palette = "vik")
bm2<-bm2+labs(x="Spawning Biomass (t)",y="Catch (t)",color="Year",title=mod_nam[i])
bm2<-bm2+geom_vline(xintercept=scen1$SSB_unfished[1]*0.35,color='red',linetype=2,linewidth=1.2)
bm2=bm2+geom_vline(xintercept=scen1$SSB_unfished[1]*0.40,color='orange',linetype=3,linewidth=1.2)
bm2=bm2+geom_vline(xintercept=scen1$SSB_unfished[1]*0.20,color='black',linetype=1,linewidth=1)
bm2=bm2+geom_vline(xintercept=scen1$SSB_unfished[1],color='gray70',linetype=4,linewidth=1)

bm2<-bm2+geom_point(data=scen1[Yr%in%c(2024,2025)],size=3,shape=17,color="black")
bm2<-bm2+geom_text(data=scen1[Yr%in%c(1977,2009,2025)],label=scen1[Yr%in%c(1977,2009,2025)]$Yr,size=4,hjust=1.1,vjust=1.1)+xlim(0,700000)+ylim(0,250000)
bm2<-bm2+guides(color="none")


bm2.1=ggplot(scen1[Yr<2026],aes(y=Catch/TOT,x=Yr,color=Yr))+geom_point(size=3)+geom_path()+theme_bw(base_size=16)
bm2.1<-bm2.1+scico::scale_color_scico(palette = "vik")
bm2.1<-bm2.1+labs(y="Catch (t) / Total biomass (t)",x="Year",color="Year",title=mod_nam[i])
bm2.1<-bm2.1+geom_point(data=scen1[Yr%in%c(2024,2025)],size=3,shape=17,color="black")+ylim(0,0.35)
#bm2.1<-bm2.1+geom_text(data=scen1[Yr%in%c(1977,2009,2025)],label=scen1[Yr%in%c(1977,2009,2025)]$Yr,size=4,hjust=1.1,vjust=-1.1)
bm=ggarrange(bm2,bm2.1, ncol = 2, nrow = 1)
print(bm)
}
dev.off() 
 




setwd("C:/WORKING_FOLDER/EBS_PCOD_work_folder/2023_ASSESSMENT/NOVEMBER_MODELS/2022_MODELS")
mods<-c("Model_22.1","Model_22.2","Model_22.3","Model_22.4")
mods_nam=c("Model 22.1","Model 22.2","Model 22.3", "Model 22.4")
mods1<-SSgetoutput(dirvec=mods)
modsS<-SSsummarize(mods1)

WT=c(0.2842,0.3158,0.2316,0.1684)
SSB_ENS<-data.table(VIOLIN_PLOT_ENSEMBLE(models=mods1,label="SSB",FY=2025,WT=WT)$MEANS)
SSB_unfished<-ensemble(models=mods1,lab='SSB_unfished',weights=WT)
CATCH_ENS_2024<-ensemble(models=mods1,lab='ForeCatch_2024',weights=WT)
CATCH_ENS_2025<-ensemble(models=mods1,lab='ForeCatch_2025',weights=WT)

catch<-data.table(Yr=data.table(profiles_M23.1.0.d[[1]])[model=='scenario_1']$Yr,Catch=data.table(profiles_M23.1.0.d[[1]])[model=='scenario_1']$Catch)
names(SSB_ENS)<-c('Model','Yr','SSB')
SSB_ENS<-merge(SSB_ENS[Yr<2026 & Model=='ENSEMBLE'],catch[Yr<2026],by='Yr',all.x=T)
SSB_ENS[Yr==2024]$Catch<-CATCH_ENS_2024
SSB_ENS[Yr==2025]$Catch<-CATCH_ENS_2025

bm3=ggplot(SSB_ENS[Yr<2026],aes(x=SSB/2,y=Catch,color=Yr))+geom_point(size=3)+geom_path()+theme_bw(base_size=16)
bm3<-bm3+scico::scale_color_scico(palette = "vik")
bm3<-bm3+labs(x="Spawning Biomass (t)",y="Catch (t)",color="Year",title="2022 Ensemble")
bm3<-bm3+geom_vline(xintercept=SSB_unfished[1]*0.35/2,color='red',linetype=2,linewidth=1.2)
bm3=bm3+geom_vline(xintercept=SSB_unfished[1]*0.40/2,color='orange',linetype=3,linewidth=1.2)
bm3=bm3+geom_vline(xintercept=SSB_unfished[1]*0.20/2,color='black',linetype=1,linewidth=1)
bm3=bm3+geom_vline(xintercept=SSB_unfished[1]/2,color='gray70',linetype=4,linewidth=1)

bm3<-bm3+geom_point(data=SSB_ENS[Yr%in%c(2024,2025)],size=3,shape=17,color="black")
bm3<-bm3+geom_text(data=SSB_ENS[Yr%in%c(1977,2009,2025)],label=SSB_ENS[Yr%in%c(1977,2009,2025)]$Yr,size=4,hjust=1.1,vjust=1.1)+xlim(0,700000)+ylim(0,250000)
bm3<-bm3+guides(color="none")


TE<-TOT_ENSEMBLE(models=mods1,Weight=WT)
TE=merge(TE,catch)
TE[Yr==2024]$Catch<-CATCH_ENS_2024
TE[Yr==2025]$Catch<-CATCH_ENS_2025

bm3.1=ggplot(TE[Yr<2026],aes(y=Catch/TOT,x=Yr,color=Yr))+geom_point(size=3)+geom_path()+theme_bw(base_size=16)
bm3.1<-bm3.1+scico::scale_color_scico(palette = "vik")
bm3.1<-bm3.1+labs(y="Catch (t) / Total biomass (t)",x="Year",color="Year",title='2022 Ensemble')
bm3.1<-bm3.1+geom_point(data=TE[Yr%in%c(2024,2025)],size=3,shape=17,color="black")+ylim(0,0.35)
#bm2.1<-bm2.1+geom_text(data=scen1[Yr%in%c(1977,2009,2025)],label=scen1[Yr%in%c(1977,2009,2025)]$Yr,size=4,hjust=1.1,vjust=-1.1)
bm3.2=ggarrange(bm3,bm3.1, ncol = 2, nrow = 1)

pdf("CATCH_BIOMASS_ENSEMBLE.pdf",width=12,height=6)
print(bm3.2)
dev.off()
