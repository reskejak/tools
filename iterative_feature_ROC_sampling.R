# Jake Reske
# Michigan State University
# December 2018

# Let 'data' be an mxn matrix (data frame) with m samples and n features, where 'classifier' is a binary classifier for genetic status of a gene: mutated (1) or wild-type (0), determined from mutation data. 
# We can iteratively sample training and test data subsets for model training and ROC evaluation until convergence to compensate for low sample size. 
# This framework can be further iterated over each feature to compare model performance and determine optimal predictors.

# reset loop output data frame
res=data.frame(rep(0,ncol(data)))
rownames(res)=colnames(data)
colnames(res)="AUC"
# begin loop for each feature
for (p in 1:ncol(data)) {
  pw = colnames(data)[p]
  # reset iteration variables
  n=0
  auc.mean=0
  # begin sampling iteration loop for AUC convergence
  for (i in 1:100) {
    # training sample with 90 observations
    train=sample(1:nrow(data),90)
    # logistic regression, "logit" function for binomial distribution
    x <- as.formula(paste("classifier ~ ", paste(pw)))
    fit <- glm(x,
               data=data[train,],
               family=binomial())
    # predict on test data (note: type="prob" used for binary classifier)
    pred <- predict(fit,
data[-train,], 
type = "response")
    pr <- prediction(pred,
   data[-train,]$classifier)
    auc <- performance(pr, measure = "auc")@y.values[[1]]
    # iterative sampling calculation of mean AUC
    n = n + 1
    auc.mean = (auc.mean*(n-1) + auc)/n
    print(paste(i, pw, auc.mean)) # for console monitoring
  }
  # write output to data frame
  res[pw,] = auc.mean
}
# order output based on highest AUC
auc.rank <- data.frame(res$AUC, rownames(res))
colnames(auc.rank) <- c("AUC", "name")
auc.rank <- auc.rank[order(auc.rank$AUC, decreasing=T),]

