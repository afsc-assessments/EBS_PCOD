#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod23D.dat // Model_19_12a.ctl
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
 0 1 0.492945 0 0 0 4 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 25 16.9871 0 0 0 2 0 5 1977 2022 2 0 0 # L_at_Amin_Fem_GP_1
 80 150 113.323 0 0 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 0.3 0.188391 0 0 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 1 0.697692 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 0.2 0.152495 0 0 0 2 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0 0.1 0.0386723 0 0 0 2 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
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
 -1 1 0.3 0 0 0 -2 # AgeKeyParm2_BLK2delta_1964
 -1 2 1.3 0 0 0 -2 # AgeKeyParm3_BLK2delta_1964
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
            10            16       13.7433             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
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
#  -0.125184 -0.182258 -0.253307 -0.34173 -0.445076 -0.559133 -0.681961 -0.881352 -1.02622 -1.19237 -1.34359 -1.4756 -1.57299 -1.62108 -1.60014 -1.86529 -0.927264 -0.489863 -2.09177 0.285117 0.591478 0.707129 0.744425 -1.11508 0.366634 0.847863 -0.375577 0.731215 0.150244 -0.264014 -0.208534 0.0124833 0.485195 0.337908 0.0525532 0.527016 -0.14916 -0.251518 -0.0699328 0.573302 0.228246 -0.0197353 0.559637 0.178884 -0.282389 -0.164106 -0.217055 -0.754693 0.145294 0.326981 0.165673 0.810996 0.0481393 0.490014 0.743631 0.427949 0.753803 -0.0169747 0.0769616 -0.531497 -0.234097 0.660051 -0.657442 -0.410868 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 0.2 0.0123233 0 0 0 1 # InitF_seas_1_flt_1trawl
#
# F rates by fleet x season
# Yr:  1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# trawl 0.018504 0.0217649 0.0290856 0.0566727 0.119041 0.124691 0.217708 0.16628 0.202026 0.330636 0.554054 0.65537 0.898655 0.618003 0.580841 0.253612 0.100807 0.10376 0.150421 0.135934 0.100799 0.0955869 0.0917979 0.115303 0.257407 0.289232 0.336648 0.267362 0.172061 0.181776 0.143394 0.186986 0.241052 0.268096 0.200659 0.19 0.172215 0.170009 0.109641 0.133856 0.125212 0.126362 0.155842 0.142713 0.103389 0.119502 0.130247 0.177112 0.292547 0.199548 0.187783 0.231216 0.268082 0.198923 0.146209 0.121027 0.125869 0.115872 0.144978 0.207159 0.207159 0.207159 0.201854 0.202023 0.205413 0.207159 0.207159 0.207159 0.207159 0.207159 0.207159 0.207159 0.207159 0.207159
# longline 9.54432e-05 0 6.20136e-06 9.10221e-05 0 7.46328e-05 2.71331e-05 0.00302153 0.00619395 0.0040787 0.000766988 0.0144671 0.0200045 0.0235999 0.0506923 0.0177511 0.0282315 0.014783 0.0118067 0.0117145 0.0382064 0.0468644 0.0353559 0.0537819 0.0032013 0.0175754 0.07422 0.162799 0.204262 0.114935 0.168629 0.19938 0.217915 0.297666 0.228243 0.245609 0.25214 0.205871 0.193878 0.217296 0.203691 0.231099 0.259506 0.259406 0.335761 0.451474 0.393691 0.376862 0.457092 0.283709 0.356968 0.348223 0.295316 0.26308 0.156932 0.153933 0.131695 0.121274 0.151352 0.197432 0.197432 0.197432 0.192377 0.192538 0.195768 0.197432 0.197432 0.197432 0.197432 0.197432 0.197432 0.197432 0.197432 0.197432
# pot 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00110509 0 0 0 0 0 3.32883e-05 0 0 0.00010136 1.3913e-06 0.000482208 0.000238377 0.00237218 0.00745545 0.0222744 0.00677497 0.0218437 0.0508956 0.088771 0.0651998 0.0454536 0.0510765 0.0700947 0.0515697 0.0405929 0.0583204 0.044728 0.0443578 0.0629396 0.0696507 0.0809461 0.0882598 0.120223 0.133145 0.145042 0.100338 0.143252 0.13912 0.131639 0.122532 0.082087 0.0864985 0.0768203 0.0705388 0.118759 0.0577029 0.0577029 0.0577029 0.0562252 0.0562724 0.0572165 0.0577029 0.0577029 0.0577029 0.0577029 0.0577029 0.0577029 0.0577029 0.0577029 0.0577029
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
            -3             3     0.0432317             0             0             0          8          0          0          0          0          0          0          0  #  LnQ_base_survey(4)
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
             0            12        6.1319          -999          -999             0          4          0          1       1977       2022          5          0          0  #  Age_DblN_peak_trawl(1)
           -10            10       1.58369          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_trawl(1)
           -10            10       1.26889          -999          -999             0          4          0          2       1977       2022          5          0          0  #  Age_DblN_ascend_se_trawl(1)
           -10            10      0.137961          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_trawl(1)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_trawl(1)
           -10            10       8.78354          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_trawl(1)
