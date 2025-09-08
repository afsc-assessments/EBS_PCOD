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
 1 20 12.1682 14.7724 0.244395 0 2 0 25 2000 2024 7 0 0 # L_at_Amin_Fem_GP_1
 60 150 113.38 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.115534 0.109893 0.0208198 0 2 0 25 2000 2024 7 0 0 # VonBert_K_Fem_GP_1
 0 10 1.51349 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
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
 1 20 12.2701 14.7724 0.244395 0 -2 0 0 0 0 0 0 0 # L_at_Amin_Fem_GP_2
 60 150 75.4569 112.958 5.92116 0 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_2
 0 1 0.218013 0.109893 0.0208198 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_2
 0 10 1.54603 1.4942 0.113808 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_2
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
 -10 10 -2.07457 0 0 0 11 0 21 1977 2039 1 0 0 # RecrDist_Area_2
 -4 4 0 0 0 0 -1 0 0 0 0 0 0 0 # RecrDist_month_1
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
 -10 100 -1.63727 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_1to_2
 -10 100 -1.48327 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_1from_2to_1
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_1from_2to_1
 -10 100 -4.82263 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_1to_2
 -10 100 -9998 0 0 0 -1 0 0 0 0 0 0 0 # MoveParm_B_seas_1_GP_2from_1to_2
 -10 100 3.82108 0 0 0 2 0 23 1977 2039 2 0 0 # MoveParm_A_seas_1_GP_2from_2to_1
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
            12            16       13.7026             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10        0.9999             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10         0.666             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.550649 0 -1 0 1 # SR_regime_BLK1add_1976
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
#  -0.0063659 -0.00360082 -0.00557832 -0.008634 -0.0132903 -0.0204169 -0.0309517 -0.0468343 -0.0691798 -0.100256 -0.140754 -0.189632 -0.242794 -0.28978 -0.310849 -0.266766 -0.117747 0.0490567 -0.0546648 0.0743654 0.970176 0.301275 0.280483 -0.537491 -0.34232 0.726629 -0.262052 0.679052 0.154172 -0.322249 -1.09078 -0.204519 0.482402 0.540612 0.22363 0.678522 -0.779026 -0.845901 -0.545755 0.386574 -0.0456573 -0.574586 0.342334 0.18336 -0.263944 -0.254832 -0.341074 -0.470614 -0.0345205 0.837658 -0.0752507 1.11923 -0.602828 0.609636 0.936729 0.388639 1.07114 -0.602903 -0.158515 -0.835719 -0.492118 0.496047 -0.741917 -0.179152 -0.0579388 -0.209583 -0.487123 -0.0499251 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 1 0.101204 0 0 0 6 # InitF_seas_1_flt_1fishery
 0 1 0.0241429 0 0 0 6 # InitF_seas_1_flt_4goa
