# Snippet: Time Series Forecasting & Analysis

## Domain Context
Forecasting, anomaly detection, or classification on temporal data.
Time adds a structural constraint that most ML best practices must respect.

## Critical Rule: No Time Leakage
- **Temporal split is the only valid split strategy** — never use random train/test split
- Walkforward validation: train on [0, t], validate on [t, t+h], slide forward
- Features must use only past data relative to the prediction point — verify point-in-time correctness
- Lag features: always compute relative to the prediction timestamp, not absolute time
- If using cross-validation: use `TimeSeriesSplit`, never `KFold`

## Data Preprocessing
- Always check for: missing timestamps, irregular intervals, duplicate timestamps
- Imputation strategy must be documented: forward-fill, interpolation, or model-based
- Normalize/scale using **only training set statistics** — never fit on full dataset
- Handle timezone and DST transitions explicitly in your pipeline
- Log data frequency (hourly, daily, etc.) and calendar effects (holidays, weekends)

## Feature Engineering
- Standard temporal features: hour, day-of-week, month, is_holiday, is_weekend
- Lag features: recent lags (1, 2, 7, 14, 28) + rolling statistics (mean, std, min, max)
- Trend and seasonality decomposition (STL) as preprocessing or features
- External regressors: weather, events, economic indicators — document each one
- Fourier features for capturing complex seasonality without dummy variables

## Model Selection
- Baseline: seasonal naive (last period value) — everything must beat this
- Statistical models (Prophet, ARIMA): start here for single series with clear patterns
- Tree-based (LightGBM + lag features): strong default for multi-series with shared patterns
- Deep learning (TFT, PatchTST, TimesFM): justify with scale (many series, complex dependencies)
- Always compare multiple approaches — no single model dominates all time series problems

## Evaluation
- Metrics: MAPE, SMAPE, RMSE, MAE — report at least two to avoid metric gaming
- Evaluate across forecast horizons separately (1-step, 7-step, 30-step are different problems)
- Break down metrics by segment: high-volume vs. low-volume series behave differently
- Visualize actual vs. predicted with confidence intervals — numbers alone hide systematic errors
- Measure and report calibration of prediction intervals (e.g., 95% CI should contain 95% of actuals)

## Common Pitfalls
- Look-ahead bias: accidentally using future information in feature computation
- Non-stationarity: model trained on one regime performs poorly when the pattern changes
- Concept drift: production model degrades over time — implement drift detection and retraining triggers
- Aggregation level mismatch: model trained on daily data applied to hourly predictions
- Outlier sensitivity: a few extreme values dominate RMSE — consider robust metrics or outlier handling
