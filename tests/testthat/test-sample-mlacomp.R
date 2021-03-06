context("sample_mlacomp() is working")

temp_path <- file.path(tempdir(), "ss3sim-test")
dir.create(temp_path, showWarnings = FALSE)
wd <- getwd()
setwd(temp_path)

test_that("sample_mlacomp() works", {
  datfile <- r4ss::SS_readdat(system.file("extdata/models/cod-om/codOM.dat", package = "ss3sim"), verbose = FALSE)
  fctl <- system.file("extdata/models/cod-om/codOM.ctl", package = "ss3sim")
  newdat <- change_data(datfile, outfile = "codOM-temp.dat",
    types = c("age", "mla"), fleets = 1, years = 2000:2012, write_file = FALSE)
  set.seed(123)
  newdat <- change_fltname(newdat)
  out <- sample_mlacomp(newdat, outfile = "ignore.dat", ctlfile = fctl,
    Nsamp = list(rep(50, 13)), years = list(2000:2012), write_file = FALSE,
    mean_outfile = NULL)
  expect_equal(names(out$MeanSize_at_Age_obs),
    c("Yr", "Seas", "FltSvy", "Gender", "Part", "AgeErr", "Nsamp", "a1",
      "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11",
      "a12", "a13", "a14", "a15", "N1", "N2", "N3", "N4", "N5", "N6",
      "N7", "N8", "N9", "N10", "N11", "N12", "N13", "N14", "N15"))
  expect_equal(round(out$MeanSize_at_Age_obs$a1, 2),
    c(0.9, 0.99, 1, 0.96, 0.97, 1.09, 0.96, 0.99, 1.05, 0.99, 0.96,
      0.87, 1.12))
})

test_that("mean of sample_mlacomp() is unbiased", {
  datfile <- r4ss::SS_readdat(system.file("extdata/models/cod-om/codOM.dat",
    package = "ss3sim"), verbose = FALSE)
  fctl <- system.file("extdata/models/cod-om/codOM.ctl", package = "ss3sim")
  newdat <- change_data(datfile, outfile = NULL, types = c("age", "mla"),
    fleets = 1, years = 2000, write_file = FALSE)
  newdat <- change_fltname(newdat)
  newdat$agecomp$Nsamp <- 800000
  ctlfile <- system.file("extdata/models/cod-om/codOM.ctl", package = "ss3sim")
  out <- sample_mlacomp(newdat, outfile = NULL, ctlfile = ctlfile,
    Nsamp = list(rep(800000, 1)), years = list(2000), write_file = FALSE,
    mean_outfile = NULL)
  result <- out$MeanSize_at_Age_obs[, -(1:9)]
  samplesize <- result[grepl("N", names(result))]
  proportion <- result[grepl("a", names(result))]
  expect_equal(mean(as.numeric(proportion[proportion > -1]), 3), 1,
               tolerance = .Machine$double.eps ^ 0.2)
})

setwd(wd)
