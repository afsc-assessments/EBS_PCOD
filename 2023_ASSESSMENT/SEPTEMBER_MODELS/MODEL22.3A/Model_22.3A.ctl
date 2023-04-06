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
 0 1 0.333388 0 0 0 1 0 0 0 0 0 0 0 # NatM_uniform_Fem_GP_1
# Sex: 1  BioPattern: 1  Growth
 10 20 15.2661 0 0 0 2 0 5 1977 2022 3 0 0 # L_at_Amin_Fem_GP_1
 60 150 120.957 0 0 0 2 0 0 1977 2022 3 0 0 # L_at_Amax_Fem_GP_1
 0 1 0.0950265 0 0 0 2 0 5 1977 2022 3 0 0 # VonBert_K_Fem_GP_1
 0 10 1.54333 0 0 0 2 0 0 0 0 0 0 0 # Richards_Fem_GP_1
 1 5 3.71011 0 0 0 2 0 0 0 0 0 0 0 # SD_young_Fem_GP_1
 1 20 10.0989 0 0 0 2 0 0 0 0 0 0 0 # SD_old_Fem_GP_1
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
 1e-06 10 0.2 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
#  1e-06 10 0.2 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
# -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
  1e-06 10 0.2 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_se
 -0.99 0.99 0 0 0 0 -1 # L_at_Amin_Fem_GP_1_dev_autocorr
 -10 10 0.355775 0 0 0 2 # AgeKeyParm2_BLK2delta_1977
 -10 10 0.832238 0 0 0 2 # AgeKeyParm3_BLK2delta_1977
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
            12            16       12.9732             0             0             0          1          0          0          0          0          0          0          0 # SR_LN(R0)
           -10            10             1             0             0             0         -1          0          0          0          0          0          0          0 # SR_BH_steep
           -10            10        0.6651             0             0             0         -1          0          0          0          0          0          0          0 # SR_sigmaR
           -10            10             0             0             0             0         -1          0          0          0          0          0          1          1 # SR_regime
         -0.99          0.99             0             0             0             0         -1          0          0          0          0          0          0          0 # SR_autocorr
# timevary SR parameters
 -10 10 -1.30942 0 -1 0 1 # SR_regime_BLK1add_1976
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
#  -0.00379847 -0.00247093 -0.0042407 -0.00723193 -0.0124173 -0.0214004 -0.0369147 -0.0631513 -0.106015 -0.171953 -0.262712 -0.377686 -0.507511 -0.63027 -0.702416 -0.641127 -0.277179 0.418583 0.41739 1.07037 0.922836 0.55765 0.654033 -0.99266 -0.682346 0.981881 -0.591934 0.888038 0.0614322 -0.515248 -1.78122 -0.209675 0.4709 0.450727 -0.0339551 0.864502 -0.271033 -0.310457 -0.437111 0.833197 -0.0991674 -0.308795 0.529817 0.344551 -0.974611 -0.0476772 -0.287976 -0.511715 -0.301518 0.774639 -0.251046 1.15332 -0.796641 0.694198 1.00471 0.105972 1.15994 -0.792566 -0.257419 -0.505899 -1.12081 0.783767 -1.03436 -0.120277 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
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
 0 1 0.240435 0 0 0 1 # InitF_seas_1_flt_1Fishery
#
# F rates by fleet x season
# Yr:  1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 2033 2034 2035 2036 2037
# seas:  1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
# Fishery 0.307334 0.377607 0.242575 0.141836 0.135635 0.106181 0.12774 0.147197 0.170311 0.160148 0.184111 0.245662 0.236266 0.267321 0.407832 0.401385 0.335047 0.418428 0.519161 0.519785 0.576874 0.459226 0.451569 0.437778 0.386231 0.38938 0.407493 0.410571 0.453465 0.490626 0.468191 0.54265 0.675086 0.598147 0.714559 0.631923 0.570607 0.572892 0.553645 0.514679 0.40483 0.300184 0.28348 0.27259 0.261776 0.337746 0.246842 0.252798 0.250248 0.252514 0.26188 0.272253 0.27961 0.283559 0.285214 0.285697 0.285715 0.285611 0.285515 0.285456 0.285429
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
          -0.5           0.5     0.0687256             0             0             0          6          0          0          0          0          0          0          0  #  LnQ_base_Survey(2)
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
            40            85       74.7643          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_peak_Fishery(1)
           -10            10       1.11379          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Fishery(1)
           -10            10       6.05078          -999          -999             0          3          0          2       1977       2022          6          0          0  #  Size_DblN_ascend_se_Fishery(1)
           -10            10      -1.23474          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Fishery(1)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Fishery(1)
           -10            10     -0.173268          -999          -999             0          5          0          2       1977       2022          6          0          0  #  Size_DblN_end_logit_Fishery(1)
