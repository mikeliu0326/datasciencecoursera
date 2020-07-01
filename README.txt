MTCars Linear Model Creation Kit

Introduction: The purpose of this tool is for interactive visual EDA of fitting linear models on the MtCars dataset, as well as various fits and their quality.

The tool has the following components.

*  Control panel: controls the number of features fit and the target feature, also toggles displays
*  Density Plot of Fitted Residuals: shows the density of fitted residuals over all fitted models
*  Line Graph of Mean Squared Error: shows MSE over all fitted models indexed by number of features fit, as well as the average and minimum MSEs.
*  Table: shows the linear model formula and its corresponding MSE.

In the backend, the program iteratively fits the linear model with the feature resulting in a minimum Mean Squared Error and stores the models, formulae, and MSE internally.


Inputs
Predictor Selector: Allows user to select any of the features provided in mtcars, they are the following.
Feature Selector: Allows user to select a range of features, between 1 and 10. If only one feature is selected, then only one feature will be displayed.
Toggle Checkboxes: Allows user to toggle the individual visuals on and off, quite self explanatory. 

Outputs
Density Plot 
* It displays the histograms of these models based on number of features used.
* The purpose of this plot is to see the concentration of residuals and how it changes as more features are fit.

MSE Line Graph
* It plots the MSE for each fit model, as well as its average and minimum.
* The purpose of this plot is to show how MSE reduces as more features are fit and ultimately to serve as a hockeystick analysis for selecting the number of features.