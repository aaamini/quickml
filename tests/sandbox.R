library(mlbench)

data("Sonar")
# data("BreastCancer")
# data("DNA")
# data = DNA
data = Sonar
# data = BreastCancer

y = data$Class
X = subset(data, select=-Class)
X = sample_cols(X, 60)

fastml_options(verbose = 2)
res = quickml(X, y)
summarize_bench(res)
plot_bench(res, save = TRUE, type = "png")

