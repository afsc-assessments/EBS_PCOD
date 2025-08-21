#V3.30.24.00-prerel;_safe;_compile_date:_Jul  8 2025;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.2
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:_https://groups.google.com/g/ss3-forum_and_NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:_https://nmfs-ost.github.io/ss3-website/
#_Source_code_at:_https://github.com/nmfs-ost/ss3-source-code

#_data_and_control_files: BSPcod24_OCT_5cm_NB_COMBO_RV.dat // Model_24.1.ctl
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
2  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond sd_ratio_rd < 0: platoon_sd_ratio parameter required after movement params.
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
2 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
2 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
 2 1 2 0
#
4 #_N_movement_definitions
3 # first age that moves (real age at begin of season, not integer)
# seas,GP,source_area,dest_area,minage,maxage
 1 1 1 2 3 8
 1 1 2 1 3 8
 1 2 1 2 3 8
 1 2 2 1 3 8
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
 1 20 12.2032 14.7724 0.244395 0 2 0 25 2000 2024 7 0 0 # L_at_Amin_Fem_GP_1
 60 150 92.7647 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.163808 0.109893 0.0208198 0 2 0 25 2000 2024 7 0 0 # VonBert_K_Fem_GP_1
 0 10 1.51528 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
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
 1 20 1 14.7724 0.244395 0 2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_2
 60 150 98.3103 112.958 5.92116 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_2
 0 1 0.594427 0.109893 0.0208198 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_2
 0 10 0.0463207 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_2
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
# Hermaphroditism
#  Recruitment Distribution 
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_GP_1
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_GP_2
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_Area_1
 -10 10 -1.6364 0 0 0 11 0 21 1977 2039 1 0 0 # RecrDist_Area_2
 -4 4 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
 -10 100 -2.54873 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_1to_2
 -10 100 3.06217 0 0 0 2 0 0 0 0 0 0 0 # MoveParm_A_seas_1_GP_1from_2to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_2to_1
 -10 100 -3.20107 0 0 0 2 0 0 0 0 0 0 0 # MoveParm_A_seas_1_GP_2from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_2from_1to_2
 -10 100 2.40936 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_2to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_2from_2to_1
#  Platoon StDev Ratio 
#  Age Error from parameters
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_2
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
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_1from_1to_2_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_1from_1to_2_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_2from_2to_1_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_2from_2to_1_dev_autocorr
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
            12            16        13.731             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10        0.9999             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10         0.666             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.41849 0 -1 0 1 # SR_regime_BLK1add_1976
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
#  -0.00591973 -0.00340554 -0.00530884 -0.00825672 -0.012842 -0.019842 -0.0302484 -0.0457563 -0.0679913 -0.0989718 -0.139683 -0.189674 -0.243984 -0.289401 -0.297492 -0.215789 -0.00883238 0.156276 0.0113245 0.132032 0.914317 0.280028 0.225284 -0.531456 -0.172099 0.776694 -0.381616 0.787318 -0.0262672 -0.521351 -0.688489 -0.313825 0.616718 0.61504 -0.0559915 0.583311 -0.687246 -0.654669 -0.562654 0.350074 -0.0745506 -0.438397 0.346426 0.324444 -0.317611 -0.28836 -0.310213 -0.628789 -0.0186112 0.782984 -0.236254 1.06698 -0.677324 0.585629 0.828327 0.407606 0.985116 -0.45148 -0.13031 -0.649278 -0.635275 0.51772 -0.578986 -0.224591 -0.0748551 -0.176569 -0.448899 -0.0380019 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 1 0.0568564 0 0 0 6 # InitF_seas_1_flt_1fishery
 0 1 0.0143535 0 0 0 6 # InitF_seas_1_flt_4goa
