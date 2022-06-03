#V3.30.18.00;_safe;_compile_date:_Sep 30 2021;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_12.3
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod22_MAY.dat // Model_19_12a.ctl
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS)
1 #_N_platoons_Within_GrowthPattern 
#_Cond 1 #_Platoon_within/between_stdev_ratio (no read if N_platoons=1)
#_Cond  1 #vector_platoon_dist_(-1_in_first_val_gives_normal_approx)
#
4 # recr_dist_method for parameters:  2=main effects for GP, Area, Settle timing; 3=each Settle entity; 4=none (only when N_GP*Nsettle*pop==1)
1 # not yet implemented; Future usage: Spawner-Recruitment: 1=global; 2=by area
1 #  number of recruitment settlement assignments 
0 # unused option
#GPattern month  area  age (for each settlement assignment)
 1 1 1 0
#
#_Cond 0 # N_movement_definitions goes here if Nareas > 1
#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10
#
3 #_Nblock_Patterns
 1 1 1 #_blocks_per_pattern 
# begin and end years of blocks
 1976 1976
 1977 2007
 1977 1980
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
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity
  #_no additional input for selected M option; read 1P per morph
#
2 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_specific_K_incr; 4=age_specific_K_decr; 5=age_specific_K_each; 6=NA; 7=NA; 8=growth cessation
1.5 #_Age(post-settlement)_for_L1;linear growth below this
999 #_Growth_Age_for_L2 (999 to use as Linf)
-999 #_exponential decay for growth above maxage (value should approx initial Z; -999 replicates 3.24; -998 to not allow growth above maxage)
0  #_placeholder for future growth feature
#
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
2 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
#
1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=disabled; 6=read length-maturity
1 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
 0.1 1 0.449813 0 0 0 6 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 20 16.8921 0 0 0 5 0 1 1977 2021 5 0 0 # L_at_Amin_Fem_GP_1
 60 150 107.112 0 0 0 5 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.165443 0 0 0 5 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 1.03042 0 0 0 5 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 10 3.41948 0 0 0 5 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 0 20 10.0504 0 0 0 5 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -10 10 5.30606e-06 0 0 0 -1 202 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 -10 10 3.19723 0 0 0 -1 203 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
# Sex: 1  BioPattern: 1  Maturity&Fecundity
 -10 100 58 0 0 0 -1 0 0 0 0 0 0 0 # Mat50%_Fem_GP_1
 -10 10 -0.132 0 0 0 -1 0 0 0 0 0 0 0 # Mat_slope_Fem_GP_1
 -10 10 1 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_inter_Fem_GP_1
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # Eggs/kg_slope_wt_Fem_GP_1
# Hermaphroditism
#  Recruitment Distribution  
#  Cohort growth dev base
 0.1 10 1 1 1 0 -1 0 0 0 0 0 0 0 # CohortGrowDev
#  Movement
#  Age Error from parameters
 -10 10 1 0 0 0 -1 0 0 0 0 0 0 0 # AgeKeyParm1
 -10 10 0 0 0 0 -1 0 0 0 0 0 2 3 # AgeKeyParm2
 -10 10 0 0 0 0 -1 0 0 0 0 0 2 3 # AgeKeyParm3
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # AgeKeyParm4
 -10 10 0.085 0 0 0 -1 0 0 0 0 0 0 0 # AgeKeyParm5
 -10 10 1.692 0 0 0 -1 0 0 0 0 0 0 0 # AgeKeyParm6
 -10 10 0 0 0 0 -1 0 0 0 0 0 0 0 # AgeKeyParm7
#  catch multiplier
#  fraction female, by GP
 1e-06 0.999999 0.5 0.5 0.5 0 -99 0 0 0 0 0 0 0 # FracFemale_GP_1
