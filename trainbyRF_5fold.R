# 安装和加载必要的包
library(pROC)
library(ranger)
library(ROCR)
# library(caret)
#library(PRROC)





# 读取数据集
args <- commandArgs()
filename = args[6]
# cell = args[7]
# filename="../K562/K562_pairs_1-20_RTfea.csv"
#cell = 'K562'
# myList <- seq(2000,40000, by=2000)

# for (eachL in myList){

aucList <- c()
prList <- c()
#filename = paste0('/home/fuying.dao/winGE/winGEfea/',cell,'_',eachL,'_',eachL/10,'_LRGfea.csv',sep='')
#filename = '/home/fuying.dao/winGE/GENA/K562.base_t2t.128.attenFea.GEfea.csv'
print(filename)
your_dataset <- read.csv(filename)
your_dataset$label <- factor(your_dataset$label, levels = c("0", "1"))

# 打乱数据集的行顺序
set.seed(123)  # Set seed for reproducibility
your_dataset <- your_dataset[sample(nrow(your_dataset)), ]

# 设置交叉验证的参数
num_folds <- 5
folds <- cut(seq(1, nrow(your_dataset)), breaks = num_folds, labels = FALSE)

# 将标签列转换为因子，并设置合适的因子水平
your_dataset$label <- factor(your_dataset$label, levels = c("0", "1"))

# 初始化AUC和AUPRC的向量
auc_values <- numeric(num_folds)
auprc_values <- numeric(num_folds)

# 进行五折交叉验证
for (i in 1:num_folds) {
  # 划分训练集和测试集
  test_indices <- which(folds == i, arr.ind = TRUE)
  test_data <- your_dataset[test_indices, ]
  train_data <- your_dataset[-test_indices, ]
  
  # 将标签列转换为数值
  train_data$label <- as.numeric(as.character(train_data$label))
  test_data$label <- as.numeric(as.character(test_data$label))
  
  # 训练Ranger模型
  rf_model <- ranger(label ~ ., data = train_data, importance = "permutation")
  
  # 获取预测概率
  predictions <- predict(rf_model, data = test_data)$predictions
  pred <- prediction(predictions,as.factor(test_data[,1]))
  # 计算AUC
  # roc_curve <- roc(test_data$label, predictions)
  # auc_values[i] <- auc(roc_curve)
  # write.table(prc_data,file=prcfile,row.names=F,col.names=c("recall","precision"),sep=',',quote=F)

  auc_perf <- performance(pred, measure = "tpr", x.measure = "fpr")
  auc_data <- data.frame(auc_perf@x.values,auc_perf@y.values)
  aucfile = paste0(filename,"_",i,"fold_auc.csv",sep='')
  write.table(auc_data,file=aucfile,row.names=F,col.names=c("fpr","tpr"),sep=',',quote=F)

  auc.tmp <- performance(pred,"auc")
  auc <- as.numeric(auc.tmp@y.values)
  auc_values[i] <- auc

  
  # 计算AUPRC
  prc_perf <- performance(pred, measure = "prec", x.measure = "rec")
  prc_data <- data.frame(prc_perf@x.values,prc_perf@y.values)
  
  prcfile = paste0(filename,"_",i,"fold_pr.csv",sep='')
  write.table(prc_data,file=prcfile,row.names=F,col.names=c("recall","precision"),sep=',',quote=F)
  aucpr.tmp <- performance(pred,"aucpr")
  pr <- as.numeric(aucpr.tmp@y.values)
  auprc_values[i] <- pr
}

performance_metrics <- data.frame(AUC = auc_values, AUPRC = auprc_values)
performance_metrics_file = paste0(filename,"_","5fold_perfMetr.csv",sep='')
write.csv(performance_metrics, file = performance_metrics_file, row.names = FALSE)


# 打印每一折叠的AUC和AUPRC
for (i in 1:num_folds) {
  cat(sprintf("Fold %d - AUC: %.4f, AUPRC: %.4f\n", i, auc_values[i], auprc_values[i]))
}

# 打印平均AUC和AUPRC
cat(sprintf("Average AUC: %.4f\n", mean(auc_values)))
cat(sprintf("Average AUPRC: %.4f\n", mean(auprc_values)))
# } 
