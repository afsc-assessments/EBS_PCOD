#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod23b.dat // Model_23_1.ctl
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
 1964 1976
 1964 2006
 1977 1980
#
# controls for all timevary parameters 
1 #_time-vary parm bound check (1=warn relative to base parm bounds; 3=no bound check); Also see env (3) and dev (5) options to constrain with base bounds
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
1 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate;_5=BETA:_Maunder_link_to_maturity;_6=Lorenzen_range
2 #_no additional input for selected M option; read 1P per morph
4 7
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
 0 1 0.355159 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
 0 1 0.355159 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 25 16.6592 0 0 0 2 0 1 1990 2022 2 0 0 # L_at_Amin_Fem_GP_1
 60 150 110.61 0 0 0 2 0 1 1990 2022 2 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.158479 0 0 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 1.0317 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 10 3.20814 0 0 0 2 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 0 20 7.63616 0 0 0 2 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
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
 1e-06 10 0.3 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 1e-06 10 0.3 0 0 0 -1 # L_at_Amax_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amax_Fem_GP_1_dev_autocorr
 -10 10 0.411088 0 0 0 2 # AgeKeyParm2_BLK2delta_1964
 -10 10 1.21059 0 0 0 2 # AgeKeyParm3_BLK2delta_1964
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
            10            16       13.1256             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -1.40183 0 0 0 2 # SR_regime_BLK1add_1964
3 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
2 #_recdev phase 
1 # (0/1) to read 13 advanced options
 1964 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 6 #_recdev_early_phase
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
#  1964E 1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975E 1976E 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021F 2022F 2023F 2024F 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F 2034F 2035F 2036F 2037F
#  -1.77949 -1.81716 -1.86278 -1.91353 -1.96833 -2.02142 -2.06102 -2.02857 -1.84274 -1.24693 -1.05117 -1.33884 -0.167128 0.650967 0.406156 0.345617 -0.535056 -0.928937 0.681709 -0.68451 0.617739 -0.231424 -0.742215 -1.36691 -0.670805 0.164261 -0.0386846 -0.0598356 0.666026 -0.230393 -0.461305 -0.525988 0.46145 -0.304846 -0.601166 0.270666 0.180716 -0.794611 -0.229674 -0.584063 -0.81137 -0.337569 0.43385 -0.179611 0.768201 -0.656134 0.447378 0.787179 0.00867714 0.820942 -0.645941 -0.42178 -0.97087 -0.785569 0.779395 -1.29133 -0.216757 -0.100565 -0.0138383 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.3 # F ballpark value in units of annual_F
-1999 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
3 # max F (methods 2-4) or harvest fraction (method 1)
4  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 1
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 1 0.1 0 0 0 7 # InitF_seas_1_flt_1trawl
#
# F rates by fleet x season
# Yr:  1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# trawl 0.00978971 0.0107744 0.0133885 0.0240652 0.0466126 0.0468691 0.0804658 0.0622286 0.0781645 0.125705 0.198198 0.223788 0.298261 0.223087 0.261155 0.183484 0.121608 0.124855 0.0879653 0.105124 0.108703 0.123698 0.132325 0.120379 0.239532 0.202847 0.16568 0.22444 0.190057 0.218262 0.197088 0.242878 0.185994 0.177154 0.123454 0.116136 0.122237 0.0743617 0.107503 0.101489 0.118513 0.115302 0.134314 0.132967 0.11464 0.133811 0.128591 0.168317 0.172368 0.17303 0.149183 0.115471 0.105482 0.0936746 0.078235 0.0665312 0.084347 0.0718543 0.0723476 0.120495 0.120495 0.120495 0.111925 0.110255 0.111702 0.113674 0.115088 0.115875 0.116235 0.116357 0.116386 0.116381 0.116368 0.116357
# longline 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00967101 0.0322363 0.017267 0.0269888 0.0152948 0.00741262 0.00830851 0.0300997 0.0485032 0.0383825 0.0636905 0.00337864 0.0178651 0.07007 0.152802 0.244407 0.157035 0.197191 0.232222 0.186484 0.213466 0.177368 0.198472 0.206026 0.191119 0.229696 0.26015 0.229798 0.254941 0.261298 0.237087 0.338206 0.404236 0.278495 0.315845 0.302184 0.255754 0.290658 0.225719 0.189053 0.172273 0.126868 0.130292 0.132381 0.131918 0.130101 0.137749 0.137749 0.137749 0.127952 0.126043 0.127697 0.129951 0.131568 0.132467 0.132879 0.133018 0.133051 0.133045 0.13303 0.133018
# pot 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000317497 0 0 0 0 0 2.63836e-05 0 0 9.6023e-05 1.29591e-06 0.000438907 0.000186516 0.0020382 0.00643394 0.0235223 0.00755734 0.0217641 0.0509194 0.0702746 0.0409717 0.0289731 0.031661 0.0463291 0.035983 0.0358365 0.0543563 0.0398568 0.039316 0.0550269 0.0548159 0.0688873 0.0638958 0.0847225 0.0828514 0.084677 0.0640271 0.106402 0.0788376 0.0742082 0.0751816 0.0506612 0.0616242 0.0604178 0.060481 0.0874192 0.0324072 0.0324072 0.0324072 0.0301023 0.0296532 0.0300423 0.0305727 0.0309531 0.0311645 0.0312616 0.0312942 0.0313021 0.0313007 0.0312972 0.0312943
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
            -3             3             0             0             0             0         8          0          0          0          0          0          0          0  #  LnQ_base_survey(4)
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
             0            12       6.05325          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_peak_trawl(1)
           -10            10       1.41201          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_top_logit_trawl(1)
           -10            10       1.53516          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_ascend_se_trawl(1)
           -10            10     -0.119459          -999          -999             0          3          0          0       1977       2022          0          0          0  #  Age_DblN_descend_se_trawl(1)
           -10            10           -10          -999          -999             0         -3          0          0       1977       2022          0          0          0  #  Age_DblN_start_logit_trawl(1)
           -10            10            10          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_end_logit_trawl(1)
