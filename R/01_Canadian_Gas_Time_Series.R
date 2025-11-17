# ==============================================================================
# Canadian Gas Time Series
# ==============================================================================

# Use available data from Jan 1960 to Dec 2000 to train, predict Canadian gas production until Feb 2005, and evaluate forecast

# load required library
library(fpp3)

# The dataset measures Canadian gas production
# Units: The measurements are in billions of cubic metres.
# Frequency: It is a monthly time series.
# Time Period: The data covers the period from January 1960 to February 2005.
# Source: It is sourced from the book Forecasting with exponential smoothing: the state space approach by Hyndman et al. (2008).

# Define Training Data 
train <- canadian_gas |> filter(year(Month) <= 2000)

View(train)
str(train)

# ------------------------------------------------------------------------------
# 1. Data Transformation
# ------------------------------------------------------------------------------

# 1.1 Analyze candadian gas and verify if production is constant over time
p1 <- train |>
  autoplot(Volume) +
  labs(title = "1. Canadian Gas Production (1960-2000)",
       subtitle = "Variance increases over time, requiring Box-Cox transformation.")

print(p1)
ggsave("/home/ephraim/Projects/Canadian-Gas-Time-Series/Figures/01_raw_data_volume.png", plot = p1, width = 7, height = 5)



# observation: variance increases with time --> box-cox transfomration

# 1.2 Find optimal lambda (box-cox transformation parameter)
train |>
  features(Volume, guerrero) |>
  pull(lambda_guerrero) -> lambda

lambda

# 1.3 Plot the transformed data 
p2 <- train |>
  autoplot(box_cox(Volume, lambda)) +
  labs(title = "2. Box-Cox Transformed Canadian Gas Production",
       subtitle = paste0("Variance stabilized using lambda = ", round(lambda, 4)))

print(p2)
ggsave("/home/ephraim/Projects/Canadian-Gas-Time-Series/Figures/02_transformed_data.png", plot = p2, width = 7, height = 5)

# ------------------------------------------------------------------------------
# 2. Differencing for Stationarity
# ------------------------------------------------------------------------------

# 2.1 Seasonal Differencing
# Seasonal Differencing of lag 12 for one year is implemented to remove the monthly seasonality. Important to remove the trend.

# visually check for non-seasonal trend after seasonal differencing
train |>
  gg_tsdisplay(box_cox(Volume, lambda) |>
                 difference(12), plot_type = "partial") 

# 2.2 Test for Stationarity (KPSS)
# KPSS test is used to check if the series is stationary after seasonal differencing (null hypothesis: time series under test is stationartiy)

train |>
  mutate(diff_s = difference(box_cox(Volume, lambda), lag = 12)) |> # create column of seasonally differenced volumn of canadian oil 
  features(diff_s, unitroot_kpss) # apply the KPSS unit root test to the newly created seasonally differenced column diff_s

# the kpps test fails --> apply additional first difference (lag 1)

# 2.3 Seasonal and First Differencing 

p3 <- train |>
  gg_tsdisplay(box_cox(Volume, lambda) |>
                 difference(12) |>
                 difference(1), plot_type = "partial") + 
  labs(title = "3. Final Stationarity Check: Twice-Differenced Series",
       subtitle = "Remaining Time Series looks like White Noise confirming Stationarity.")

print(p3)
ggsave("/home/ephraim/Projects/Canadian-Gas-Time-Series/Figures/03_final_differencing_diagnostics.png", plot = p3, width = 10, height = 7)

train |>
  mutate(diff_final = difference(box_cox(Volume, lambda), lag = 12) |> difference()) |>
  features(diff_final, unitroot_kpss)

# kpss_pvalue of 0.1 confirms stationarity (note: if the p value is 0.1 or higher the function shows simply 0.1 as result)

# ------------------------------------------------------------------------------
# 3. Model Identification
# ------------------------------------------------------------------------------

# Use ARIMA function to find best model and compare it to baseline

# 3.1 Fit different models
train |>
  model(
    manual = ARIMA(box_cox(Volume, lambda) ~ 0 + pdq(0, 1, 1) + PDQ(0, 1, 1)),
    auto = ARIMA(box_cox(Volume, lambda))) -> fitted_models

# Report manual model
fitted_models |>
  select(manual) |>
  report()

# Report automatic model from ARIMA function
fitted_models |>
  select(auto) |>
  report()

# Compare AICc of manual and automatic model
glance(fitted_models)

# automatetely created model from the ARIMA function is considerably better than the manual one --> use this one for further procdure 

# ------------------------------------------------------------------------------
#  4. Check the residuals 
# ------------------------------------------------------------------------------

# check residuals to verify if any remaining pattern is left 

# 4.1 Verify residuals visually 
p4 <- fitted_models |>
  select(auto) |>
  gg_tsresiduals() +
  labs(title = "4. Residual Diagnostics for Best ARIMA Model",
       subtitle = "Residuals pass the Ljung-Box test, confirming that residual autocorrelation is not significant and only white noise remains.")

print(p4)
ggsave("/home/ephraim/Projects/Canadian-Gas-Time-Series/Figures/04_residual_diagnostics.png", plot = p4, width = 10, height = 7)

# graph shows some spikes outside of the confidence bounds --> Ljung-Box test to verify statistically

# 4.2 Verify residuals statistically
fitted_models |>
  select(auto) |>
  augment() |> # extracts fitted values and residuals (.resid)
  features(.resid, ljung_box) # calculates Ljung-Box test statistic and p-value on the residuals column

# observation: p-value = 0.838 --> residuals of model do resemble white noise, 
# --> model captures all significant autocorrelation, making the model valid for forecasting

# ------------------------------------------------------------------------------
#  5. Model Evaluation
# ------------------------------------------------------------------------------

# evaluate best model (auto) by generating forecasts for the period Jan 2001 until Feb 2025

# 5.1 Define test data

canadian_gas |>
  filter(year(Month) > 2000) -> test

# 5.2 Generate Forecasts on Test Data
forecasts <- fitted_models |>
  select(auto) |>
  forecast(h = 50)  # 50 months from 2001 to Feb 2005

# 5.3 Evaluate Forecast Accuracy

# actual values from test set
actuals <- test$Volume
# forecast point estimates
predictions <- forecasts$.mean

# Calculate RMSE 
sqrt(mean((actuals - predictions)^2))
# Calculate MAE 
mean(abs(actuals - predictions))

p5 <- forecasts |>
  autoplot(canadian_gas) +
  labs(title = "5. Canadian Gas Production Forecast (2001-2005)",
       subtitle = "Forecasts generated by the optimal ARIMA(1,1,1)(0,1,1)[12] model")

print(p5)
ggsave("/home/ephraim/Projects/Canadian-Gas-Time-Series/Figures/05_final_forecast_evaluation.png", plot = p5, width = 7, height = 5)








