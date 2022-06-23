# quickml

The package allows one to quickly run a couple of most common binary classification algorithms on a new problem to get of idea of the limits of performance. It makes some guesses about the values of the hyperparameters (mostly the default values!) and avoids hyperparameter tuning in favor of performance. 

The package should handle factor variables properly by coding them to dummy variables, and in later editions should have a basic imputation method for missing values. 

Run `tests/sandbox.R` for a quick demonsteration. It should produce a plot like this

<img src="https://user-images.githubusercontent.com/17173393/175207094-1e8668be-c1df-42fc-bb30-13208b60cb9b.png" width = "600"> 


The package is under development, including the documentation. 
