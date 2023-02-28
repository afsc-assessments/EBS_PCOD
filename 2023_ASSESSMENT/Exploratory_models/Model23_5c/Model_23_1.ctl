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
2 #_N_breakpoints
4 7 # age(real) at M breakpoints
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
 0 1 0.30565 0 0 0 1 0 0 0 0 0 0 0 # NatM_break_1_Fem_GP_1
 0 1 0.30565 0 0 0 1 0 0 0 0 0 0 0 # NatM_break_1_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 25 16.5626 0 0 0 2 0 1 1990 2022 2 0 0 # L_at_Amin_Fem_GP_1
 60 150 131.434 0 0 0 2 0 1 1990 2022 2 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.113195 0 0 0 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 1.15286 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 0 10 3.21587 0 0 0 2 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 0 20 8.32634 0 0 0 2 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
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
 -10 10 0.404394 0 0 0 2 # AgeKeyParm2_BLK2delta_1964
 -10 10 1.35904 0 0 0 2 # AgeKeyParm3_BLK2delta_1964
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
            10            16       13.0681             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -1.29506 0 0 0 2 # SR_regime_BLK1add_1964
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
#  -1.57522 -1.60154 -1.63595 -1.68483 -1.74438 -1.80681 -1.87112 -1.89102 -1.78881 -1.29454 -1.10945 -1.39132 -0.316098 0.52264 0.358791 0.312926 -0.482815 -0.936624 0.64621 -0.68811 0.563219 -0.247336 -0.752485 -1.36963 -0.712362 0.102627 -0.093718 -0.112425 0.603017 -0.282044 -0.512741 -0.586543 0.37529 -0.346336 -0.630765 0.208796 0.126682 -0.818084 -0.305407 -0.64981 -0.891828 -0.409353 0.353045 -0.246008 0.680201 -0.703916 0.377925 0.70373 -0.0670529 0.740349 -0.682691 -0.469111 -1.02857 -0.849328 0.689939 -1.29194 -0.237098 -0.16114 -0.012683 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
1999 # F ballpark year (neg value to disable)
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
# trawl 0.010278 0.0113116 0.0140587 0.0253492 0.0499087 0.0526312 0.0977968 0.0827738 0.111477 0.186892 0.301585 0.339199 0.425984 0.280248 0.283451 0.179943 0.112458 0.11103 0.0758646 0.0890063 0.0918261 0.107063 0.118507 0.108752 0.215588 0.180218 0.148041 0.204538 0.178201 0.205681 0.178395 0.208973 0.15418 0.143688 0.0990368 0.0940407 0.101617 0.0625803 0.0898909 0.0843578 0.0984658 0.094413 0.109948 0.110382 0.0962871 0.113542 0.108915 0.139276 0.140605 0.13802 0.118398 0.0925671 0.0853574 0.0766037 0.0646352 0.0564589 0.0739715 0.0666407 0.0673653 0.167681 0.167681 0.167681 0.162623 0.156589 0.161037 0.164903 0.166454 0.166649 0.166525 0.166423 0.166388 0.166383 0.166386 0.166388
# longline 0 0 0 0 0 0 0 0 0 0 0 0 0 0.011609 0.0340924 0.0168415 0.0254146 0.0140543 0.00656588 0.00718628 0.026241 0.0430193 0.0354375 0.0579904 0.00303058 0.0162195 0.0625648 0.143255 0.235668 0.150717 0.179926 0.202163 0.158664 0.178258 0.145562 0.16827 0.17785 0.166171 0.195454 0.224567 0.196538 0.212653 0.220262 0.205287 0.291951 0.355474 0.24324 0.268334 0.252495 0.212542 0.235423 0.189405 0.157657 0.145577 0.109666 0.113145 0.122261 0.126118 0.124113 0.188351 0.188351 0.188351 0.18267 0.175891 0.180887 0.18523 0.186973 0.187192 0.187052 0.186937 0.186898 0.186893 0.186896 0.186898
# pot 0 0 0 0 0 0 0 0 0 0 0 0 0 0.000399632 0 0 0 0 0 2.26777e-05 0 0 8.54735e-05 1.1564e-06 0.000390721 0.000164568 0.0017881 0.0057345 0.0217522 0.00717832 0.0198881 0.0441045 0.0585996 0.0337647 0.0232431 0.0255138 0.0383783 0.0307446 0.0299408 0.0450466 0.0333894 0.0323022 0.0445487 0.0455495 0.0575684 0.054089 0.0722031 0.0696976 0.0688842 0.0523164 0.0832668 0.0635399 0.0610256 0.0616239 0.0426524 0.0520444 0.0525893 0.0555945 0.082417 0.0428603 0.0428603 0.0428603 0.0415675 0.0400251 0.041162 0.0421503 0.0425468 0.0425966 0.0425649 0.0425387 0.0425297 0.0425285 0.0425292 0.0425298
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
            -3             3           0             0             0             0          8          0          0          0          0          0          0          0  #  LnQ_base_survey(4)
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
             0            12       5.92669          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_peak_trawl(1)
           -10            10        1.4278          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_top_logit_trawl(1)
           -10            10       1.52019          -999          -999             0          3          0          0       1977       2022          3          0          0  #  Age_DblN_ascend_se_trawl(1)
           -10            10      0.320298          -999          -999             0          3          0          0       1977       2022          0          0          0  #  Age_DblN_descend_se_trawl(1)
           -10            10           -10          -999          -999             0         -3          0          0       1977       2022          0          0          0  #  Age_DblN_start_logit_trawl(1)
           -10            10            10          -999          -999             0         -3          0          0       1977       2022          3          0          0  #  Age_DblN_end_logit_trawl(1)
