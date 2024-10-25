



# Stock synthesis model example
# AI Pacific cod length compositions
# SS3 verson info: SS_V3_30_21

# Installation info for r4ss:
# install.packages("pak")
# pak::pkg_install("r4ss/r4ss")
library(r4ss)

# afscOSA relies on compResidual:
# https://github.com/fishfollower/compResidual#composition-residuals for
# installation instructions

# TMB:::install.contrib("https://github.com/vtrijoulet/OSA_multivariate_dists/archive/main.zip")
# devtools::install_github("fishfollower/compResidual/compResidual")
library(compResidual)

# other afscOSA package dependencies:
library(ggplot2)
library(cowplot)
library(here)
library(dplyr)
library(reshape2)
library(here)

library(afscOSA)

# create directory for analysis
# out_path <- "test_aicod"
if(!exists("out_path")) out_path = getwd()
if(!dir.exists(out_path)) dir.create(out_path)

# copy all data files to working directory
pkg_path <- find.package('afscOSA')
example_data_files <- list.files(path = file.path(pkg_path, "examples", "AI_PCOD"))
example_data_files
file.copy(from = file.path(path = file.path(pkg_path, "examples", "AI_PCOD"),
                           example_data_files),
          to = file.path(file.path(out_path), example_data_files),
          overwrite = TRUE)

setwd(out_path)




plottingSSOSA_lengths <- function(mods=mods1,type=c("Fishery","EBS Survey"),names=names1,NS1=100,NM=1,flt1=c(1,2),sx=1){

# comps for the fleets defined in "fleet" and "sx"
  comps <- as.data.frame(mods[[NM]]$lendbase[,c(1,6,13,16:18)])
  comps <- comps[comps$Fleet %in% flt1 & comps$Sex %in% sx, ]
  comps <- reshape2::melt(comps,id.vars = c('Yr','Fleet','Sex','Bin'))

# input sample sizes for the fleets defined in "fleet" and "sx"
  Ndf <- as.data.frame(mods[[NM]]$lendbase[,c(1,6,13,16,22)])
  Ndf <- Ndf[Ndf$Bin == min(Ndf$Bin),]


# length bins
  lens <- sort(unique(comps$Bin))

# fishery (fleet 1) ----

  flt <- flt1[1] # USER INPUT

# this is a 1 sex model but if it had sex structure you would define each sex as
# a separate fleet (e.g., Fishery F and Fishery M)
  tmp <- comps[comps$Fleet==flt,]

# input sample sizes (vector)
  N <- Ndf$effN[Ndf$Fleet==flt]

# observed values -> put in matrix format (nrow = nyr, ncol = age/length)
  obs <- tmp[tmp$variable=='Obs',]
  obs <- reshape2::dcast(obs, Yr~Bin, value.var = "value")
  yrs <- obs$Yr # years sampled
  obs <- as.matrix(obs[,-1])

# expected values -> put in matrix format (nrow = nyr, ncol = age/length
  exp <- tmp[tmp$variable=='Exp',]
  exp <- reshape2::dcast(exp, Yr~Bin, value.var = "value")
  exp <- as.matrix(exp[,-1])

# should all be true!
  length(N) == length(yrs); length(N) == nrow(obs); nrow(obs) == nrow(exp)
  ncol(obs);ncol(exp);length(lens)

  out1 <- run_osa(fleet = paste0(type[1],' ',names[NM]), index_label = 'Length',
                         obs = obs, exp = exp, N = N, NS=NS1,index = lens, years = yrs)
  input <- list(out1)

if(length(flt1)>1){
# this is a 1 sex model but if it had sex structure you would define each sex as
# a separate fleet (e.g., Survey F and Survey M)
    flt=flt1[2]
    tmp <- comps[comps$Fleet==flt,]

# input sample sizes (vector)
    N <- Ndf$effN[Ndf$Fleet==flt]

# observed values -> put in matrix format (nrow = nyr, ncol = age/length)
    obs <- tmp[tmp$variable=='Obs',]
    obs <- reshape2::dcast(obs, Yr~Bin, value.var = "value")
    yrs <- obs$Yr # years sampled
    obs <- as.matrix(obs[,-1])

# expected values -> put in matrix format (nrow = nyr, ncol = age/length
    exp <- tmp[tmp$variable=='Exp',]
    exp <- reshape2::dcast(exp, Yr~Bin, value.var = "value")
    exp <- as.matrix(exp[,-1])

# should all be true!
    length(N) == length(yrs); length(N) == nrow(obs); nrow(obs) == nrow(exp)
    ncol(obs);ncol(exp);length(lens)

    out2 <- run_osa(fleet = paste0(type[2],' ',names[NM]), index_label = 'Length',
                         obs = obs, exp = exp, N = N, NS=NS1,index = lens, years = yrs)

# plot results ----
    input <- list(out1, out2)
  }

  osaplots <- plot_osa(input) # this saves a file in working directory or outpath called "osa_length_diagnostics.png"
}




