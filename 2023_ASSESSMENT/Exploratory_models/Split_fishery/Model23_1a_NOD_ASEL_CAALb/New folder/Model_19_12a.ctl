#V3.30.20.00;_safe;_compile_date:_Sep 30 2022;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.0
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod23C.dat // Model_19_12a.ctl
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
 0 1 0.339709 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 25 17.0035 0 0 0 2 0 5 1977 2022 2 0 0 # L_at_Amin_Fem_GP_1
 80 150 116.357 0 0 0 2 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 0.3 0.175112 0 0 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 1 0.789487 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 0.2 0.145813 0 0 0 2 0 0 0 0 0 0 0 # CV_young_Fem_GP_1
 0 0.1 0.0310818 0 0 0 2 0 0 0 0 0 0 0 # CV_old_Fem_GP_1
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
 -1 1 0.186919 0 0 0 2 # AgeKeyParm2_BLK2delta_1964
 -1 2 1.9984 0 0 0 2 # AgeKeyParm3_BLK2delta_1964
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
            12            16        12.524             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
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
#  -0.483675 -0.581811 -0.678509 -0.779873 -0.880021 -0.974488 -1.0649 -1.21267 -1.311 -1.40713 -1.46884 -1.5112 -1.49616 -1.4353 -1.37715 -1.65956 -1.0153 -0.610653 -2.15902 0.101865 0.259919 0.411213 0.624055 -1.10026 0.480525 0.846348 -0.183954 0.723829 0.198633 -0.118724 -0.199369 0.164313 0.599484 0.533368 0.264965 0.703369 0.0771674 -0.0933791 0.0518024 0.644784 0.365376 0.123574 0.683106 0.395089 -0.108944 0.0638575 0.0441362 -0.438884 0.379091 0.579892 0.401815 1.04549 0.317574 0.695532 0.906248 0.53583 0.860961 0.102994 0.203202 -0.342682 -0.0913492 0.849015 -0.509852 -0.472012 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 0.2 0.0107121 0 0 0 1 # InitF_seas_1_flt_1trawl
#
# F rates by fleet x season
# Yr:  1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# trawl 0.0175797 0.0213545 0.0293545 0.0585426 0.125432 0.134201 0.238965 0.185569 0.22663 0.371246 0.626832 0.756663 1.12369 0.811926 2.99995 0.569014 0.214984 0.212658 0.287518 0.279498 0.196921 0.164868 0.152405 0.169354 0.369787 0.399373 0.460087 0.396852 0.245922 0.25236 0.20008 0.247428 0.3114 0.351994 0.288316 0.276533 0.24455 0.253569 0.163631 0.194063 0.170042 0.169946 0.209364 0.19196 0.130785 0.14212 0.154021 0.21948 0.404218 0.285612 0.251572 0.297557 0.357293 0.292018 0.228911 0.189159 0.184176 0.166177 0.18181 0.142228 0.142228 0.142228 0.14015 0.138328 0.139244 0.140535 0.141419 0.141939 0.142153 0.142202 0.142211 0.142205 0.142197 0.142191
# longline 9.2216e-05 0 6.36001e-06 9.55005e-05 0 8.14073e-05 3.01851e-05 0.00341575 0.00703082 0.00463007 0.000875302 0.0167512 0.0247517 0.0335872 0.106688 0.0394915 0.0616779 0.0296761 0.0240617 0.0240987 0.0766571 0.0834485 0.0568508 0.0824958 0.00465127 0.0262794 0.122986 0.233467 0.290091 0.159445 0.232133 0.264389 0.284975 0.400655 0.320935 0.348258 0.360254 0.315628 0.281886 0.305853 0.283959 0.315348 0.349016 0.343305 0.424275 0.524829 0.455588 0.451613 0.557362 0.365831 0.448936 0.449667 0.393921 0.380162 0.238508 0.225138 0.186686 0.16168 0.186273 0.107687 0.107687 0.107687 0.106114 0.104734 0.105428 0.106406 0.107075 0.107469 0.107631 0.107668 0.107674 0.10767 0.107664 0.10766
# pot 0 0 0 0 0 0 0 0 0 0 0 0 0 0.00140711 0 0 0 0 0 6.50089e-05 0 0 0.00014963 2.00342e-06 0.00066597 0.000325164 0.00330923 0.0100679 0.0303312 0.00891871 0.0282832 0.0649886 0.111303 0.0848513 0.0615709 0.068775 0.0953434 0.0732801 0.0574045 0.0792949 0.0596534 0.0582877 0.0810927 0.0866216 0.0963597 0.0983526 0.132867 0.151341 0.169077 0.121606 0.17722 0.170869 0.172743 0.171646 0.115898 0.121916 0.102838 0.0894946 0.137982 0.0294732 0.0294732 0.0294732 0.0290426 0.028665 0.0288548 0.0291224 0.0293057 0.0294134 0.0294577 0.0294679 0.0294697 0.0294684 0.0294668 0.0294656
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
            -3             3      0             0             0             0           8          0          0          0          0          0          0          0  #  LnQ_base_survey(4)
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
             0            12       6.18229          -999          -999             0          4          0          1       1977       2022          5          0          0  #  Age_DblN_peak_trawl(1)
           -10            10       1.61052          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_trawl(1)
           -10            10       1.42401          -999          -999             0          4          0          2       1977       2022          5          0          0  #  Age_DblN_ascend_se_trawl(1)
           -10            10             0          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_trawl(1)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_trawl(1)
           -10            10       9.02157          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_trawl(1)
