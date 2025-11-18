# SARIMA Forecasting for Canadian Gas Production

## Project Overview

This repository documents a time series analysis project focused on developing and evaluating an **SARIMA (Seasonal Autoregressive Integrated Moving Average) model** to forecast **Canadian Gas Production**. The project follows standard statistical methodology to achieve a robust forecast, including data transformation, stationarity testing (KPSS), model identification (ACF/PACF), and out-of-sample accuracy evaluation.

---

## Table of Contents

1.  [Project Overview](#project-overview)
2.  [Dataset](#dataset)
3.  [Methodology](#methodology)
4.  [Model Used](#model-used)
5.  [Key Results](#key-results)
6.  [Repository Structure](#repository-structure)
7.  [Setup and Installation](#setup-and-installation)
8.  [Usage](#usage)
9.  [Future Work](#future-work)
10. [License](#license)

---

## Dataset

The project utilizes the built-in R time series dataset, `canadian_gas`, available within the `fpp3` package ecosystem.

* ***Variable***: Monthly production volume of natural gas in Canada.
* ***Units***: Billions of cubic meters.
* ***Frequency***: Monthly ($s=12$).
* ***Time Period***: January 1960 to February 2005.
* ***Split***: Data up to **December 2000** was used for **training**, and the data from **January 2001 to February 2005** (50 months) was used for **testing/evaluation**.

---

## Methodology

The project follows the classic Box-Jenkins methodology for time series analysis:

1.  ***Data Transformation***:
    * **Visual Check**: Confirmed increasing variance.
    * **Box-Cox Transformation**: Calculated the optimal $\lambda = \mathbf{0.3156}$ (on the training set) to stabilize variance.

2.  ***Stationarity Testing***:
    * **Seasonal Differencing** ($\nabla_{12}$): Applied to remove seasonality. The **KPSS test failed** ($p = 0.01$), indicating remaining trend non-stationarity.
    * **First Differencing** ($\nabla_1$): Applied to remove the trend. The final KPSS test **passed** ($p = 0.1$), confirming stationarity with orders $\mathbf{d=1}$ and $\mathbf{D=1}$.

3.  ***Model Identification***:
    * A manual model ($\text{ARIMA}(0, 1, 1)(0, 1, 1)_{12}$) was identified from the ACF/PACF plots.
    * An automatic model was selected by the `ARIMA()` function.

4.  ***Model Selection***: The models were compared using the $\text{AICc}$ criterion.

5.  ***Diagnostic Checking***: The residuals of the best model were checked visually (ACF plot) and statistically (Ljung-Box test, $p = 0.990$) to confirm they resemble **white noise**.

6.  ***Forecasting & Evaluation***: The final model was used to forecast the 50 months of the held-out test set, and accuracy metrics (RMSE, MAE) were calculated.

---

## Model Used

Two models were compared on the training set. The **Automatic ARIMA** model was selected as the best performer.

* **Best Model (Auto):** $\mathbf{\text{ARIMA}(1, 1, 1)(0, 1, 1)_{12}}$

| Model | Log-Likelihood | $\text{AICc}$ | Residual $\sigma^2$ |
| :------------------ | :------- | :------------------ |:-------------------|
| Manual $\text{ARIMA}(0, 1, 1)(0, 1, 1)_{12}$ | $640.$ | $-1274.$ | $0.00403$ |
| **Auto $\text{ARIMA}(1, 1, 1)(0, 1, 1)_{12}$** | $\mathbf{645.}$ | $\mathbf{-1281.}$ | $\mathbf{0.00395}$ |

---

## Key Results

The final **$\text{ARIMA}(1, 1, 1)(0, 1, 1)_{12}$** model was evaluated on the 50-month test set (Jan 2001 - Feb 2005).

| Metric | Value (Out-of-Sample) |
| :--- | :--- |
| **Root Mean Squared Error (RMSE)** | **2.028514** |
| **Mean Absolute Error (MAE)** | **1.753585** |

The model provided a robust and accurate forecast on the unseen test data. The forecast plot (Figure 5) visually confirms that the model successfully tracks the seasonal and level changes in the actual gas production volume.

---

## Repository Structure

/Canadian-Gas-Time-Series/   
|-- README.md   
|-- **R/**   
|   |-- 01_Canadian_Gas_Time_Series.R
|-- **Figures/**   
|   |-- 01_raw_data_volume.png   
|   |-- 02_transformed_data.png   
|   |-- 03_final_differencing_diagnostics.png   
|   |-- 04_residual_diagnostics.png   
|   |-- 05_final_forecast_evaluation.png   

---

## Setup and Installation

This project is built entirely in **R** using the specialized `fable` ecosystem packages for time series analysis.

1.  **Install R and RStudio** (recommended).

2.  **Install the required packages** in your R console:
    ```R
    install.packages("fpp3")
    ```

3.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Ephraim-E-Stiefel/Canadian-Gas-Time-Series.git](https://github.com/Ephraim-E-Stiefel/Canadian-Gas-Time-Series.git)
    cd Canadian-Gas-Time-Series
    ```

---

## Usage

1.  **Run the script**: Open RStudio, set the working directory to the repository folder, and run the `R/01_arima_analysis.R` script.

2.  **View Results**: All key results and model outputs (including the calculated RMSE and MAE) are printed to the console. The generated visualization files will be saved in the `Figures/` folder.

---

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---

> **Note:** Some portions of this documentation were generated with the assistance of **Generative AI** to improve clarity and structure.
