char_to_factor = function(X) {
  idx = sapply(X, is.character)
  if (sum(idx) > 0) {
    report_info1("Converting character variables to factor.")
    X[, idx] = lapply(X[, idx, drop=FALSE], as.factor)  # drop=FALSE handle the case where there only 1 factor
  }
  X
}

#' @export
factor_diversity = function(fac) {
  length(levels(fac)) / length(fac)
}

#' Remove highly diverse factors
#' @export
remove_hd_factors = function(X, threshold = 0.9){
  idx = sapply(X, is.factor)
  if (sum(idx) > 0) {
    div_idx = sapply(X[, idx, drop=FALSE], factor_diversity) > threshold
    div_locs = which(idx)[which(div_idx)]
    div_count = length(div_locs)
    if (div_count > 0) {
      report_info1((sprintf("Removing %d highly diverse factors", div_count)))
      X = X[, -div_locs]
    }
  }
  X
}

count_factors = function(X) {
  sum(sapply(X, is.factor))
}

count_numerics = function(X) {
  sum(sapply(X, is.numeric))
}


factor_to_numeric = function(fac) {
  as.numeric(fac)-1
}

code_factors = function(X, drop_intercept = FALSE) {
  if (is.null(dim(X))) {
    # X is a vector,
    stop("Univariate models are not implemented yet. X should have 2 dimensions.")
  }
  idx = sapply(X, is.factor)
  if (sum(idx) == 0) return(X) # nothing to do

  report_info1("Coding factors into dummy variables.")
  temp = model.matrix(~ ., X[,idx])
  groups = attr(temp,"assign")  # for future use, groups of created dummy variables
  if (drop_intercept) temp = subset(temp, select = -`(Intercept)`)

  cbind(temp, X[!idx])
}

collapse_factor_to_two = function(y) {
  most_frequent_level = names(which.max(table(y)))[1]
  new_level = paste0("not_", most_frequent_level)

  y = as.character(y)
  y[!y == most_frequent_level] = new_level
  as.factor(y)
  # (y == most_frequent_level)*1
}