# 2   longline AgeSelex
             0            12       5.12618          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_peak_longline(2)
           -10            10      -7.11793          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_longline(2)
           -10            10      0.294037          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Age_DblN_ascend_se_longline(2)
           -10            10      0.611514          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Age_DblN_descend_se_longline(2)
           -10            10           -10          -999          -999             0         -3          0          0       1978       2022          0          0          0  #  Age_DblN_start_logit_longline(2)
           -10            10      0.398564          -999          -999             0          3          0          0       1978       2022          0          0          0  #  Age_DblN_end_logit_longline(2)
# 3   pot AgeSelex
             0            12       4.10658          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_peak_pot(3)
           -10            10     -0.570187          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_pot(3)
           -10            10      -6.68226          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Age_DblN_ascend_se_pot(3)
           -10            10      -4.07922          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Age_DblN_descend_se_pot(3)
           -10            10           -10          -999          -999             0         -3          0          0       1991       2022          0          0          0  #  Age_DblN_start_logit_pot(3)
           -10            10       1.28789          -999          -999             0          3          0          0       1991       2022          0          0          0  #  Age_DblN_end_logit_pot(3)
# 4   survey AgeSelex
             0            12       1.01032          -999          -999             0          3          0          0       1982       2022          3          0          0  #  Age_DblN_peak_survey(4)
           -10            10     -0.838224          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_top_logit_survey(4)
           -10            10           -10          -999          -999             0         -3          0          0       1982       2022          3          0          0  #  Age_DblN_ascend_se_survey(4)
           -10            10      -1.69803          -999          -999             0          3          0          0          0          0          0          0          0  #  Age_DblN_descend_se_survey(4)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_start_logit_survey(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Age_DblN_end_logit_survey(4)
#_Dirichlet and/or MV Tweedie parameters for composition error
#_multiple_fleets_can_refer_to_same_parm;_but_list_cannot_have_gaps
           -10            10       0             0          -999             0          9          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P1
           -10            10       0             0          -999             0          9          0          0          0          0          0          0          0  #  ln(DM_theta)_Len_P2
           -10            10       0             0          -999             0          9          0          0          0          0          0          0          0  #  ln(DM_theta)_Age_P3
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
#      1     3     1     0     0     0     0     1     1  1990  2022     2 0.00116915  0.271 0.0998174 0.0513476 0.0382164 0.168866 0.165106 0.0955272 0.209939 -0.201038 0.26105 0.166252 0.414421 0.02553 0.378291 -0.320911 -0.396795 -0.328073 -0.529341 -0.558946 0.228356 -0.579149 -0.125543 0.11619 -0.337918 0.738705 0.592573 0.825684 0.863862 0.647308 0.832561 0.381323 1.45592
#      1     4     3     0     0     0     0     2     1  1990  2022     2 0.11779 -0.122185 -0.220688 0.381243 0.133698 0.0185808 0.00732146 -0.0486353 -0.134923 -0.0646202 -0.166833 0.124292 -0.16551 0.112992 -0.100333 -0.304881 0.176207 -0.265503 0.131596 0.24106 -0.142614 -0.0930602 0.188897 -0.279809 0.282114 -0.0267178 0.0418147 -0.369528 0.137848 0.0514223 -0.492501 0.414388 0.0259684
#      1    17     5     2     3     0     0     0     0     0     0     0
#      1    18     6     2     3     0     0     0     0     0     0     0
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
      4      1         16
      4      2         16
      4      3         16
      4      4         2
      5      4         18
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

