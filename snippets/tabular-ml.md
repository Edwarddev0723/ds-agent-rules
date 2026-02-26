# Snippet: Tabular ML / Traditional Machine Learning

## Domain Context
Structured/tabular data modeling: classification, regression, ranking on feature-engineered datasets.
Feature engineering and data quality drive most of the performance gains — not model complexity.

## Feature Engineering
- Start with simple features, add complexity only when baselines are established
- Encode categorical variables properly: label encoding for tree models, target/one-hot for linear
- Handle missing values explicitly: document the imputation strategy and why
- Create interaction features only when domain knowledge supports them
- Time-based features: always use point-in-time correctness — no future leakage
- Log all feature transformations for reproducibility (use sklearn Pipeline or equivalent)

## Model Selection
- **Always start with a strong baseline**: logistic regression / linear regression → then gradient boosting
- Tree-based models (XGBoost, LightGBM, CatBoost) are default for tabular — justify using anything else
- Neural networks on tabular data: only when >100K rows AND non-linear interactions are proven
- Ensemble only if marginal gain justifies the complexity — document the improvement

## Cross-Validation
- Use stratified K-fold (K=5) for classification; standard K-fold for regression
- For time-dependent data: **time-series split only** — never random shuffle
- For grouped data (e.g., per-user): **group K-fold** — same group never in both train and val
- Report mean ± std across folds — a single fold result is not reliable
- Nested CV for hyperparameter tuning: inner loop tunes, outer loop evaluates

## Hyperparameter Tuning
- Use Optuna or similar Bayesian optimization — avoid grid search on large spaces
- Define the search space based on domain knowledge, not arbitrary ranges
- Budget: 50-100 trials for tree models; fewer for expensive models
- Always compare tuned model against default hyperparameters — report the delta

## Explainability
- SHAP values: mandatory for any model going to production or stakeholder review
- Feature importance: compute and log for every trained model
- Partial dependence plots for top-5 features — sanity check against domain knowledge
- If top features don't make domain sense, investigate data issues before celebrating metrics

## Evaluation
- Classification: report precision, recall, F1, AUC-ROC; confusion matrix for multi-class
- Regression: report RMSE, MAE, R²; plot predicted vs. actual
- Always evaluate on holdout test set after all tuning is done (never peek during tuning)
- Segment-level evaluation: check performance across key demographic/business segments

## Common Pitfalls
- Target leakage from features computed using the target variable
- Class imbalance: random accuracy baseline is misleading — use appropriate metrics
- High cardinality categoricals: naive one-hot encoding causes memory explosion
- Train/test distribution mismatch: validate feature distributions are consistent across splits
