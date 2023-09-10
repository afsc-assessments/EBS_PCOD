#V3.30.21.00;_safe;_compile_date:_Feb 10 2023;_Stock_Synthesis_by_Richard_Methot_(NOAA)_using_ADMB_13.1
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
 0.3 0.5 0.425329 0.4 0.1 0 2 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 1   20  14.7724  14.7724   0.244395  6   2 0 5 1977 2023  7 0 0 # L_at_Amin_Fem_GP_1
 60 150 112.958  112.958    5.92116   6  10 0 0    0    0  0 0 0 # L_at_Amax_Fem_GP_1
 0    1   0.109893 0.109893 0.0208198 6   2 0 0    0    0  0 0 0 # VonBert_K_Fem_GP_1
 0   10   1.4942   1.4942   0.113808  6   2 0 5 1977  2023 7 0 0 # Richards_Fem_GP_1
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
            12            16       13.7085             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -0.516211 0 -1 0 1 # SR_regime_BLK1add_1976
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
#  -0.00233588 -0.00147593 -0.00233289 -0.00377021 -0.0060739 -0.00976605 -0.015497 -0.0245447 -0.0383545 -0.0591759 -0.0881518 -0.12717 -0.175858 -0.228895 -0.272627 -0.28159 -0.225077 -0.108783 0.00599391 0.200108 0.200262 0.858575 0.399413 -0.0781314 -0.669138 0.718063 -0.259397 0.762658 0.0988904 -0.757816 -1.73862 -0.460925 0.350226 0.0826051 0.112925 1.00209 0.0716761 -0.412977 -0.604852 0.53322 -0.267011 -0.311402 0.711179 0.238466 -0.376682 -0.313921 -0.358052 -0.714409 -0.169838 0.260451 -0.240021 0.92494 -0.429283 0.580824 0.712804 0.673079 0.939291 -0.546275 -0.101992 -0.734179 -0.17813 0.592433 -0.877951 -0.223069 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 1 0.0756245 0 0 0 6 # InitF_seas_1_flt_1Fishery
#
# F rates by fleet x season
# Yr:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# Fishery 0.0756291 0.101542 0.0865114 0.0839554 0.0920276 0.0671019 0.0853358 0.115967 0.145705 0.141352 0.162921 0.226516 0.208712 0.2299 0.370801 0.396347 0.336968 0.355328 0.421274 0.385281 0.476376 0.385804 0.400196 0.382147 0.31173 0.342453 0.343225 0.36207 0.399331 0.446776 0.475719 0.601758 0.656434 0.544686 0.662359 0.570477 0.506658 0.438735 0.338797 0.297308 0.28777 0.243636 0.216464 0.226705 0.205107 0.242825 0.503513 0.503513 0.467675 0.433385 0.448134 0.468096 0.479252 0.482929 0.483328 0.482941 0.482619 0.482477 0.482441 0.482442 0.482449
#
#_Q_setup for fleets with cpue or survey data
#_1:  fleet number
#_2:  link type: (1=simple q, 1 parm; 2=mirror simple q, 1 mirrored parm; 3=q and power, 2 parm; 4=mirror with offset, 2 parm)
#_3:  extra input for link, i.e. mirror fleet# or dev index number
#_4:  0/1 to select extra sd parameter
#_5:  0/1 for biasadj or not
#_6:  0/1 to float
#_   fleet      link link_info  extra_se   biasadj     float  #  fleetname
         2         1         0         0         0         0  #  Survey
-9999 0 0 0 0 0
#
#_Q_parms(if_any);Qunits_are_ln(q)
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
          -0.5           0.5     -0.252085             0             0             0          6          0          0          0          0          0          0          0  #  LnQ_base_Survey(2)
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
 24 0 0 0 # 1 Fishery
 24 0 0 0 # 2 Survey
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
 0 0 0 0 # 1 Fishery
 0 0 0 0 # 2 Survey
