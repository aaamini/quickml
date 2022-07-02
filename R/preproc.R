char_to_factor = function(X) {
  idx = sapply(X, is.character)
  if (sum(idx) > 0) {
    report_info1("Converting character variables to factor.")
    X[, idx] = lapply(X[, idx, drop=FALSE], as.factor)  # drop=FALSE handle the case where there only 1 factor
  }
  X
}
drop_colnames = function(X) {
  colnames(X) = paste0("X", 1:ncol(X))
  X
}

# Works only for binary features, assume all columns are numeric (dbl or int)
remove_sparse_binary_features = function(X, p = 0.7, N=1000, eps = 1/N) {
  # N = 100 # How many simulation to run
  # # p = 0.7  # probability of including in the training
  # eps = 1/N # the probability of observing a bad event

#  factor(X[,2], levels(X[,2])[table(X[,2]) >=  threshold]

  # Y = model.matrix(~., X %>% char_to_factor %>% remove_hd_factors)
  # Y = X %>% char_to_factor %>% remove_hd_factors %>% code_factors(F)
  int_cols = sapply(X, is.integer)
  Xint = X[int_cols]
  freqs = lapply(Xint, table)
  bin_cols = sapply(freqs, length) == 2    # select binary features
  if (sum(bin_cols) == 0) return(X) # No binary features. Nothing to do

  threshold = round(log(1-exp(log(1-eps)/N)) / log(1-p))
  # 2*log(N) /  -log(1-p)

  Xbin = Xint[bin_cols]
  nonsparse_cols = sapply(freqs[bin_cols], min) >= threshold
  if (sum(nonsparse_cols) == 0) return(X) # No sparse features; Nothing to do
  report_info1(sprintf("Sparse binary features (frequency < %d) detected. Removing.", threshold))

  new_X = cbind(Xbin[nonsparse_cols], Xint[!bin_cols], X[!int_cols])
  report_var_counts(new_X)
  new_X
  # X %>% lapply(table) %>% sapply(length) <= threshold
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

count_ints = function(X) {
  sum(sapply(X, is.integer))
}

count_dbls = function(X) {
  sum(sapply(X, is.double))
}

factor_to_numeric = function(fac) {
  as.numeric(fac)-1
}

code_ordinal_factors = function(X, ord2int = TRUE) {
  idx = sapply(X, is.ordered)
  if (sum(idx) ==  0) return(X) # Nothing to do

  if (ord2int) {
    report_info1("Coding ordinal factors into integers.")
    X[,idx] = lapply(X[, idx], as.integer)
    return(X)
  }

  report_info1("Coding ordinal factors using poly contrast.")
  temp = model.matrix(~., X[, idx])
  temp = subset(temp, select = -`(Intercept)`) # Removed the intercept
  cbind(temp, X[!idx])
}

code_factors = function(X, ord2int = TRUE) { #, drop_intercept = FALSE) {
  if (is.null(dim(X))) {
    # X is a vector,
    stop("Univariate models are not implemented yet. X should have 2 dimensions.")
  }

  # Deal with ordinal variables
  X = code_ordinal_factors(X, ord2int)

  # Ordered factors are excluded at this point. Only nominal factors remain.
  idx = sapply(X, is.factor)
  if (sum(idx) == 0) return(X) # nothing to do

  report_info1("Coding (nominal) factors into dummy variables.")
  temp = model.matrix(~ ., X[,idx])
  groups = attr(temp,"assign")  # for future use, groups of created dummy variables
  # if (drop_intercept) temp = subset(temp, select = -`(Intercept)`)
  temp = subset(temp, select = -`(Intercept)`) # Removed the intercept

  temp = apply(temp, 2, as.integer)
  new_X = cbind(temp, X[!idx])
  report_var_counts(new_X)

  new_X
}

collapse_factor_to_two = function(y) {
  most_frequent_level = names(which.max(table(y)))[1]
  new_level = paste0("not_", most_frequent_level)

  y = as.character(y)
  y[!y == most_frequent_level] = new_level
  as.factor(y)
  # (y == most_frequent_level)*1
}

