library(mlbench)

data("Sonar")
# data("BreastCancer")
data("DNA")
data = DNA
data = Sonar
# data = BreastCancer

data = readr::read_csv("data/Social_Network_Ads.csv")
data = data[,-1]
y = data$Purchased
X = subset(data, select=-Purchased)

y = data$Class
X = subset(data, select=-Class)
# X = sample_cols(X, 60)
X = sample_cols(X, 60)

fastml_options(verbose = 2)
res = quickml(X, y)
summarize_bench(res)
plot_bench(res, save = TRUE, type = "png")

