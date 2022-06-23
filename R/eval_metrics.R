#' @export
#' @importFrom pROC roc
get_roc = function(y, yh_prob) {
  roc(y, yh_prob, quiet = TRUE)
}
#' @export
get_auc = function(roc) {
  as.numeric(roc$auc)
}