#
# F rates by fleet x season
#_year:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037 2038 2039
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# fishery 0.0968385 0.120311 0.0881643 0.0718443 0.0866272 0.0738422 0.105686 0.146909 0.170228 0.150021 0.164927 0.231788 0.231806 0.250418 0.382292 0.451593 0.314925 0.303724 0.388808 0.33538 0.436574 0.345478 0.373243 0.390799 0.339809 0.391544 0.428275 0.432061 0.396361 0.400958 0.401112 0.543677 0.513972 0.394587 0.498927 0.503718 0.490769 0.446254 0.368193 0.389738 0.37233 0.304967 0.273783 0.262765 0.227225 0.288467 0.285054 0.345573 0.146837 0.158936 0.167401 0.177566 0.192481 0.194605 0.194605 0.194605 0.194605 0.194605 0.194605 0.194605 0.194605 0.194605 0.194605
# russia 0.0102651 0.00619266 0.00970593 0.0321665 0.118605 0.21969 0.223389 0.276883 0.359757 1.09525 0.683522 0.374193 0.26557 0.250386 0.304258 0.318187 0.452567 0.382387 0.242512 0.554922 0.261795 0.334319 0.578623 0.515232 1.01597 0.799096 0.277639 0.182524 0.167053 0.171647 0.142158 0.115142 0.109455 0.219267 0.237004 0.214251 0.186813 0.182267 0.121656 0.0785385 0.0872772 0.138878 0.25534 0.452313 0.748341 0.905228 1.28231 1.28152 0.42973 0.46514 0.489913 0.519663 0.563311 0.569529 0.569529 0.569529 0.569529 0.569529 0.569529 0.569529 0.569529 0.569529 0.569529
# goa 0 0.0334381 0.0340076 0.0804566 0.0524116 0.0288517 0.0308618 0.0225418 0.0164451 0.0266971 0.030838 0.0326138 0.046523 0.0880296 0.0656972 0.115735 0.0676347 0.0449337 0.0587693 0.0635067 0.0639563 0.0663691 0.0918535 0.0738306 0.0445456 0.0555934 0.0672102 0.0666132 0.0483814 0.0649072 0.083017 0.126428 0.107222 0.116075 0.108136 0.0892481 0.0864695 0.0959811 0.0742234 0.0705476 0.0600424 0.0149448 0.0149319 0.00352795 0.0145611 0.0178128 0.0133616 0.0156912 0.00697042 0.00754479 0.00794663 0.00842918 0.00913717 0.00923802 0.00923802 0.00923802 0.00923802 0.00923802 0.00923802 0.00923802 0.00923802 0.00923802 0.00923802
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
            10            90       75.9827          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_peak_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_fishery(1)
           -10            10       6.01629          -999          -999             0          3          0          0       1977       2024          8          4          2  #  Size_DblN_ascend_se_fishery(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_fishery(1)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_fishery(1)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_fishery(1)
# 2   survey LenSelex
            10            80       13.8819          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_peak_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_survey(2)
           -10            10      -3.31533          -999          -999             0          3          0          0       1982       2024          0          0          0  #  Size_DblN_ascend_se_survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_survey(2)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_survey(2)
           -10            99            99          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_survey(2)
