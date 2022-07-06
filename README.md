
<!-- README.md is generated from README.Rmd. Please edit that file -->

# quickml

<!-- badges: start -->
<!-- badges: end -->

**quickml** is an R package that aims to provide a full ML pipeline to
rapidly benchmark a binary classification problem by running some of the
most common algorithms on it. Ideally, once fully functional, it should
handle any *raw* dataset, automatically cleaning it up, recoding
factors, filtering problematic features, imputing missing values, doing
some basic hyperparameter tuning, etc. By comparing the performance of multiple methods on the same task,
it will give you an idea of the limits of performance achievable on the
given dataset. In other words, it tells you how hard of a classification
task it is.

Some of the pre-test steps are:

-   Converting character features to factors (i.e., categorical
    variables).
-   Removing highly diverse factors (e.g., phone numbers or IDs).
-   Removing sparse factor levels (those that will most likely lead to a constant level in train/test splits).
-   Coding ordinal factors either into integer or using polynomial contrasts (two options as of now).
-   Coding nominal factors into dummy variables.
-   TODO: Imputing on train/test.
-   Hyperparameter tuning for some of the algorithms.

Currently the following algorithms are used for the benchmark:

-   **Random Forest (RF)**: Fast [`ranger` implementation](https://github.com/imbs-hl/ranger). No tuning.
-   **Gradient Boosted Trees (XGB)**: [XGBoost implementation](https://github.com/dmlc/xgboost). Basic tuning (number of rounds by early stopping on validation AUC, max_depth, eta).
-   **Regularized Logistic Regression (RLR)**: L2-regularized. `glmnet` implementation.
    <!--- with alpha parameter decided between 0 or 1 (L2 vs. L1regularization, respectively) during hyperparameter tuning.--->
    Regularization parameter lambda is tuned.
-   **Decision Tree (DecT)**: A single decision tree. No tuning. `rpart` implementation. 
-   **Kernel SVM (KSVM)**: SVM with the Gaussian (a.k.a Radial Basis) kernel. No tuning.

## Installation

quickml is under development. You can install the latest version in R by running the follwoing command:

``` r
devtools::install_github("aaamini/quickml")
```
For a list of package dependencies see the *Imports* section of the [DESCRIPTION file](https://github.com/aaamini/quickml/blob/main/DESCRIPTION). The above command should automatically install the necessary packages. An exception is when you have an older version of a package installed and a newer version is needed, in which case `R` throws an error. You have to manually upgrade that package. In particular, make sure your `glmnet` package is up to date.

## Example

This is a basic example which shows you how to run it on the Sonar data from the `mlbench` library:

``` r
library(quickml)
library(mlbench)

## basic example code
data("Sonar")
data = Sonar
y = data$Class
X = subset(data, select=-Class)
res = quickml(X, y)
summarize(res)
plot(res, save = TRUE, type = "png")
```

It produces the following output:

<img src="man/figures/quickml_output.png" alt="drawing" width="550"/>

and the following plot:

<img src="man/figures/auc_boxplot.png" alt="drawing" width="500"/>

# Known bugs
- XGB could take a very long time on certain machines (with lots of cores?). The fix is to reduce the `nthread` parameter. This fix is on the TODO list.




