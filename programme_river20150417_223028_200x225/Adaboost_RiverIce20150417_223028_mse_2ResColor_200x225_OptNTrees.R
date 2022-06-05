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
fileload = str_c(pathtmp,"\\RadarData\\RiverIce20150417_223028_mse_color_200x225.Rdata")
filesave = str_c(pathsave,"Adaboost_RiverIce20150417_223028_mse_color_200x225_Res2OptTreesNum.Rdata")

load(fileload)

ntrees_opt_3channel = c(6330, 8790, 9560)

mse_opt_3channel = numeric(3)
t_opt_3channel = numeric(3)
Yhat_opt_3channel = matrix(0, 180000, 3)


for (ii in 1:3){
    # Fit a GBM
    train_data = dataGer[[ii]]$train_data
    colnames(train_data)[1] = "Y"
    test_data = dataGer[[ii]]$test_data
    colnames(test_data)[1] = "Y"
    ntreesNumTmp = ntrees_opt_3channel[ii]
    t1=proc.time()
    gbm_results <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                       distribution = "gaussian", n.trees = ntreesNumTmp, shrinkage = 0.1, interaction.depth = 1,
                       bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                       keep.data = TRUE, verbose = FALSE, n.cores = 5)
    t2=proc.time()
    ttmp = t2-t1
    t_opt_3channel[ii] = ttmp[3][[1]]
    
    Yhat <- predict(gbm_results, newdata = test_data, n.trees = ntreesNumTmp, type = "link")
    mse_opt_3channel[ii] <- sum((test_data$Y - Yhat)^2)/length(Yhat)
    Yhat_opt_3channel[,ii] = Yhat
    rm(Yhat)
    
    
    print(paste0("channel", ii, "  mse: ", mse_opt_3channel[ii], 
                 "  Time cost: ",t_opt_3channel[ii],"  seconds"))
    
}

Adaboost_results = list(ntrees_opt_3channel = ntrees_opt_3channel, mse_opt_3channel = mse_opt_3channel, 
                        t_opt_3channel = t_opt_3channel, Yhat_opt_3channel = Yhat_opt_3channel)

save(Adaboost_results, file=filesave)