# 2   longline AgeSelex
             0            12       5.13213          -999          -999             0          4          0          1       1978       2022          5          0          0  #  Age_DblN_peak_longline(2)
           -10            10            10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_longline(2)
           -10            10     -0.122351          -999          -999             0          4          0          2       1978       2022          5          0          0  #  Age_DblN_ascend_se_longline(2)
           -10            10             0          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_longline(2)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_longline(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_end_logit_longline(2)
# 3   pot AgeSelex
             0            12        5.4506          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_peak_pot(3)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_pot(3)
           -10            10     -0.328611          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_ascend_se_pot(3)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_pot(3)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_pot(3)
           -10            10       3.20768          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_pot(3)
# 4   survey AgeSelex
             0            12       2.80778          -999          -999             0          4          0          1       1982       2022          5          0          0  #  Age_DblN_peak_survey(4)
           -10            10       2.13747          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_top_logit_survey(4)
           -10            10       1.27601          -999          -999             0          4          0          2       1982       2022          5          0          0  #  Age_DblN_ascend_se_survey(4)
           -10            10     0.0675151          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_descend_se_survey(4)
           -10            10           -10          -999          -999             0         -4          0          0          0          0          0          0          0  #  Age_DblN_start_logit_survey(4)
           -10            10            10          -999          -999             0          4          0          0          0          0          0          0          0  #  Age_DblN_end_logit_survey(4)
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_peak_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_peak_trawl(1)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_ascend_se_trawl(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Age_DblN_ascend_se_trawl(1)_dev_autocorr
         1e-06            10           0.5             0             0             0      -9  # Age_DblN_peak_longline(2)_dev_se
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
#      1     2     1     0     0     0     0     1     5  1977  2022     2 0.150318 1.45393 -0.0424263 -0.25162 -1.0969 -2.62105 1.98216 1.56568 -2.02627 1.93471 0.582534 0.577208 -2.26609 -3.00891 -0.908841 -0.962458 -0.250044 1.90148 1.20345 0.16279 -2.54307 -0.295581 -1.76024 0.0155094 0.143074 0.46718 -2.56162 -0.922834 -2.99927 -3.03126 -2.74181 -1.42948 -2.62978 1.04717 -3.36158 -0.24015 0.493745 -1.6775 4.00032 2.51614 3.59184 5.51623 0.0835458 3.54661 1.58606 3.87758
#      1    16     3     2     3     0     0     0     0     0     0     0
#      1    17     4     2     3     0     0     0     0     0     0     0
#      5     1     5     0     0     0     0     2     1  1977  2022     5 -0.26965 1.04263 -0.190923 -0.779782 -0.7823 0.380325 0.187129 -0.218347 -2.0093 -1.94341 -0.198338 -0.0652986 0.607028 1.17436 0.297231 -0.23188 -0.382459 -0.79084 -0.9733 0.0852283 0.168388 0.189085 0.348632 -0.169471 0.952631 0.104715 0.656139 0.022179 0.0514085 0.11753 -0.0751148 -0.684304 -1.23292 -0.53102 -0.55579 0.49778 0.207355 0.158484 0.453248 0.647034 0.435628 0.700194 0.958172 1.42848 0.892475 1.02824
#      5     3     7     0     0     0     0     3     2  1977  2022     5 -0.99837 0.370525 -1.41775 -1.2938 -1.6708 -0.426681 -0.922402 1.55958 -4.3518 -3.09414 1.47169 0.584526 1.34167 0.883268 -0.216103 -0.0660241 -1.13341 -1.77822 -1.59127 -0.159113 0.38454 -0.773588 0.473442 -1.24449 1.04683 1.20562 1.29415 0.588476 -0.188222 -0.124498 0.1579 -0.431589 -3.48939 -0.42633 -1.36538 0.871355 1.40573 1.05597 0.584801 0.4119 -0.545894 1.10714 1.98945 5.57839 0.926455 2.02454
#      5     7     9     0     0     0     0     4     1  1978  2022     5 0.00539087 -0.362954 -0.284195 -0.14273 0.736551 0.830786 1.13373 -0.184379 0.0830956 -0.446882 -0.118653 -0.0392561 0.625928 0.474628 0.265267 -0.100714 0.0164419 -0.148053 -0.0875007 0.294475 -0.0629972 -0.187913 -0.0910358 0.157452 -0.389585 -0.301448 -0.28138 -0.280322 -0.210079 0.106245 0.126553 -0.305881 0.186022 -0.236918 -0.0475322 -0.255994 -0.101091 0.00397723 0.244749 0.0134304 0.0793819 -0.0962928 -0.170502 -0.33512 -0.109062
#      5     9    11     0     0     0     0     5     2  1978  2022     5 -0.221017 0.550392 -1.28546 0.599028 2.78866 3.21687 4.92079 -1.38167 -0.997283 -2.65985 0.0118143 -0.00264182 -0.0613402 0.734731 1.19151 0.0455242 -0.819374 0.132838 -1.04796 2.09934 0.528134 0.0864719 -0.500582 1.72561 0.261716 -0.218293 -0.919755 -0.362585 -1.63148 -0.858703 1.06409 -2.07707 0.247806 -0.645119 -1.19041 -0.962514 -0.70698 -1.03406 1.45851 -1.49979 0.827296 -0.840116 0.172917 -0.292334 -0.446319
#      5    19    13     0     0     0     0     6     1  1982  2022     5 1.75965 1.15363 0.0570911 -0.785798 -0.255734 0.138123 1.00565 2.5168 0.25813 0.143528 -0.4103 -1.24163 -0.458631 0.384425 0.643516 0.664056 0.213009 1.07723 0.783878 -1.71609 0.255251 0.0945498 0.417483 -0.553235 -0.221056 -3.95031 -0.0564354 -0.984437 0.746086 -0.0722085 -1.68301 0.28876 -0.461162 0.333841 1.39334 1.62815  1.225 -2.0458 5.30227e-09 -1.75255 -0.532923
#      5    21    15     0     0     0     0     7     2  1982  2022     5 -0.251421 2.19848 -0.974015 0.19991 -1.18737 -0.0781518 -1.06175 1.03445 0.852751 -0.337025 0.04359 0.292687 -0.850573 -0.829045 -1.2553 0.517715 -1.91478 -0.752835 0.979563 0.22397 -0.386651 0.288496 -0.0385615 0.145821 0.474808 0.09881 -0.0865691 0.594794 -0.995964 1.10627 0.226381 -1.08399 0.4969 -0.688609 0.783094 1.29858 0.170301 0.225377 3.65025e-09 0.221719 0.298154
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
   ##   1      4   0.201481
      4      1   1.12962
      4      2   6.85649
      4      3   2.05698
      4      4  0.846353
      5      1   3.57951
      5      2   1.40306
      5      3   3.11518
      5      4   1.45296
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

