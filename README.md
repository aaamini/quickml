# quickml

The package allows one to quickly run a couple of most common binary classification algorithms on a new problem to get of idea of the limits of performance. It makes some guesses about the values of the hyperparameters (mostly the default values!) and avoids hyperparameter tuning in favor of performance. 

The package should handle factor variables properly by coding them to dummy variables, and in later editions should have a basic imputation method for missing values. 

Run `tests/sandbox.R` for a quick demonsteration. It should produce a plot like this
![auc_boxplot](https://user-images.githubusercontent.com/17173393/175206797-948af52f-b300-4048-8e33-fc3f40caf9a9.png){width=25%}

The package is under development, including the documentation. 
