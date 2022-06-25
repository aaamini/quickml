#
decide_nreps = function(X) {
  # max(15, round(250 / log(prod(dim(X)))))
  max(10, round(250 / (log(nrow(X)) + 2*log(ncol(X)))))
}


#' @export
quickml = function(X, y,
                     nreps = NULL,
                     # ncore = 1,
                     verbose = 1) {

  if (is.null(nreps)) nreps = decide_nreps(X)
  if (!is.factor(y)) y = factor(y)
  if (length(levels(y)) != 2) {
    report_info1("Only binary classification implemented: Collapsing 'y' to two levels.\n")
    y = collapse_factor_to_two(y)
  }
  y = factor_to_numeric(y)
  X = char_to_factor(X)
  X = code_factors(X, drop_intercept = TRUE)

  # # report_msg1(sprintf("Running benchmark with nreps = %d\n", nreps))
  # report_info1(sprintf("Running benchmark with nreps = %d", nreps))
  train_idxs = get_splits(y, p = 0.7, times = nreps)
  methods = list(dt = c(tune_dt, fit_dt),
                 xgb = c(tune_xgb, fit_xgb),
                 rf = c(tune_rf, fit_rf),
                 lr2 = c(tune_lr2, fit_lr2),
                 ksvm = c(tune_ksvm, fit_ksvm))
  mtd_names = names(methods)

  # hparams = vector("list", length(methods))
  # tune hyperparameters by splitting further train into train/validation sets
  report_info1("Tuning hyperparameters ...")
  idx = train_idxs[[1]]
  hparams = lapply(seq_along(methods), function(j) {
    out = methods[[j]][[1]](X[idx, ], y[idx])
    if (!is.null(out)) {
      tune_str = paste(names(out), "=", out, collapse = ", ")
    } else {
      tune_str = "No tunning."
    }

    report_msg1(sprintf("\t %4s: %s\n", mtd_names[j], tune_str))
    out
  })

  report_info1(sprintf("Running benchmark with nreps = %d", nreps))
  # do.call(rbind, mclapply(1:nreps, mc.cores = ncore, FUN = function(i) {
  res = do.call(rbind, lapply(2:nreps, FUN = function(i) {
    report_msg2(sprintf("\t(%d / %d)\r", i, nreps))
    idx = train_idxs[[i]]
    Xpair = list(train = X[idx, ], test = X[!idx, ])
    ypair = list(train = y[idx], test = y[!idx])

    do.call(rbind, lapply(seq_along(methods), function(j) {
      t0 = Sys.time()
      fit = methods[[j]][[2]](Xpair, ypair, hparams[[j]])
      # # tune hyperparameters by splitting further train into train/validation sets
      # hparams = methods[[j]][[1]](Xpair$train, ypair$train)
      # # fit the model and compute the test AUC for reps > 1
      # fit = methods[[j]][[2]](Xpair, ypair, hparams)
      delta_t = Sys.time() - t0
      roc = get_roc(ypair$test, fit$yh_prob)
      data.frame(rep = i, method = mtd_names[j], auc = get_auc(roc), delta_t = delta_t)
    }))
  }))
  report_succ1("Benchmark concluded successfully.")
  res
}

