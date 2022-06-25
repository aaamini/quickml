library(mlbench)

set.seed(123)
data("Sonar")
# data("BreastCancer")
# data("DNA")
# data = DNA
data = Sonar
# data = BreastCancer

# data = readr::read_csv("data/Social_Network_Ads.csv")
# data = data[,-1]
# y = data$Purchased
# X = subset(data, select=-Purchased)

y = data$Class
X = subset(data, select=-Class)

# X = X %>% tibble::as_tibble()
# X = sample_cols(X, 60)
X = sample_cols(X, 60)

# randomForest::rfImpute(X, y)

fastml_options(verbose = 2)
res = quickml(X, y)
summarize_bench(res)
plot_bench(res, save = TRUE, type = "png")

# X = char_to_factor(X)
#
# X2 =  X %>% as_tibble() %>% char_to_factor %>% remove_hd_factors
#
# X4 = code_factors(X3, drop_intercept = TRUE)
#
# invisible(capture.output(X3 <- randomForest::rfImpute(X2, y, iter = 3)))
# X3 <- randomForest::rfImpute(X2, y, iter = 3)