#  M2 parameter for each predator fleet
#
# timevary MG parameters 
#_ LO HI INIT PRIOR PR_SD PR_type  PHASE
 1e-06 10 0.15 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 -10 10 1 0 0 -1 -1 # Wtlen_1_Fem_GP_1_ENV_add
 -10 10 1 0 0 -1 -1 # Wtlen_2_Fem_GP_1_ENV_add
 -10 10 0.253727 0 0 0 1 # AgeKeyParm2_BLK2delta_1977
 -10 10 0.980583 0 0 0 1 # AgeKeyParm3_BLK2delta_1977
# info on dev vectors created for MGparms are reported with other devs after tag parameter section 
#
#_seasonal_effects_on_biology_parms
 0 0 0 0 0 0 0 0 0 0 #_femwtlen1,femwtlen2,mat1,mat2,fec1,fec2,Malewtlen1,malewtlen2,L1,K
#_ LO HI INIT PRIOR PR_SD PR_type PHASE
#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters
#
3 #_Spawner-Recruitment; Options: 1=NA; 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepherd_3Parm; 9=RickerPower_3parm
0  # 0/1 to use steepness in initial equ recruitment calculation
0  #  future feature:  0/1 to make realized sigmaR a function of SR curvature
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn #  parm_name
            12            16       13.8512             0             0             0          3          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10      0.587955             0             0             0          3          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.885813 0 -1 0 1 # SR_regime_BLK1add_1976
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 -1 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1900 #_last_yr_nobias_adj_in_MPD; begin of ramp
 1901 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2020 #_last_yr_fullbias_adj_in_MPD
 2021 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS sets bias_adj to 0.0 for fcast yrs)
 1 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
 0 #_period of cycles in recruitment (N parms read below)
 -5 #min rec_dev
 5 #max rec_dev
 0 #_read_recdevs
#_end of advanced SR options
#
#_placeholder for full parameter lines for recruitment cycles
# read specified recr devs
#_Yr Input_value
#
# all recruitment deviations
#  1957E 1958E 1959E 1960E 1961E 1962E 1963E 1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975E 1976E 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021F 2022F 2023F 2024F 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F
#  0.00157583 0.00109734 0.00117391 0.00107377 6.44106e-05 -0.00363764 -0.0144047 -0.0387545 -0.088159 -0.175724 -0.306843 -0.466455 -0.621598 -0.725085 -0.709505 -0.475665 0.310542 0.896238 0.148194 1.20784 1.13886 0.451005 0.655646 -0.347983 -0.354613 1.20607 -0.576382 0.649189 0.050472 -0.481162 -0.759096 -0.268695 0.455631 0.0944495 -0.0659461 0.60132 -0.585792 -0.555546 -0.359487 0.651891 0.00932623 -0.087604 0.286539 0.0708908 -0.779639 -0.467887 -0.67065 -0.967255 -0.834075 0.514486 -0.0102893 0.920189 -0.52583 0.272568 0.954552 0.181325 1.0134 -0.51433 -0.23145 -0.890951 -0.895978 0.735158 0.191428 0.126244 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
-1999 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
3 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 1
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 1 0.118724 0 0 0 1 # InitF_seas_1_flt_1Fishery
#
# F rates by fleet x season
# Yr:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# Fishery 0.148862 0.172862 0.0998817 0.0620718 0.0664678 0.0578808 0.0798549 0.101805 0.114171 0.100311 0.120355 0.164818 0.166577 0.196741 0.310645 0.295045 0.21962 0.290485 0.370846 0.378987 0.485938 0.409684 0.406356 0.386559 0.318246 0.309175 0.330904 0.336196 0.38175 0.43856 0.433881 0.521552 0.613292 0.492741 0.633502 0.581335 0.499225 0.50562 0.489094 0.454748 0.371642 0.266064 0.24963 0.25082 0.259027 0.438748 0.438748 0.438748 0.438748 0.438748 0.438748 0.438748 0.437929 0.436489 0.436151 0.436158 0.436216
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         2         1         0         1         0         0  #  Survey
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
          -0.2           0.2     -0.123982             0             0             0          4          0          0          0          0          0          0          0  #  LnQ_base_Survey(2)
             0            10      0.132409             0             0             0          7          0          0          0          0          0          0          0  #  Q_extraSD_Survey(2)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
