#
decide_nreps = function(X) {
  # max(15, round(250 / log(prod(dim(X)))))
  max(10, round(250 / (log(nrow(X)) + 2*log(ncol(X)))))
}

create_method_list = function() {
  method_list = NULL
  idx = c(opt.env$dt, opt.env$xgb, opt.env$rf, opt.env$rlr, opt.env$ksvm)

  method_list = list(dt = c(tune_dt, fit_dt),
                    xgb = c(tune_xgb, fit_xgb),
                    rf = c(tune_rf, fit_rf),
                    rlr = c(tune_rlr, fit_rlr),
                    ksvm = c(tune_ksvm, fit_ksvm))
  method_list[idx]
}

#' @export
quickml = function(X, y,
                     nreps = NULL,
                     # ncore = 1,
                     verbose = 1) {

  if (!is.null(dim(y))) stop("y should be a vector.")
  if (nrow(X) != length(y)) stop("nrow(X) should be the same as length(y).")

  y_na_idx = is.na(y)
  if (any(y_na_idx)) {
    report_info1("Missing values in `y`. Removing the corresponding rows.")
    X = X[!y_na_idx, , drop=FALSE]
    y = y[!y_na_idx]
  }

  if (!is.factor(y)) y = factor(y)
  if (length(levels(y)) != 2) {
    report_info1("Only binary classification implemented: Collapsing 'y' to two levels.\n")
    y = collapse_factor_to_two(y)
  }
  y = factor_to_numeric(y)
  X = char_to_factor(X)
  X = remove_hd_factors(X)

  if (any(is.na(X))) {
    stop("Missing values in features. Imputation not implemented yet. Stopping.")
  }

  X = code_factors(X, drop_intercept = TRUE)

  report_info1(sprintf("Data (now) has %d samples on %d variables (%d factors, %d numeric)",
                       nrow(X), ncol(X), count_factors(X), count_numerics(X)))

  class_prop = as.numeric(signif(table(y) / length(y),2))
  report_info1(paste0("Class proportions: ", paste0(class_prop, collapse = ", ")))
  if (is.null(nreps)) nreps = decide_nreps(X)
  # # report_msg1(sprintf("Running benchmark with nreps = %d\n", nreps))
  # report_info1(sprintf("Running benchmark with nreps = %d", nreps))
  train_idxs = get_splits(y, p = 0.7, times = nreps)
  methods = create_method_list()
  if (is.null(methods)) {
    report_info1("Nothing to do. Try selecting some methods using qml_options(). Returning.")
    return(NULL)
  }
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
      data.frame(rep = i, method = mtd_names[j], auc = roc2auc(roc), delta_t = delta_t)
    }))
  }))
  report_succ1("Benchmark concluded successfully.")
  attr(res, "class") = c("aucres", class(res))
  res
}

