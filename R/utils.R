opt.env = new.env(parent = emptyenv())

opt.env$verbose = 2
opt.env$dt = TRUE
opt.env$rf = TRUE
opt.env$xgb = TRUE
opt.env$rlr = TRUE
opt.env$ksvm = TRUE
opt.env$ord2int = TRUE

#' @export
sample_cols = function(X, size = ncol(X)) {
  d = ncol(X)
  X[, sample(d, min(size, d))]
}

#' @export
#' @importFrom caret createDataPartition
get_splits = function(y, p = 0.5, times = 1) {
  lapply( createDataPartition(y, p = p, times = times), function(idx) {
    temp = rep(FALSE, length(y))
    temp[idx] = TRUE
    temp
  })
}

#' @importFrom cli cli_alert_info
report_info1 = function(...) {
  if (opt.env$verbose > 0) cli::cli_alert_info(...)
}

#' @importFrom cli cli_alert_info
report_succ1 = function(msg) {
  if (opt.env$verbose > 0) cli::cli_alert_success(msg)
}


report_msg1 = function(msg) {
  if (opt.env$verbose > 0) cat(msg)
}

report_msg2 = function(msg) {
  if (opt.env$verbose > 1) cat(msg)
}

#' @export
qml_options = function(verbose = 2,
                       dt = TRUE, rf = TRUE, xgb = TRUE, rlr = TRUE, ksvm = TRUE,
                       ord2int = TRUE) {
  opt.env$verbose = verbose
  opt.env$dt = dt
  opt.env$rf = rf
  opt.env$xgb = xgb
  opt.env$rlr = rlr
  opt.env$ksvm = ksvm
  opt.env$ord2int = ord2int
}
# set_verbose = function(verbose) {
#   opt.env$verbose = verbose
# }
