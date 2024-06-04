
#! /media/dasdata3/fuying/conda/yes/envs/r/bin Rscript
#setwd("/home/fydao/newTargetFinder/tar")
library(pROC)
# library(PRROC)
# library(glmnet)
library(ranger)
# library(Matrix)
library(ROCR)

#######load model
# args <- commandArgs()
# cell = args[6]
# type = args[7]
# testfile = args[8]
# outfile = args[9]
testfile = 'binsRT/K562heatmapTest.RTbinFea.csv'
outfile = 'binsRT/K562heatmapTest.RTbinFea.HiTrAC.pre.csv'
#model = paste0('/media/dasdata3/fuying/RT/',type,'/',cell,'/',cell,'_pairs_1-20.bedpe.binsRTfea.csv.BinsFea_model.RData')
#model = paste0('/media/dasdata3/fuying/RT/',type,'/',cell,'/',cell,'_pairs_1-20.bedpe.binsRTfea.csv.BinsFea_model.RData')
model = 'binsRT/model/K562.HiTrAC.BinsFea_model.RData'
print(model)
RFall1 <- load(model)
RFall2<- eval(parse(text=RFall1))

######load predict file
dataDSBtest <-read.csv(testfile)#K562-43fea.csv AML29_out/seq.csv

######save predict result
pred <- prediction(predict(RFall2,dataDSBtest)$predictions,as.factor(dataDSBtest[,1]))
pred_data <- data.frame(pred@predictions,pred@labels)
write.table(pred_data,file=outfile,row.names=F,sep=',',col.names = FALSE,quote=F)

auc.tmp <- performance(pred,"auc")
auc <- as.numeric(auc.tmp@y.values)
print('auc')
print(auc)
aucpr.tmp <- performance(pred,"aucpr")
pr <- as.numeric(aucpr.tmp@y.values)
print('prc')
print(pr)


# v <- 1:40
# for ( i in v) {
# a <- list.files('/RF/clusterTopEPI/cancerRTfea/HiTrAC')
# for(i in a){
#   eachname <- paste('cancerRTfea/',i,sep="")
#   print(i)
#   dataDSBtest <-read.csv(eachname)
#   pred <- prediction(predict(RFall,dataDSBtest)$predictions,as.factor(dataDSBtest[,1]))
#   pred_data <- data.frame(pred@predictions)
#   refile = paste('cancerRTfea/',i,'_re',sep="")
#   write.table(pred_data,file=refile,row.names=F,sep=',',col.names = FALSE,quote=F)
# }

# o <- 1:38
# o <- list.files('HiTrAC_bins_EPdata')

# for ( i in o) {
#   eachname <- paste0('HiTrAC_bins_EPdata/',i,sep="")
#   print(eachname)
#   dataDSBtest <-read.csv(eachname)
#   pred <- prediction(predict(RFall2,dataDSBtest)$predictions,as.factor(dataDSBtest[,1]))
#   pred_data <- data.frame(pred@predictions)
#   refile = paste0('RF/clusterTopEPI/cancerRTfea/HiTrAC_re/',i,'_predRe.txt',sep="")
#   write.table(pred_data,file=refile,row.names=F,sep=',',col.names = FALSE,quote=F)
# }


