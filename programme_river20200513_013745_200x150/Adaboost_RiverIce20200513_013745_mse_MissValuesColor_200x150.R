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
fileload = str_c(pathtmp,"\\RadarData\\RiverIce20200513_013745_mse_color_MissingVal_200x150.Rdata")
filesave = str_c(pathsave,"Adaboost_RiverIce20200513_013745_mse_color_200x150_MissVal.Rdata")

load(fileload)

ExNum = 20
ntreesIniNum = 10
ntreesAddNum = 10
ntreesAddTotalTimes = 1000


mse_adaboost_3channel = list()
for (ii in 1:3){
  mse_adaboost_3channel[[ii]] = matrix(0, ExNum, ntreesAddTotalTimes)
}
mse_adaboost_all = matrix(0, ExNum, ntreesAddTotalTimes)

mse_adaboost_mean_3channel = matrix(0, 3, ntreesAddTotalTimes)
mse_adaboost_std_3channel = matrix(0, 3, ntreesAddTotalTimes)

mse_opt_3channel = numeric(3)
ntress_opt_3channel = numeric(3)

tt <- 1
while (tt<=ExNum){
    
    dataChannelTmp = list()
    dataChannelTmp[[1]] = list(train_data=dataGer[[tt]]$train_data_channel1, test_data=dataGer[[tt]]$test_data_channel1)
    dataChannelTmp[[2]] = list(train_data=dataGer[[tt]]$train_data_channel2, test_data=dataGer[[tt]]$test_data_channel2)
    dataChannelTmp[[3]] = list(train_data=dataGer[[tt]]$train_data_channel3, test_data=dataGer[[tt]]$test_data_channel3)
    
    SquareErrTmp = matrix(0, 3, ntreesAddTotalTimes)
    TestNumTmp = matrix(0, 3, ntreesAddTotalTimes)
    for (ii in 1:3){
      # Fit a GBM
      t1=proc.time()
      train_data = dataChannelTmp[[ii]]$train_data
      colnames(train_data)[1] = "Y"
      test_data = dataChannelTmp[[ii]]$test_data
      colnames(test_data)[1] = "Y"
      gbm_results <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                         distribution = "gaussian", n.trees = ntreesIniNum, shrinkage = 0.1, interaction.depth = 1,
                         bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                         keep.data = TRUE, verbose = FALSE, n.cores = 5)
      
      Yhat <- predict(gbm_results, newdata = test_data, n.trees = ntreesIniNum, type = "link")
      SquareErrTmp[ii, 1] = sum((test_data$Y - Yhat)^2)
      TestNumTmp[ii, 1] = length(Yhat)
      mse_adaboost_3channel[[ii]][tt, 1] <- SquareErrTmp[ii,1]/TestNumTmp[ii,1]
      rm(Yhat)
      t2=proc.time()
      t = t2-t1
      
      add_count <- 1
      print(paste0("Ex ", tt, "--channel ", ii, "   add_count", add_count, "  mse: ", mse_adaboost_3channel[[ii]][tt, 1], 
                   "  Time cost: ",t[3][[1]],"  seconds"))
      
      while(add_count<ntreesAddTotalTimes)
      {
        t1=proc.time()
        add_count <- add_count+1
        ntrees = ntreesIniNum+(add_count-1)*ntreesAddNum
        # Add more (i.e., ntreesAddNum) boosting iterations to the ensemble
        gbm_results <- gbm.more(gbm_results, n.new.trees = ntreesAddNum, verbose = FALSE)
        Yhat <- predict(gbm_results, newdata = test_data, n.trees = ntrees, type = "link")
        
        SquareErrTmp[ii, add_count] = sum((test_data$Y - Yhat)^2)
        TestNumTmp[ii, add_count] = length(Yhat)
        mse_adaboost_3channel[[ii]][tt, add_count] <- SquareErrTmp[ii, add_count]/TestNumTmp[ii, add_count]
        rm(Yhat)
        
        t2=proc.time()
        t = t2-t1
        
        print(paste0("Ex ", tt, "--channel ", ii, "    add_count", add_count, "  mse: ", 
                     mse_adaboost_3channel[[ii]][tt, add_count], "  Time cost: ",t[3][[1]],"  seconds"))
      }
    }
    SquareErrTmpSum = colSums(SquareErrTmp)
    TestNumTmpSum = colSums(TestNumTmp)
    mse_adaboost_all[tt,] = SquareErrTmpSum/TestNumTmpSum
    tt <- tt+1
}

for (ii in 1:3){
  mse_adaboost_mean_3channel[ii,] = colMeans(mse_adaboost_3channel[[ii]])
  mse_adaboost_std_3channel[ii,] = apply(mse_adaboost_3channel[[ii]],2,sd)
  ntress_opt_3channel[ii] = which.min(mse_adaboost_mean_3channel[ii,])
  mse_opt_3channel[ii] = mse_adaboost_mean_3channel[ii, ntress_opt_3channel[ii]]
}
mse_adaboost_mean_all = colMeans(mse_adaboost_all)
mse_adaboost_std_all = apply(mse_adaboost_all,2,sd)
ntress_opt_all = which.min(mse_adaboost_mean_all)
mse_opt_all = mse_adaboost_mean_all[ntress_opt_all]


Adaboost_results = list(ntreesIniNum = ntreesIniNum, ntreesAddNum = ntreesAddNum, ntreesAddTotalTimes = ntreesAddTotalTimes, 
                        mse_adaboost_3channel = mse_adaboost_3channel, mse_adaboost_mean_3channel = mse_adaboost_mean_3channel,
                        mse_adaboost_std_3channel = mse_adaboost_std_3channel, ntress_opt_3channel = ntress_opt_3channel, 
                        mse_opt_3channel= mse_opt_3channel, mse_adaboost_all = mse_adaboost_all, 
                        mse_adaboost_mean_all = mse_adaboost_mean_all, mse_adaboost_std_all = mse_adaboost_std_all,
                        ntress_opt_all = ntress_opt_all, mse_opt_all = mse_opt_all)

save(Adaboost_results, file=filesave)