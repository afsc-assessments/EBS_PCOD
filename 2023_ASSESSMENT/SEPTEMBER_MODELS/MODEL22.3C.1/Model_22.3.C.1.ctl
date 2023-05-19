#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod22_OCT.dat // Model_22.3A.ctl
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
 0 1 0.42492 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 20 13.7646 0 0 0 2 0 5 1977 2022 3 0 0 # L_at_Amin_Fem_GP_1
 60 150 116.938 0 0 0 2 0 0 1977 2022 3 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.11002 0 0 0 2 0 0 1977 2022 3 0 0 # VonBert_K_Fem_GP_1
 0 10 1.55968 0 0 0 2 0 5 1977 2022 3 0 0 # Richards_Fem_GP_1
 0.01 0.4 0.256214 0 0 0 2 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0.01 0.2 0.0510582 0 0 0 2 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
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
 1e-06 10 0.7 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 1e-06 10 0.7 0 0 0 -1 # Richards_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # Richards_Fem_GP_1_dev_autocorr
 -10 10 0.41418 0 0 0 2 # AgeKeyParm2_BLK2delta_1977
 -10 10 1.41852 0 0 0 2 # AgeKeyParm3_BLK2delta_1977
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
            12            16       13.6753             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -1.62054 0 -1 0 1 # SR_regime_BLK1add_1976
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 -1 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1966.1 #_last_yr_nobias_adj_in_MPD; begin of ramp
 1981.2 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2017.3 #_last_yr_fullbias_adj_in_MPD
 2070.8 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.986 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
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
#  -0.00542367 -0.00315668 -0.00512438 -0.00818465 -0.0130711 -0.020863 -0.0332147 -0.0525507 -0.0823126 -0.127063 -0.190001 -0.276761 -0.391008 -0.532533 -0.698728 -0.880003 -1.05403 -1.1485 -0.304077 1.22998 1.39135 1.22103 0.374756 -1.92892 -0.611722 0.743054 -0.0121209 0.889105 -0.0531053 -0.514194 -2.02542 -0.301016 0.417298 0.263425 0.0953043 0.216943 0.236198 -0.108907 -0.432586 0.658724 -0.133149 -0.195923 0.388086 0.330505 -0.640494 -0.164494 -0.369995 -0.515476 -0.586686 0.439876 -0.289391 1.02655 -0.461919 0.363582 0.805834 0.300243 1.17167 -0.377538 -0.48088 -0.289179 -0.590992 0.628716 -0.680124 -0.198016 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 1 0.0438814 0 0 0 1 # InitF_seas_1_flt_1Fishery
 0 1 0.0438814 0 0 0 1 # InitF_seas_1_flt_1Fishery
#
# F rates by fleet x season
# Yr:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# Fishery 0.0751729 0.101769 0.0737258 0.0434399 0.0546252 0.0574105 0.0720702 0.0902405 0.110479 0.0992047 0.119614 0.162865 0.158705 0.189931 0.293829 0.29161 0.249405 0.296918 0.363039 0.35246 0.418265 0.346443 0.350262 0.34022 0.287982 0.284454 0.29649 0.305655 0.346531 0.384032 0.378422 0.456356 0.521845 0.433507 0.566897 0.529154 0.46209 0.459074 0.421959 0.396166 0.318166 0.221584 0.189567 0.178776 0.174629 0.211058 0.424776 0.393822 0.329129 0.319491 0.332564 0.345745 0.352735 0.355129 0.355492 0.355298 0.355092 0.354983 0.354944 0.354937 0.354939
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         4         1         0         0         0         0  #  Survey
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
          -0.5           0.5     -0.259807             0             0             0          6          0          0          0          0          0          0          0  #  LnQ_base_Survey(2)
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
 24 0 0 0 # 4 survey
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
 0 0 0 0 # 4 survey
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   trawl LenSelex
            10            90       79.4481          -999          -999             0          4          0          1       1977       2022          5          0          0  #  Size_DblN_peak_trawl(1)
           -10            10      0.462808          -999          -999             0          4          0          0       1977       2022          0          0          0  #  Size_DblN_top_logit_trawl(1)
           -10            10       6.42252          -999          -999             0          4          0          2       1977       2022          6          0          0  #  Size_DblN_ascend_se_trawl(1)
           -10            10     -0.093357          -999          -999             0          4          0          0       1977       2022          0          0          0  #  Size_DblN_descend_se_trawl(1)
           -10            10          -999          -999          -999             0         -3          0          0       1977       2022          0          0          0  #  Size_DblN_start_logit_trawl(1)
           -10            10          -10          -999          -999             0           4          0          0       1977       2022          6          0          0  #  Size_DblN_end_logit_trawl(1)
