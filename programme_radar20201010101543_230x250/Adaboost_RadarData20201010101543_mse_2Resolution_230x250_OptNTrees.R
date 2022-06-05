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
fileload = str_c(pathtmp,"\\RadarData\\20201010101543_mse_230x250.Rdata")
filesave = str_c(pathsave,"Adaboost_20201010101543_mse_230x250_Res2OptTreesNum.Rdata")

load(fileload)

ntrees_opt = 9890

# Fit a GBM
t1=proc.time()
train_data = dataGer$train_data
colnames(train_data)[1] = "Y"
test_data = dataGer$test_data
colnames(test_data)[1] = "Y"
gbm_results <- gbm(Y ~ ., data = train_data, var.monotone = rep(0, dim(train_data)[2]-1),
                   distribution = "gaussian", n.trees = ntrees_opt, shrinkage = 0.1, interaction.depth = 1,
                   bag.fraction = 0.5, train.fraction = 1, n.minobsinnode = 10, cv.folds = 0,
                   keep.data = TRUE, verbose = FALSE, n.cores = 5)


t2=proc.time()
ttmp = t2-t1
t_opt = ttmp[3][[1]]

Yhat_opt <- predict(gbm_results, newdata = test_data, n.trees = ntrees_opt, type = "link")
mse_opt <- sum((test_data$Y - Yhat_opt)^2)/length(Yhat_opt)


print(paste0("  mse: ", mse_opt,  "  Time cost: ",t_opt,"  seconds"))


Adaboost_results = list(ntrees_opt = ntrees_opt, mse_opt = mse_opt, 
                        t_opt = t_opt, Yhat_opt = Yhat_opt)

save(Adaboost_results, file=filesave)