#
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type      PHASE    env-var    use_dev   dev_mnyr   dev_mxyr     dev_PH      Block    Blk_Fxn  #  parm_name
# 1   Fishery LenSelex
            10            80       74.9569          -999          -999             0          3          0          0       1977       2023          8          0          0  #  Size_DblN_peak_Fishery(1)
           -10            10      -9.07665          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Fishery(1)
           -10            10        6.0091          -999          -999             0          3          0          0       1977       2023          8          0          0  #  Size_DblN_ascend_se_Fishery(1)
           -10            10      -8.28792          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Fishery(1)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Fishery(1)
           -10            10       2.72293          -999          -999             0          3          0          0       1977       2023          8          0          0  #  Size_DblN_end_logit_Fishery(1)
# 2   Survey LenSelex
            10            80        20.723          -999          -999             0          3          0          0       1982       2023          9          0          0  #  Size_DblN_peak_Survey(2)
           -10            10       5.77002          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Survey(2)
             0            10       3.77158          -999          -999             0          3          0          2       1982       2023          9          0          0  #  Size_DblN_ascend_se_Survey(2)
           -10            10       8.71995          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Survey(2)
           -10            10          -999          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Survey(2)
           -10            10         -1040          -999          -999             0         -3          0          0       1982       2023          6          0          0  #  Size_DblN_end_logit_Survey(2)
