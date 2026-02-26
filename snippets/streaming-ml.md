# Snippet: Streaming ML & Online Learning

## Domain Context
Real-time feature engineering, online model updates, and streaming inference pipelines.
Latency and correctness under time pressure are the primary constraints.

## Streaming Architecture
- Clearly separate: event ingestion → feature computation → model serving → output action
- Each stage must be independently scalable and monitorable
- Use message queues (Kafka, Pulsar) between stages — never direct function calls in production
- Exactly-once processing: understand your framework's guarantees and document them
- Define and enforce SLA per stage: max latency, max backlog, error rate threshold

## Real-Time Feature Engineering
- **Point-in-time correctness is non-negotiable** — a feature must never use data from the future
- Windowed aggregations: clearly define window size, slide interval, and late-arrival policy
- Feature consistency: same feature definition must be used in training (offline) and serving (online)
- Feature store integration: compute features once, serve everywhere — avoid training/serving skew
- Late data handling: define a watermark policy — how long to wait for late events before closing the window

## Online Learning
- Model update frequency: tune based on concept drift rate, not arbitrary schedule
- Learning rate for online updates: lower than batch training (typically 1/10th to 1/100th)
- Catastrophic forgetting: monitor performance on historical data after each update
- Replay buffer: maintain a sample of historical data to mix with new data during updates
- Rollback capability: always maintain the previous model version for instant revert

## Concept Drift Detection
- Monitor input feature distributions in real-time — use PSI (Population Stability Index) or KS test
- Prediction distribution monitoring: alert when output distribution shifts beyond threshold
- Supervised drift: when labels arrive (even delayed), compare live accuracy vs. training accuracy
- Drift response policy: retrain on fresh data, expand training window, or trigger human review
- Log drift metrics alongside model predictions for retrospective analysis

## Inference Pipeline
- Warm-up: pre-load models and caches before routing traffic — cold-start latency is unacceptable
- Timeout policy: if inference exceeds SLA, return fallback prediction (cached, rule-based, or default)
- Feature missing handling: define default values for each feature — never fail silently
- Batch micro-batching: accumulate requests for short window (10-50ms) for GPU efficiency
- Shadow mode: run new model alongside production model, log both predictions, compare before switching

## Evaluation for Streaming Systems
- **Prequential evaluation**: evaluate on each sample BEFORE using it for training (test-then-train)
- Sliding window metrics: report accuracy on recent window (e.g., last 1 hour, last 1 day)
- Throughput: events processed per second — must exceed peak ingestion rate
- End-to-end latency: from event creation to prediction output — measure p50, p95, p99
- Backpressure metrics: monitor queue depth to detect when processing can't keep up with input

## Common Pitfalls
- Training/serving skew: feature computation differs between offline pipeline and streaming pipeline
- Clock skew between systems causing temporal feature corruption
- Unbounded state: streaming aggregations that grow indefinitely → OOM
- Testing only with steady-state load — also test burst traffic, recovery after failures, and data gaps
- Assuming events arrive in order — they don't in distributed systems; handle out-of-order explicitly
