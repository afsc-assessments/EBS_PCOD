# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# SJB, 2022-05-27, R version 4.05.01 64 bit
### BS Pacific cod

## write SS3 files for stock assessment

libs <- c("tidyverse", "dplyr","RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal","fishmethods","reshape2","swo","vcdExtra","misty")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)


<<<<<<< HEAD
afsc_user  = "sbarb"   ## enter afsc username
afsc_pwd   = "BluFsh$$7890"    ## enter afsc password
akfin_user = "sbarbeaux"  ## enter AKFIN username
akfin_pwd  = "$tockmen12"   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)

#afsc  = odbcConnect("AFSC",afsc_user,afsc_pass,believeNRows=FALSE)
#akfin = odbcConnect("AKFIN",akfin_user,akfin_pass,believeNRows=FALSE)


## DEFINE ALL CONSTANTS FOR THIS RUN

# is this a new SS DAT file
is_new_SS_DAT_file <- FALSE

# this assumes that the FUNCTIONS subdirectory is in the working directory
working_dir <- "C:/WORKING_FOLDER/EBS_PCOD/2022_ASSESSMENT"

# previous SS DAT filename, if it exists
old_SS_dat_filename <- "BSPcod22_MAY.dat"

# current SS DAT filename
new_SS_dat_filename <- "BSPcod22_OCT.dat"

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


## Get all the alternative data that isn't in AKFIN or AFSC databases
setwd(paste(working_dir,"\\Functions\\ALT_DATA",sep=""))

test_file <- "OLD_SEAS_GEAR_CATCH_BS.csv"
if (!file.access(test_file,mode=4))
   {
    OLD_SEAS_GEAR_CATCH<-read.csv("OLD_SEAS_GEAR_CATCH_BS.csv",header=T)
   }

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


## get VAST index and age comps files

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

## Source the main data gathering function, one function to rule them all...
setwd(paste(working_dir,"\\Functions\\R",sep=""))
source("SBSS_GET_ALL_DATA_EBS_PCOD_cor.r")

## change working directory to main level.

setwd(paste(working_dir,"\\Functions", sep=""))

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

# test that the new file is readable
test_dat <- SS_readdat_3.30(new_SS_dat_filename,verbose=TRUE)

## ctrl file needs to be edited manually due to complexity at this time.
