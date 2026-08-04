#V3.30.24.00-prerel;_safe;_compile_date:_Jul  8 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_data_and_control_files: BSPcod24_OCT_5cm_NB_COMBO_RV.dat // Model_24.1.ctl
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
3  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond sd_ratio_rd < 0: platoon_sd_ratio parameter required after movement params.
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
2 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
3 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
 2 1 2 0
 3 1 3 0
#
6 #_N_movement_definitions
3 # first age that moves (real age at begin of season, not integer)
# seas,GP,source_area,dest_area,minage,maxage
 1 1 1 2 3 8
 1 1 2 1 3 8
 1 2 1 2 3 8
 1 2 2 1 3 8
 1 3 1 3 3 8
 1 3 3 1 3 8
#
5 #_Nblock_Patterns
 1 1 1 1 1 #_blocks_per_pattern 
# begin and end years of blocks
 1976 1976
 1977 2007
 1977 1980
 1977 1989
 1977 2019
#
# controls for all timevary parameters 
3 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
#
# AUTOGEN
 1 1 1 1 1 # autogen: 1st element for biology, 2nd for SR, 3rd for Q, 4th reserved, 5th for selex
# where: 0 = autogen time-varying parms of this category; 1 = read each time-varying parm line; 2 = read then autogen if parm min==-12345
#
#_Available timevary codes
#_Block types: 0: P_block=P_base*exp(TVP); 1: P_block=P_base+TVP; 2: P_block=TVP; 3: P_block=P_block(-1) + TVP
#_Block_trends: -1: trend bounded by base parm min-max and parms in transformed units (beware); -2: endtrend and infl_year direct values; -3: end and infl as fraction of base range
#_EnvLinks:  1: P(y)=P_base*exp(TVP*env(y));  2: P(y)=P_base+TVP*env(y);  3: P(y)=f(TVP,env_Zscore) w/ logit to stay in min-max;  4: P(y)=2.0/(1.0+exp(-TVP1*env(y) - TVP2))
#_DevLinks:  1: P(y)*=exp(dev(y)*dev_se;  2: P(y)+=dev(y)*dev_se;  3: random walk;  4: zero-reverting random walk with rho;  5: like 4 with logit transform to stay in base min-max
#_DevLinks(more):  21-25 keep last dev for rest of years
#
#_Prior_codes:  0=none; 6=normal; 1=symmetric beta; 2=CASAL's beta; 3=lognormal; 4=lognormal with biascorr; 5=gamma
#
# setup for M, growth, wt-len, maturity, fecundity, (hermaphro), recr_distr, cohort_grow, (movement), (age error), (catch_mult), sex ratio 
#_NATMORT
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
  #_no additional input for selected M option; read 1P per morph
#
2 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
1.5 #_Age(post-settlement) for L1 (aka Amin); first growth parameter is size at this age; linear growth below this
999 #_Age(post-settlement) for L2 (aka Amax); 999 to treat as Linf
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
1 #_First_Mature_Age
1 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms;  if N_GP>1, then nest GP within sex in parameters below
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
 0.3 0.5 0.3866 0.3866 0.4 0 -2 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 1 20 12.2575 14.7724 0.244395 0 2 0 25 2000 2024 7 0 0 # L_at_Amin_Fem_GP_1
 60 150 109.88 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.119176 0.109893 0.0208198 0 2 0 25 2000 2024 7 0 0 # VonBert_K_Fem_GP_1
 0 10 1.50649 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0.01 0.4 0.2 0 0 0 -2 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.2 0.06 0 0 0 -2 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -10 10 5.40706e-06 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 -10 10 3.19601 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 -10 100 58 0 0 0 -1 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -10 10 -0.132 0 0 0 -1 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 -10 10 1 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_1
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_1
# Sex: 1  BioPattern: 2  NatMort
 0.3 0.5 0.3866 0.3866 0.4 0 -2 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_2
# Sex: 1  BioPattern: 2  Growth
 1 20 12.3 14.7724 0.244395 0 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_2
 60 150 109.9 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_2
 0 1 0.12 0.109893 0.0208198 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_2
 0 10 1.5 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_2
 0.01 0.4 0.2 0 0 0 -2 0 0 0 0 0 0 0 # CV_young_Fem_GP_2
 0.01 0.2 0.06 0 0 0 -2 0 0 0 0 0 0 0 # CV_old_Fem_GP_2
