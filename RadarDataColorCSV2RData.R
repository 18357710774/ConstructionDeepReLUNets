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

pathtmp = "C:\\Users\\admin\\Desktop\\¡ıœº\\code\\RadarData\\"
# savefile = str_c(pathtmp,"RiverIce20200513_013745_mse_color_200x150.Rdata")
savefile = str_c(pathtmp,"RiverIce20150417_223028_mse_color_200x225.Rdata")


dataGer = list()

train_x<-read.csv(str_c(pathtmp,"train_x.csv"),header=FALSE)
test_x<-read.csv(str_c(pathtmp,"test_x.csv"),header=FALSE)
tt <- 1
t_num <- 3

while(tt<=t_num) {# loops
    train_y<-read.csv(str_c(pathtmp,"train_y", as.character(tt), ".csv"), header=FALSE)
    train_data<-data.frame(train_y, train_x)
    test_y<-read.csv(str_c(pathtmp,"test_y", as.character(tt), ".csv"), header=FALSE)
    test_data<-data.frame(test_y, test_x)
    dataGer[[tt]] = list(train_data=train_data, test_data=test_data)
    tt <- tt+1
}  

save(dataGer,file=savefile)
