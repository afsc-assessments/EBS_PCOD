#V3.30.21.00;_safe;_compile_date:_Feb 10 2023;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.1
#_Stock_Synthesis_is_a_work_of_the_U.S._Government_and_is_not_subject_to_copyright_protection_in_the_United_States.
#_Foreign_copyrights_may_apply._See_copyright.txt_for_more_information.
#_User_support_available_at:NMFS.Stock.Synthesis@noaa.gov
#_User_info_available_at:https://vlab.noaa.gov/group/stock-synthesis
#_Source_code_at:_https://github.com/nmfs-stock-synthesis/stock-synthesis

#_data_and_control_files: BSPcod23b2.dat // control_modified.ss
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
 1994 2007
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
 0.3 0.5 0.309998 0.4 0.1 0 2 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 1 20 14.7717 14.7927 0.243848 6 2 0 5 1977 2023 7 0 0 # L_at_Amin_Fem_GP_1
 60 150 116.215 112.011 4.45498 6 10 0 0 0 0 0 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.0938586 0.113517 0.0170864 6 2 0 0 0 0 0 0 0 # VonBert_K_Fem_GP_1
 0 10 1.71734 1.7843 0.100468 6 2 0 5 1977 2023 7 0 0 # Richards_Fem_GP_1
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
 0 1 0.4416 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 0 1 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 0 1 0.2995 0 0 0 -1 # Richards_Fem_GP_1_dev_se
 0 1 0 0 0 0 -1 # Richards_Fem_GP_1_dev_autocorr
 -10 10 0.38 0 0 0 -2 # AgeKeyParm2_BLK2delta_1994
 -10 10 1.2 0 0 0 -2 # AgeKeyParm3_BLK2delta_1994
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
            12            16         12.64             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.615591 0 -1 0 1 # SR_regime_BLK1add_1976
1 #do_recdev:  0=none; 1=devvector (R=F(SSB)+dev); 2=deviations (R=F(SSB)+dev); 3=deviations (R=R0*dev; dev2=R-f(SSB)); 4=like 3 with sum(dev2) adding penalty
1977 # first year of main recr_devs; early devs can preceed this era
2020 # last year of main recr_devs; forecast devs start in following year
1 #_recdev phase 
1 # (0/1) to read 13 advanced options
 -20 #_recdev_early_start (0=none; neg value makes relative to recdev_start)
 1 #_recdev_early_phase
 -1 #_forecast_recruitment phase (incl. late recr) (0 value resets to maxphase+1)
 1 #_lambda for Fcast_recr_like occurring before endyr+1
 1977 #_last_yr_nobias_adj_in_MPD; begin of ramp
 1980.4 #_first_yr_fullbias_adj_in_MPD; begin of plateau
 2019.9 #_last_yr_fullbias_adj_in_MPD
 2038.6 #_end_yr_for_ramp_in_MPD (can be in forecast to shape ramp, but SS3 sets bias_adj to 0.0 for fcast yrs)
 0.9331 #_max_bias_adj_in_MPD (typical ~0.8; -3 sets all years to 0.0; -2 sets all non-forecast yrs w/ estimated recdevs to 1.0; -1 sets biasadj=1.0 for all yrs w/ recdevs)
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
#  1965E 1966E 1967E 1968E 1969E 1970E 1971E 1972E 1973E 1974E 1975E 1976E 1977R 1978R 1979R 1980R 1981R 1982R 1983R 1984R 1985R 1986R 1987R 1988R 1989R 1990R 1991R 1992R 1993R 1994R 1995R 1996R 1997R 1998R 1999R 2000R 2001R 2002R 2003R 2004R 2005R 2006R 2007R 2008R 2009R 2010R 2011R 2012R 2013R 2014R 2015R 2016R 2017R 2018R 2019R 2020R 2021F 2022F 2023F 2024F 2025F 2026F 2027F 2028F 2029F 2030F 2031F 2032F 2033F 2034F 2035F 2036F 2037F
#  -0.00145423 -0.00880611 -0.0202145 -0.043718 -0.0756501 -0.103653 -0.10654 -0.106154 -0.153626 -0.200526 -0.150805 -0.0446189 0.334487 0.66056 0.113241 -0.337384 -0.851887 0.755578 -0.374446 0.75942 0.00140006 -0.782074 -1.72715 -0.352028 0.374188 0.165865 0.228637 0.928096 0.305516 -0.451836 -0.613736 0.566417 -0.173557 -0.315521 0.688728 0.371781 -0.371287 -0.239069 -0.318434 -0.613145 -0.11162 0.34707 -0.120234 1.01475 -0.436884 0.658517 0.790701 0.713203 1.02057 -0.777878 -0.408654 -0.649805 -0.351659 0.745929 -1.01875 -0.147607 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#
#Fishing Mortality info 
0.2 # F ballpark value in units of annual_F
1999 # F ballpark year (neg value to disable)
3 # F_Method:  1=Pope midseason rate; 2=F as parameter; 3=F as hybrid; 4=fleet-specific parm/hybrid (#4 is superset of #2 and #3 and is recommended)
3 # max F (methods 2-4) or harvest fraction (method 1)
5  # N iterations for tuning in hybrid mode; recommend 3 (faster) to 5 (more precise if many fleets)
#
#_initial_F_parms; for each fleet x season that has init_catch; nest season in fleet; count = 2
#_for unconstrained init_F, use an arbitrary initial catch and set lambda=0 for its logL
#_ LO HI INIT PRIOR PR_SD  PR_type  PHASE
 0 1 0.875782 0 0 0 6 # InitF_seas_1_flt_1trawl
 0 1 0.0161877 0 0 0 6 # InitF_seas_1_flt_2longline