# Sex: 1  BioPattern: 2  WtLen
 -10 10 5.40706e-06 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_2
 -10 10 3.19601 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_2
# Sex: 1  BioPattern: 2  Maturity&Fecundity
 -10 100 58 0 0 0 -1 0 0 0 0 0 0 0 # Mat50%_Fem_GP_2
 -10 10 -0.132 0 0 0 -1 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_2
 -10 10 1 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_2
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_2
# Sex: 1  BioPattern: 3  NatMort
 0.3 0.5 0.3866 0.3866 0.4 0 -2 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_3
# Sex: 1  BioPattern: 3  Growth
 1 20 20 14.7724 0.244395 0 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_3
 60 150 108.363 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_3
 0 1 0.174371 0.109893 0.0208198 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_3
 0 10 0.781651 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_3
 0.01 0.4 0.2 0 0 0 -2 0 0 0 0 0 0 0 # CV_young_Fem_GP_3
 0.01 0.2 0.06 0 0 0 -2 0 0 0 0 0 0 0 # CV_old_Fem_GP_3
# Sex: 1  BioPattern: 3  WtLen
 -10 10 5.40706e-06 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_3
 -10 10 3.19601 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_3
# Sex: 1  BioPattern: 3  Maturity&Fecundity
 -10 100 58 0 0 0 -1 0 0 0 0 0 0 0 # Mat50%_Fem_GP_3
 -10 10 -0.132 0 0 0 -1 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_3
 -10 10 1 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_3
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_3
# Hermaphroditism
#  Recruitment Distribution 
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_GP_1
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_GP_2
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_GP_3
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_Area_1
 -10 10 -2.05032 0 0 0 11 0 21 1977 2039 1 0 0 # RecrDist_Area_2
 -10 10 -0.875617 0 0 0 11 0 21 1977 2039 1 0 0 # RecrDist_Area_3
 -4 4 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
 -10 100 -2.02458 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_1to_2
 -10 100 -0.546645 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_2to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_2to_1
 -10 100 -3.98797 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_2from_1to_2
 -10 100 1.74358 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_2to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_2from_2to_1
 -10 100 -2.81395 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_3from_1to_3
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_3from_1to_3
 -10 100 -0.262676 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_3from_3to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_3from_3to_1
#  Platoon StDev Ratio 
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_2
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_3
#  M2 parameter for each predator fleet
#
# timevary MG parameters 
#_ LO HI INIT PRIOR PR_SD PR_type  PHASE
 0 1 0.3654 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 0 1 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 0 1 0.1315 0 0 0 -1 # VonBert_K_Fem_GP_1_dev_se
 0 1 0 0 0 0 -1 # VonBert_K_Fem_GP_1_dev_autocorr
 0 1 0.9 0 99 0 -1 # RecrDist_Area_2_dev_se
 0 1 0 0 0 0 -1 # RecrDist_Area_2_dev_autocorr
 0 1 0.9 0 99 0 -1 # RecrDist_Area_3_dev_se
 0 1 0 0 0 0 -1 # RecrDist_Area_3_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_1from_1to_2_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_1from_1to_2_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_1from_2to_1_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_1from_2to_1_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_2from_1to_2_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_2from_1to_2_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_2from_2to_1_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_2from_2to_1_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_3from_1to_3_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_3from_1to_3_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_3from_3to_1_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_3from_3to_1_dev_autocorr
# info on dev vectors created for MGparms are reported with other devs after tag parameter section 
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm; 10=B-H_ab
0  # 0/1 to use steepness in initial equ recruitment calculation
 0 #  not_used
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
            12            16       13.7862             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10        0.9999             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10         0.666             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.634377 0 -1 0 1 # SR_regime_BLK1add_1976
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can precede this era
2024 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 -1 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1971.1 #_last_yr_nobias_adj_in_MPD; begin of ramp
 1982.2 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2022 #_last_yr_fullbias_adj_in_MPD
 2023.4 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.9216 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -5 #min rec_dev
 5 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_year Input_value
