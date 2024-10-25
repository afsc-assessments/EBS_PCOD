
Qbt = seq(-0.25,0.5,by=0.05)
Prof_Q=list()

for(i in 1){
Prof_Q<-profile(
  dir=paste0(getwd(),'/',mods[i]),
  oldctlfile = "control.ss_new",
  masterctlfile = lifecycle::deprecated(),
  newctlfile = "control_modified.ss",
  linenum = NULL,
  string = "LnQ_base_survey(2)",
  profilevec = Qbt,
  usepar = FALSE,
  globalpar = FALSE,
  parlinenum = NULL,
  parstring = NULL,
  saveoutput = TRUE,
  overwrite = TRUE,
  whichruns = NULL,
  prior_check = TRUE,
  read_like = lifecycle::deprecated(),
  exe = "ss",
  verbose = TRUE,
  conv_criteria = 0.0001
)
}



profilemodels <- SSgetoutput(dirvec = paste0(getwd(),'/',mods[1]), keyvec = 1:(length(Qbt)-1))
profilesummary <- SSsummarize(profilemodels)


profilemodels <- SSgetoutput(dirvec = paste0(getwd(),'/',mods[1]), keyvec = 1:length(Qbt))
profilesummary <- SSsummarize(profilemodels)

results <- SSplotProfile(profilesummary, # summary object
  profile.string = "LnQ_base_survey", exact=F, # substring of profile parameter
  profile.label = "Log(Q)",
  ymax=10
) 





SigmaR = seq(0.4,1.0,by=0.05)
Prof_SigmaR=list()

for(i in 1:length(mods)){
Prof_SigmaR[[i]]<-profile(
  dir=paste0(getwd(),'/',mods[i]),
  oldctlfile = "control.ss_new",
  masterctlfile = lifecycle::deprecated(),
  newctlfile = "control_modified.ss",
  linenum = NULL,
  string = "SR_sigmaR",
  profilevec = SigmaR,
  usepar = FALSE,
  globalpar = FALSE,
  parlinenum = NULL,
  parstring = NULL,
  saveoutput = TRUE,
  overwrite = TRUE,
  whichruns = NULL,
  prior_check = TRUE,
  read_like = lifecycle::deprecated(),
  exe = "ss",
  verbose = TRUE,
  conv_criteria = 0.01
)
}

profilemodels <- SSgetoutput(dirvec = paste0(getwd(),'/',mods[5]), keyvec = 1:length(SigmaR))
profilesummary <- SSsummarize(profilemodels)



results <- SSplotProfile(profilesummary, # summary object
  profile.string = "SR_sigmaR", # substring of profile parameter
  profile.label = "Sigma R",
  ymax=10
) 


R0 = seq(13.1,13.3,by=0.01)
Prof_R0=list()

for(i in 1:length(mods)){
Prof_R0[[i]]<-profile(
  dir=paste0(getwd(),'/',mods[i]),
  oldctlfile = "control.ss_new",
  masterctlfile = lifecycle::deprecated(),
  newctlfile = "control_modified.ss",
  linenum = NULL,
  string = "SR_LN(R0)",
  profilevec = R0,
  usepar = FALSE,
  globalpar = FALSE,
  parlinenum = NULL,
  parstring = NULL,
  saveoutput = TRUE,
  overwrite = TRUE,
  whichruns = NULL,
  prior_check = TRUE,
  read_like = lifecycle::deprecated(),
  exe = "ss3",
  verbose = TRUE,
  conv_criteria = 0.001
)
}


profilemodels <- SSgetoutput(dirvec = paste0(getwd(),'/',mods[2]), keyvec = 1:length(R0))
profilesummary <- SSsummarize(profilemodels)


results <- SSplotProfile(profilesummary, # summary object
  profile.string = "SR_LN", # substring of profile parameter
  profile.label = "Ln(R0)",
  ymax=10
) 


M = seq(0.2,0.5,by=0.025)

Prof_M=list()

for(i in 1){
Prof_M<-profile(
  dir=paste0(getwd(),'/',mods[i]),
  oldctlfile = "control.ss_new",
  masterctlfile = lifecycle::deprecated(),
  newctlfile = "control_modified.ss",
  linenum = NULL,
  string = "NatM_uniform_Fem_GP_1",
  profilevec = M,
  usepar = FALSE,
  globalpar = FALSE,
  parlinenum = NULL,
  parstring = NULL,
  saveoutput = TRUE,
  overwrite = TRUE,
  whichruns = NULL,
  prior_check = TRUE,
  read_like = lifecycle::deprecated(),
  exe = "ss",
  verbose = TRUE,
  conv_criteria = 0.001
)
}


profilemodels <- SSgetoutput(dirvec = paste0(getwd(),'/',mods[1]), keyvec = 1:(length(M)-1))
profilesummary <- SSsummarize(profilemodels)


results <- SSplotProfile(profilesummary, # summary object
  profile.string = "NatM_uniform_Fem_GP_1", # substring of profile parameter
  profile.label = "Natural mortality",
  ymax=10
) 

PinerPlot(profilesummary, )