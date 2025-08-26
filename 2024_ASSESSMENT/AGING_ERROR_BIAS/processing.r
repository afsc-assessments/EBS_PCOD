

data2<-AgeingError:::CreateData("dataBSAll.dat", NDataSet = 1, verbose = TRUE, EchoFile = "dataAll_echo.out")

PCOD2_spc <- AgeingError:::CreateSpecs("control3.spc", DataSpecs = data2,verbose = TRUE)


PCOD2_mod <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data2,
  ModelSpecsInp = PCOD2_spc,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "ResultsBS10_Spline",
  verbose = TRUE
)



PCOD2_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "ResultsBS10_Spline", CalcEff = TRUE, verbose = FALSE)












data1<-AgeingError:::CreateData("dataBoth10.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data1_echo.out")

PCOD1_spc <- AgeingError:::CreateSpecs("control3.spc", DataSpecs = data1,verbose = TRUE)


PCOD1_mod <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data1,
  ModelSpecsInp = PCOD1_spc,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "ResultsBoth_Linear",
  verbose = TRUE
)



PCOD1_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "ResultsBoth_Linear", CalcEff = TRUE, verbose = FALSE)


## 2000-2007 data aging error


data2000<-AgeingError:::CreateData("data2000.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data2000_echo.out")

PCOD2000_spc <- AgeingError:::CreateSpecs("control2.spc", DataSpecs = data2000,verbose = TRUE)


PCOD2000_mod <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data2000,
  ModelSpecsInp = PCOD2000_spc,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "Results2000",
  verbose = TRUE
)


PCOD2000_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "Results2000", CalcEff = TRUE, verbose = FALSE)



## 2007-2023 data aging error


data2007<-AgeingError:::CreateData("data2007.dat", NDataSet = 1, verbose = TRUE, EchoFile = "data2007_echo.out")

PCOD2007_spc <- AgeingError:::CreateSpecs("control2.spc", DataSpecs = data2007,verbose = TRUE)


PCOD2007_mod <- AgeingError::DoApplyAgeError(
  Species = "Pcod",
  DataSpecs = data2007,
  ModelSpecsInp = PCOD2007_spc,
  AprobWght = 1e-06,
  SlopeWght = 0.01,
  SaveDir = "Results2007",
  verbose = TRUE
)


PCOD2007_out <- AgeingError:::ProcessResults(Species = "Pcod", SaveDir = "Results2007", CalcEff = TRUE, verbose = FALSE)


