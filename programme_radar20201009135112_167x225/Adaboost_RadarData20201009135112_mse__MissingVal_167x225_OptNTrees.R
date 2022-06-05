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
filesave = str_c(pathsave,"Adaboost_RadarData20201009135112_mse_167x225_MissValOptTreesNum.Rdata")

load(fileload)

ExNum = 20
ntrees_opt = 1800

mse_opt = rep(0, ExNum)
t_opt = rep(0, ExNum)
Yhat_opt = list()

tt <- 1
while (tt<=ExNum){
  # Fit a GBM
  t1=proc.time()
  train_data = dataGer[[tt]]$train_data
  colnames(train_data)[1] = "Y"
  test_data = dataGer[[tt]]$test_data
  colnames(test_data)[1] = "Y"
  gbm_results <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                     distribution = "gaussian", n.trees = ntrees_opt, shrinkage = 0.1, interaction.depth = 1,
                     bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                     keep.data = TRUE, verbose = FALSE, n.cores = 5)
  
  t2=proc.time()
  ttmp = t2-t1
  t_opt[tt] = ttmp[3][[1]]
  
  Yhat_opt[[tt]] <- predict(gbm_results, newdata = test_data, n.trees = ntrees_opt, type = "link")
  mse_opt[tt] <- sum((test_data$Y - Yhat_opt[[tt]])^2)/length(Yhat_opt[[tt]])

  print(paste0("Ex  ", tt,  "  mse: ", mse_opt[tt], "  Time cost: ",t_opt[tt],"  seconds"))
 
  tt <- tt+1
}

mse_opt_mean = mean(mse_opt)
mse_opt_std = sd(mse_opt)
t_opt_mean = mean(t_opt)
t_opt_std = sd(t_opt)

Adaboost_results = list(ntrees_opt = ntrees_opt, mse_opt = mse_opt, mse_opt_mean = mse_opt_mean, mse_opt_std = mse_opt_std,
                        t_opt = t_opt, t_opt_mean = t_opt_mean, t_opt_std = t_opt_std, Yhat_opt = Yhat_opt)

save(Adaboost_results, file=filesave)