# 3   russia LenSelex
# 4   goa LenSelex
            10            80       65.9743          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_peak_goa(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_goa(4)
           -10            10       5.41803          -999          -999             0          3          0          0       1977       2024          8          5          2  #  Size_DblN_ascend_se_goa(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_goa(4)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_goa(4)
           -10            99            99          -999          -999             0         -3          0          0       1977       2024          8          0          0  #  Size_DblN_end_logit_goa(4)
# 5   rus_surv LenSelex
            10            90       24.8509          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_peak_rus_surv(5)
           -10            10            10          -999          -999             0         -3          0          0       1982       2024          8          0          0  #  Size_DblN_top_logit_rus_surv(5)
           -10            10       3.58886          -999          -999             0          3          0          0       1982       2024          8          0          0  #  Size_DblN_ascend_se_rus_surv(5)
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
            10            90       82.5832          -999          -999             0      8  # Size_DblN_peak_fishery(1)_BLK4repl_1977
           -10            10       6.70625          -999          -999             0      8  # Size_DblN_ascend_se_fishery(1)_BLK4repl_1977
            10            80       72.3448          -999          -999             0      8  # Size_DblN_peak_goa(4)_BLK5repl_1977
           -10            10         5.486          -999          -999             0      8  # Size_DblN_ascend_se_goa(4)_BLK5repl_1977
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
#      1     2     1     0     0     0     0     1     5  2000  2024     7 1.57074 0.0304219 0.89517 0.054443 0.583877 1.49894 1.76287 0.751461 0.839591 -0.595565 0.656418 0.843902 -0.223365 0.537106 0.0672317 -0.058182 0.735458 -0.299514 2.1015 0.240829 1.08917 0.394776 1.0812 -0.0700946 -0.207867
#      1     4     3     0     0     0     0     2     5  2000  2024     7 -0.25644 -0.0979075 -0.416514 1.07327 0.548901 0.215695 -0.205647 -0.415671 -0.237795 -1.3111 -0.84082 -1.60533 -0.877603 -1.32753 0.841552 -0.0266652 0.0623856 -0.619877 0.845813 1.09872 0.052585 -0.0808692 -0.242145 0.234453 -0.241487
#      1    30     5     0     0     0     0     3     1  1977  2039     1 -1.33495 -0.125028 -0.336019 0.733967 0.874252 1.13935 0.194535  0.924 1.07118 0.751968 0.14601 0.207869 0.111577 0.396474 -1.1572 -1.25428 0.128707 0.557631 -0.52223 -0.323803 0.519556 -0.249777 -0.142998 0.604846 -0.599349 -0.37335 0.495272 -0.243071 0.16612 0.113487 -0.0722029 0.903222 0.211708 0.885917 0.0827908 0.0626511 -0.115471 -1.05094 -0.987011 -1.01054 -1.44044 0.153557 0.243901 -0.323134 0.120645 0.0936025 -0.233014 1.35076e-05      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    33     7     0     0     0     0     4     3  1977  2039     2 3.61798e-07 -0.380436 -0.369472 -0.317815 -0.166591 0.627797 0.549298 -0.466955 -0.907567 0.258022 0.52072 0.735018 -0.0005541 -0.0296694 0.971056 -0.732994 -1.22806 0.777813 -0.656172 0.557743 -0.578201 0.219738 -0.543653 -0.425143 0.111747 1.36673 0.489685 -0.437007 0.0827105 0.226372 0.621318 -1.365 -0.892004 -0.0240969 0.166142 -0.175881 -0.035462 0.877622 0.670972 -0.926736 -1.31876 -0.377766 -0.0601454 0.138183 0.00877886 -0.0307243 -0.168214      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    35     9     0     0     0     0     5     3  1977  2039     2 -8.25736e-08 0.35419 0.413448 0.436177 0.360833 0.104907 0.238384 -0.00262196 0.937601 -0.262141 -0.118955 0.0685087 0.0572276 0.0647054 -0.20804 0.107878 0.520963 -0.55174 -0.172074 -0.231425 0.210414 -0.13165 0.0088949 0.239593 0.075145 -0.0524712 0.0213978 0.328489 -0.15634 -0.559242 -0.709626 -0.171373 -0.21485 -1.01245 -0.729412 -0.383043 -0.207882 -0.370451 -0.280992 -0.0316183 0.458547 0.24674 0.194915 0.148218 0.00757931 -0.0145331 0.018349      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    37    11     0     0     0     0     6     3  1977  2039     2 7.1821e-08 7.27731e-05 0.0026684 0.0004286 0.00245306 0.018051 -0.00107041 0.0337449 0.00368031 0.0308597 0.0193894 0.0119649 0.0112026 0.0106517 0.010675 0.00402593 0.000198099 0.0133585 -0.0049765 0.124268 0.0885476 0.120901 0.120678 0.106661 0.116177 0.138308 0.103568 0.1123 0.113051 0.109339 0.10223 0.0831736 0.098527 0.156429 0.173366 0.129623 0.134564 0.175786 0.177072 0.177926 0.119778 0.256019 0.300765 0.291654 0.383363 0.194922 -0.107328      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
#      1    39    13     0     0     0     0     7     3  1977  2039     2 -2.89826e-08 -0.00376741 -0.00626435 -0.0150618 -0.0164159 -0.0650322 -0.067084 -0.0639991 -0.0641099 -0.00172847 -0.00734405 -0.00935626 -0.00553798 -0.00901153 -0.011976 -0.0247086 -0.0253876 -0.105463 -0.185536 -0.249817 -0.254757 -0.286627 -0.209835 -0.22815 -0.258159 -0.535752 -0.516917 -0.364822 -0.121322 -0.072145 -0.0962189 -0.0144445 -0.0365654 -0.269433 -0.309135 -0.307968 -0.317122 -0.367021 -0.312724 0.155668 0.630231 -0.127052 -0.0369007 -0.0962595 -0.120612 -0.0260184 0.120755      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0      0
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