# 1   Fishery AgeSelex# 1   Fishery AgeSelex
# 2   Survey AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
 #        1e-06            10           0.1           0             0             0      -9  # Size_DblN_ascend_se_Fishery(1)_dev_se
 #        -0.99          0.99             0           0             0             0      -9  # Size_DblN_ascend_se_Fishery(1)_dev_autocorr
 #        1e-06            10           0.1           0             0             0      -9  # Size_DblN_end_logit_Fishery(1)_dev_se
 #        -0.99          0.99             0           0             0             0      -9  # Size_DblN_end_logit_Fishery(1)_dev_autocorr
 #        1e-06            10           0.1           0             0             0      -9  # Age_DblN_ascend_se_Survey(2)_dev_se
 #        -0.99          0.99             0           0             0             0      -9  # Age_DblN_ascend_se_Survey(2)_dev_autocorr
         1e-06            10           0.2           0             0             0      -9  # Age_DblN_ascend_se_Survey(2)_dev_se
         -0.99          0.99             0           0             0             0      -9  # Age_DblN_ascend_se_Survey(2)_dev_autocorr


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
#      1     2     1     0     0     0     0     1     1  1977  2023     3 -1.73726 -0.246944 0.297185 1.47124 -0.159386 -0.147954 -0.776493 0.328991 -0.373803 0.289709 0.0517122 -0.302121 -0.114688 -0.270828 -0.0298081 0.0650231 0.679903 -0.588903 -0.646258 -0.748956 -1.16594 -0.58185 -0.0935509 0.758102 -0.0524529 0.196296 0.16028 0.460518 0.531706 0.326411 -0.16264 0.0223942 -0.384839 0.147205 0.0129771 -0.365659 0.172743 -0.221292 0.0446125 0.0228446 -0.192874 0.598839 0.591772 0.522815 0.20505 1.40617      0
#      1     5     3     0     0     0     0     2     1  1977  2023     3 1.97578 -0.367041 1.75347 -0.384007 0.957313 1.04587 0.964972 -0.451842 1.89232 0.232343 0.296697 0.777391 1.02566 0.990348 0.0149033 1.01515 -0.0111583 0.335905 -1.16233 -1.42235 -1.55797 0.110428 0.0100349 -0.948768 0.159513 0.104742 -0.313037 -0.564869 -1.01373 -1.46505 -1.84577 0.282778 -0.070579 -0.0837923 -0.786995 0.650014 -0.224687 -0.0221519 -0.0841088 0.233309 -0.196948 1.10086 -1.10786 -1.43123 0.212033 -0.62558      0
#      1    16     5     2     3     0     0     0     0     0     0     0
#      1    17     6     2     3     0     0     0     0     0     0     0
#      2     4     7     1     1     0     0     0     0     0     0     0
#      5     3     8     0     0     0     0     3     2  1977  2023     6 0.641009 0.525887 0.140879 0.676671 0.650965 -0.184485 0.320979 1.65543 1.1004 1.88188 0.894778 1.26572 0.928415 -0.477996 -0.198638 0.0295151 0.148403 -0.0862617 0.238858 -0.356497 -0.0944141 -0.532949 -0.481005 -0.361164 -0.589143 0.0961284 -0.214358 0.000894954 -0.299002 -0.368819 0.042113 0.116409 -0.262755 -0.138603 -0.417617 -0.257955 0.0324159 -0.292117 -0.797388 -1.10192 -1.11752 -0.559353 -0.395375 0.450613 -1.05266 -1.20031      0
#      5     6    10     0     0     0     0     4     2  1977  2023     6 -0.308329 -0.288979 -0.368145 0.0202068 -0.106883 0.177884 0.104853 -0.0208474 -0.47583 -0.286133 1.38001 1.03499 1.16332 1.56084 -0.0185596 -0.617883 0.092363 -0.179811 -0.318647 2.19633 0.547325 -0.379192 -0.210659 -0.124452 -0.106607 -1.27405 -0.0191577 0.112743 0.559638 2.54373 2.18294 0.591447 -1.4904 -0.803467 -0.93557 -0.685636 -1.72313 -1.57637 -1.23264 -1.44474 -0.543521 -0.115607 -0.761202 0.951189 -0.0159149 1.21256      0
#      5     9    12     0     0     0     0     5     2  1982  2023     6 -0.731395 1.22522 -0.855602 -0.592779 0.100033 -0.223986 -0.424189 -1.30159 0.748688 -0.130301 -0.988385 -0.0110096 0.657882 0.385987 0.491253 0.837971 0.984365 0.0263059 -0.921378 0.93995 -0.075941 0.187121 -0.432038 -0.193449 -0.377139 1.02288 -0.194666 0.123778 -0.410875 1.18878 1.25295 -0.867174 0.253417 0.265362 0.0174788 -0.585272 -0.562947 0.339002      0 0.0406751 -1.20895      0
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
         1     2      0
         4     1    0.032708    #    0.040057    0.032708 0.233054     0.816542   0.534857   1.405753 5.818055  len Fishery     
         4     2    0.061795    #    0.055816    0.061795 0.223615     1.107122   0.696482   5.644781 4.006289  len  Survey     
         5     2    0.246566    #    0.254622    0.246566 0.147996     0.968361   0.674542   1.756978 0.581238  age  Survey     
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
#  1 1 1 1 #_lencomp:_1
#  1 1 1 1 #_lencomp:_2
#  0 0 0 0 #_agecomp:_1
#  1 1 1 1 #_agecomp:_2
#  0 0 0 0 #_size-age:_1
#  0 0 0 0 #_size-age:_2
#  1 1 1 1 #_init_equ_catch1
#  1 1 1 1 #_init_equ_catch2
#  1 1 1 1 #_recruitments
#  1 1 1 1 #_parameter-priors
#  1 1 1 1 #_parameter-dev-vectors
#  1 1 1 1 #_crashPenLambda
#  1 1 1 1 # F_ballpark_lambda
0 # (0/1/2) read specs for more stddev reporting: 0 = skip, 1 = read specs for reporting stdev for selectivity, size, and numbers, 2 = add options for M,Dyn. Bzero, SmryBio
 # 0 2 0 0 # Selectivity: (1) fleet, (2) 1=len/2=age/3=both, (3) year, (4) N selex bins
 # 0 0 # Growth: (1) growth pattern, (2) growth ages
 # 0 0 0 # Numbers-at-age: (1) area(-1 for all), (2) year, (3) N ages
 # -1 # list of bin #'s for selex std (-1 in first bin to self-generate)
 # -1 # list of ages for growth std (-1 in first bin to self-generate)
 # -1 # list of ages for NatAge std (-1 in first bin to self-generate)
999