#
# F rates by fleet x season
#_year:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037 2038 2039
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# fishery 0.0528085 0.0656707 0.049416 0.0454572 0.0627609 0.0598295 0.0900176 0.129877 0.156224 0.14284 0.156515 0.219651 0.211412 0.234948 0.357398 0.384011 0.292017 0.281044 0.333896 0.294209 0.39586 0.328871 0.354056 0.377263 0.335071 0.377238 0.402877 0.420082 0.374026 0.384378 0.376469 0.516804 0.456381 0.356725 0.435113 0.454107 0.462188 0.390338 0.363047 0.358281 0.36668 0.26079 0.26585 0.254693 0.201684 0.259211 0.272343 0.32722 0.149145 0.160725 0.16761 0.177023 0.185951 0.185951 0.185951 0.185951 0.185951 0.185951 0.185951 0.185951 0.185951 0.185951 0.185951
# russia 0.03841 0.0201683 0.028811 0.066177 0.172628 0.227873 0.213268 0.27277 0.397217 1.45846 0.662473 0.372744 0.2547 0.26271 0.371797 0.457176 0.537257 0.329075 0.246178 0.558945 0.282954 0.35962 0.668665 0.525326 1.03219 0.832112 0.302006 0.21161 0.192856 0.163831 0.160015 0.130116 0.155308 0.278907 0.36277 0.257581 0.201184 0.308398 0.13361 0.108519 0.106122 0.270696 0.410315 0.66051 1.20181 0.975586 1.03294 1.18614 0.515762 0.55581 0.579619 0.612167 0.643042 0.643042 0.643042 0.643042 0.643042 0.643042 0.643042 0.643042 0.643042 0.643042 0.643042
# goa 0 0.0192729 0.0201046 0.0522938 0.0398238 0.024975 0.0280601 0.0212429 0.0160076 0.0273943 0.0311238 0.0332269 0.0449437 0.0830483 0.0617472 0.0981842 0.0630794 0.041879 0.0505749 0.0559064 0.0582289 0.0635405 0.0875943 0.0717403 0.0442973 0.0539656 0.0635614 0.0655276 0.0460087 0.062623 0.0784355 0.12076 0.0949552 0.10542 0.0944534 0.0805768 0.0818877 0.0840916 0.0734456 0.0649869 0.059291 0.0127978 0.0145302 0.00348492 0.0132309 0.01639 0.0129229 0.0149083 0.00711924 0.00767203 0.00800068 0.00844995 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613 0.00887613
# rus_surv 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
         2         1         0         0         0         0  #  survey
         5         1         0         0         0         0  #  rus_surv
-9999 0 0 0 0 0
#
#_Q_parameters
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
          -0.5           0.5             0             0             0             0         -6          0          0          0          0          0          0          0  #  LnQ_base_survey(2)
          -0.5           0.5             0             0             0             0         -6          0          0          0          0          0          0          0  #  LnQ_base_rus_surv(5)
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
 24 0 0 0 # 1 fishery
 24 0 0 0 # 2 survey
 15 0 0 1 # 3 russia
 24 0 0 0 # 4 goa
 24 0 0 0 # 5 rus_surv
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
 0 0 0 0 # 1 fishery
 0 0 0 0 # 2 survey
 0 0 0 0 # 3 russia
 0 0 0 0 # 4 goa
 0 0 0 0 # 5 rus_surv
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   fishery LenSelex
            10            90       74.9694          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_peak_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_fishery(1)
           -10            10       6.00101          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_ascend_se_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_fishery(1)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_fishery(1)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_fishery(1)
# 2   survey LenSelex
            10            80       13.8808          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_peak_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_survey(2)
           -10            10      -3.44953          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_ascend_se_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_survey(2)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_survey(2)
           -10            99            99          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_survey(2)
