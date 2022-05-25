# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2021-10-07, R version 4.05.01 64 bit
# SJB, 2022-05-25, R version 4.0.5 (2021-03-31) 64 bit 
### Data file generation for BS Pacific cod 2022

## write SS3 files for stock assessment

libs <- c("tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)


afsc_user  = ""   ## enter afsc username
afsc_pwd   = ""    ## enter afsc password
akfin_user = ""  ## enter AKFIN username
akfin_pwd  = ""   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)

## DEFINE ALL CONSTANTS FOR THIS RUN

# is this a new SS DAT file
is_new_SS_DAT_file <- FALSE

# this assumes that the FUNCTIONS subdirectory is in the working directory
working_dir <- "C:/WORKING_FOLDER/2022 Stock Assessments/EBS Pcod"

# previous SS DAT filename, if it exists
old_SS_dat_filename <- "BSPcod22A.dat"

# current SS DAT filename
new_SS_dat_filename <- "BSPcod22_MAY.dat"

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


## Get all the functions for pulling GOA Pcod data

setwd(paste(working_dir,"\\Functions\\new_scripts\\R",sep=""))

source_files=c("BIN_LEN_DATA.r","FORMAT_AGE_MEANS1.r", "GET_BS_ACOMP1.r","GET_BS_BIOM.r","GET_BS_LCOMP1.r",             
     "GET_SURV_AGE_cor.r", "LENGTH_BY_CATCH_BS.r","Get_lengthweight.r","utils.r") 


lapply(source_files, source)


## Get all the alternative data that isn't in AKFIN or AFSC databases
setwd(paste(working_dir,"\\Functions\\new_scripts\\ALT_DATA",sep=""))

test_file <- "OLD_SEAS_GEAR_CATCH_BS.csv"
if (!file.access(test_file,mode=4))
   {
    OLD_SEAS_GEAR_CATCH<-read.csv("OLD_SEAS_GEAR_CATCH_BS.csv",header=T)
   }

setwd(paste(working_dir,"\\Functions\\new_scripts\\ALT_DATA\\VAST",sep=""))
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

setwd(paste(working_dir,"\\Functions\\new_scripts\\ALT_DATA",sep=""))
test_file <- "Larval_indices.csv"
if (!file.access(test_file,mode=4))
{
    Larval_indices <- read.csv(test_file,header=T)
}


test_file <- "Aging_error.csv"
if (!file.access(test_file,mode=4))
{
    AGING_ERROR_CSV <- read.csv(test_file,header=T)
}

test_file <- "ADFG_IPHC.csv"
  if (!file.access(test_file,mode=4))
 {
    ADFG_IPHC <- read.csv(test_file,header=T)
 }

test_file <- "ALL_STATE_LENGTHS.csv"
  if (!file.access(test_file,mode=4))
 {
    ALL_STATE_LENGTHS <- read.csv(test_file,header=T)
 }


## get all data for data file
setwd(paste(working_dir,"\\Functions\\new_scripts\\R",sep=""))
source("SBSS_GET_ALL_DATA_EBS_PCOD_cor.r")

setwd(paste(working_dir,"\\Functions\\new_scripts", sep=""))

 if (!is_new_SS_DAT_file && !file.access(old_SS_dat_filename,mode=4))
  {
    old_data <- SS_readdat_3.30(old_SS_dat_filename)
    new_data <- old_data
  }else{print(" Warning:  Need to enter old SS data file name")}



new_data <- SBSS_GET_ALL_DATA(new_data           = new_data,
                              new_file           = new_SS_dat_filename,
                              new_year           = new_SS_dat_year,
                              sp_area            = sp_area,
                              fsh_sp_label       = fsh_sp_label,
                              fsh_sp_area        = fsh_sp_area,
                              fsh_sp_str         = fsh_sp_str,
                              fsh_start_yr       = fsh_start_yr,
                              srv_sp_str         = srv_sp_str,
                              srv_start_yr       = srv_start_yr,
                              len_bins           = len_bins,
                              max_age            = max_age,
                              is_new_SS_DAT_file = is_new_SS_DAT_file,
		              AUXFCOMP           = 1,
                              ONE_FLEET          =TRUE,
                              LL_DAT             =FALSE,
                              ICC_T              =FALSE)



# write out SS DAT file

SS_writedat_3.30(new_data,new_SS_dat_filename,overwrite=T)


# Add_climate(Old_datafile=new_SS_dat_filename, New_datafile=new_SS_dat_filename, dir1=paste0(working_dir,"/functions/ALT_DATA",dir2=working_dir)



# test that the new file is readable
test_dat <- SS_readdat_3.30(new_SS_dat_filename,verbose=TRUE)

## ctrl file needs to be edited manually due to complexity at this time.
