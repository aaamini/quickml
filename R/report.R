#' @export
rename_methods = function(res) {
  res$method = factor(res$method)
  levels(res$method) = list(`RF` = "rf", XGB = "xgb", `RLR` = "rlr", `DecT` = "dt", KSVM = "ksvm")
  res
}

#' @export
#' @importFrom dplyr %>%
summarize_bench = function(res) {
  res %>%
    rename_methods %>%
    dplyr::group_by(method) %>%
    dplyr::summarize(auc_mean = mean(auc), auc_sd = sd(auc),
                     delta_t_mean = signif(mean(delta_t),2))
}

#' @export
#' @importFrom dplyr %>%
#' @import ggplot2
plot_bench = function(res, save = FALSE, type = "pdf") {
  p = res %>%
    rename_methods %>%
    ggplot(aes(x=method, y = auc, color = method)) +
    geom_boxplot() + theme_minimal(base_size = 16) +
    xlab("Method") + ylab("AUC") +
    theme(
      legend.background = ggplot2::element_blank(),
      legend.title = ggplot2::element_blank(),
      legend.position = c(0.2, 0.2)
      # axis.text.x = element_text(angle = 90)
      # legend.text = ggplot2::element_text(size=18),
    ) +
    guides(colour = ggplot2::guide_legend(keywidth = 2, keyheight = 1.25))
  if (save) ggsave(sprintf("auc_boxplot.%s", type), width = 5, height = 5)
  p
}