# 2   longline LenSelex
            10            90       68.5646          -999          -999             0          4          0          1       1978       2022          5          0          0  #  Size_DblN_peak_longline(2)
           -10            10      -3.44965          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_top_logit_longline(2)
           -10            10       5.27341          -999          -999             0          4          0          2       1978       2022          6          0          0  #  Size_DblN_ascend_se_longline(2)
           -10            10       4.85693          -999          -999             0          4          0          0       1978       2022          0          0          0  #  Size_DblN_descend_se_longline(2)
           -10            10          -999          -999          -999             0         -3          0          0       1978       2022          0          0          0  #  Size_DblN_start_logit_longline(2)
           -10            10          -999          -999          -999             0         -3          0          0       1978       2022          0          0          0  #  Size_DblN_end_logit_longline(2)
# 3   pot LenSelex
            10            90       70.4466          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_peak_pot(3)
           -10            10       5.23881          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_top_logit_pot(3)
           -10            10       5.02002          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_pot(3)
           -10            10       7.90615          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_descend_se_pot(3)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_pot(3)
           -10            10           -10          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_pot(3)
# 4   survey LenSelex
            10            80       24.2196          -999          -999             0          4          0          1       1982       2022          6          0          0  #  Size_DblN_peak_survey(4)
           -10            10       4.15512          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_top_logit_survey(4)
           -10            10       4.45911          -999          -999             0          4          0          2       1982       2022          6          0          0  #  Size_DblN_ascend_se_survey(4)
           -10            10       -2.6206          -999          -999             0          4          0          0          0          0          0          0          0  #  Size_DblN_descend_se_survey(4)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_survey(4)
           -10            10          -999          -999          -999             0         -4          0          0          0          0          0          0          0  #  Size_DblN_end_logit_survey(4)
