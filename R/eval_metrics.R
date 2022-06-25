#' @export
#' @importFrom pROC roc
get_roc = function(y, yh_prob) {
  roc(y, yh_prob, quiet = TRUE)
}
#' @export
roc2auc = function(roc) {
  as.numeric(roc$auc)
}

#' @export
get_auc = function(y, yh_prob) {
  roc2auc(get_roc(y, yh_prob))
}
