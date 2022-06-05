## Main function for the performance comparison of different boosting on simulated sinusoid data
## algorithms
## data: Dec., 2017
# Note that one should install "rpart","ada" and "ifultools" first
rm(list=ls())
library(stringr)
library(rpart)
library(ada)
library(ifultools)
library(lattice)
library(ggplot2)
library(caret)
library(parallel)
library(iterators)
library(foreach)
library(doParallel)
t_num = 20

pathtmp = "C:\\Users\\admin\\Desktop\\¡ıœº\\code\\RadarData\\"
# savefile = str_c(pathtmp,"20201009135112_mse_MissingVal_167x225.Rdata")
# savefile = str_c(pathtmp,"20201009135029_mse_MissingVal_140x170.Rdata")
savefile = str_c(pathtmp,"20201010101543_mse_MissingVal_230x250.Rdata")

tt = 1
dataGer = list()
while(tt<=t_num) # loops
  ############### generate orange datasets #################### 
{
  train_x<-read.csv(str_c(pathtmp,"train_x", as.character(tt),".csv"),header=FALSE)
  train_y<-read.csv(str_c(pathtmp,"train_y", as.character(tt),".csv"),header=FALSE)
  
  train_data<-data.frame(train_y, train_x)
  
  test_x<-read.csv(str_c(pathtmp,"test_x", as.character(tt),".csv"),header=FALSE)
  test_y<-read.csv(str_c(pathtmp,"test_y", as.character(tt),".csv"),header=FALSE)
  
  test_data<-data.frame(test_y, test_x)
  
  dataGer[[tt]] = list(train_data=train_data, test_data=test_data)
  
  tt <- tt+1
}

save(dataGer,file=savefile)
