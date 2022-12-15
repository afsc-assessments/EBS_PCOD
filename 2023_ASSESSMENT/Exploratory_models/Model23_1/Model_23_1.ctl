#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod23.dat // Model_23_1.ctl
0  # 0 means do not read wtatage.ss; 1 means read and use wtatage.ss and also read and use growth parameters
1  #_N_Growth_Patterns (Growth Patterns, Morphs, Bio Patterns, GP are terms used interchangeably in SS3)
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
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
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
1 #_fecundity_at_length option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=female-to-male age-specific fxn; -1=male-to-female age-specific fxn
1 #_parameter_offset_approach for M, G, CV_G:  1- direct, no offset**; 2- male=fem_parm*exp(male_parm); 3: male=female*exp(parm) then old=young*exp(parm)
#_** in option 1, any male parameter with value = 0.0 and phase <0 is set equal to female parameter
#
#_growth_parms
#_ LO HI INIT PRIOR PR_SD PR_type PHASE env_var&link dev_link dev_minyr dev_maxyr dev_PH Block Block_Fxn
# Sex: 1  BioPattern: 1  NatMort
 0 1 0.344251 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 20 17.7127 0 0 0 2 0 1 1977 2022 2 0 0 # L_at_Amin_Fem_GP_1
 60 150 103.748 0 0 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.159427 0 0 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 1.12389 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 10 3.38202 0 0 0 2 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 0 20 10.7459 0 0 0 2 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
# Sex: 1  BioPattern: 1  WtLen
 -10 10 5.40706e-06 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_1_Fem_GP_1
 -10 10 3.19601 0 0 0 -1 0 0 0 0 0 0 0 # Wtlen_2_Fem_GP_1
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
 1e-06 10 0.1804 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 -10 10 0.338186 0 0 0 2 # AgeKeyParm2_BLK2delta_1977
 -10 10 0.902486 0 0 0 2 # AgeKeyParm3_BLK2delta_1977
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
            12            16        13.092             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.994424 0 -1 0 1 # SR_regime_BLK1add_1976
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 0 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1900 #_last_yr_nobias_adj_in_MPD; begin of ramp
 1901 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2020 #_last_yr_fullbias_adj_in_MPD
 2021 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
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
#  1957E 1958E 1959E 1960E 1961E 1962E 1963E 1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975E 1976E 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021F 2022F 2023F 2024F 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F 2034F 2035F 2036F 2037F
#  -0.00794797 -0.00500485 -0.00805924 -0.013423 -0.0219699 -0.0353662 -0.0564016 -0.0886394 -0.136166 -0.202769 -0.289854 -0.393464 -0.500721 -0.584848 -0.595714 -0.44632 -0.0306151 0.325989 0.0427596 0.262631 1.06103 0.773087 0.686604 -1.79655 -0.676042 0.990885 -0.780386 0.822914 -0.0345409 -0.723519 -0.90747 -0.289973 0.447805 0.3244 -0.01053 0.842726 -0.136017 -0.336921 -0.41791 0.694909 -0.21333 -0.232848 0.611764 0.10311 -0.358383 -0.381625 -0.346309 -0.704728 -0.439444 0.463357 -0.11391 1.10394 -0.604876 0.515471 0.959369 0.452933 0.944981 -0.460444 0.0832339 -0.944899 -0.518806 0.645292 -0.790208 -0.308137 -0.195083 0.109532 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
 1999 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
