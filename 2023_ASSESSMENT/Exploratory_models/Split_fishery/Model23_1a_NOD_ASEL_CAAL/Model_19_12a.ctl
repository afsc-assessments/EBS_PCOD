#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod23b.dat // Model_19_12a.ctl
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
 1964 2006
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
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
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
 0 1 0.514165 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 25 17.005 0 0 0 2 0 5 1977 2022 2 0 0 # L_at_Amin_Fem_GP_1
 80 150 113.277 0 0 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 0.3 0.20248 0 0 0 2 0 5 1977 2022 2 0 0 # VonBert_K_Fem_GP_1
 0 1 0.731369 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 0.4 0.14758 0 0 0 2 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0 0.2 0.0289658 0 0 0 2 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
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
 1e-06 10 0.3 0 0 0 -1 # VonBert_K_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # VonBert_K_Fem_GP_1_dev_autocorr
 -10 10 0.152076 0 0 0 2 # AgeKeyParm2_BLK2delta_1964
 -10 10 1.82777 0 0 0 2 # AgeKeyParm3_BLK2delta_1964
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
            12            16       14.0848             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
#_no timevary SR parameters
3 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 -1 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1945.3 #_last_yr_nobias_adj_in_MPD; begin of ramp
 1980.5 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2016.9 #_last_yr_fullbias_adj_in_MPD
 2083 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.9824 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
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
#  -0.0153271 -0.0244918 -0.0382124 -0.0587451 -0.0884772 -0.129852 -0.185469 -0.352018 -0.445786 -0.564217 -0.708295 -0.86482 -1.03031 -1.18206 -1.26302 -1.1538 -0.42361 -0.0983161 -0.544858 0.373392 0.768915 0.689012 0.30875 -1.73925 -0.521122 0.693688 -0.812672 0.508888 0.139868 -0.276714 -0.266535 -0.0055284 0.185012 -0.00567681 -0.231831 0.382389 -0.318541 -0.378678 -0.266956 0.323192 0.116894 -0.200577 0.323587 0.0435083 -0.411303 -0.391552 -0.513926 -0.967521 -0.321254 0.272786 -0.0271865 0.633072 -0.295359 0.277711 0.701519 0.301024 0.689989 -0.215964 -0.214083 -0.88012 -0.56283 0.395023 -0.914306 -0.263121 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 0.2 0.00866368 0 0 0 1 # InitF_seas_1_flt_1trawl
#
# F rates by fleet x season
# Yr:  1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# trawl 0.0118079 0.013237 0.0167345 0.0305417 0.0590323 0.0562684 0.0877314 0.0596499 0.0659916 0.0963561 0.135865 0.131658 0.147683 0.078216 0.0925391 0.0632631 0.0341057 0.0573949 0.100634 0.102716 0.0910881 0.102061 0.0905685 0.125212 0.245916 0.252896 0.271546 0.221885 0.157219 0.156414 0.130704 0.181666 0.239652 0.237691 0.170394 0.168899 0.142478 0.147623 0.109811 0.136954 0.128189 0.12826 0.148201 0.12957 0.0942081 0.100486 0.108167 0.129524 0.229646 0.154108 0.168445 0.200266 0.220706 0.135309 0.098421 0.0935271 0.131857 0.111023 0.12481 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876 0.192876
# longline 6.2135e-05 0 3.63288e-06 4.98598e-05 0 3.42184e-05 1.11118e-05 0.00110166 0.00205753 0.00120913 0.000191498 0.00298268 0.00337625 0.00367039 0.0100397 0.00520656 0.00930009 0.0082458 0.00802108 0.00845477 0.0320012 0.0455139 0.0374082 0.0527631 0.00274574 0.0146347 0.0579078 0.139373 0.185774 0.103439 0.155298 0.196889 0.20981 0.253448 0.20558 0.216109 0.21858 0.19958 0.179605 0.203586 0.196034 0.221819 0.239054 0.238126 0.324283 0.39357 0.361597 0.292102 0.33966 0.237579 0.31091 0.295806 0.248859 0.193818 0.121202 0.126699 0.120713 0.118588 0.132618 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442 0.214442
# pot 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000146807 0 0 0 0 0 2.36665e-05 0 0 0.000108149 1.43867e-06 0.000477581 0.000223544 0.0020909 0.00631783 0.0187968 0.00556287 0.0192378 0.0493352 0.0857066 0.0579747 0.040128 0.0442196 0.0591394 0.0467943 0.0370383 0.0526116 0.041548 0.04148 0.0562889 0.0623727 0.0759934 0.0800386 0.116559 0.109509 0.109757 0.083652 0.127344 0.118714 0.102458 0.0911461 0.0622126 0.0697671 0.0684306 0.0676706 0.108603 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662 0.0624662
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
            -3             3             0             0             0             0         -8          0          0          0          0          0          0          0  #  LnQ_base_survey(4)
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
 0 0 0 0 # 1 trawl
 0 0 0 0 # 2 longline
 0 0 0 0 # 3 pot
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
 20 0 0 0 # 1 trawl
 20 0 0 0 # 2 longline
 20 0 0 0 # 3 pot
 20 0 0 0 # 4 survey
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   trawl LenSelex
# 2   longline LenSelex
# 3   pot LenSelex
# 4   survey LenSelex
# 1   trawl AgeSelex
             0            12       5.91811          -999          -999             0          4          0          1       1977       2022          5          0          0  #  Age_DblN_peak_trawl(1)
           -10            10       8.36465          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_trawl(1)
           -10            10        1.2325          -999          -999             0          4          0          2       1977       2022          5          0          0  #  Age_DblN_ascend_se_trawl(1)
           -10            10     -0.197674          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_trawl(1)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_trawl(1)
           -10            10       7.48994          -999          -999             0          4          0          2        1977      2022          5          0          0  #  Age_DblN_end_logit_trawl(1)
