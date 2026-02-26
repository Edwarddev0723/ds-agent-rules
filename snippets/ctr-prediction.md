# Snippet: CTR Prediction / Recommendation Systems

## Domain Context
Click-through rate prediction on advertising platforms.
Data is large-scale, sparse, and highly temporal — treat accordingly.

## Critical Rules
- **Feature leakage check is mandatory** before any model evaluation — this is non-negotiable
- **Temporal split only** — never use random split; future data must not appear in training
- Sparse categorical features must use embedding layers, not one-hot at scale
- Log feature importance for every model — helps debug both model and data issues

## Evaluation Metrics
- Always report both: AUC-ROC and Log Loss — never just one
- Online metric proxy: compare predicted CTR distribution vs. actual CTR distribution
- Calibration check: plot reliability diagram for every new model before deployment
- Offline → online metric gap must be documented and monitored

## Data Pipeline
- User/item features: distinguish between static features and real-time features clearly
- Handle cold-start items explicitly — don't let them silently degrade model performance
- Sample negative examples carefully — random negative sampling may not reflect real distribution

## Scale Considerations
- Assume dataset doesn't fit in RAM — use chunked processing or Spark
- Feature store lookups must be batched — never row-by-row in production
- Embedding tables dominate model size — monitor and cap embedding dimensions (start with dim=16)

## Common Pitfalls
- Using future impressions/clicks in training features — temporal leakage is the #1 silent killer
- Ignoring position bias: items shown in position 1 always get more clicks regardless of relevance
- Evaluating on uniformly random traffic but deploying on biased traffic — offline/online gap is inevitable
- One-hot encoding high-cardinality features (>10K categories) — use hashing or embeddings instead
- Not monitoring prediction distribution shift after deployment — models degrade within days as user behavior changes
