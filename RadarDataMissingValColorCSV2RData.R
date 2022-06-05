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
# savefile = str_c(pathtmp,"RiverIce20150417_223028_mse_color_MissingVal_200x225.Rdata")
savefile = str_c(pathtmp,"RiverIce20200513_013745_mse_color_MissingVal_200x150.Rdata")

dataGer = list()

tt <- 1
t_num <- 20

while(tt<=t_num) {# loops
    train_x_channel1<-read.csv(str_c(pathtmp,"train_x", as.character(tt), "1.csv"), header=FALSE)
    train_y_channel1<-read.csv(str_c(pathtmp,"train_y", as.character(tt), "1.csv"), header=FALSE)
    train_data_channel1<-data.frame(train_y_channel1, train_x_channel1)
    test_x_channel1<-read.csv(str_c(pathtmp,"test_x", as.character(tt), "1.csv"), header=FALSE)
    test_y_channel1<-read.csv(str_c(pathtmp,"test_y", as.character(tt), "1.csv"), header=FALSE)
    test_data_channel1<-data.frame(test_y_channel1, test_x_channel1)
    
    train_x_channel2<-read.csv(str_c(pathtmp,"train_x", as.character(tt), "2.csv"), header=FALSE)
    train_y_channel2<-read.csv(str_c(pathtmp,"train_y", as.character(tt), "2.csv"), header=FALSE)
    train_data_channel2<-data.frame(train_y_channel2, train_x_channel2)
    test_x_channel2<-read.csv(str_c(pathtmp,"test_x", as.character(tt), "2.csv"), header=FALSE)
    test_y_channel2<-read.csv(str_c(pathtmp,"test_y", as.character(tt), "2.csv"), header=FALSE)
    test_data_channel2<-data.frame(test_y_channel2, test_x_channel2)
    
    train_x_channel3<-read.csv(str_c(pathtmp,"train_x", as.character(tt), "3.csv"), header=FALSE)
    train_y_channel3<-read.csv(str_c(pathtmp,"train_y", as.character(tt), "3.csv"), header=FALSE)
    train_data_channel3<-data.frame(train_y_channel3, train_x_channel3)    
    test_x_channel3<-read.csv(str_c(pathtmp,"test_x", as.character(tt), "3.csv"), header=FALSE)
    test_y_channel3<-read.csv(str_c(pathtmp,"test_y", as.character(tt), "3.csv"), header=FALSE)
    test_data_channel3<-data.frame(test_y_channel3, test_x_channel3)
    
    dataGer[[tt]] = list(train_data_channel1=train_data_channel1, test_data_channel1=test_data_channel1,
                         train_data_channel2=train_data_channel2, test_data_channel2=test_data_channel2,
                         train_data_channel3=train_data_channel3, test_data_channel3=test_data_channel3)
    tt <- tt+1
}  

save(dataGer,file=savefile)