#Pattern:_2;  parm=6; modification of pattern 24 with improved sex-specific offset
#Pattern:_5;  parm=2; mirror another size selex; PARMS pick the min-max bin to mirror
#Pattern:_11; parm=2; selex=1.0  for specified min-max population length bin range
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_6;  parm=2+special; non-parm len selex
#Pattern:_43; parm=2+special+2;  like 6, with 2 additional param for scaling (average over bin range)
#Pattern:_8;  parm=8; double_logistic with smooth transitions and constant above Linf option
#Pattern:_9;  parm=6; simple 4-parm double logistic with starting length; parm 5 is first length; parm 6=1 does desc as offset
#Pattern:_21; parm=2+special; non-parm len selex, read as pairs of size, then selex
#Pattern:_22; parm=4; double_normal as in CASAL
#Pattern:_23; parm=6; double_normal where final value is directly equal to sp(6) so can be >1.0
#Pattern:_24; parm=6; double_normal with sel(minL) and sel(maxL), using joiners
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 0 0 0 # 1 Fishery
 0 0 0 0 # 2 Survey
#
#_age_selex_patterns
#Pattern:_0; parm=0; selex=1.0 for ages 0 to maxage
#Pattern:_10; parm=0; selex=1.0 for ages 1 to maxage
#Pattern:_11; parm=2; selex=1.0  for specified min-max age
#Pattern:_12; parm=2; age logistic
#Pattern:_13; parm=8; age double logistic
#Pattern:_14; parm=nages+1; age empirical
#Pattern:_15; parm=0; mirror another age or length selex
#Pattern:_16; parm=2; Coleraine - Gaussian
#Pattern:_17; parm=nages+1; empirical as random walk  N parameters to read can be overridden by setting special to non-zero
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 0 0 0 0 # 1 Fishery
 20 0 0 0 # 2 Survey
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   Fishery LenSelex
            10            80       73.8429          -999          -999             0          1          0          2       1977       2021          1          0          0  #  Size_DblN_peak_Fishery(1)
           -10            10      -3.59478          -999          -999             0          1          0          2       1977       2021          1          0          0  #  Size_DblN_top_logit_Fishery(1)
           -10            10       5.97149          -999          -999             0          1          0          2       1977       2021          1          0          0  #  Size_DblN_ascend_se_Fishery(1)
           -10            10      -9.79532          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Fishery(1)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Fishery(1)
           -10            10       2.26663          -999          -999             0          1          0          2       1977       2021          1          0          0  #  Size_DblN_end_logit_Fishery(1)
# 2   Survey LenSelex
# 1   Fishery AgeSelex
# 2   Survey AgeSelex
           0.1            10       3.75495          -999          -999             0          1          0          2       1982       2021          1          0          0  #  Age_DblN_peak_Survey(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_Survey(2)
           -10             5       2.30857          -999          -999             0          1          0          2       1982       2021          1          0          0  #  Age_DblN_ascend_se_Survey(2)
           -10            10     -0.436119          -999          -999             0          1          0          0          0          0          0          0          0  #  Age_DblN_descend_se_Survey(2)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_Survey(2)
           -10            10      -5.37357          -999          -999             0          1          0          0          0          0          0          0          0  #  Age_DblN_end_logit_Survey(2)
