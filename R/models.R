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
fit_rlr = function(Xpair, ypair, hparams) {
  model = glmnet(Xpair$train, factor(ypair$train), family="binomial", alpha=hparams$alpha, lambda=hparams$lambda)
  yh_prob = as.numeric(predict(model, as.matrix(Xpair$test), type = "response"))
  list(yh_prob = yh_prob, model = model)
}


tune_rlr = function(Xtrain, ytrain) {
  lambda_vec = 10^seq(-2, 2, len=25)
  best_auc = -Inf
  best_idx = NULL
  best_alpha = NULL
  for (a in seq(0,1,by=1)) { # can try seq(0,1,by=0.25) but due to a bug in glmnet the lambda that is found will lead to AUC = 0.5 in training
    model = glmnet(Xpair$train, factor(ypair$train), family="binomial", alpha = a, lambda=lambda_vec)
    Yh_prob = predict(model, as.matrix(Xpair$test), type = "response")
    auc_values = apply(Yh_prob, 2, function(yh_prob) get_auc(ypair$test, yh_prob))

    max_idx = which.max(auc_values)
    max_auc = auc_values[max_idx]
    if (max_auc > best_auc) {
      best_auc = max_auc
      best_idx = max_idx
      best_alpha = a
    }
  }
  list(alpha = best_alpha, lambda = signif(lambda_vec[best_idx],3))
}
# glmnet(Xpair$train, factor(ypair$train), family="binomial", alpha = .5, lambda = 6.8)

#' @export
#' @importFrom e1071 svm
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
