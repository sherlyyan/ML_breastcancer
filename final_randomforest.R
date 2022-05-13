#setwd("C:/Users/maryy/Desktop/Machine Learning2/Final Project")
rm(list=ls())
installIfAbsentAndLoad  <-  function(neededVector) {
  if(length(neededVector) > 0) {
    for(thispackage in neededVector) {
      if(! require(thispackage, character.only = T)) {
        install.packages(thispackage)}
      require(thispackage, character.only = T)
    }
  }
}
needed <- c('glmnet','e1071','rattle','randomForest', 'pROC', 'verification', 'rpart')
installIfAbsentAndLoad(needed)
#####################################
#### Define evaluation functions ####
#####################################
my.auc <- function(actual, pred.prob){
  score <- roc.area(as.integer(as.factor(actual))-1, pred.prob)
  return(score)
}
my.rocPlot <- function(actual, pred.prob,auc, title){
  roc.plot(as.integer(as.factor(actual))-1, pred.prob, main="")
  legend("bottomright", bty="n",
         sprintf("Area Under the Curve (AUC) = %1.3f", auc$A))
  title(main = title,
        sub = paste("David Murray", format(Sys.time(), "%Y-%b-%d %H:%M:%S"), Sys.info()["user"]))
}
my.typeErr <- function(table){
  print(c("Type I Error:", table[1,2] / (table[1,2] + table[1,1])))
  print(c("Type II Error:", table[2,1] / (table[2,1] + table[2,2])))
}
data <- read.table(file = 'breast-cancer-wisconsin.data', header =  F, sep = ",")
colnames(data) <- c("ID", 
                     "ClumpThickness",
                     "CellSizeUniformity",
                     "CellShapeUniformity",
                     "MarginalAdhesion",
                     "SingleEpithelialCellSize",
                     "BareNuclei",
                     "BlandChromatin",
                     "NormalNucleoli",
                     "Mitoses",
                     "Class")
str(data)
data[data == "?"] <- NA
data <- na.omit(data)
data$BareNuclei <- as.integer(data$BareNuclei)
data$Class <- as.factor(data$Class)
str(data)


##################
##### Trees ######
##################
nobs <- nrow(data)
set.seed(5082)
trainrows <- sample(nobs, 0.6* nobs) #1999
validaterows <- sample(setdiff(seq_len(nobs), trainrows), 0.2* nobs) 
testrows <- setdiff(setdiff(seq_len(nobs), trainrows), validaterows)

train<-data[trainrows,]
validate<-data[validaterows,]
test<-data[testrows,]

rpart <- rpart(Class ~ ., data = train, method = "class", parms=list(split='information'), 
               control=rpart.control(usesurrogate = 0, 
                                     maxsurrogate = 0, 
                                     cp=0, 
                                     minsplit = 2, 
                                     minbucket = 1))
print(rpart)
fancyRpartPlot(rpart,main="our plot")
rpart.plot(rpart)

###evaluate predictive power using validate dataset###
predict <- predict(rpart, newdata=test, type="class")
acc <- mean(test$Class == predict)
acc
mytable <- table(validate$Class, predict,dnn=c("Actual", "Predicted"))
round(100*table(validate$Class, predict,dnn=c("% Actual", "% Predicted"))/length(predict))
error <- (mytable[2] + mytable[3]) / sum(mytable)
error
my.typeErr(mytable)  #0.082  0.04
#####################################
######### Pruned Tree ###############
#####################################
xerr <- rpart$cptable[,"xerror"]  #cross-validation error
minxerr <- which.min(xerr)
mincp <- rpart$cptable[minxerr,"CP"]
rpart.prune <- prune(rpart,cp = mincp)
### Evaluating Model ###
pred.tree <- predict(rpart.prune, test, type = "class")
pred.tree.prob <- predict(rpart.prune, test, type = "prob")
acc.tree <- mean(test$Class == pred.tree)
table.tree<-table(test$Class, pred.tree ,dnn = c("Actual", "Predicted"))

print(acc.tree)    #0.927 accuracy

print(table.tree)
round(100* table(test$Class, pred.tree ,dnn = c("% Actual", "% Predicted")) / length(pred.tree))
my.typeErr(table.tree) #TypeI:0.03  TypeII:0.17

#####################################
######## Bagging 500 Trees ##########
#####################################
set.seed(5082)
# set mtry = number of predictors for bagging only
bag.fit <- randomForest(formula = Class ~ ., data = train,
                        ntree = 300, mtry = ncol(train)-1,
                        importance = TRUE, localImp = TRUE, replace = TRUE)
bag.fit         #OOB error rate 0.042
head(bag.fit$oob.times)
head(bag.fit$err.rate)

### Evaluating model ###
pred.bag <- predict(bag.fit, test, type = "class")
pred.bag.prob <- predict(bag.fit, test, type = "prob")
acc.bag <- mean(test$Class == pred.bag)
auc.bag <- my.auc(test$Class, pred.bag.prob[, "2"])
table.bag <- table(test$Class, pred.bag ,dnn = c("Actual", "Predicted"))

print(acc.bag)   #0.956 accuracy

print(table.bag)
round(100* table(test.set$churn, pred.bag ,dnn = c("% Actual", "% Predicted")) / length(pred.bag))
my.typeErr(table.bag)  #Type 1:0.03  Type 2:0.146
#####################################
###### 500 Trees Random Forest#######
#####################################
set.seed(5082)
rf.fit <- randomForest(formula = Class ~ ., data = train,
                       ntree = 500, mtry = 4,
                       importance = TRUE, localImp = TRUE, replace = TRUE)
rf.fit
head(rf.fit$err.rate)
plot(rf.fit, main = "Error Rates for Random Forest")
legend("topright", c("OOB", "No", "Yes"), text.col=1:6, lty=1:3, col=1:3)


### Evaluating Model ###
pred.rf <- predict(rf.fit, test, type = "class")
pred.rf.prob <- predict(rf.fit, test, type = "prob")
acc.rf <- mean(test$Class == pred.rf)
auc.rf <- my.auc(test$Class, pred.rf.prob[, "2"]) ################################
table.rf <- table(test$Class, pred.rf ,dnn = c("Actual", "Predicted"))

print(acc.rf)   #0.956 accuracy
my.rocPlot(test$Class, pred.rf.prob[, "2"], auc.rf, "ROC Curve for Random Forest")
print(auc.rf$A)

print(table.rf)
round(100* table(test$Class, pred.rf ,dnn = c("% Actual", "% Predicted")) / length(pred.rf))
my.typeErr(table.rf) #TypeI: 0.02  TypeII:0.09