names1<-c("Model 23.1.0.d","Model 24.0","Model 24.1","Model 24.2","Model 24.3")

pdf("SURVEY_LENGTHS_OSA.pdf")
for(i in 1:length(models)){

  plottingSSOSA_lengths(mods=mods1,type=c("Fishery","EBS Survey"),names=names1,NS1=100,NM=i,flt1=c(1,2))
}
dev.off()






## plotting Agecomps
plottingSSOSA_ages <- function(mods=mods1,names=models,NS1=100,NM=1,sx=1,flt1=2){

# comps for the fleets defined in "fleet" and "sx"
  comps <- as.data.frame(mods[[NM]]$agedbase[,c(1,6,13,16:18)])
  comps <- comps[comps$Fleet %in% flt1 & comps$Sex %in% sx, ]
  comps <- reshape2::melt(comps,id.vars = c('Yr','Fleet','Sex','Bin'))

# input sample sizes for the fleets defined in "fleet" and "sx"
  Ndf <- as.data.frame(mods[[NM]]$agedbase[,c(1,6,13,16,22)])
  Ndf <- Ndf[Ndf$Bin == min(Ndf$Bin),]

# length bins
  lens <- sort(unique(comps$Bin))

# fishery (fleet 1) ----

  flt <- flt1 # USER INPUT

# this is a 1 sex model but if it had sex structure you would define each sex as
# a separate fleet (e.g., Fishery F and Fishery M)
  tmp <- comps[comps$Fleet==flt,]

# input sample sizes (vector)
  N <- Ndf$effN[Ndf$Fleet==flt]

# observed values -> put in matrix format (nrow = nyr, ncol = age/length)
  obs <- tmp[tmp$variable=='Obs',]
  obs <- reshape2::dcast(obs, Yr~Bin, value.var = "value")
  yrs <- obs$Yr # years sampled
  obs <- as.matrix(obs[,-1])

# expected values -> put in matrix format (nrow = nyr, ncol = age/length
  exp <- tmp[tmp$variable=='Exp',]
  exp <- reshape2::dcast(exp, Yr~Bin, value.var = "value")
  exp <- as.matrix(exp[,-1])

# should all be true!
  length(N) == length(yrs); length(N) == nrow(obs); nrow(obs) == nrow(exp)
  ncol(obs);ncol(exp);length(lens)

  out1 <- run_osa(fleet = paste0('EBS Survey ',names[NM]), index_label = 'Age',
                         obs = obs, exp = exp, N = N, index = lens, years = yrs)
# plot results ----
  input <- list(out1)
  osaplots <- plot_osa(input) 
}

names1<-c("Model 23.1.0.d","Model 24.0","Model 24.1","Model 24.2","Model 24.3")

pdf("SURVEY_AGES_OSA.pdf")
for(i in 1:length(models)){

  plottingSSOSA_ages(mods=mods1,names=names1,NS=NS1,NM=i,sx=1,flt1=2)
}
dev.off()

# this saves a file in working directory or outpath called "osa_length_diagnostics.png"
# extract individual figures for additional formatting:
osaplots$bubble
osaplots$qq
osaplots$aggcomp






















