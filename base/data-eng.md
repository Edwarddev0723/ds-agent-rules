# Data Engineering Overlay
> Appended on top of core.md for data-centric projects (ETL, feature engineering, data platforms).

## Project Mindset
Data is the product. **Data quality > pipeline speed > code elegance.**
Every pipeline must be idempotent, observable, and recoverable.
Treat data contracts like API contracts — breaking changes require versioning and migration.

---

## Data Pipeline Principles
- Pipelines must be **idempotent**: running the same pipeline twice produces the same result
- Every pipeline step must be independently re-runnable without side effects
- Use a DAG orchestrator (Airflow, Dagster, Prefect) — never cron jobs for multi-step pipelines
- Pipeline naming convention: `{source}_{transform}_{destination}_{frequency}`
- Pipeline ownership: every pipeline must have an owner documented in config

---

## Data Quality
- Schema validation at every boundary: source → raw → staging → production
- Data quality checks (mandatory per table): row count, null %, unique constraint, value range
- Implement data contracts: agreed schema + freshness + quality SLA between producer and consumer
- Anomaly detection on key metrics: alert on volume changes >20%, null rate spikes, distribution shifts
- Quarantine bad data: route failing records to a dead-letter table, not silently drop them

---

## Feature Store & Feature Engineering
- Feature definitions must be centralized — one source of truth for each feature
- Feature computation must be identical between training (offline) and serving (online)
- Track feature lineage: which raw data sources contribute to each feature
- Feature documentation: name, type, description, update frequency, owner, downstream consumers
- Deprecation policy: mark features as deprecated before removing them; track usage

---

## Storage & Format Standards
- Columnar format preferred for analytics: Parquet or Delta Lake
- Partition strategy: define by access pattern (date, region, etc.) — document the choice
- File size target: 128MB-1GB per file for Spark; avoid small file problem
- Schema evolution: use formats that support it (Parquet, Avro) — never break downstream readers
- Data retention policy: define TTL per dataset; implement automated cleanup

---

## Observability
- Every pipeline run must log: start time, end time, records processed, records failed, duration
- Data freshness monitoring: alert when data is older than SLA threshold
- Cost tracking: monitor compute and storage costs per pipeline — optimize the expensive ones
- Lineage tracking: maintain a graph of data dependencies (source → transform → destination)
- Runbook: every pipeline must have a documented troubleshooting guide

---

## Security & Governance
- PII classification: tag columns containing personal data at ingestion time
- Access control: implement column-level or row-level security for sensitive data
- Audit logging: track who accessed what data, when, and why
- Data masking: provide anonymized views for development and testing environments
- Compliance: document which regulations apply to each dataset (GDPR, HIPAA, etc.)
