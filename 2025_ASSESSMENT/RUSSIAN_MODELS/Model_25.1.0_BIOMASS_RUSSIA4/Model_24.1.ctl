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
 1 20 12.2701 14.7724 0.244395 0 2 0 25 2000 2024 7 0 0 # L_at_Amin_Fem_GP_1
 60 150 91.9734 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.163489 0.109893 0.0208198 0 2 0 25 2000 2024 7 0 0 # VonBert_K_Fem_GP_1
 0 10 1.53877 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
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
 1 20 12.2701 14.7724 0.244395 0 -2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_1
 60 150 91.9734 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.163489 0.109893 0.0208198 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 1.53877 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
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
 -10 10 0 0 0 0 -11 0 21 1977 2039 1 0 0 # RecrDist_Area_2
 -4 4 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
 -10 100 -2.46267 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_1to_2
 -10 100 -0.570804 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_2to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_2to_1
 -10 100 -1.26202 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_2from_1to_2
 -10 100 2.86646 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_2to_1
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
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_1from_2to_1_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_1from_2to_1_dev_autocorr
 0 1 0.8997 0 99 0 -1 # MoveParm_A_seas_1_GP_2from_1to_2_dev_se
 0 1 0 0 0 0 -1 # MoveParm_A_seas_1_GP_2from_1to_2_dev_autocorr
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
            12            16       13.7512             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10        0.9999             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10         0.666             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.419294 0 -1 0 1 # SR_regime_BLK1add_1976
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
#  -0.00615275 -0.00349909 -0.0054217 -0.00837804 -0.0129398 -0.0198661 -0.0300614 -0.0451738 -0.0667126 -0.0965973 -0.135843 -0.184084 -0.236776 -0.281344 -0.290741 -0.21416 -0.0138528 0.141296 -0.006791 0.118544 0.901226 0.221438 0.236622 -0.331008 -0.397347 0.860088 -0.526169 0.802008 -0.0328699 -0.528515 -0.594984 -0.266652 0.623501 0.593326 -0.142135 0.575994 -0.683915 -0.678809 -0.583755 0.351384 -0.067682 -0.443211 0.380212 0.319346 -0.315938 -0.270944 -0.290623 -0.613224 -0.0198558 0.753763 -0.220775 1.06192 -0.665746 0.596203 0.852484 0.432237 1.01683 -0.49307 -0.136617 -0.676331 -0.640012 0.539438 -0.575058 -0.218337 -0.035012 -0.172707 -0.458702 -0.0380156 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 1 0.063118 0 0 0 6 # InitF_seas_1_flt_1fishery
 0 1 0.0158405 0 0 0 6 # InitF_seas_1_flt_4goa
#
# F rates by fleet x season
#_year:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037 2038 2039
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# fishery 0.0583687 0.0727338 0.0544912 0.0491528 0.0668661 0.0626212 0.0935964 0.133879 0.162936 0.147712 0.159666 0.224136 0.215734 0.23527 0.366715 0.413324 0.308365 0.290319 0.340952 0.299513 0.408394 0.337198 0.361956 0.384583 0.344884 0.381688 0.414843 0.428367 0.382574 0.392265 0.388705 0.524422 0.488724 0.367242 0.449897 0.466757 0.477636 0.403005 0.362005 0.373874 0.382067 0.266632 0.266682 0.256288 0.205058 0.263306 0.276221 0.330895 0.160949 0.174073 0.182276 0.191409 0.198033 0.198033 0.198033 0.198033 0.198033 0.198033 0.198033 0.198033 0.198033 0.198033 0.198033
# russia 0.0170515 0.00956623 0.0142328 0.0407944 0.132348 0.216453 0.211014 0.274039 0.33853 1.05696 0.620182 0.350167 0.250905 0.248117 0.283153 0.331279 0.400104 0.242647 0.201633 0.468479 0.230103 0.277904 0.539969 0.465013 0.804042 0.732595 0.269734 0.19944 0.181868 0.156268 0.141278 0.120963 0.121508 0.262912 0.333932 0.249216 0.187106 0.277895 0.133657 0.0934846 0.0955661 0.22892 0.379137 0.62275 1.04057 0.854931 0.878592 1.01829 0.482739 0.522101 0.546705 0.574097 0.593967 0.593967 0.593967 0.593967 0.593967 0.593967 0.593967 0.593967 0.593967 0.593967 0.593967
# goa 0 0.0211955 0.0220005 0.0561182 0.0419231 0.0258218 0.0288549 0.0216488 0.016496 0.027977 0.0313293 0.0334243 0.0454257 0.0830275 0.063294 0.10572 0.0666549 0.0431408 0.0515163 0.0567837 0.0599374 0.0649837 0.0893211 0.0729098 0.0454846 0.0543986 0.0653208 0.0665839 0.0469621 0.0637735 0.0808255 0.122278 0.101868 0.108153 0.0974701 0.0826148 0.0843948 0.0866019 0.073072 0.0676225 0.0615963 0.0130401 0.0145353 0.00347727 0.0133628 0.0164959 0.0130011 0.0149077 0.00763034 0.00825251 0.00864142 0.00907438 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845 0.00938845
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
            10            90       75.2882          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_peak_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_fishery(1)
           -10            10       6.00185          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_ascend_se_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_fishery(1)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_fishery(1)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_fishery(1)
# 2   survey LenSelex
            10            80       13.6301          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_peak_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_survey(2)
           -10            10        -3.456          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_ascend_se_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_survey(2)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_survey(2)
           -10            99            99          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_survey(2)