# 2   Survey LenSelex
            10            70        20.887          -999          -999             0          3          0          1       1982       2022          6          0          0  #  Size_DblN_peak_Survey(2)
           -10            10       1.82281          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_top_logit_Survey(2)
           -10            10       3.52648          -999          -999             0          3          0          2       1982       2022          6          0          0  #  Size_DblN_ascend_se_Survey(2)
           -10            10      -5.99678          -999          -999             0          3          0          0          0          0          0          0          0  #  Size_DblN_descend_se_Survey(2)
           -10            10           -10          -999          -999             0         -3          0          0          0          0          0          0          0  #  Size_DblN_start_logit_Survey(2)
           -10            10     -0.840328          -999          -999             0          5          0          0          0          0          0          0          0  #  Size_DblN_end_logit_Survey(2)
# 1   Fishery AgeSelex
# 2   Survey AgeSelex
#_No_Dirichlet parameters
# timevary selex parameters 
#_          LO            HI          INIT         PRIOR         PR_SD       PR_type    PHASE  #  parm_name
         1e-06            10        0.1639             0             0             0      -9  # Size_DblN_ascend_se_Fishery(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_Fishery(1)_dev_autocorr
         1e-06            10        0.7726             0             0             0      -9  # Size_DblN_end_logit_Fishery(1)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_end_logit_Fishery(1)_dev_autocorr
         1e-06            10        0.2092             0             0             0      -9  # Size_DblN_peak_Survey(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_peak_Survey(2)_dev_autocorr
         1e-06            10         0.771             0             0             0      -9  # Size_DblN_ascend_se_Survey(2)_dev_se
         -0.99          0.99             0             0             0             0      -9  # Size_DblN_ascend_se_Survey(2)_dev_autocorr
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
#      1     2     1     0     0     0     0     1     1  1977  2022     3 1.31971 0.0648024 0.358683 0.10671 -1.3901 -1.21199 1.11135 -0.00366166 -1.80773 -0.117007 -0.738746 -1.18464 -0.949159 -0.153619 0.101761 -0.113849 0.27621 -0.570874 -0.669359 -0.282396 -0.344279 -1.00836 -1.38457 0.515665 0.323517 0.442499 0.0814894 1.20126 -0.323844 -0.517926 -1.29122 -1.20511 -1.1062 0.0225527 -1.31507 0.274649 -0.549189 -0.109528 1.24731 1.42036 1.49811 2.01872 1.79856 1.04984 0.33535 2.77931
#      1    16     3     2     3     0     0     0     0     0     0     0
#      1    17     4     2     3     0     0     0     0     0     0     0
#      2     4     5     1     1     0     0     0     0     0     0     0
#      5     3     6     0     0     0     0     2     2  1977  2022     6 0.605322 -0.370426 -0.512168 0.7899 0.873128 -0.151617 0.132199 2.20159 2.33405 2.72059 1.27978 2.0016 0.919364 -0.889105 -0.389876 0.269173 0.50657 -0.084923 0.660149 -0.905746 -0.0486357 -0.877054 -0.606247 -0.249492 -0.983677 0.520012 -0.0343553 0.545427 -0.0297988 -0.215945 0.401521 0.710246 -0.32224 -0.563849 -0.732501 -0.285287 0.155407 -0.494965 -1.86617 -2.24582 -1.77593 -0.627273 -0.415087 1.07485 -1.68281 -1.33984
#      5     6     8     0     0     0     0     3     2  1977  2022     6 -0.0191911 -0.00605709 -0.00420122 -0.0010123 0.000243988 0.00141947 -0.00234222 -0.00356074 -0.00361777 0.0147204 0.00455069 -0.00133337 0.0056472 -0.027938 -0.191837 -0.139812 0.074154 -0.0381282 -0.114976 -0.0561147 -0.0616786 0.0784059 0.0804276 0.115732 0.0232793 0.0252164 -0.0690582 0.0406739 -0.0456472 0.0598247 0.0335009 0.0407023 0.0272254 0.0383474 -0.00390806 -0.00546064 -0.000409192 -0.00109518 -0.00577289 -0.00017939 -0.00539742 -0.0100954 0.0186411 0.0442855 0.144083 -0.0522542
#      5     7    10     0     0     0     0     4     1  1982  2022     6 -0.526556 -0.452684 1.39526 0.448674 -0.763238 -0.0286055 -0.0974768 0.309215 -0.443152 1.33679 -0.305438 0.144872 0.427439 0.568073 0.270538 0.957387 2.2954 0.614013 -0.828687 -0.626755 -0.528087 0.405471 0.181049 -0.639913 -1.65436 -2.40679 -1.59957 -0.559204 -0.51085 -0.0304456 -2.28144 1.23596 -0.15538 0.414807 1.1406 1.57537 0.80908 -1.17413      0 0.610847 0.471606
#      5     9    12     0     0     0     0     5     2  1982  2022     6 -0.976059 0.0679205 1.22711 0.589929 -0.500775 -0.152184 -0.287214 -0.0391754 -0.0474215 1.75068 -0.277929 0.78943 0.543623 0.387348 -0.268604 0.996939 2.32743 0.713283 -0.888438 -0.169315 -0.543615 0.511603 0.1844 -0.792716 -1.47833 -2.68513 -1.78547 0.624671 -0.702381 -0.0702135 -1.91955 1.40851 -0.195061 0.481422 0.834067 1.26464 -0.122945 -1.19793      0 0.188465 0.209039
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
      4      1  0.114442
      4      2   1.64127
      5      2  0.220366
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