#
# F rates by fleet x season
# Yr:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# trawl 0.632375 0.671897 0.425872 0.242652 0.226179 0.154469 0.179043 0.191511 0.21512 0.220286 0.209263 0.424026 0.357609 0.29877 0.428704 0.380445 0.411452 0.32903 0.366173 0.291866 0.333172 0.26707 0.276286 0.280715 0.158974 0.212763 0.179535 0.20749 0.2025 0.238197 0.243512 0.219844 0.259628 0.253806 0.356668 0.345044 0.329395 0.262865 0.205154 0.196051 0.181354 0.158419 0.124635 0.140527 0.122715 0.129683 0.128458 0.135595 0.136894 0.141179 0.147653 0.153381 0.156034 0.156034 0.156034 0.156034 0.156034 0.156034 0.156034 0.156034 0.156034
# longline 0.0195072 0.0645071 0.0314946 0.0412591 0.0222345 0.0108938 0.0118324 0.0448575 0.0667379 0.0481385 0.0882619 0.00455665 0.0260813 0.0996857 0.232765 0.359453 0.220024 0.258305 0.275236 0.236131 0.346739 0.318395 0.386249 0.368419 0.336372 0.358608 0.356488 0.324835 0.368752 0.372064 0.354261 0.510021 0.600818 0.425387 0.568478 0.491159 0.420541 0.399325 0.330845 0.290324 0.268065 0.223623 0.194878 0.176218 0.163808 0.176566 0.11566 0.122087 0.123257 0.127114 0.132944 0.138101 0.140489 0.140489 0.140489 0.140489 0.140489 0.140489 0.140489 0.140489 0.140489
# pot 0.00080111 0 0 0 0 0 4.09683e-05 0 0 0.000125771 2.06489e-06 0.000629646 0.000304398 0.00317078 0.0108138 0.0388014 0.0117735 0.0326716 0.0665525 0.0901411 0.0744065 0.0569807 0.06879 0.0898426 0.0751132 0.0650435 0.0801673 0.0617977 0.0645023 0.0842878 0.0915972 0.117064 0.106736 0.131397 0.174941 0.142753 0.127924 0.154252 0.123775 0.130868 0.120444 0.101421 0.100835 0.0886897 0.0823737 0.115329 0.0295691 0.0312121 0.0315111 0.0324973 0.0339877 0.0353061 0.0359167 0.0359167 0.0359167 0.0359167 0.0359167 0.0359167 0.0359167 0.0359167 0.0359167
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
 -0.5 0.5 0.5 0 0 0 -6 0 0 0 0 0 0 0 #  LnQ_base_survey(4)
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
            10           100        83.242          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_peak_trawl(1)
           -10            10      0.742355          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_trawl(1)
           -10            10       6.62935          -999          -999             0          3          0          0          0          0          6          0          0  #  Size_DblN_ascend_se_trawl(1)
           -10            10      0.030143          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_trawl(1)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_trawl(1)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_trawl(1)