3 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 1
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 1 0.165054 0 0 0 1 # InitF_seas_1_flt_1trawl
#
# F rates by fleet x season
# Yr:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# trawl 0.222531 0.264427 0.190577 0.117638 0.12473 0.0980017 0.120395 0.117765 0.129017 0.133595 0.129283 0.265894 0.240527 0.215725 0.279774 0.203607 0.2409 0.230698 0.272347 0.251684 0.252701 0.195256 0.166545 0.164113 0.107143 0.123985 0.12143 0.136552 0.138882 0.157086 0.147714 0.115448 0.140081 0.133923 0.18483 0.198664 0.185575 0.153518 0.139567 0.141329 0.117457 0.0918049 0.0807109 0.0878444 0.0848762 0.0957306 0.133046 0.129825 0.123713 0.123738 0.130837 0.138553 0.143276 0.14526 0.145778 0.145748 0.145605 0.145494 0.145435 0.145411 0.145405
# longline 0.00752511 0.0261375 0.0142638 0.0216683 0.0130442 0.00703836 0.00815455 0.0298756 0.0437782 0.03272 0.0592231 0.00306334 0.0180859 0.0698924 0.150368 0.203054 0.130368 0.188592 0.225194 0.198963 0.267631 0.218911 0.231133 0.216439 0.211253 0.226069 0.238663 0.229782 0.256391 0.251527 0.228882 0.301548 0.346153 0.250266 0.309563 0.288891 0.257349 0.250173 0.221897 0.192899 0.162914 0.130253 0.128021 0.121637 0.110278 0.127341 0.127998 0.124899 0.11902 0.119043 0.125873 0.133296 0.13784 0.139749 0.140247 0.140218 0.140081 0.139974 0.139917 0.139894 0.139888
# pot 0.000270054 0 0 0 0 0 2.84207e-05 0 0 8.53143e-05 1.38347e-06 0.000423359 0.000211776 0.00223525 0.00698978 0.0216503 0.00673775 0.0236507 0.054031 0.0771608 0.0586353 0.0396347 0.0413664 0.0522477 0.0470206 0.0401914 0.0528593 0.043574 0.0448146 0.0568558 0.0591302 0.0685652 0.0604246 0.0776373 0.0945434 0.083558 0.0771516 0.0954289 0.0826265 0.0879121 0.0746626 0.0589479 0.0653238 0.0607069 0.0553545 0.0833487 0.0328722 0.0320765 0.0305665 0.0305726 0.0323265 0.034233 0.0354 0.0358902 0.0360181 0.0360107 0.0359754 0.0359479 0.0359333 0.0359274 0.0359259
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         4         1         0         0         0         0  #  survey
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
            -3             3     0             0             0             0          1          0          0          0          0          0          0          0  #  LnQ_base_survey(4)
#_no timevary Q parameters
#
#_size_selex_patterns
#Pattern:_0;  parm=0; selex=1.0 for all sizes
#Pattern:_1;  parm=2; logistic; with 95% width specification
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
#Pattern:_2;  parm=6; double_normal with sel(minL) and sel(maxL), using joiners, back compatibile version of 24 with 3.30.18 and older
#Pattern:_25; parm=3; exponential-logistic in length
#Pattern:_27; parm=special+3; cubic spline in length; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=special+3+2; cubic spline; like 27, with 2 additional param for scaling (average over bin range)
#_discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead;_4=define_dome-shaped_retention
#_Pattern Discard Male Special
 24 0 0 0 # 1 trawl
 24 0 0 0 # 2 longline
 24 0 0 0 # 3 pot
 0 0 0 0 # 4 survey
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
#Pattern:_41; parm=2+nages+1; // like 17, with 2 additional param for scaling (average over bin range)
#Pattern:_18; parm=8; double logistic - smooth transition
#Pattern:_19; parm=6; simple 4-parm double logistic with starting age
#Pattern:_20; parm=6; double_normal,using joiners
#Pattern:_26; parm=3; exponential-logistic in age
#Pattern:_27; parm=3+special; cubic spline in age; parm1==1 resets knots; parm1==2 resets all 
#Pattern:_42; parm=2+special+3; // cubic spline; with 2 additional param for scaling (average over bin range)
#Age patterns entered with value >100 create Min_selage from first digit and pattern from remainder
#_Pattern Discard Male Special
 0 0 0 0 # 1 trawl
 0 0 0 0 # 2 longline
 0 0 0 0 # 3 pot