#_Dirichlet parameters
#_multiple_fleets_can_refer_to_same_parm;_but_list_cannot_have_gaps
           -10            10      0.778284             0          -999             0          4          0          0          0          0          0          0          0  #  ln(DM_theta)_1
           -10            10       9.94258             0          -999             0          4          0          0          0          0          0          0          0  #  ln(DM_theta)_2
           -10            10      0.343977             0          -999             0          4          0          0          0          0          0          0          0  #  ln(DM_theta)_3
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10          0.01             0             0             0      -9  # Size_DblN_peak_Fishery(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_peak_Fishery(1)_dev_autocorr
         1e-06            10           0.3             0             0             0      -9  # Size_DblN_top_logit_Fishery(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_top_logit_Fishery(1)_dev_autocorr
         1e-06            10          0.28             0             0             0      -9  # Size_DblN_ascend_se_Fishery(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_Fishery(1)_dev_autocorr
         1e-06            10          0.05             0             0             0      -9  # Size_DblN_end_logit_Fishery(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_end_logit_Fishery(1)_dev_autocorr
         1e-06            10         0.001             0             0             0      -9  # Age_DblN_peak_Survey(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_Survey(2)_dev_autocorr
         1e-06            10          0.82             0             0             0      -9  # Age_DblN_ascend_se_Survey(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_Survey(2)_dev_autocorr