# 2   longline AgeSelex
             0            12       5.08758          -999          -999             0          4          0          1       1978       2022          5          0          0  #  Age_DblN_peak_longline(2)
           -10            10            10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_longline(2)
           -10            10     -0.170367          -999          -999             0          4          0          2       1978       2022          5          0          0  #  Age_DblN_ascend_se_longline(2)
           -10            10             0          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_longline(2)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_longline(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_end_logit_longline(2)
# 3   pot AgeSelex
             0            12       5.52384          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_peak_pot(3)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_pot(3)
           -10            10     -0.239543          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_ascend_se_pot(3)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_pot(3)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_pot(3)
           -10            10       2.11189          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_pot(3)
# 4   survey AgeSelex
             0            12       4.27645          -999          -999             0          4          0          1       1982       2022          5          0          0  #  Age_DblN_peak_survey(4)
           -10            10        4.4472          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_survey(4)
           -10            10        2.0983          -999          -999             0          4          0          2       1982       2022          5          0          0  #  Age_DblN_ascend_se_survey(4)
           -10            10       1.09829          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_survey(4)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_start_logit_survey(4)
           -10            10      -0.27931          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_survey(4)
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_peak_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_trawl(1)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_ascend_se_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_trawl(1)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_peak_longline(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_longline(2)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_ascend_se_longline(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_longline(2)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_peak_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_survey(4)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_ascend_se_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_survey(4)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_ascend_se_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_survey(4)_dev_autocorr

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
#      1     2     1     0     0     0     0     1     5  1977  2022     2 0.00119655 0.161749 0.160091 -0.169273 -0.837481 -2.65188 0.493513 2.52684 -2.70702 0.92494 0.247446 -0.358932 -2.50952 -1.52848 -0.120785 -0.777207 -0.816711 0.491709 1.45604 -0.0272921 -1.20672 0.375665 -2.01123 0.454323 0.145945 1.14239 -0.987558 0.257332 -2.6766 -3.19824 -2.50358 -3.85734 -2.65658 1.04436 -3.78909 -1.32906 0.0229431 -0.107888 3.60243 3.39789 3.67576 5.41361 1.54783 4.04254 2.06911 2.52305
#      1     3     3     0     0     0     0     2     5  1977  2022     2 -0.955777 -0.760853 -0.576817 -0.771631 -1.16132 -0.962719 -0.816002 -1.48457 -0.261983 -0.226152 0.075892 0.241145 0.489637 0.746728 -0.286611 -0.124597 2.33466 1.82106 0.607406 2.47868 1.93629 -0.549041 -0.190132 0.770816 0.281168 -0.590839 2.13456 2.80022 2.83881 2.56342 0.733392 -0.839644 -1.31418 0.050477 -2.03535 -2.62881 -2.06845 -1.30363 1.50572 0.358633 1.22679 -0.484682 -1.83388 0.397043 -0.238927 1.02151
#      1     4     5     0     0     0     0     3     5  1977  2022     2 -1.17148 -0.568541 -0.243061 -0.872988 -2.67272 -0.613773 0.586071 -0.911974 1.04264 0.276031 -0.272654 -0.0721416 -0.623233 -1.50874 -1.3779 -1.773 -1.71838 -1.04899 -1.45615 -1.41374 -1.89897 -0.787087 -0.324076 -1.53805 -0.749705 -0.74869 -2.16731 -2.51676 -2.45253 -1.55257 -1.54351 1.61544 0.491828 -0.568636 0.564892 1.96152 0.884889 -0.712566 -0.95282 -1.60537 -1.37752 -0.258162 0.0672831 -1.36999 -0.859368 2.01849
#      1    16     7     2     3     0     0     0     0     0     0     0
#      1    17     8     2     3     0     0     0     0     0     0     0
#      5     1     9     0     0     0     0     4     1  1977  2022     5 -0.320775 -0.209776 -0.187702 -0.544656 -0.25173 0.310345 0.184493 -0.439256 -0.746778 -0.901171 0.195291 0.0463808 0.265654 0.45635 0.0392734 0.101656 -0.147173 -0.44067 -0.363291 0.155423 0.163662 0.0654733 0.193602 -0.0549147 0.449614 0.19876 0.437195 0.213934 0.205033 0.192999 -0.0413644 -0.402457 -0.516949 -0.155305 -0.322355 0.194292 -0.0802372 0.0770437 0.261759 0.380725 0.174706 0.246734 0.409658 0.838898 0.395978 0.401836
#      5     3    11     0     0     0     0     5     2  1977  2022     5 -0.706348 -0.986634 -0.756111 -1.07604 -0.637739 0.0361491 -0.0171167 -0.301119 -1.90899 -1.84713 1.21436 0.337352 0.587859 0.366457 -0.48621 0.489863 -0.635512 -1.46919 -0.931766 0.146665 0.391578 -0.406947 0.327848 -0.560697 0.686715 0.888208 1.0221 0.698169 0.346605 0.378131 0.0249543 -0.72245 -1.50152 -0.00993715 -0.915944 0.480619 0.140587 0.337885 0.375734 0.535806 -0.141551 0.622189 1.12377 2.92656 0.540382 0.825605
#      5     7    13     0     0     0     0     6     1  1978  2022     5 -0.139387 -0.128391 -0.132213 -0.00178813 0.308107 0.28525 0.311385 -0.157307 0.0266979 -0.196692 -0.149327 -0.161723 -0.0476769 0.18287 0.239498 0.0279279 0.00669859 -0.0234326 -0.0110669 0.113217 0.00919169 -0.0627744 -0.0108816 0.117496 -0.103325 -0.064674 -0.0520111 -0.0358935 -0.0401816 0.0529574 0.0914458 -0.114027 0.120787 -0.0959885 -0.0105728 -0.132139 -0.0458213 0.00376289 0.222959 -0.00392953 0.0171811 -0.046997 -0.0534611 -0.10527 -0.0240713
#      5     9    15     0     0     0     0     7     2  1978  2022     5 -0.225011 0.340971 -0.202584 0.0287921 0.325242 0.375687 0.128935 -0.549011 -0.221293 -0.554103 0.0111105 0.0151899 -0.0125886 0.0900135 0.888592 0.0431624 -0.595117 0.0972302 -0.472234 0.820342 0.260718 -0.0552134 -0.126891 0.893493 0.228739 0.0492024 -0.344699 -0.13487 -0.710904 -0.402926 0.689984 -0.449662 0.524203 -0.090422 -0.258217 -0.30487 -0.334554 -0.610238 1.22037 -0.675006 0.409933 -0.33335 0.169877 -0.0713256 0.125151
#      5    19    17     0     0     0     0     8     1  1982  2022     5 0.359973 0.0850848 0.0792955 -0.00259718 -0.791753 -0.200308 -0.00492644 0.542185 0.98282 0.654779 0.493841 -0.123912 -1.01265 -0.58717 -0.502958 0.108822 -0.673656 -0.101611 0.577082 -0.426302 -0.169845 -0.13065 -0.134566 -0.283438 0.123342 -0.125607 0.335583 0.454175 -0.234723 0.148793 0.0774661 0.0965405 0.00259868 -0.242162 0.171364 0.691981 0.0338905 -0.411958      0 0.0468994 0.094058
#      5    21    19     0     0     0     0     9     2  1982  2022     5 -0.0152838 0.429483 -0.0396886 0.95239 -3.06816 -0.895449 -1.51959 -0.537058 2.63133 1.86133 1.82473 0.729231 -2.53084 -2.48175 -2.5474 -0.142491 -3.08961 -1.64675 1.11194 0.79395 -0.963795 -0.109238 -0.563048 0.28128 1.39141 2.21793 0.851778 2.26452 -1.39469 1.26536 1.36861 -0.513636 0.598103 -1.08505 -0.123731 1.28704 -0.556817 0.932454      0 0.666123 0.36509
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
      4      1  0.273344
      4      2  0.221833
      4      3   1.24829
      4      4  0.810578
      5      1   3.56501
      5      2   1.54593
      5      3    3.2102
      5      4    1.5045
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
#  1 #_agecomp:_1
#  1 #_agecomp:_2
#  1 #_agecomp:_3
#  1 #_agecomp:_4
#  1 #_init_equ_catch1
#  1 #_init_equ_catch2
#  1 #_init_equ_catch3
#  1 #_init_equ_catch4
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

