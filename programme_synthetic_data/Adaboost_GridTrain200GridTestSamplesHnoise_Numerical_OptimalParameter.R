rm(list=ls())

library(stringr)
library(rpart)
library(gbm)
library(viridis)

# set the root path of the code
script.dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
a <- unlist(strsplit(script.dir, split="/"))
pathtmp <- str_c(paste(a[-(length(a))], collapse="/"), "/")

pathsave = str_c(pathtmp,"results\\simulation3\\")
if (!dir.exists(str_c(pathtmp,"results"))){
  dir.create(str_c(pathtmp,"results"))
  dir.create(str_c(pathtmp,"results\\simulation3\\"))
}

# Simulate data
fileload = str_c(pathtmp,"\\SyntheticData\\GridTrainGridTestSamplesHnoise40000.Rdata")
filesave = str_c(pathsave,"AdaboostGridTrainGridTestHnoiseNumericalReusltsOptParameterGridNum200.Rdata")

load(fileload)

ntreesNumOpt = 520


t_num <- length(dataGer)
mse_adaboost = rep(0, t_num)
t_adaboost = rep(0, t_num)
Yhat = list()
gbm_results = list()
tt <- 1

while(tt<=t_num) # loops
{
  # Fit a GBM
  
  train_data = dataGer[[tt]]$train_data
  colnames(train_data)[1] = "Y"
  test_data = dataGer[[tt]]$test_data
  colnames(test_data)[1] = "Y"
  t1=proc.time()
  gbm_results[[tt]] <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                     distribution = "gaussian", n.trees = ntreesNumOpt, shrinkage = 0.1, interaction.depth = 1,
                     bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                     keep.data = TRUE, verbose = FALSE, n.cores = 5)
  t2=proc.time()
  t_adaboost[tt] = t2-t1

  Yhat[[tt]] <- predict(gbm_results[[tt]], newdata = test_data, n.trees = ntreesNumOpt, type = "link")
  mse_adaboost[tt] <- sum((test_data$Y - Yhat[[tt]])^2)/length(Yhat[[tt]])
  

  print(paste0("Ex", tt, "  mse: ", mse_adaboost[tt], "  Time cost: ",t_adaboost[tt],"  seconds"))
  
  tt <- tt+1
}

mse_adaboost_Mean = mean(mse_adaboost)
mse_adaboost_std = sd(mse_adaboost)
t_adaboost_Mean = mean(t_adaboost)
t_adaboost_std = sd(t_adaboost)

Adaboost_results = list(ntreesNumOpt = ntreesNumOpt, t_adaboost = t_adaboost, t_adaboost_Mean = t_adaboost_Mean,
                        t_adaboost_std = t_adaboost_std, mse_adaboost = mse_adaboost, mse_adaboost_Mean = mse_adaboost_Mean,
                        mse_adaboost_std = mse_adaboost_std, ExNum = t_num, gbm_results = gbm_results, Yhat = Yhat)


save(Adaboost_results, file=filesave)