20 0 0 0 # 4 survey
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   trawl LenSelex
            10            90             80          -999          -999             0          3          0          0       1977       2022          0          0          0  #  Size_DblN_peak_trawl(1)
           -10            10      0.225308          -999          -999             0          3          0          2       1977       2022          3          0          0  #  Size_DblN_top_logit_trawl(1)
           -10            10       6.54254          -999          -999             0          3          0          2       1977       2022          3          0          0  #  Size_DblN_ascend_se_trawl(1)
           -10            10       3.39272          -999          -999             0          3          0          0       1977       2022          0          0          0  #  Size_DblN_descend_se_trawl(1)
           -10            10           -10          -999          -999             0         -3          0          0       1977       2022          0          0          0  #  Size_DblN_start_logit_trawl(1)
           -10            10            10          -999          -999             0         -3          0          0       1977       2022          0          0          0  #  Size_DblN_end_logit_trawl(1)
# 2   longline LenSelex
            10            90            60          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_peak_longline(2)
           -10            10    -0.0367334          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_longline(2)
           -10            10       5.26745          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Size_DblN_ascend_se_longline(2)
           -10            10       -3.0761          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Size_DblN_descend_se_longline(2)
           -10            10           -10          -999          -999             0         -3          0          0       1978       2022          0          0          0  #  Size_DblN_start_logit_longline(2)
           -10            10            10          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Size_DblN_end_logit_longline(2)
# 3   pot LenSelex
            10            90            60          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_peak_pot(3)
           -10            10      0.728158          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_pot(3)
           -10            10       5.05058          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Size_DblN_ascend_se_pot(3)
           -10            10       3.22019          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Size_DblN_descend_se_pot(3)
           -10            10           -10          -999          -999             0         -3          0          0       1991       2022          0          0          0  #  Size_DblN_start_logit_pot(3)
           -10            10            10          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Size_DblN_end_logit_pot(3)
# 4   survey LenSelex
            1             10             1          -999          -999             0          3          0          1       1982       2022          3          0          0  #  Size_DblN_peak_survey(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_survey(4)
           -10            10       3.66068          -999          -999             0          3          0          2       1982       2022          3          0          0  #  Size_DblN_ascend_se_survey(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_survey(4)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_survey(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_survey(4)
