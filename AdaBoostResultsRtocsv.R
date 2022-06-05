library(stringr)

# ------------Synthtic Data---------------
# savepath = "C:\\Users\\admin\\Desktop\\¡ıœº\\code\\results\\simulation3\\"
# Y_mat = matrix(0, 40000, 20)
# for (i in 1:20){
#   Y_mat[,i] = Adaboost_results$Yhat[[i]]
# }
# file = str_c(savepath,"Yhat.csv")
# write.csv(Y_mat,file=file)


# -----------Gray Radar Data--------------
# savepath = "C:\\Users\\admin\\Desktop\\¡ıœº\\code\\results\\RadarResults\\"
# Y_mat = Adaboost_results$Yhat_opt
# file = str_c(savepath,"Yhat.csv")
# write.csv(Y_mat,file=file)

savepath = "C:\\Users\\admin\\Desktop\\¡ıœº\\code\\results\\RadarResults\\"
file = str_c(savepath,"Yhat_opt.csv")
write.csv(Yhat_opt1,file=file)


# -----------RGB Radar Data--------------
savepath = "C:\\Users\\admin\\Desktop\\¡ıœº\\code\\results\\RadarResults\\"
Y_mat = Adaboost_results$Yhat_opt_3channel
file = str_c(savepath,"Yhat.csv")
write.csv(Y_mat,file=file)