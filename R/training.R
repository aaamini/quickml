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
  X = code_factors(X, drop_intercept = TRUE)

  # report_msg1(sprintf("Running benchmark with nreps = %d\n", nreps))
  report_info1("Running benchmark with nreps = {nreps}")
  train_idxs = get_splits(y, p = 0.7, times = nreps)
  methods = list(dt = fit_dt, xgb = fit_xgb, rf = fit_rf, lr2 = fit_lr2)
  mtd_names = names(methods)

  # do.call(rbind, mclapply(1:nreps, mc.cores = ncore, FUN = function(i) {
  do.call(rbind, lapply(1:nreps, FUN = function(i) {
    report_msg2(sprintf("(%d / %d)\r", i, nreps))
    idx = train_idxs[[i]]
    Xpair = list(train = X[idx, ], test = X[!idx, ])
    ypair = list(train = y[idx], test = y[!idx])

    do.call(rbind, lapply(seq_along(methods), function(j) {
      t0 = Sys.time()
      fit = methods[[j]](Xpair, ypair)
      delta_t = Sys.time() - t0
      roc = get_roc(ypair$test, fit$yh_prob)
      data.frame(rep = i, method = mtd_names[j], auc = get_auc(roc), delta_t = delta_t)
    }))
  }))
}