run_osa <- function(obs, exp, N, NS=100, fleet, index, years, index_label = 'Age or Length'){

  # check dimensions
  stopifnot(all.equal(nrow(obs), nrow(exp), length(N), length(years)))
  stopifnot(all.equal(ncol(obs), ncol(exp),  length(index)))

  # calculate osa residuals for multinomial (note the rounding here, multinomial
  # expects integer) - sum of obs should equal N
  o <- round(N*obs/rowSums(obs), 0); p <- exp/rowSums(exp)
  # o <-N*obs/rowSums(obs); p <- exp/rowSums(exp)
  
  #res <- compResidual::resMulti(t(o), t(p))

  res1<-list()
  sdnr1<-list()
  for(i in 1:NS){
    res1[[i]] <- compResidual::resMulti(t(o), t(p))
    sdnr1[[i]]<-sd(res1[[i]])
  }
  sdnr<-data.table::data.table(do.call(rbind,sdnr1))
  names(sdnr)="sdnr"
  sdnr$ID<-1:nrow(sdnr)
  sdnr<-sdnr[order(sdnr),]
  n=1
  if(NS>1){n=trunc(NS/2)}

  res=res1[[sdnr$ID[n]]]  ## pick the median


  # aggregated fits to the composition data
  oagg <- colSums(o)/sum(o)
  eagg <- colSums(p)/sum(p)
  agg <- data.frame(fleet = fleet, index_label = index_label, index = index, obs = oagg, exp = eagg)

  if(!all(is.finite(res))){
    warning("failed to calculate OSA residuals.")
    return(NULL)
  }

  # long format dataframe for residuals
  mat <- t(matrix(res, nrow=nrow(res), ncol=ncol(res)))
  # FLAG - check this change:
  # dimnames(mat) <- list(year=years, index=index[-1])
  dimnames(mat) <- list(year=years, index=index[1:(length(index)-1)])
  res <- reshape2::melt(mat, value.name='resid') %>%
    dplyr::mutate(fleet = fleet,
                   index_label = index_label) %>%
    dplyr::relocate(fleet, index_label, .before = year)

  return(list(res = res, agg = agg))
}


