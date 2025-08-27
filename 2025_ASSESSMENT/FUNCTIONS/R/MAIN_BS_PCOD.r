# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# SJB, 2022-05-27, R version 4.05.01 64 bit
### BS Pacific cod

# this assumes that the FUNCTIONS subdirectory is in the working directory
working_dir <- "C:/Users/steve.barbeaux/Work/WORKING_FOLDER/EBS_PCOD_work_folder/2024_ASSESSMENT"

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}


libs <- c(
  "datasets", 
  "data.table",
  "devtools",
  "dplyr",
  "fishmethods", 
  "flextable",
  "forcats", 
  "FSA",
  "ggplot2",
  "gnm",  
  "graphics", 
  "grDevices", 
  "grid",
  "gt",
  "keyring",
  "lubridate", 
  "magrittr", 
  "methods",
  "misty",
  "mgcv", 
  "nlme", 
  "nlstools",
  "officer", 
  "pdftools",
  "pivottabler", 
  "purrr",
  "r4ss",
  "readr",
  "readxl", 
  "remotes",
  "reshape2",
  "RODBC", 
  "scales",
  "sizeMat", 
  "sp",
  "ss3diags", 
  "stats",
  "stringr",
  "swo",
  "tabulizer",
  "tibble", 
  "tidyr", 
  "tidyverse", 
  "usethis", 
  "utils",
  "vcd",
  "vcdExtra"
  )

pacman::p_load(char = libs)


## set the working directory, load functions, and set up connection to databases

working_dir <- "C:/Users/steve.barbeaux/Work/WORKING_FOLDER/EBS_PCOD_work_folder/2024_ASSESSMENT"

setwd(file.path(working_dir, "Functions", "R"))


source_files=c(
  "BIN_LEN_DATA.r",
   "cond_length_age_cor.r",
   "cond_length_age_corFISH.r",
  "FORMAT_AGE_MEANS1.r",
  "get_noncommercial_catch.r",
  "Get_lengthweight.r",
  "GET_SURVEY_ACOMP.r",
   "GET_SURVEY_BIOM.r",
  "GET_SURVEY_LCOMP.r",
  "LENGTH_BY_CATCH_short.r", 
  "utils.r") 


lapply(source_files, source)


# create a keyring database called "afsc" and "akfin" with a username and password
# the username and password can then be called with 

afsc_user  =  keyring::key_list("afsc")$username[2]  ## enter afsc username
afsc_pwd   = keyring::key_get("afsc", keyring::key_list("afsc")$username[2])   ## enter afsc password
akfin_user = keyring::key_list("akfin")$username ## enter AKFIN username
akfin_pwd  =  keyring::key_get("akfin", keyring::key_list("akfin")$username)   ## enter AKFIN password


  afsc = DBI::dbConnect(odbc::odbc(), "afsc",
                      UID = afsc_user, PWD = afsc_pwd)
  akfin = DBI::dbConnect(odbc::odbc(), "akfin",
                      UID = akfin_user, PWD = akfin_pwd)

# Install packages based on DESCRIPTION file
#remotes::install_deps(dependencies=TRUE)



## DEFINE ALL CONSTANTS FOR THIS RUN

# is this a new SS DAT file
is_new_SS_DAT_file <- FALSE

# previous SS DAT filename, if it exists
old_SS_dat_filename <- "BSPcod24_FEB_1cm.dat"

# current SS DAT filename
new_SS_dat_filename <- "BSPcod24_OCT_1cm.dat"

# the most recent year of data to be used
new_SS_dat_year <- 2024
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
min_size <- 0.5
max_size <- 119.5  # less than 1% of the fish in each year are 105 cm or larger (max less than 0.6%)
len_bins <- c(seq(min_size,max_size,bin_width))

# maximum age
max_age <- 20



## Get all the alternative data that isn't in AKFIN or AFSC databases
setwd(file.path(working_dir,"Functions","ALT_DATA"))

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

setwd(file.path(working_dir,"Functions","ALT_DATA","VAST"))
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
setwd(file.path(working_dir,"Functions","R"))
source("SBSS_GET_ALL_DATA_EBS_PCOD_cor_2024.r")

## change working directory to main level.

setwd(file.path(working_dir,"Functions"))

 if (!is_new_SS_DAT_file && !file.access(old_SS_dat_filename,mode=4))
  {
    old_data <- r4ss::SS_readdat(old_SS_dat_filename)
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
                              vmax_age           = 12,
                              is_new_SS_DAT_file = is_new_SS_DAT_file,
		                          AUXFCOMP           = 1,
                              ONE_FLEET          = TRUE,
                              LL_DAT             = FALSE,
                              ICC_T              = FALSE,
                              VAST               = TRUE)



# write out SS DAT file

SS_writedat_3.30(new_data,new_SS_dat_filename,overwrite=T)

# test that the new file is readable
test_dat <- SS_readdat_3.30(new_SS_dat_filename,verbose=TRUE)

## ctrl file needs to be edited manually due to complexity at this time.

new_data           = new_data
                              new_file           = new_SS_dat_filename
                              new_year           = new_SS_dat_year
                              sp_area            = sp_area
                              fsh_sp_label       = fsh_sp_label
                              fsh_sp_area        = fsh_sp_area
                              fsh_sp_str         = fsh_sp_str
                              fsh_start_yr       = fsh_start_yr
                              srv_sp_str         = srv_sp_str
                              srv_start_yr       = srv_start_yr
                              len_bins           = len_bins
                              max_age            = max_age
                              vmax_age           = 12
                              is_new_SS_DAT_file = is_new_SS_DAT_file
		                          AUXFCOMP           = 1
                              ONE_FLEET          =TRUE
                              LL_DAT             =FALSE
                              ICC_T              =FALSE
                              VAST               =TRUE