# 2   longline AgeSelex
             0            12       5.10614          -999          -999             0          4          0          1       1978       2022          5          0          0  #  Age_DblN_peak_longline(2)
           -10            10            10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_longline(2)
           -10            10     -0.336001          -999          -999             0          4          0          2       1978       2022          5          0          0  #  Age_DblN_ascend_se_longline(2)
           -10            10             0          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_longline(2)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_longline(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_end_logit_longline(2)
# 3   pot AgeSelex
             0            12       5.47123          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_peak_pot(3)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_pot(3)
           -10            10     -0.560142          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_ascend_se_pot(3)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_pot(3)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_pot(3)
           -10            10       2.08995          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_pot(3)
# 4   survey AgeSelex
             0            12        4.2507          -999          -999             0          4          0          1       1982       2022          5          0          0  #  Age_DblN_peak_survey(4)
           -10            10       1.96772          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_survey(4)
           -10            10       2.14076          -999          -999             0          4          0          2       1982       2022          5          0          0  #  Age_DblN_ascend_se_survey(4)
           -10            10      0.021487          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_survey(4)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_start_logit_survey(4)
           -10            10       7.22047          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_survey(4)
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10           0.2             0             0             0      -9  # Age_DblN_peak_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_trawl(1)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Age_DblN_ascend_se_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_trawl(1)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Age_DblN_peak_longline(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_longline(2)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Age_DblN_ascend_se_longline(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_longline(2)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Age_DblN_peak_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_survey(4)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Age_DblN_ascend_se_survey(4)_dev_se
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
#      1     2     1     0     0     0     0     1     5  1977  2022     2 -0.0280184 1.8991 0.358934 -0.641668 -1.44543 -2.74303 2.19055 2.17302 -2.45568 2.24013 0.670048 0.722011 -2.88348 -2.9603 -0.580431 -1.10242 -0.750421 2.1302 1.00793 0.0221974 -2.89373 0.0194756 -1.77641 -0.195432 -0.0281661 0.377676 -2.73751 -0.913739 -3.04194 -3.08002 -2.4045 -1.41317 -2.54774 1.34996 -3.6615 -0.449308 0.510599 -1.53404 4.53806 2.56305 4.34545 5.43929 -0.23718  3.963 1.50053 3.95098
#      1    16     3     2     3     0     0     0     0     0     0     0
#      1    17     4     2     3     0     0     0     0     0     0     0
#      5     1     5     0     0     0     0     2     1  1977  2022     5 -0.0702497 0.0149814 -0.203956 -0.798453 -0.679194 0.476921 0.186756 -0.429783 -1.9286 -1.89664 0.0268629 0.0565226 0.734343 1.26111 0.159872 -0.165767 -0.315548 -0.829117 -0.866012 0.167247 0.282066 0.163581 0.27714 -0.0954923 0.969019 0.0447378 0.644882 0.141909 0.156932 0.174741 -0.16863 -0.743427 -1.12846 -0.430906 -0.592124 0.304155 -0.0775255 0.0127435 0.458319 0.69089 0.442755 0.635151 0.857725 1.32312 0.692944 0.973188
#      5     3     7     0     0     0     0     3     2  1977  2022     5 -0.81936 -1.42487 -1.27739 -1.46933 -1.53217 -0.183552 -0.676263 1.37348 -4.25541 -3.16291 1.95515 0.784184 1.70427 1.33332 -0.531357 0.212533 -0.918266 -2.03056 -1.49324 0.0407232 0.726258 -0.739488 0.328594 -1.03307 1.37413 1.09853 1.44501 0.984607 0.260501 0.249479 -0.0286716 -0.72485 -3.50317 -0.265668 -1.66356 0.514305 0.616464 0.521274 0.559607 0.644411 -0.383116 1.22736 2.05084 5.51767 0.523903 1.9077
#      5     7     9     0     0     0     0     4     1  1978  2022     5 -0.01524 -0.440081 -0.323103 -0.134218 0.68784 0.755836 0.983397 -0.247606 0.0424092 -0.291732 -0.112737 -0.0520506 0.283753 0.442898 0.365176 -0.0849754 0.0270832 -0.115708 -0.0241463 0.363998 -0.0952294 -0.24878 -0.072245 0.115626 -0.365056 -0.287676 -0.185357 -0.223731 -0.114412 0.105595 0.0846229 -0.260949 0.222783 -0.239126 -0.0274072 -0.246117 -0.087611 0.0368309 0.331184 0.0457156 0.00785707 -0.0667496 -0.144157 -0.374976 -0.0870024
#      5     9    11     0     0     0     0     5     2  1978  2022     5 -0.184841 0.767418 -1.09758 0.199954 2.45987 2.92936 4.31486 -1.20234 -1.22765 -1.49892 0.0111249 0.00114243 -0.0177563 0.504802 1.98459 0.0448223 -0.936897 0.108195 -0.744643 2.51257 0.233038 -0.548105 -0.537905 1.58702 0.380554 -0.431846 -0.377203 -0.15004 -0.889705 -0.884019 0.85119 -1.95819 0.247525 -1.09362 -1.21651 -1.16199 -0.939679 -1.1385 1.87218 -1.58147 0.144948 -0.534099 0.457169 -0.771648 -0.478557
#      5    19    13     0     0     0     0     6     1  1982  2022     5 0.599224 0.538981 0.697176 -0.202725 -0.458493 -0.155337 0.470369 1.49819 1.03738 0.58306 0.552684 -0.670224 -1.61539 -0.630707 -0.274248 0.287591 -0.182803 0.310191 0.960087 -1.36774 -0.0326962 -0.362236 -0.0789724 -0.717956 0.061405 -1.23812 0.548183 0.133093 -0.0296343 0.016221 -0.475419 0.384077 -0.452853 -0.309847 0.447391 1.10653 0.534218 -1.11181      0 -0.194053 -0.20487
#      5    21    15     0     0     0     0     7     2  1982  2022     5 -1.9577 1.10479 1.00035 0.642607 -1.12293 -0.195304 -1.60059 -0.862573 1.74534 0.492258 1.39098 0.745271 -0.572295 -1.90072 -2.3385 -0.500189 -1.93327 -1.91806 0.953575 0.643214 -0.604886 -0.199553 -0.554993 0.275962 0.847751 1.98749 1.02031 1.75437 -1.33909 1.05629 1.3159 -0.295504 0.527104 -0.924588 -0.582184 0.602377 -0.514429 0.74588      0 0.970102 0.0954441
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
      4      1      1.24
      4      2      5.18
      4      3      2.05
      4      4      0.95
      5      1         1
      5      2         1
      5      3         1
      5      4      1.49
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