#' Plot OSA residuals for one for more fleets
#'
#' @param input a \emph{list} of the output from one more runs of
#'   \code{\link{run_osa}}, which includes \code{res}, a long-format dataframe
#'   with the following columns: fleet, index_label (indicates whether the comp
#'   is age or length), year, index (age or length bin), resid (osa), and
#'   \code{agg}, a dataframe with the observed and expected values
#'   for the index aggregated across all years (and appropriately weighted by N)
#' @param outpath (default=NULL) directory to save figures to (e.g., "figs")
#' @param figheight (default=8 in) figure height in inches, user may want to increase
#'   if they have a large number of ages or lengths
#' @param figwidth (default=NULL) by default the function scales the figure width by
#'   the number of fleets being plotted. user may want to overwrite depending on
#'   other variables like the number of years in the model.
#'
#' @return Saves a multipanel figure with OSA bubble plots, standard normal QQ plots,
#'   and aggregated fits to the composition data for one or more fleets. Also
#'   returns these plots as an outputted list for further refinement by user if
#'   needed.
#'
#' @import ggplot2
#'
#' @export
#' @seealso \code{\link{run_osa}}
#'
#' @examples
#' # GOA pollock info
#' repfile <- afscOSA::goapkrep
#' datfile <- afscOSA::goapkdat
#'
#' # ages and years for age comp data
#' ages <- 3:10
#' yrs <- datfile$srv_acyrs1
#' # observed age comps
#' myobs <- repfile$Survey_1_observed_and_expected_age_comp[ ,ages]
#' # predicted age comps from assessment model
#' myexp <- repfile$Survey_1_observed_and_expected_age_comp[ ,10+ages]
#' # assumed effective sample sizes
#' myN <- datfile$multN_srv1 # this gets rounded
#' #
#' myfleet='Survey1'
#' out1 <- run_osa(obs = myobs, exp = myexp, N = myN, index = ages, years = yrs, index_label = 'Age')
#'
#' # survey2
#' yrs <- datfile$srv_acyrs2
#' obs <- repfile$Survey_2_observed_and_expected_age_comp[ ,ages]
#' exp <- repfile$Survey_2_observed_and_expected_age_comp[ ,10+ages]
#' N <- datfile$multN_srv2 # this gets rounded
#' out2 <- run_osa(fleet = 'Survey2', index_label = 'Age',
#'                 obs = obs, exp = exp, N = N, index = ages, years = yrs)
#'
#'# needs to be in list format
#' input <- list(out1, out2)
#' osaplots <- plot_osa(input) # this saves a file in working directory (or user-defined outpath) called "osa_age_diagnostics.png"
#' # extract individual figures for additional formatting:
#' osaplots$bubble
#' osaplots$qq
#' osaplots$aggcomp
plot_osa <- function(input, outpath = NULL, figheight = 8, figwidth = NULL) {

  # create output filepath if it doesn't already exist
  if(!is.null(outpath)) dir.create(file.path(outpath), showWarnings = FALSE)

  # ensure osa inputs are structured properly:
  res <- lapply(input, `[[`, 1) # extracts each element of the list of lists
  if(all(unlist(lapply(res, is.data.frame)))) {
    res <- do.call("rbind", res)
  } else {
    stop("The input argument should be a list() of output objects from run_osa. The $res element in one of these lists was not a dataframe.")
  }

  # ensure user is only plotting either ages or lengths at one time:
  if(length(unique(res$index_label))>1) stop("you are mixing age and length compositions. please input these separately for plotting purposes.")

  # ensure aggregated fit inputs are structured properly:
  agg <- lapply(input, `[[`, 2)
  if(all(unlist(lapply(agg, is.data.frame)))) {
    agg <- do.call("rbind", agg)
  } else {
    stop("The input argument should be a list() of output objects from run_osa. The $agg element in one of these lists was not a dataframe.")
  }

  # bubble plots
  res <- res %>%
    dplyr::mutate(sign = ifelse(resid < 0, "Neg", "Pos"),
                  Outlier = ifelse(abs(resid) >= 3, "Yes", "No"))


  bubble_plot <- ggplot(data = res, aes(x = year, y = index,
                                        color = sign, size = abs(resid),
                                        shape = Outlier, alpha = abs(resid))) +
    geom_point() +
    scale_color_manual(values=c("blue","red")) +
    # scale_shape_manual(values = c(16, 8)) + #,guide = FALSE) +
    # guides(shape = "none") +
    labs(x = NULL, y = unique(res$index_label),
         color = "Sign", sign = "abs(Resid)",
         size = "abs(Resid)", alpha = "abs(Resid)") +
    facet_wrap(~fleet, nrow = 1) +
    {if(length(unique(res$index)) < 30)
    scale_size(range = c(0.1,4))} +
    {if(length(unique(res$index)) >= 30)
    scale_size(range = c(0.1,3))} +
    {if(length(unique(res$index)) < 20)
    scale_y_continuous(breaks = unique(res$index), labels = unique(res$index))}+
    theme_bw(base_size = 10) +
    theme(legend.position = "top")

  # QQ plots
  sdnr <- res %>%
    dplyr::group_by(fleet) %>%
    dplyr::summarise(sdnr = paste0('SDNR = ', formatC(round(sd(resid),3), format = "f", digits = 2)))

  qq_plot <- ggplot() +
    stat_qq(data = res, aes(sample = resid), col = "blue") +
    geom_abline(slope = 1, intercept = 0) +
    labs(x = 'Theoretical quantiles', y = 'Sample quantiles') +
    facet_wrap(~fleet, nrow = 1) +
    theme_bw(base_size = 10) +
    geom_text(data = sdnr,
              aes(x = -Inf, y = Inf, label = sdnr),
              hjust = -0.5,
              vjust = 2.5)

  # aggregated fits

  agg_plot <- ggplot(data = agg) +
    geom_bar(aes(x = index, y = obs), stat = 'identity',
             color = "blue", fill = 'blue', alpha=0.4) +
    geom_point(aes(x = index, y = exp), color = 'red') +
    geom_line(aes(x = index, y = exp), color = 'red') +
    facet_wrap(~fleet, nrow = 1) +
    {if(length(unique(agg$index)) < 20)
      scale_x_continuous(breaks = unique(agg$index), labels = unique(agg$index))}+
    labs(x = unique(agg$index_label), y = "Proportion") +
    theme_bw(base_size = 10)

  # full plot
  if(length(unique(res$index)) < 20) {myrelht <- c(4,3,3)} else {myrelht <- c(6,3,3)}

  p <- cowplot::plot_grid(bubble_plot, qq_plot, agg_plot,
                     nrow = 3, rel_heights = myrelht)

  # create file name and file path
  fn <- paste0("osa_", tolower(unique(res$index_label)), "_diagnostics.png")
   if(is.null(outpath)) {
    fp <- fn
  } else {
    fp <- here::here(outpath, fn)
  }

  # use the fleet number to scale figure dimensions
  nflt <- length(unique(res$fleet))
  if(is.null(figwidth)) {
    if(nflt <= 2 | length(unique(res$index)) > 60 | max(abs(res$resid)) >= 5) {
      figwidth <- nflt * 5
    } else {
      figwidth <- nflt * 3
    }
  }

  # save and print figure
  ggsave(plot = p, filename = fp, units = 'in', bg = 'white', height = figheight,
         width = figwidth, dpi = 300)
  print(p)
  return(list(bubble = bubble_plot,
              qq = qq_plot,
              aggcomp = agg_plot))
  }