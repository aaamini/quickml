#' @export
#' @import xgboost
fit_xgb = function(Xpair, ypair) {
  dtrain = xgb.DMatrix(as.matrix(Xpair$train), label = ypair$train)
  dtest =  xgb.DMatrix(as.matrix(Xpair$test), label = ypair$test)

  params <- list(objective = "binary:logistic",
                 eval_metric = "auc",
                 max_depth = 5, eta = .1)
                 #learning_rate = 0.1) # redundant
  watchlist <- list(train = dtrain, eval = dtest)

  model = xgb.train(params, dtrain, nrounds = 1000, watchlist,
                    print_every_n = 11, early_stopping_rounds = 5, verbose = 0)

  yh_prob = predict(model, newdata = dtest)
  list(yh_prob = yh_prob, model = model)
}

#' @export
#' @importFrom randomForest randomForest
fit_rf = function(Xpair, ypair) {
  model = randomForest(Xpair$train, factor(ypair$train))
  yh_prob = predict(model, Xpair$test, type = "prob")[,1]
  list(yh_prob = yh_prob, model = model)
}

#' @export
#' @import rpart
fit_dt = function(Xpair, ypair) {
  model = rpart(y ~ ., data = data.frame(Xpair$train, y = factor(ypair$train)))
  yh_prob = predict(model, Xpair$test, type = "prob")[,1]
  list(yh_prob = yh_prob, model = model)
}

#' @export
#' @importFrom glmnet glmnet
fit_lr = function(Xpair, ypair, alpha = 0) {
  model = glmnet(Xpair$train, factor(ypair$train), family="binomial", alpha=alpha, lambda=1)
  yh_prob = as.numeric(predict(model, as.matrix(Xpair$test), type = "response"))
  list(yh_prob = yh_prob, model = model)
}

fit_lr2 = function(Xpair, ypair) {
  fit_lr(Xpair, ypair, 0)
}
