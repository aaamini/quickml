#' @export
#' @import xgboost
fit_xgb = function(Xpair, ypair, hparams) {
  dtrain = xgb.DMatrix(as.matrix(Xpair$train), label = ypair$train)
  dtest =  xgb.DMatrix(as.matrix(Xpair$test), label = ypair$test)

  model = xgb.train(data = dtrain, nrounds = hparams$nrounds,
                    objective = "binary:logistic",
                    eta = hparams$eta, max_depth = hparams$max_depth,
                    verbose = 0)

  # params <- list(objective = "binary:logistic",
  #                eval_metric = "auc",
  #                max_depth = 5, eta = .1)
  #                #learning_rate = 0.1) # redundant
  # watchlist <- list(train = dtrain, eval = dtest)
  #
  # model = xgb.train(params, dtrain, nrounds = 1000, watchlist,
  #                   print_every_n = 11, early_stopping_rounds = 5, verbose = 0)

  yh_prob = predict(model, newdata = dtest, hparams=NULL)
  list(yh_prob = yh_prob, model = model)
}

#' Returns hparams for fit_xgb
tune_xgb = function(Xtrain, ytrain) {
  idx = get_splits(ytrain, p = 0.7, times = 1)[[1]]  # split into further train/valid

  dtrain = xgb.DMatrix(as.matrix(Xtrain[idx, ]), label = ytrain[idx])
  dvalid =  xgb.DMatrix(as.matrix(Xtrain[!idx, ]), label = ytrain[!idx])

  hp_grid = expand.grid(eta = c(0.1,0.3,0.5,1), max_depth = c(3,5,8))
  best_hp_idx = NULL
  best_iteration = NULL
  best_hp_score = -Inf
  for (i in 1:nrow(hp_grid)) {
    model = xgb.train(data = dtrain, nrounds = 1000,
                      watchlist = list(train = dtrain, eval = dvalid),
                      objective = "binary:logistic", eval_metric = "auc",
                      max_depth = hp_grid[i,"max_depth"], eta = hp_grid[i, "eta"],
                      print_every_n = 11, early_stopping_rounds = 5, verbose = 0)
    # report_info1(round(model$best_score,3))
    if (model$best_score > best_hp_score) {
      best_hp_score = model$best_score
      best_iteration = model$best_iteration
      best_hp_idx = i
    }
  }
  c(as.list(unlist(hp_grid[best_hp_idx, ])), nrounds = best_iteration)
}


#' @export
#' @importFrom randomForest randomForest
fit_rf = function(Xpair, ypair, hparams) {
  model = randomForest(Xpair$train, factor(ypair$train))
  yh_prob = predict(model, Xpair$test, type = "prob")[,1]
  list(yh_prob = yh_prob, model = model)
}

tune_rf = function(Xtrain, ytrain) {
  NULL
}

#' @export
#' @import rpart
fit_dt = function(Xpair, ypair, hparams) {
  model = rpart(y ~ ., data = data.frame(Xpair$train, y = factor(ypair$train)))
  yh_prob = predict(model, Xpair$test, type = "prob")[,1]
  list(yh_prob = yh_prob, model = model)
}

tune_dt = function(Xtrain, ytrain) {
  NULL
}

#' @export
#' @importFrom glmnet glmnet
fit_lr = function(Xpair, ypair, alpha = 0, hparams) {
  model = glmnet(Xpair$train, factor(ypair$train), family="binomial", alpha=alpha, lambda=1)
  yh_prob = as.numeric(predict(model, as.matrix(Xpair$test), type = "response"))
  list(yh_prob = yh_prob, model = model)
}

fit_lr2 = function(Xpair, ypair, hparams) {
  fit_lr(Xpair, ypair, 0, hparams)
}

tune_lr2 = function(Xtrain, ytrain) {
  NULL
}

#' @export
#' @importFrom e1071
fit_ksvm = function(Xpair, ypair, hparams) {
  model = e1071::svm(Xpair$train, ypair$train,
      type = 'C-classification', # this is because we want to make a regression classification
      kernel = 'radial', probability = TRUE)
  yh_prob = attr(predict(model, as.matrix(Xpair$test), probability = TRUE), "probabilities")[,1]
  list(yh_prob = yh_prob, model = model)
}

tune_ksvm = function(Xtrain, ytrain) {
  NULL
}