# 3   russia LenSelex
# 4   goa LenSelex
            10            80       64.2403          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_peak_goa(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_goa(4)
           -10            10       5.30388          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_ascend_se_goa(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_goa(4)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_goa(4)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_goa(4)
# 5   rus_surv LenSelex
            10            90        18.504          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_peak_rus_surv(5)
           -10            10            10          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_top_logit_rus_surv(5)
           -10            10       2.55515          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_ascend_se_rus_surv(5)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_rus_surv(5)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_rus_surv(5)
           -10            99            99          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_end_logit_rus_surv(5)
# 1   fishery AgeSelex
# 2   survey AgeSelex
# 3   russia AgeSelex
# 4   goa AgeSelex
# 5   rus_surv AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
            10            90       78.3543          -999          -999             0      8  # Size_DblN_peak_fishery(1)_BLK4repl_1977
           -10            10       6.61038          -999          -999             0      8  # Size_DblN_ascend_se_fishery(1)_BLK4repl_1977
            10            80       71.7151          -999          -999             0      8  # Size_DblN_peak_goa(4)_BLK5repl_1977
           -10            10       5.48544          -999          -999             0      8  # Size_DblN_ascend_se_goa(4)_BLK5repl_1977
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
#      1     2     1     0     0     0     0     1     5  2000  2024     7 1.71943 -0.0612725 0.785956 0.0513177 0.664827 1.43721 1.6403 0.747353 0.704149 -0.536979 0.57404 0.76808 -0.321547 0.449753 0.0326413 -0.0866258 0.528347 -0.241411 1.8986 0.215427 1.17152 0.38928 1.12715 -0.0869331 -0.143395
#      1     4     3     0     0     0     0     2     5  2000  2024     7 0.466933 -0.0136805 0.148621 0.205564 -0.15403 -0.0675605 -0.347094 -0.301659 0.0832214 -0.614941 -0.330246 -0.679159 0.0988616 -0.646119 1.43266 0.472209 0.545357 -0.60183 0.0136141 0.129219 0.279705 0.142112 -0.068935 0.287809 -0.129886
#      1    30     5     0     0     0     0     3     1  1977  2039     1 0.938547 0.16332 0.76424 0.281235 0.227016 -0.274376 -0.304989 -0.641404 -0.667361 -0.0467603 -1.45039 -0.431387 -0.319272 -0.17647 0.0712044 1.16524 0.769382 -0.0860501 0.27951 0.687423 -0.052726 -1.00781 0.00338875 -0.456194 -0.0207588 0.703654 0.784903 0.605791  0.279 1.04783 0.705329 0.996505 -0.190253 0.50436 0.766655 0.00150892 0.371822 -1.60455 -1.32119 -1.46064 -0.834959 0.810913 -1.12467 -0.364953 0.216936 -0.0765543 -0.231968 -2.04283e-05      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    33     7     0     0     0     0     4     3  1977  2039     2      0 0.0157787 0.0658196 0.0719234 0.0930431 0.389096 0.507098 -0.235611 -1.04977 0.208789 0.623699 1.00212 0.286485 -0.26387 0.566475 -0.357146 -1.56096 0.0206784 -0.675478 0.802424 -0.242623 -0.0224837 -0.130985 -0.415419 -0.119688 1.36787 0.775099 -0.267347 0.25865 0.144415 0.770383 -0.758771 -0.575344 -0.583501 0.363763 0.317875 -0.502856 0.854342 0.449458 0.783164 -0.599631 -0.00857021 0.0469061 -0.84809 -0.436978 -0.217869 -0.654549      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    39     9     0     0     0     0     5     3  1977  2039     2      0 -0.000991754 -0.000723033 -0.000374692 -0.00237395 -0.0367108 -0.128061 -0.200196 0.506358 0.182283 -0.548341 -0.899273 -0.849483 -0.194159 -0.260136 -0.417526 -0.546259 -0.444045 -0.0253057 0.0644643 0.375332 0.560607 0.411516 0.132522 0.85784 -0.371981 -0.239327 -0.0606658 -0.178575 -0.314184 -0.326413 0.053689 0.162501 0.190804 0.21335 0.0353161 -0.0757038 -0.284062 0.0816754 0.114973 0.511557 -0.302125 0.460992 0.390173 0.273698 0.10466 0.0112526      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      2     4    11     1     1     0     0     0     0     0     0     0
#      5     1    12     4     2     0     0     0     0     0     0     0
#      5     3    13     4     2     0     0     0     0     0     0     0
#      5    13    14     5     2     0     0     0     0     0     0     0
#      5    15    15     5     2     0     0     0     0     0     0     0
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
#  1 1 1 1 #_lencomp:_1
#  1 1 1 1 #_lencomp:_2
#  0 0 0 0 #_lencomp:_3
#  1 1 1 1 #_lencomp:_4
#  1 1 1 1 #_lencomp:_5
#  1 1 1 1 #_agecomp:_1
#  1 1 1 1 #_agecomp:_2
#  0 0 0 0 #_agecomp:_3
#  0 0 0 0 #_agecomp:_4
#  0 0 0 0 #_agecomp:_5
#  1 1 1 1 #_init_equ_catch1
#  1 1 1 1 #_init_equ_catch2
#  1 1 1 1 #_init_equ_catch3
#  1 1 1 1 #_init_equ_catch4
#  1 1 1 1 #_init_equ_catch5
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

