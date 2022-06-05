rm(list=ls())

library(stringr)
library(rpart)
library(gbm)
library(viridis)

# set the root path of the code
script.dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
a <- unlist(strsplit(script.dir, split="/"))
pathtmp <- str_c(paste(a[-(length(a))], collapse="/"), "/")

pathsave = str_c(pathtmp,"results\\RadarResults\\")
if (!dir.exists(str_c(pathtmp,"results"))){
  dir.create(str_c(pathtmp,"results"))
  dir.create(str_c(pathtmp,"results\\RadarResults\\"))
}

# Simulate data
fileload = str_c(pathtmp,"\\RadarData\\20201009135112_mse_MissingVal_167x225.Rdata")
filesave = str_c(pathsave,"Adaboost_20201009135112_mse_167x225_MissVal.Rdata")

load(fileload)

ExNum = 20
ntreesIniNum = 10
ntreesAddNum = 10
ntreesAddTotalTimes = 1000

mse_adaboost = matrix(0, ExNum, ntreesAddTotalTimes)

tt <- 1
while (tt<=ExNum){
  # Fit a GBM
  t1=proc.time()
  train_data = dataGer[[tt]]$train_data
  colnames(train_data)[1] = "Y"
  test_data = dataGer[[tt]]$test_data
  colnames(test_data)[1] = "Y"
  gbm_results <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                     distribution = "gaussian", n.trees = ntreesIniNum, shrinkage = 0.1, interaction.depth = 1,
                     bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                     keep.data = TRUE, verbose = FALSE, n.cores = 5)
  
  Yhat <- predict(gbm_results, newdata = test_data, n.trees = ntreesIniNum, type = "link")
  mse_adaboost[tt, 1] <- sum((test_data$Y - Yhat)^2)/length(Yhat)
  rm(Yhat)
  t2=proc.time()
  t = t2-t1
  
  add_count <- 1
  print(paste0("add_count", add_count, "  mse: ", mse_adaboost[tt, 1], "  Time cost: ",t[3][[1]],"  seconds"))
  
  while(add_count<ntreesAddTotalTimes)
  {
    t1=proc.time()
    add_count <- add_count+1
    ntrees = ntreesIniNum+(add_count-1)*ntreesAddNum
    # Add more (i.e., ntreesAddNum) boosting iterations to the ensemble
    gbm_results <- gbm.more(gbm_results, n.new.trees = ntreesAddNum, verbose = FALSE)
    Yhat <- predict(gbm_results, newdata = test_data, n.trees = ntrees, type = "link")
    mse_adaboost[tt, add_count] <- sum((test_data$Y - Yhat)^2)/length(Yhat)
    rm(Yhat)
    
    t2=proc.time()
    t = t2-t1
    
    print(paste0("add_count", add_count, "  mse: ", mse_adaboost[tt, add_count],
                 "  Time cost: ",t[3][[1]],"  seconds"))
  }
  
  tt <- tt+1
}

mse_adaboost_Mean = colMeans(mse_adaboost)
mse_adaboost_std = apply(mse_adaboost,2,sd)
ntress_opt = which.min(mse_adaboost_Mean)

Adaboost_results = list(ntreesIniNum = ntreesIniNum, ntreesAddNum = ntreesAddNum, ntreesAddTotalTimes = ntreesAddTotalTimes, 
                        mse_adaboost = mse_adaboost, mse_adaboost_Mean = mse_adaboost_Mean,
                        mse_adaboost_std = mse_adaboost_std, ntress_opt = ntress_opt)


save(Adaboost_results, file=filesave)