# 3   russia LenSelex
# 4   goa LenSelex
            10            80        64.309          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_peak_goa(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_goa(4)
           -10            10       5.30083          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_ascend_se_goa(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_goa(4)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_goa(4)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_goa(4)
# 5   rus_surv LenSelex
            10            90       19.5394          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_peak_rus_surv(5)
           -10            10            10          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_top_logit_rus_surv(5)
           -10            10       2.79321          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_ascend_se_rus_surv(5)
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
            10            90       79.4334          -999          -999             0      8  # Size_DblN_peak_fishery(1)_BLK4repl_1977
           -10            10       6.64082          -999          -999             0      8  # Size_DblN_ascend_se_fishery(1)_BLK4repl_1977
            10            80       71.9028          -999          -999             0      8  # Size_DblN_peak_goa(4)_BLK5repl_1977
           -10            10       5.48235          -999          -999             0      8  # Size_DblN_ascend_se_goa(4)_BLK5repl_1977
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
#      1     2     1     0     0     0     0     1     5  2000  2024     7 1.65509 -0.110906 0.732726 -0.00174443 0.617962 1.40068 1.63571 0.68852 0.695336 -0.56963 0.541644 0.7169 -0.359428 0.401711 0.0250456 -0.11941 0.476768 -0.270105 1.81228 0.185654 1.12732 0.347291 1.13272 -0.0927112 -0.0928973
#      1     4     3     0     0     0     0     2     5  2000  2024     7 0.434958 0.0272121 0.168974 0.0921617 -0.276121 -0.129811 -0.347865 -0.27384 0.0876784 -0.662642 -0.361784 -0.587864 0.086368 -0.676772 1.36021 0.760201 0.246124 -0.643767 -0.165852 -0.00631429 0.279582 0.108258 -0.143827 0.247414 -0.0501341
#      1    30     5     0     0     0     0     3     1  1977  2039     1 0.907209 0.122509 0.892427 -0.1129 0.218195 -0.343509 -0.533009 -0.702328 -0.727724 -0.166805 -1.46406 -0.592834 -0.456163 -0.214462 0.366436 1.0426 0.540074 -0.0572427 0.29711 0.735082 -0.188487 -0.954345 -0.0992636 -0.281356 0.198491 0.79308 0.809969 0.655285 0.405237 1.10625 0.764224 0.952511 -0.23382 0.524797 0.725245 -0.0179633 0.36039 -1.32009 -1.30292 -1.30637 -0.719323 0.897567 -1.06497 -0.286756 0.144003 -0.0759621 -0.23604 1.2161e-05      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    33     7     0     0     0     0     4     3  1977  2039     2 8.5255e-08 -0.135582 -0.14929 -0.153203 -0.0723135 0.563638 0.561984 -0.18355 -1.09927 0.294355 0.769045 0.873911 -0.0833183 -0.0132483 0.792038 -0.814331 -1.20479 -0.17493 -0.56789 0.78662 -0.207949 0.280083 -0.245816 -0.197466 -0.1133 1.51774 0.698509 -0.305649 0.269727 0.11506 0.581452 -0.958171 -0.618071 -0.340551 0.412731 0.404754 -0.456162 0.829668 0.654256 0.790052 -0.792044 0.0941405 -0.000400063 -0.740291 -0.428064 -0.19718 -0.664431      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    35     9     0     0     0     0     5     3  1977  2039     2 2.82795e-08 0.156319 0.191418 0.260033 0.284953 0.222267 0.28968 0.0932091 0.645369 -0.308092 -0.252173 -0.150464 -0.155007 -0.165399 -0.451289 0.124603 0.477194 -0.364339 0.287935 0.0824916 0.378819 0.172466 0.11793 0.243956 0.202306 0.00777966 0.0389025 0.114529 -0.185827 -0.34604 -0.474877 -0.163185 0.34761 0.166781 0.0927017 0.193785 0.428862 0.0947041 -0.0370255 -0.42918 -0.102978 0.24933 0.170963 0.295696 0.0592891 0.0359615 0.0957101      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    37    11     0     0     0     0     6     3  1977  2039     2 -1.8295e-08 -0.0145756 -0.0217881 -0.0268306 -0.042185 0.202794 0.10869 -0.0365411 -0.767371 -0.338962 -0.271517 0.174367 0.0315867 0.153584 0.586996 -0.11491 -0.310371 0.761365 -0.185054 0.536841 -0.456144 -0.424677 -0.416347 -0.499742 -0.477254 -0.197283 -0.237283 -0.315549 -0.138917 0.00839482 0.0689315 0.0406226 0.0188117 -0.00390606 -0.0210253 -0.0365628 -0.0504226 -0.00507939 0.0274684 0.0652976 -0.00276143 -0.0393568 -0.109607 -0.124664 -0.0204176 -0.0025582 -0.0335833      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    39    13     0     0     0     0     7     3  1977  2039     2 -3.33963e-08 0.000522703 0.00171849 0.0029789 0.0152777 -0.00346943 -0.197557 -0.300485 0.473784 0.16761 -0.511993 -0.747723 -0.711679 0.284114 0.0349951 -0.0430672 -0.0371314 -0.345242 -0.257893 -0.766484 -0.0232356 0.300233 0.155643 -0.0947122 0.975399 -0.370766 -0.254228 -0.0538377 -0.104407 -0.169768 -0.207008 0.175978 0.19368 0.184187 0.146076 0.0137201 -0.0708349 -0.241874 0.26385 0.218197 0.0893677 -0.490631 0.348175 0.299331 0.24997 0.0941192 0.00969147      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      2     4    15     1     1     0     0     0     0     0     0     0
#      5     1    16     4     2     0     0     0     0     0     0     0
#      5     3    17     4     2     0     0     0     0     0     0     0
#      5    13    18     5     2     0     0     0     0     0     0     0
#      5    15    19     5     2     0     0     0     0     0     0     0
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