# 1   trawl AgeSelex
# 2   longline AgeSelex
# 3   pot AgeSelex
# 4   survey AgeSelex
#_Dirichlet and/or MV Tweedie parameters for composition error
#_multiple_fleets_can_refer_to_same_parm;_but_list_cannot_have_gaps
           -10            10       9.96839             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P1
           -10            10       9.99767             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P2
           -10            10       9.98905             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P3
           -10            10       9.97179             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P4
           -10            10       0.22267             0          -999             0          4          0          0          0          0          0          0          0  #  ln(DM_theta)_Age_P5
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10          0.2            0             0             0      -9  # Size_DblN_top_logit_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_top_logit_trawl(1)_dev_autocorr
         1e-06            10        0.2             0             0             0      -9  # Size_DblN_ascend_se_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_trawl(1)_dev_autocorr
         1e-06            10        0.2             0             0             0      -9  # Size_DblN_peak_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_peak_survey(4)_dev_autocorr
         1e-06            10         0.771             0             0             0      -9  # Size_DblN_ascend_se_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_survey(4)_dev_autocorr
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
#      1     2     1     0     0     0     0     1     1  1977  2022     2 -0.803179 -0.0698729 0.333467 -0.125288 -1.87447 -1.84161 0.456377 -0.466575 -2.19186 -0.16896 -0.466097 -0.636364 -1.74474 -0.78502 -0.49217 -0.656444 0.624311 -0.603578 -0.841776 -1.05676 -0.667224 -0.68615 -0.244399 1.0312 -0.45103 0.178207 0.134703 0.328842 0.97045 0.985372 1.15874 1.01822 1.62372 0.207118 0.262019 1.06031 0.153847 0.61352 -0.0842878 2.98725 -0.263247 0.883157 0.110241 0.284137 -0.28158 2.10494
#      1    16     3     2     3     0     0     0     0     0     0     0
#      1    17     4     2     3     0     0     0     0     0     0     0
#      2     4     5     1     1     0     0     0     0     0     0     0
#      5     2     6     0     0     0     0     2     2  1977  2022     3 -1.88805e-06 -4.13105e-07 -1.01837e-07 -7.87944e-09 3.26812e-08 8.03758e-08 -7.55451e-08 -1.08377e-07 4.97564e-07 7.20269e-07 2.21483e-07 -2.91805e-06 -2.78292e-06 -2.78364e-06 -8.59498e-06 9.25776e-07 2.80427e-06 -2.90774e-06 -4.57053e-06 -1.93689e-08 -7.0764e-07 3.40639e-06 2.63223e-06 2.924e-06 3.19243e-06 1.06449e-06 8.65671e-07 3.17454e-06 5.13378e-07 2.03887e-06 2.32784e-06 1.8018e-06 1.91954e-07 7.21196e-07 -1.51188e-07 2.2466e-07 -5.70048e-07 -2.97963e-07 -3.7762e-07 5.89313e-07 2.68843e-07 1.08669e-07 1.06605e-06 1.3768e-06 3.27041e-06 2.04345e-06
#      5     3     8     0     0     0     0     3     2  1977  2022     3 0.39827 -0.224854 -0.512987 0.133542 0.250324 -0.178286 -0.112975 1.36258 1.70129 1.93159  1.187 0.851096 0.0991418 -1.49238 -0.885414 0.513065 -0.297454 -0.0784753 0.769852 -0.858311 -0.121775 -1.4507 -0.523851 -0.335106 -1.41298 0.722733 -0.726133 0.556926 -0.345249 -0.158885 0.5703 1.30013 0.257881 0.66587 0.264592 -0.104316 0.550713 0.465624 -0.693826 -1.48733 -1.33538 -0.20045 -0.410897 1.70504 -1.30666 -1.00289
#      5    19    10     0     0     0     0     4     1  1982  2022     3 -0.935903 -0.755726 1.10265 0.0168105 -1.01379 -0.474417 0.713762 3.18216 -0.891698 1.4793 -0.45094 -0.128711 -0.651053 -0.261467 -0.349912 -0.510631 -0.0546416 -0.206576 0.0902386 -0.986769 -0.0290182 -0.540139 0.00830243 -0.410458 -0.617348 -0.794349 0.60348 0.480728 1.43733 -0.586159 -0.498012 2.02152 -0.431234 0.25996 0.0750639 1.88358 -0.0644245 -0.649441      0 -0.842302 -0.221522
#      5    21    12     0     0     0     0     5     2  1982  2022     3 -0.692384 0.399637 1.42322 0.798473 -0.0717583 0.217114 0.76195 3.02311 0.0578017 2.37631 0.206721 1.07506 -0.266528 -0.248184 -0.465557 -0.303822 -0.164569 -0.502894 -0.409842 -0.567638 -0.0268402 -0.485131 -0.245792 -0.599286 -1.13358 -1.00573 -0.338527 -0.275134 0.0685777 -0.776733 -0.67315 1.36914 -0.24118 -0.235249 -0.382906 -0.355858 -0.590232 -0.330763      0 -0.470551 0.0825324
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
      4      2         1
      4      3         1
      4      4         1
      5      1         1
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
#  0 #_CPUE/survey:_2
#  0 #_CPUE/survey:_3
#  1 #_CPUE/survey:_4
#  1 #_lencomp:_1
#  1 #_lencomp:_2
#  1 #_lencomp:_3
#  1 #_lencomp:_4
#  0 #_agecomp:_1
#  0 #_agecomp:_2
#  0 #_agecomp:_3
#  1 #_agecomp:_4
#  1 #_init_equ_catch1
#  1 #_init_equ_catch2
#  1 #_init_equ_catch3
#  1 #_init_equ_catch4
#  1 #_recruitments
#  1 #_parameter-priors
#  1 #_parameter-dev-vectors
#  1 #_crashPenLambda
#  1 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

