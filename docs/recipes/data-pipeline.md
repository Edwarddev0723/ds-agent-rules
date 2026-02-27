# Recipe: Data Pipeline

> **Use Case**: This configuration targets projects building batch or streaming data pipelines, feature stores, and ETL/ELT workflows. It prevents common issues like missing data quality checks, silent schema drift, untracked feature transformations, and non-reproducible feature engineering.

## Configuration (`.ai-rules.yaml`)

Copy the following into your project's root `.ai-rules.yaml`:

```yaml
profile: data-eng
snippets:
  - streaming-ml
  - mlops
  - tabular-ml
```

## Why this stack?

**`data-eng` (profile)**: Data Engineering overlay enforces idempotent pipeline design, mandatory data lineage tracking, schema validation at ingestion, and SLA-aware partitioning strategies.

**`streaming-ml`**: Adds rules for handling out-of-order events, watermark management, and stateful stream processing — essential for real-time feature pipelines that feed online model serving.

**`mlops`**: Ensures that all pipeline runs are logged, feature transformations are versioned, and data quality metrics are tracked as first-class signals. Prevents silent degradation in upstream features from going undetected.

**`tabular-ml`**: Provides guardrails for feature engineering on structured data — requiring explicit handling of target leakage, consistent train/serving feature parity, and documented feature semantics in the feature store.
