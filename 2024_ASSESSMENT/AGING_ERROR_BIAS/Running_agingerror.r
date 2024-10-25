

## splined aging error
data<-AgeingError:::CreateData("dataBoth10.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data_echo.out")
PCOD_spline <- AgeingError:::CreateSpecs("spline5.spc", DataSpecs = data,verbose = TRUE)

PCOD_spline <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data,
  ModelSpecsInp = PCOD_spline,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "Results_spline",
  verbose = TRUE
)


PCOD_spline_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "Results_spline", CalcEff = TRUE, verbose = FALSE)

## linear aging error
data<-AgeingError:::CreateData("dataBoth10.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data_echo.out")
PCOD_linear <- AgeingError:::CreateSpecs("linear.spc", DataSpecs = data,verbose = TRUE)

PCOD_linear <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data,
  ModelSpecsInp = PCOD_linear,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "Results_linear",
  verbose = TRUE
)


PCOD_linear_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "Results_linear", CalcEff = TRUE, verbose = FALSE)


## splined aging error w/bias
data<-AgeingError:::CreateData("dataREREADS.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data_echo.out")
PCOD_spline_bias <- AgeingError:::CreateSpecs("spline5_bias.spc", DataSpecs = data,verbose = TRUE)

PCOD_spline <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data,
  ModelSpecsInp = PCOD_spline_bias,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "Results_spline_bias",
  verbose = TRUE
)


PCOD_spline_bias_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "Results_spline_bias", CalcEff = TRUE, verbose = FALSE)






## splined aging error w/bias
data<-AgeingError:::CreateData("dataREREADS.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data_echo.out")
PCOD_linear_bias <- AgeingError:::CreateSpecs("linear_bias.spc", DataSpecs = data,verbose = TRUE)

PCOD_spline <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data,
  ModelSpecsInp = PCOD_linear_bias,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "Results_linear_bias",
  verbose = TRUE
)


PCOD_linear_bias_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "Results_linear_bias", CalcEff = TRUE, verbose = FALSE)












age_dat<-data.table(read.csv('paired_age_readings.csv'))
x=ageing_comparison(xvec=age_dat$read_age, yvec=age_dat$test_age, scale.pts = 0.75,
                              col.pts = grDevices::heat.colors(100, alpha = .4),
                              col.hist = grDevices::rgb(0, 0, .5, alpha = .7),
                              counts = TRUE, maxage = 14,
                              hist = F, hist.frac = .1,
                              xlab = "Age reader 1",
                              ylab = "Age reader 2",
                              title = NULL,
                              png = FALSE,
                              filename = "ageing_comparison.png",
                              SaveFile = NULL,
                              verbose = TRUE)


x=ageing_comparison(xvec=f3$Second_Age, yvec=f3$Final_Age, scale.pts = 0.75,
                              col.pts = grDevices::heat.colors(100, alpha = .4),
                              col.hist = grDevices::rgb(0, 0, .5, alpha = .7),
                              counts = TRUE, maxage = 14,
                              hist = F, hist.frac = .1,
                              xlab = "2018 Read",
                              ylab = "2004 Read",
                              title = NULL,
                              png = FALSE,
                              filename = "ageing_comparison.png",
                              SaveFile = NULL,
                              verbose = TRUE)