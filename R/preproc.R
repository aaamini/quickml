char_to_factor = function(X) {
  idx = sapply(X, is.character)
  if (sum(idx) > 0) {
    report_info1("Converting character variables to factor.")
    X[, idx] = lapply(X[,idx], as.factor)
  }
  X
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

