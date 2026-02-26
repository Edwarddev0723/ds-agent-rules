# Snippet: MLOps & Model Deployment

## Domain Context
Taking models from experimentation to production with reliability, monitoring, and automation.
The model is only as good as the system around it.

## CI/CD for ML
- Model training pipelines must be reproducible from a single command or config
- Every model artifact must be traceable: commit hash, data version, config, training logs
- Automated tests for data pipelines: schema validation, distribution drift, missing values
- Automated tests for model quality: eval metrics must pass a minimum threshold gate
- Separate pipelines: data prep → training → evaluation → packaging → deployment

## Model Registry
- Every production model must be registered with: version, metrics, training config, data hash
- Promote models through stages: `dev → staging → production` — never skip staging
- Keep at least 2 previous production model versions for instant rollback
- Model metadata must include: input/output schema, expected latency, resource requirements

## Serving & Inference
- Define SLA upfront: latency p99, throughput, availability target
- Health checks must verify model is loaded and producing valid outputs, not just HTTP 200
- Implement graceful degradation: fallback model or cached responses when primary fails
- Batch inference: prefer offline batch processing for non-real-time use cases (cheaper, simpler)
- A/B testing infrastructure: route traffic by percentage, log predictions for both models

## Monitoring in Production
- **Data drift detection** is mandatory — monitor input feature distributions daily
- **Model performance monitoring**: track prediction distribution shift, not just system metrics
- Alert on: prediction latency spike, error rate increase, confidence score distribution shift
- Log all predictions with timestamps — enables retroactive analysis when issues are discovered
- Dashboard must show: request volume, latency percentiles, error rate, model version, drift score

## Infrastructure
- Containerize everything: model serving, data pipelines, evaluation jobs
- GPU resource management: right-size instances, use spot/preemptible for training
- Model artifacts stored in versioned object storage (S3/GCS), not local filesystem
- Secrets and credentials: use vault/secret manager, never env files in containers

## Common Pitfalls
- Training-serving skew: feature engineering differs between training and inference
- Silent model degradation: model still returns predictions but quality drops over weeks
- Missing monitoring: team discovers issues from user complaints, not alerts
- Over-engineering: not every model needs Kubernetes — start simple, scale when needed