# 1   trawl AgeSelex
# 2   longline AgeSelex
# 3   pot AgeSelex
# 4   survey AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10           0.2             0             0             0      -9  # Size_DblN_ascend_se_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_trawl(1)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Size_DblN_ascend_se_longline(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_longline(2)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Size_DblN_peak_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_peak_survey(4)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Size_DblN_ascend_se_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_survey(4)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Size_DblN_peak_survey(4)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_peak_survey(4)_dev_autocorr
         1e-06            10           0.2             0             0             0      -9  # Size_DblN_ascend_se_survey(4)_dev_se
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
#      1     2     1     0     0     0     0     1     5  1977  2022     3 -1.0385 -0.0391837 0.0257367 0.0366272 -0.698312 -2.22183 -1.84637 5.38691 -2.18288 1.86217 0.161927 -0.737457 -1.4806 -1.59521 1.0176 1.63349 -0.404673 -0.244107 -0.252077 0.591633 -0.103612 -0.0705575 -0.000465412 0.250721 -0.176365 0.0784607 -0.0504772 -0.138444 -0.0257034 -0.340091 0.214481 0.0128984 0.154769 -0.199322 -0.338992 0.0513501 -0.767278 0.0384327 -0.0113254 0.393128 -0.0952464 -0.0848801 0.281776 0.0521449 2.87218 0.0275275
#      1     5     3     0     0     0     0     2     5  1977  2022     3 2.48902 -1.0542 1.61976 1.55262 0.81791 1.05158 0.640242 -1.32595 1.98717 0.0309356 0.0680837 0.178459 -1.89367 0.78424 0.104803 -0.0914166 0.54953 -0.2523 -1.24725 -0.573193 -0.202857 -0.445654 -0.564467 0.105259 0.0194183 0.134094 -0.359291 -0.197153 -0.171074 -0.684106 -1.2314 0.256238 -1.32954 0.0317741 -1.72388 0.130584 -0.22337 -0.36138 -0.382437 1.03666 -0.909809 1.49674 0.257764 0.0247829 -1.71353 1.57024
#      1    16     5     2     3     0     0     0     0     0     0     0
#      1    17     6     2     3     0     0     0     0     0     0     0
#      2     4     7     1     1     0     0     0     0     0     0     0
#      5     3     8     0     0     0     0     3     2  1977  2022     6 0.124521 -0.018108 -0.496846 -0.0914875 0.28962 -0.405804 0.0391525 0.903034 0.781964 1.05886 0.702114 0.492506 0.168702 -0.933181 -0.340278 0.268919 0.0219783 0.135294 0.453392 -0.172337 -0.0534945 -0.586014 -0.282332 -0.150154 -0.552527 0.321957 -0.145297 0.251576 -0.168208 -0.156307 0.213791 0.362171 0.216458 0.206045 0.00809845 -0.097295 0.119668 0.122457 -0.368934 -0.745617 -0.662721 -0.272122 -0.126698 0.840701 -0.80035 -0.476754
#      5     9    10     0     0     0     0     4     2  1978  2022     6 0.737131 0.258474   -0.4 0.125368 -0.130107 0.156076 0.0841478 -0.216379 -0.480883 -0.208455 0.00039037 -0.0187632 -0.221341 -0.655189 -0.234077 0.210686 -0.243504 0.0279112 -0.0939204 0.0509312 0.137554 0.17203 0.148257 0.285291 0.559584 0.619455 0.449163 0.37333 0.0316069 -0.266721 -0.132089 -0.0437505 -0.214888 -0.0244249 -0.100166 0.0497234 -0.166427 -0.311473 -0.31901 -0.432734 -0.0289993 -0.000278998 0.0945205 0.237947 0.13215
#      5    19    12     0     0     0     0     5     1  1982  2022     6 -0.0735525 -0.140791 0.545878 0.212045 0.318035 -0.132465 -0.312869 0.424978 -0.101126 -0.0902732 -0.134288 0.0689909 -1.5978 -0.489722 -0.216409 0.185513 0.326172 0.383829 0.259924 -0.959773 -0.0625378 -0.299362 0.00585453 -0.185613 -0.114226 -0.197614 0.851302 0.030611 0.444323 -0.212208 -0.161281 0.778376 -0.178373 0.144175 -0.0607521 0.831579 0.25136 -0.160915      0 -0.232841 0.0512147
#      5    21    14     0     0     0     0     6     2  1982  2022     6 -1.23167 -0.568626 0.399908 0.194031 0.82902 -1.2094 -1.58855 0.114841 -0.585734 -0.760291 -1.23848 0.313123 0.438549 -0.13482 -0.0991876 0.0129858 0.184836 0.261513 0.129092 0.223899 0.0357783 0.0159461 0.0175242 0.0109294 0.273578 0.156152 1.92847 0.0338485 0.136097 0.0712967 0.0300989 1.11739 0.0297872 0.0246024 0.0134008 1.12643 -0.0293968 0.034076      0 0.076916 -0.787906
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
      4      1   0.451292
      4      2   0.503042
      4      3   1.259340
      4      4   2.115830
      5      4   0.0980467
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
#  0 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

