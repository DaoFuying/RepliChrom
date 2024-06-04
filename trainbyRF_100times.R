# setwd("code/")
#! /media/dasdata3/fuying/conda/yes/envs/r/bin Rscript

library(pROC)
library(ranger)
library(ROCR)
#library(caret)

args <- commandArgs()

filename = args[6]
dataDSB <-read.csv(filename)
print(filename)

# cell = args[7]

aucList <- c()
prList <- c()
timeF <- 1:100
for (timecount in timeF) {
  print(timecount)

  #filename = 're/K562_fea.csv'
  #filename = paste0('winGEdis/',args[6])

  # dataDSB= bin.Mat
  rownames(dataDSB)=1:nrow(dataDSB)
  print(floor(nrow(dataDSB)*0.8))
  idxs=sample(1:nrow(dataDSB),floor(nrow(dataDSB)*0.8))# 随机选择80%的数据
  dataDSBlearn=dataDSB[sort(idxs),]
  dataDSBtest=dataDSB[-idxs,]
  
  RFall=ranger("label~.",data=dataDSBlearn,importance="permutation")
  pred <- prediction(predict(RFall,dataDSBtest)$predictions,as.factor(dataDSBtest[,1]))
  
  auc_perf <- performance(pred, measure = "tpr", x.measure = "fpr")
  auc_data <- data.frame(auc_perf@x.values,auc_perf@y.values)
  
  #aucfile = paste0(filename,"_",timecount,"_auc.csv",sep='')
  #write.table(auc_data,file=aucfile,row.names=F,col.names=c("fpr","tpr"),sep=',',quote=F)
  auc.tmp <- performance(pred,"auc")
  auc <- as.numeric(auc.tmp@y.values)
  aucList <- append(aucList,auc)
  #print('auc')
  print(auc)
  
  prc_perf <- performance(pred, measure = "prec", x.measure = "rec")
  prc_data <- data.frame(prc_perf@x.values,prc_perf@y.values)
  
  #prcfile = paste0(filename,"_",timecount,"_pr.csv",sep='')
  #write.table(prc_data,file=prcfile,row.names=F,col.names=c("recall","precision"),sep=',',quote=F)
  aucpr.tmp <- performance(pred,"aucpr")
  pr <- as.numeric(aucpr.tmp@y.values)
  prList <- append(prList,pr)
  #print('prc')
  print(pr)
}
#print(aucList)
#print(prList)
l <- list('auc'=aucList,'pr'=prList)
df <- data.frame(l)
dffile = paste0(filename,"_100times_auc_pr.csv",sep='')
write.csv(df, dffile, row.names=TRUE, quote=FALSE) 