#
# all recruitment deviations
#  1957E 1958E 1959E 1960E 1961E 1962E 1963E 1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975E 1976E 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021R 2022R 2023R 2024R 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F 2034F 2035F 2036F 2037F 2038F 2039F
#  -0.00703693 -0.00405523 -0.00631066 -0.00981217 -0.0151824 -0.0234092 -0.0349515 -0.0530088 -0.0781228 -0.112814 -0.157611 -0.211674 -0.270744 -0.324431 -0.350393 -0.299966 -0.121229 0.0849961 -0.0411738 0.0206714 0.75705 0.349483 0.0827312 -0.360293 -0.213724 0.688305 -0.296826 0.575875 0.0714042 -0.271225 -0.918477 -0.132996 0.550084 0.684203 0.2654 0.500364 -0.720872 -1.15827 -0.337906 0.264999 -0.176598 -0.550673 0.323744 0.159055 -0.271125 -0.356608 -0.444041 -0.479232 0.0347145 0.657822 0.109685 0.914935 -0.00348806 0.494232 0.771735 0.519979 0.949482 -0.33074 -0.283599 -0.770624 -0.627156 0.421083 -0.715917 -0.223317 0.0542001 -0.0193182 -0.480258 -0.0572759 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
-1999 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
3 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 2
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 1 0.0824818 0 0 0 6 # InitF_seas_1_flt_1EBSNBS_fishery
 0 1 0.456599 0 0 0 6 # InitF_seas_1_flt_4WGOA_fishery
#
# F rates by fleet x season
#_year:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037 2038 2039
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# EBSNBS_fishery 0.0809877 0.101105 0.0761074 0.067794 0.0881003 0.0789302 0.113485 0.159707 0.180715 0.153258 0.163252 0.242394 0.250741 0.290027 0.500107 0.554131 0.379873 0.352021 0.455542 0.404905 0.541416 0.432221 0.455822 0.473435 0.404486 0.439938 0.452878 0.478865 0.452867 0.479343 0.501967 0.72459 0.726286 0.482007 0.567924 0.577957 0.570898 0.465377 0.373281 0.391154 0.366171 0.304995 0.282921 0.276871 0.242046 0.309648 0.304731 0.368425 0.20135 0.219812 0.232569 0.24262 0.255649 0.269543 0.275523 0.275523 0.275523 0.275523 0.275523 0.275523 0.275523 0.275523 0.275523
# WBS_fishery 0.0202163 0.0117164 0.0173921 0.0479247 0.139183 0.205444 0.211225 0.270335 0.336268 1.00734 0.630543 0.3369 0.250053 0.254209 0.232331 0.314799 0.39803 0.334258 0.25314 0.546589 0.255426 0.298818 0.566529 0.475211 0.893456 0.79147 0.315348 0.188393 0.172326 0.159151 0.126181 0.109273 0.102047 0.203726 0.224396 0.211799 0.179609 0.167624 0.112161 0.0749935 0.0848366 0.135641 0.250047 0.439886 0.721595 0.85121 1.14871 1.12216 0.511498 0.558397 0.590807 0.616338 0.649436 0.684732 0.699924 0.699924 0.699924 0.699924 0.699924 0.699924 0.699924 0.699924 0.699924
# WGOA_fishery 0 0.583627 0.70795 2.35128 1.22313 0.472775 0.402657 0.212391 0.153485 0.285953 0.448848 0.330947 0.39502 0.669382 0.383711 0.509007 0.40881 0.365393 0.428016 0.421398 0.363446 0.385682 0.555851 0.481755 0.333862 0.49061 0.658585 0.654562 0.45894 0.534938 0.626926 0.754515 0.559209 0.983182 1.00978 0.67284 0.524261 1.07474 1.80486 1.91213 1.73792 0.400342 0.457429 0.146339 0.550296 0.561635 0.416396 0.439602 0.290148 0.316752 0.335136 0.349619 0.368394 0.388415 0.397034 0.397034 0.397034 0.397034 0.397034 0.397034 0.397034 0.397034 0.397034
#
#_Q_setup for fleets with cpue or survey or deviation data
#_1:  fleet number
#_2:  link type: 1=simple q; 2=mirror; 3=power (+1 parm); 4=mirror with scale (+1p); 5=offset (+1p); 6=offset & power (+2p)
#_     where power is applied as y = q * x ^ (1 + power); so a power value of 0 has null effect
#_     and with the offset included it is y = q * (x + offset) ^ (1 + power)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         2         1         0         0         0         0  #  EBSNBS_survey
         5         1         0         0         0         0  #  WBS_survey
         6         1         0         0         0         0  #  WGOA_survey