# info on dev vectors created for selex parms are reported with other devs after tag parameter section 
#
0   #  use 2D_AR1 selectivity(0/1)
#_no 2D_AR1 selex offset used
#
# Tag loss and Tag reporting parameters go next
0  # TG_custom:  0=no read and autogen if tag data exist; 1=read
#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters
#
# deviation vectors for timevary parameters
#  base   base first block   block  env  env   dev   dev   dev   dev   dev
#  type  index  parm trend pattern link  var  vectr link _mnyr  mxyr phase  dev_vector
#      1     2     1     0     0     0     0     1     1  1977  2021     5 -0.937035 -0.330887 -1.04696 0.154386 -0.118958 -0.517987 0.528828 0.440314 -1.03957 0.271073 0.135685 0.145816 -0.518539 0.213793 -0.38929 0.130774 0.837452 -0.744372 -1.11547 0.0141557 0.0830724 -0.888187 -0.763751 -0.059814 -0.347151 0.385013 0.37806 0.571892 0.998094 1.32686 1.85484 1.12265 -0.95215 -0.37799 -1.18737 0.968974 -0.215745 -0.549871 0.238982 1.31876 0.53707 2.02379 1.04587 0.43206 -4.05731
#      1     8     3     0     0     2     2     0     0     0     0     0
#      1     9     4     0     0     2     3     0     0     0     0     0
#      1    16     5     2     3     0     0     0     0     0     0     0
#      1    17     6     2     3     0     0     0     0     0     0     0
#      2     4     7     1     1     0     0     0     0     0     0     0
#      5     1     8     0     0     0     0     2     2  1977  2021     1 -0.00523835 -0.00669169 -0.010387 -0.00154865 -0.00413866 0.00719862 0.00188961 -0.00270062 -0.0263067 -0.017494 0.0270927 0.0251149 0.0204341 0.0551206 -0.00184356 0.0300357 -0.0118918 -0.0110347 -0.0425039 0.0421149 0.0600207 -0.0544832 0.00884884 -0.0181247 0.0427331 -0.0603345 -0.0356527 -0.0993839 -0.0655465 -0.0246741 -0.00898359 0.000898307 -0.0591458 0.0761364 -0.0387179 0.0708134 -0.00691697 0.0523711 0.0169109 0.0143128 0.0309651 0.0245592 -0.0117952 0.0231717 -0.00524107
#      5     2    10     0     0     0     0     3     2  1977  2021     1 -0.0974577 -0.00674507 -0.131924 0.10816 -0.00844753 0.0370316 -0.00867621 -0.111294 -0.199807 -0.175931 -0.0535394 0.269209 0.175422 0.239015 0.122114 0.172361 -0.00873086 -0.00767879 -0.296737 0.0747793 0.355764 -0.0080191 0.294864 -0.00875622 0.147291 -0.422456 -0.0180478 -0.479784 -0.00765471 -0.293042 -0.426267 -0.305854 -0.00771664 0.312331 -0.0084062 0.017173 -0.00438583 0.104213 0.0291819 0.131642 0.334927 0.228052 -0.0088001 -0.0356951 -0.00934867
#      5     3    12     0     0     0     0     4     2  1977  2021     1 0.674376 -0.343261 -0.161439 1.25735 1.39246 0.203704 0.439912 1.72274 1.54535 2.36117 1.16408 1.50366 0.777572 -0.905168 -0.47392 0.0861113 0.331238 0.0583107 0.49599 -0.424771 -0.207583 -0.735426 -0.61479 -0.528684 -0.801484 0.269004 -0.111156 0.28665 -0.0603132 -0.297309 -0.089395 -0.00501916 -0.405624 -0.234279 -0.494609 -0.411707 -0.0424466 -0.443852 -1.13329 -1.43583 -1.50956 -0.78966 -0.709423 0.255862 -1.45522
#      5     6    14     0     0     0     0     5     2  1977  2021     1 -0.0213029 -0.0254762 -0.0349546 0.013343 -0.0162298 0.0509786 0.0151736 0.0087374 -0.0578057 -0.0455119 0.271108 0.221607 0.205017 0.291465 0.100643 -0.0335184 -0.000114796 -0.0561535 -0.155051 0.572953 0.103741 -0.181918 -0.0410819 0.0606726 0.150717 -0.330726 -0.110213 -0.322622 -0.162217 0.541349 0.344873 -0.0143979 -0.379195 0.00973999 -0.029208 -0.0805077 -0.237395 -0.365798 -0.263209 -0.150981 0.0261858 0.116652 -0.212605 0.232537 -0.00939489
#      5     7    16     0     0     0     0     6     2  1982  2021     1 0.00391795 0.00226017 0.00325665 -0.0025113 -0.00612481 -0.00250333 -0.0033059 0.0106705 0.00112213 -0.00159141 -0.00421723 -0.00439131 -0.00142601 -0.00472698 -0.00356091 -0.000188931 -0.0029365 0.00403821 0.00625616 -0.0034208 0.000201553 -0.00176613 -0.00148258 -0.00245332 -0.00502611 -0.00580786 0.00406595 0.00117601 0.00153009 0.000659744 0.000292597 0.00667815 0.00419712 -4.03607e-06 0.00613652 0.000506625 0.000735809 -0.00552865      0 0.00529062
#      5     9    18     0     0     0     0     7     2  1982  2021     1 -1.09239 -0.689597 -0.766092 1.3216 0.253351 0.313774 -0.907913 -1.49188 0.0750179 0.324976 1.30672 1.34599 0.616869 0.0679434 -0.882832 -0.78526 -1.08148 -0.98027 -0.744165 1.38579 -0.622119 0.628768 -0.0790682 0.824908 1.74419 1.83983 -0.654189 0.653745 -0.88624 0.949785 0.344822 -1.1465 -0.211198 -0.334742 -0.670822 0.450612 -0.614392  1.734      0 -1.54165
     #
# Input variance adjustments factors: 
 #_1=add_to_survey_CV
 #_2=add_to_discard_stddev
 #_3=add_to_bodywt_CV
 #_4=mult_by_lencomp_N
 #_5=mult_by_agecomp_N
 #_6=mult_by_size-at-age_N
 #_7=mult_by_generalized_sizecomp
#_Factor  Fleet  Value
      4      1         1
      4      2         8
      5      2         1
 -9999   1    0  # terminator
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 0 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
-9999  1  1  1  1  #  terminator
#
# lambdas (for info only; columns are phases)
#  0 #_CPUE/survey:_1
#  1 #_CPUE/survey:_2
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  0 #_agecomp:_1
#  1 #_agecomp:_2
#  1 #_init_equ_catch1
#  1 #_init_equ_catch2
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

