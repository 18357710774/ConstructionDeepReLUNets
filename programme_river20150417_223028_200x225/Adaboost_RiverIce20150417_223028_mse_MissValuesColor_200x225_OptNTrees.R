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
fileload = str_c(pathtmp,"\\RadarData\\RiverIce20150417_223028_mse_color_MissingVal_200x225.Rdata")
filesave = str_c(pathsave,"Adaboost_RiverIce20150417_223028_mse_color_200x225_MissValOptTreesNum.Rdata")

load(fileload)

ExNum = 20
ntrees_opt_3channel = c(1830, 1700, 2060)
mse_opt_3channel = matrix(0, 3, ExNum)
t_opt_3channel = matrix(0, 3, ExNum)
Yhat_opt_3channel = list()
mse_opt_all = rep(0, ExNum)

tt <- 1

while (tt<=ExNum){
    
    dataChannelTmp = list()
    dataChannelTmp[[1]] = list(train_data=dataGer[[tt]]$train_data_channel1, test_data=dataGer[[tt]]$test_data_channel1)
    dataChannelTmp[[2]] = list(train_data=dataGer[[tt]]$train_data_channel2, test_data=dataGer[[tt]]$test_data_channel2)
    dataChannelTmp[[3]] = list(train_data=dataGer[[tt]]$train_data_channel3, test_data=dataGer[[tt]]$test_data_channel3)
    
    Yhat_opt_3channel_tmp = list()
    SquareErrTmp = rep(0, 3)
    TestNumTmp = rep(0, 3)
    for (ii in 1:3){
      # Fit a GBM
      train_data = dataChannelTmp[[ii]]$train_data
      colnames(train_data)[1] = "Y"
      test_data = dataChannelTmp[[ii]]$test_data
      colnames(test_data)[1] = "Y"
      t1=proc.time()
      gbm_results <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                         distribution = "gaussian", n.trees = ntrees_opt_3channel[ii], shrinkage = 0.1, interaction.depth = 1,
                         bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                         keep.data = TRUE, verbose = FALSE, n.cores = 5)
      t2=proc.time()
      ttmp = t2-t1
      t_opt_3channel[ii, tt] = ttmp[3][[1]]
      
      
      Yhat_opt_3channel_tmp[[ii]] <- predict(gbm_results, newdata = test_data, n.trees = ntrees_opt_3channel[ii], type = "link")
      
      SquareErrTmp[ii] = sum((test_data$Y - Yhat_opt_3channel_tmp[[ii]])^2)
      TestNumTmp[ii] = length(Yhat_opt_3channel_tmp[[ii]])
      mse_opt_3channel[ii, tt] <- SquareErrTmp[ii]/TestNumTmp[ii]

      print(paste0("Ex ", tt, "--channel ", ii, "  mse: ", mse_opt_3channel[ii, tt], 
                   "  Time cost: ",t_opt_3channel[ii, tt],"  seconds"))
      
      
    }
    SquareErrTmpSum = sum(SquareErrTmp)
    TestNumTmpSum = sum(TestNumTmp)
    mse_opt_all[tt] = SquareErrTmpSum/TestNumTmpSum
    Yhat_opt_3channel[[tt]] = Yhat_opt_3channel_tmp
    
    rm(Yhat_opt_3channel_tmp, SquareErrTmp, TestNumTmp)
    tt <- tt+1
}


mse_opt_3channel_mean = rowMeans(mse_opt_3channel)
mse_opt_3channel_std = apply(mse_opt_3channel, 1, sd)
t_opt_3channel_mean = rowMeans(t_opt_3channel)
t_opt_3channel_std = apply(t_opt_3channel, 1, sd)
mse_opt_all_mean = mean(mse_opt_all)
mse_opt_all_std = sd(mse_opt_all)


Adaboost_results = list(ntrees_opt_3channel = ntrees_opt_3channel, 
                        mse_opt_3channel = mse_opt_3channel, t_opt_3channel = t_opt_3channel,
                        Yhat_opt_3channel = Yhat_opt_3channel, mse_opt_all = mse_opt_all, 
                        mse_opt_3channel_mean= mse_opt_3channel_mean, mse_opt_3channel_std = mse_opt_3channel_std, 
                        t_opt_3channel_mean = t_opt_3channel_mean, t_opt_3channel_std = t_opt_3channel_std,
                        mse_opt_all_mean = mse_opt_all_mean, mse_opt_all_std = mse_opt_all_std)

save(Adaboost_results, file=filesave)