-9999 0 0 0 0 0
#
#_Q_parameters
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
          -0.5           0.5             0             0             0             0         -6          0          0          0          0          0          0          0  #  LnQ_base_EBSNBS_survey(2)
          -0.5           0.5             0             0             0             0         -6          0          0          0          0          0          0          0  #  LnQ_base_WBS_survey(5)
          -0.5           0.5             0             0             0             0         -6          0          0          0          0          0          0          0  #  LnQ_base_WGOA_survey(6)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (mean over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2*special; non-parm len selex, read as N break points, then N selex parameters
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (mean over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 0 0 0 # 1 EBSNBS_fishery
 24 0 0 0 # 2 EBSNBS_survey
 15 0 0 1 # 3 WBS_fishery
 24 0 0 0 # 4 WGOA_fishery
 24 0 0 0 # 5 WBS_survey
 24 0 0 0 # 6 WGOA_survey
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic. Recommend using pattern 18 instead.
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (mean over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (mean over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 0 0 0 0 # 1 EBSNBS_fishery
 0 0 0 0 # 2 EBSNBS_survey
 0 0 0 0 # 3 WBS_fishery
 0 0 0 0 # 4 WGOA_fishery
 0 0 0 0 # 5 WBS_survey
 0 0 0 0 # 6 WGOA_survey
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   EBSNBS_fishery LenSelex
            10            90       74.8517          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_peak_EBSNBS_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_EBSNBS_fishery(1)
           -10            10       5.95612          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_ascend_se_EBSNBS_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_EBSNBS_fishery(1)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_EBSNBS_fishery(1)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_EBSNBS_fishery(1)
# 2   EBSNBS_survey LenSelex
            10            80        13.569          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_peak_EBSNBS_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_EBSNBS_survey(2)
           -10            10      -3.68626          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_ascend_se_EBSNBS_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_EBSNBS_survey(2)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_EBSNBS_survey(2)
           -10            99            99          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_EBSNBS_survey(2)
# 3   WBS_fishery LenSelex
# 4   WGOA_fishery LenSelex
            10            80       75.1572          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_peak_WGOA_fishery(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_WGOA_fishery(4)
           -10            10       5.52802          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_ascend_se_WGOA_fishery(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_WGOA_fishery(4)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_WGOA_fishery(4)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_WGOA_fishery(4)
# 5   WBS_survey LenSelex
            10            90       35.2462          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_peak_WBS_survey(5)
           -10            10            10          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_top_logit_WBS_survey(5)
           -10            10       4.82845          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_ascend_se_WBS_survey(5)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_WBS_survey(5)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_WBS_survey(5)
           -10            99            99          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_end_logit_WBS_survey(5)
# 6   WGOA_survey LenSelex
            10            90       47.1021          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_peak_WGOA_survey(6)
           -10            10            10          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_top_logit_WGOA_survey(6)
           -10            10       5.34925          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_ascend_se_WGOA_survey(6)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_WGOA_survey(6)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_WGOA_survey(6)
           -10            99            99          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_end_logit_WGOA_survey(6)
# 1   EBSNBS_fishery AgeSelex
# 2   EBSNBS_survey AgeSelex
# 3   WBS_fishery AgeSelex
# 4   WGOA_fishery AgeSelex
# 5   WBS_survey AgeSelex
# 6   WGOA_survey AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
            10            90       78.7424          -999          -999             0      8  # Size_DblN_peak_EBSNBS_fishery(1)_BLK4repl_1977
           -10            10       6.62636          -999          -999             0      8  # Size_DblN_ascend_se_EBSNBS_fishery(1)_BLK4repl_1977
            10            80       73.6123          -999          -999             0      8  # Size_DblN_peak_WGOA_fishery(4)_BLK5repl_1977
           -10            10       5.40665          -999          -999             0      8  # Size_DblN_ascend_se_WGOA_fishery(4)_BLK5repl_1977
# info on dev vectors created for selex parms are reported with other devs after tag parameter section 
#
0   #  use 2D_AR1 selectivity? (0/1)
#_no 2D_AR1 selex offset used
#_specs:  fleet, ymin, ymax, amin, amax, sigma_amax, use_rho, len1/age2, devphase, before_range, after_range
#_sigma_amax>amin means create sigma parm for each bin from min to sigma_amax; sigma_amax<0 means just one sigma parm is read and used for all bins
#_needed parameters follow each fleet's specifications
# -9999  0 0 0 0 0 0 0 0 0 0 # terminator
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# deviation vectors for timevary parameters
#  base   base first block   block  env  env   dev   dev   dev   dev   dev
#  type  index  parm trend pattern link  var  vectr link _mnyr  mxyr phase  dev_vector
#      1     2     1     0     0     0     0     1     5  2000  2024     7 1.37253 -0.0272535 0.816162 0.0551928 0.633934 1.71874 1.89547 0.5273 1.00716 -0.854532 0.897354 0.686747 -0.270265 0.704952 0.0612198 -0.131319 0.82009 -0.24923 2.08354 0.197521 1.13947 0.350327 1.07218 0.0178639 -0.259316
#      1     4     3     0     0     0     0     2     5  2000  2024     7 -0.439415 0.0461142 0.22414 1.21594 0.423451 0.400607 -0.00327552 -0.36232 -0.108608 -1.9515 -0.809262 -1.72767 -1.38753 -1.17684 1.11992 0.32028 0.257558 -0.561198 0.692936 0.822575 0.0968648 0.00765503 -0.264258 0.207519 -0.37175
#      1    44     5     0     0     0     0     3     1  1977  2039     1 -0.656008 0.422745 0.464728 0.619152 0.73242 0.860293 -0.327121 1.01737 0.885624 0.505835 0.104434 -0.23803 -0.355404 -0.981063 -1.43042 -0.380761 -0.2701 0.0482939 -0.772196 0.353792 0.341548 0.124996 -0.601938 0.562975 -0.582217 0.0437881 0.468074 -0.472194 -0.0839629 0.111954 0.359977 0.865029 0.514268 0.707505 0.235651 -0.203926 0.00130197 -0.888372 -0.820613 -0.957487 -1.0771 0.619558 0.0787042 -0.0921165 0.219252 0.0793643 -0.157694 9.56673e-05      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    45     7     0     0     0     0     4     1  1977  2039     1 0.389995 -0.168991 -0.616147 -0.955249 -0.917565 -0.425256 -0.34201 -0.437116 -0.483716 -0.697567 -0.802671 0.24803 1.07211 0.739816 0.171365 0.330908 -0.344825 0.722191 -0.77089 0.451956 0.680778 -0.35219 0.768499 0.685626 0.547426 0.800755 0.965127 0.301219 -0.333147 0.103186 -1.23644 0.322561 -1.50194 0.183114 0.97281 -0.851416 0.138564 -1.33465 1.15947 -0.116269 0.208721 0.680647 0.159505 0.308521 0.00225664 -0.296642 -0.130587 0.000131861      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    48     9     0     0     0     0     5     3  1977  2039     2 3.43848e-08 -0.0956242 -0.0737315 -0.0705453 -0.0279855 0.455292 0.591489 -0.283656 -0.992076 0.24931 0.617768 0.784408 -0.105216 0.353654 0.428627 -0.877 -1.21408 0.600503 -0.619643 0.652827 -0.54911 -0.0470922 -0.561622 -0.372608 0.0380761 1.37917 0.688613 -0.548712 0.251725 0.250527 0.570385 -1.33908 -0.769594 -0.0258559 0.240722 0.0925214 -0.127926 0.686013 0.669837 -0.866528 -1.36168 -0.421387 -0.0236361 0.279578 0.203531 -0.0361191 -0.224903      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    50    11     0     0     0     0     6     3  1977  2039     2 3.01459e-08 0.144066 0.164192 0.199136 0.215343 0.188728 0.225202 -0.124963 0.74475 -0.447893 -0.301817 -0.0887279 -0.0966161 -0.333441 -0.311941 0.52985 0.94082 -0.678021 -0.054783 -0.25975 0.212545 -0.128572 0.0214316 0.335849 0.167291 -0.0527713 0.0201384 0.334881 -0.314207 -0.682728 -0.725889 -0.112279 -0.212072 -1.14568 -0.756438 -0.446514 -0.246627 -0.270821 -0.190379 0.0282203 0.405802 0.360192 0.280359 0.166634 -0.0203069 -0.0033509 0.0268851      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    52    13     0     0     0     0     7     3  1977  2039     2 -1.54017e-08 0.00274164 0.00620939 0.00693674 0.0108798 0.0378422 0.0327408 0.0404506 0.0272447 0.0472256 0.0540085 0.0549092 0.053452 0.0528201 0.049726 0.047299 0.0394115 0.143956 0.131784 0.675347 0.583264 0.83811 0.850278 0.459403 0.188424 0.493583 -0.0146413 -0.100643 -0.179787 -0.212094 -0.160225 -0.0946252 -0.115319 0.12875 0.179968 0.170208 0.132395 0.14299 0.120344 0.121342 0.0384272 0.0454349 0.0223009 0.0152933 0.110056 0.0625489 -0.0186194      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    54    15     0     0     0     0     8     3  1977  2039     2 -1.61702e-08 0.00325654 0.00366243 -0.00595369 -0.0149265 -0.0453228 -0.0536679 -0.0482879 -0.0487661 0.162547 0.125345 0.115934 0.149113 0.141858 0.152424 0.0910062 0.150259 0.0423429 -0.0641361 -0.200586 -0.215261 -0.110348 -0.0703646 -0.0619748 0.033548 -0.418278 -0.347697 -0.238176 -0.204484 -0.133898 -0.202541 -0.233449 -0.152054 -0.379891 -0.430843 -0.450601 -0.41207 -0.463898 -0.297877 -0.166744 0.207495 0.0468088 0.188714 0.149466 -0.180916 -0.126454 0.0166533      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    56    17     0     0     0     0     9     3  1977  2039     2 3.81264e-09 0.128208 0.134502 0.0936286 0.0844925 -0.0374757 0.351753 0.16862 0.0481695 -0.376372 0.474789 -0.454563 0.109122 0.438487 -0.553402 -0.444956 -0.176123 -0.110537 -0.221206 -0.263318 -0.227488 -0.182794 -0.163811 -0.15867 -0.103305 -0.00740189 0.142993 0.103075 0.0395639 -0.0482011 -0.0990887 -0.0934792 -0.100541 -0.0593193 0.112862 0.130422 0.153593 0.412258 0.628871 -0.0283776 -0.609246 -0.506638 -0.364476 -0.0956402 0.0801134 -0.0734744 0.02786      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    58    19     0     0     0     0    10     3  1977  2039     2 -1.56209e-09 -0.153287 -0.2198 -0.271478 -0.23841 0.181637 -0.279208 1.01503 0.198635 0.404619 -1.1149 -0.148619 -0.442539 -0.399272 -0.0555056 -0.0959747 -0.479616 -0.51542 0.0195517 0.741421 0.249447 -0.0268067 0.159426 0.321021 0.269272 -0.336443 -1.54545 -0.702921 -0.226008 0.287507 0.854465 0.948484 1.96427 -0.954706 -0.752228 0.171808 1.63233 -0.21592 0.184852 0.154149 -0.942588 0.153138 0.209009 -0.57869 -0.131877 0.648332 -0.243808      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      2     4    21     1     1     0     0     0     0     0     0     0
#      5     1    22     4     2     0     0     0     0     0     0     0
#      5     3    23     4     2     0     0     0     0     0     0     0
#      5    13    24     5     2     0     0     0     0     0     0     0
#      5    15    25     5     2     0     0     0     0     0     0     0
     #
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_factor  fleet  value
      1      2         0
      4      1  0.475979
      4      2  0.047434
      4      4  0.052919
      4      5  0.043876
      5      2  0.941898
 -9999   1    0  # terminator
#
4 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 1 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
 7 2 1 0 1
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 0 0 0 #_CPUE/survey:_1
#  1 1 1 1 #_CPUE/survey:_2
#  0 0 0 0 #_CPUE/survey:_3
#  0 0 0 0 #_CPUE/survey:_4
#  1 1 1 1 #_CPUE/survey:_5
#  1 1 1 1 #_CPUE/survey:_6
#  1 1 1 1 #_lencomp:_1
#  1 1 1 1 #_lencomp:_2
#  0 0 0 0 #_lencomp:_3
#  1 1 1 1 #_lencomp:_4
#  1 1 1 1 #_lencomp:_5
#  0 0 0 0 #_lencomp:_6
#  0 0 0 0 #_agecomp:_1
#  1 1 1 1 #_agecomp:_2
#  0 0 0 0 #_agecomp:_3
#  0 0 0 0 #_agecomp:_4
#  0 0 0 0 #_agecomp:_5
#  1 1 1 1 #_agecomp:_6
#  1 1 1 1 #_init_equ_catch1
#  1 1 1 1 #_init_equ_catch2
#  1 1 1 1 #_init_equ_catch3
#  1 1 1 1 #_init_equ_catch4
#  1 1 1 1 #_init_equ_catch5
#  1 1 1 1 #_init_equ_catch6
#  1 1 1 1 #_recruitments
#  1 1 1 1 #_parameter-priors
#  1 1 1 1 #_parameter-dev-vectors
#  1 1 1 1 #_crashPenLambda
#  0 0 0 0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