# 2   longline AgeSelex
             0            12        5.1799          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_peak_longline(2)
           -10            10      -2.16763          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_longline(2)
           -10            10      0.320313          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Age_DblN_ascend_se_longline(2)
           -10            10     -0.327028          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Age_DblN_descend_se_longline(2)
           -10            10           -10          -999          -999             0         -3          0          0       1978       2022          0          0          0  #  Age_DblN_start_logit_longline(2)
           -10            10            10          -999          -999             0         3          0          0       1978       2022          0          0          0  #  Age_DblN_end_logit_longline(2)
# 3   pot AgeSelex
             0            12       4.11183          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_peak_pot(3)
           -10            10     -0.529452          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_pot(3)
           -10            10      -6.54474          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Age_DblN_ascend_se_pot(3)
           -10            10      -4.31191          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Age_DblN_descend_se_pot(3)
           -10            10           -10          -999          -999             0         -3          0          0       1991       2022          0          0          0  #  Age_DblN_start_logit_pot(3)
           -10            10            10          -999          -999             0         3          0          0       1991       2022          0          0          0  #  Age_DblN_end_logit_pot(3)
# 4   survey AgeSelex
             0            12         1.013          -999          -999             0          3          0          0       1982       2022          3          0          0  #  Age_DblN_peak_survey(4)
           -10            10     0.0137609          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_survey(4)
           -10            10           -10          -999          -999             0         -3          0          0       1982       2022          3          0          0  #  Age_DblN_ascend_se_survey(4)
           -10            10      -1.53392          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_descend_se_survey(4)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_survey(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_end_logit_survey(4)
#_Dirichlet and/or MV Tweedie parameters for composition error
#_multiple_fleets_can_refer_to_same_parm;_but_list_cannot_have_gaps
           -10            10          9.99             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P1
           -10            10          9.99             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P2
           -10            10          9.99             0          -999             0         -4          0          0          0          0          0          0          0  #  ln(DM_theta)_Age_P3
#_no timevary selex parameters
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
#      1     2     1     0     0     0     0     1     1  1990  2022     2 -0.00352045 0.268128 0.0866851 0.041591 0.0290866 0.150646 0.144543 0.0718257 0.205934 -0.215114 0.238075 0.152587 0.40976 0.00930008 0.348509 -0.34176 -0.422974 -0.353672 -0.543654 -0.605068 0.187892 -0.608639 -0.177042 0.0797083 -0.423859 0.712185 0.52929 0.766586 0.841176 0.61023 0.809316 0.361584 1.54116
#      1     3     3     0     0     0     0     2     1  1990  2022     2 0.124176 -0.112121 -0.205236 0.439277 0.170523 0.0810543 0.0793725 0.0493366 -0.0965001 -0.0151934 -0.118041 0.171113 -0.149239 0.191668 -0.0275868 -0.254956 0.292001 -0.21483 0.184395 0.339757 -0.0825892 -0.0108188 0.280238 -0.233231 0.40037 0.00650993 0.145388 -0.287356 0.193833 0.106346 -0.445012 0.47107 -0.088923
#      1    16     5     2     3     0     0     0     0     0     0     0
#      1    17     6     2     3     0     0     0     0     0     0     0
#      2     4     7     1     1     0     0     0     0     0     0     0
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
      5      4         1
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