# 2   longline LenSelex
            10            80       68.1543          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_peak_longline(2)
           -10            10      -2.01944          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_longline(2)
           -10            10        5.3279          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_ascend_se_longline(2)
           -10            10     -0.328306          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_longline(2)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_longline(2)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_longline(2)
# 3   pot LenSelex
            10            80       71.0132          -999          -999             0          3          0          0          0          0          8          0          0  #  Size_DblN_peak_pot(3)
           -10            10      -2.67616          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_pot(3)
           -10            10       5.09459          -999          -999             0          3          0          0          0          0          8          0          0  #  Size_DblN_ascend_se_pot(3)
           -10            10     -0.462583          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_pot(3)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_pot(3)
           -10            10            10          -999          -999             0         -3          0          0          0          0          8          0          0  #  Size_DblN_end_logit_pot(3)
# 4   survey LenSelex
            10            80       21.1643          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_peak_survey(4)
           -10            10      -4.42146          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_survey(4)
             0            10        3.7104          -999          -999             0          3          0          2       1982       2023          9          0          0  #  Size_DblN_ascend_se_survey(4)
           -10            10      -1.62959          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_survey(4)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_survey(4)
           -10            10            10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_end_logit_survey(4)
# 1   trawl AgeSelex
# 2   longline AgeSelex
# 3   pot AgeSelex
# 4   survey AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
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
#      1     2     1     0     0     0     0     1     5  1977  2023     7 -0.616021 -0.103121 -0.0629531 0.0663325 -0.390246 -0.655709 -1.946  1.644 -1.12924 0.766799 -0.468405 -0.982811 -0.597776 -0.883685 -0.282901 0.235499 1.36701 -0.71509 -0.0536379 -0.622758 -0.541015 -0.769283 -1.09859 1.88408 -0.552998 0.524662 -0.154389 0.657001 1.11121 1.44626 -0.416702 0.0611259 -0.872934 0.707474 1.16017 -1.68232 0.50898 0.184601 0.162512 -0.458698 -0.60276 1.77845 0.045983 1.15647 0.571189 0.030016      0
#      1     5     3     0     0     0     0     2     5  1977  2023     7 -1.85402 -0.78182 -0.736339 -0.0197981 -0.193544 0.332625 0.0993394 -1.01436 0.63339 -0.442564 -0.0472783 -0.00155656 0.841027 0.140954 -0.191919 -0.347597 0.606131 0.193766 0.0672933 -0.66642 -0.321597 -0.563218 -0.197659 0.449488 0.0252008 -0.379045 0.333067 -0.181909 -0.00309849 0.0566915 -0.0371614 -0.418611 0.502059 -0.595464 0.16993 0.441947 -0.36516 0.381831 -0.463116 0.269041 -0.954998 1.06831 1.02115 -0.394357 -0.187537 0.900697      0
#      1    16     5     2     3     0     0     0     0     0     0     0
#      1    17     6     2     3     0     0     0     0     0     0     0
#      2     4     7     1     1     0     0     0     0     0     0     0
#      5    21     8     0     0     0     0     3     2  1982  2023     9 -0.352311 1.87116 -0.691109 -0.104698 0.50168 -0.000254031 -0.277775 -1.38341 0.904945 0.074392 -0.668608 0.399105 0.818288 -0.222792 -0.0776711 -0.270426 -0.169392 -0.292336 -0.479498 0.93941 -0.240539 0.1347 -0.144483 0.17492 -0.0544788 0.730459 -0.424817 0.0304513 -0.427982 0.249784 0.471006 -0.675814 0.26069 0.00373645 0.031799 -0.304778 -0.382923 0.892133      0 0.315048 -1.15763      0
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
      4      1  0.016077
      4      2  0.031013
      4      3  0.022622
      4      4  0.107845
      5      4  0.245747
 -9999   1    0  # terminator
#
1 #_maxlambdaphase
1 #_sd_offset; must be 1 if any growthCV, sigmaR, or survey extraSD is an estimated parameter
# read 1 changes to default Lambdas (default value is 1.0)
# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch; 
# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark; 18=initEQregime
#like_comp fleet  phase  value  sizefreq_method
 7 4 1 0 1
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
#  0 #_size-age:_1
#  0 #_size-age:_2
#  0 #_size-age:_3
#  0 #_size-age:_4
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

