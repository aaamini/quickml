opt.env = new.env(parent = emptyenv())

opt.env$verbose = 2

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
fastml_options = function(verbose = 2) {
  opt.env$verbose = verbose
}
# set_verbose = function(verbose) {
#   opt.env$verbose = verbose
# }
