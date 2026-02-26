# Snippet: Evaluation Framework

## Domain Context
Systematic evaluation across the full ML lifecycle: offline metrics, online experiments, and monitoring.
If you can't measure it rigorously, you can't improve it reliably.

## Evaluation Design Principles
- Define metrics and success criteria **before** building the model — never after seeing results
- Every model must be compared against at least one baseline (heuristic, previous model, or random)
- Separate evaluation into layers: component-level → pipeline-level → end-to-end → user-facing
- Evaluation code is production code — it must be tested, reviewed, and versioned

## Offline Evaluation
- Holdout test set: must be created ONCE and never used during development (only final evaluation)
- Development eval: use a separate validation set for iterative improvement
- Report metrics with confidence intervals: bootstrap with ≥1000 resamples
- Segment analysis is mandatory: break metrics by key dimensions (user type, data source, difficulty)
- Statistical significance: use paired tests (McNemar, Wilcoxon) to compare models, not just point estimates

## Online Evaluation (A/B Testing)
- Define primary metric, guardrail metrics, and minimum detectable effect (MDE) before launch
- Sample size calculation: run power analysis to determine required traffic and duration
- Minimum experiment duration: 1 full business cycle (usually 1-2 weeks) to capture temporal effects
- Check for Sample Ratio Mismatch (SRM) — if traffic split is unexpected, results are invalid
- Guardrail metrics: latency p99, error rate, revenue — must not degrade beyond threshold

## Offline → Online Alignment
- Track and document the gap between offline metrics and online outcomes
- Build a mapping table: which offline metrics best predict online wins
- If offline and online metrics consistently disagree, the offline eval is broken — fix it
- Replay analysis: use logged production data to backtest new models before A/B deployment

## Evaluation Datasets
- Minimum size: 500+ examples for reliable metric estimation; 1000+ for segment analysis
- Update eval sets periodically — data drift makes static eval sets misleading over time
- Include adversarial/hard examples: 10-20% of eval set should be known difficult cases
- Never use eval data for any form of training, fine-tuning, or prompt optimization
- Version and hash eval datasets — any change must be documented and metrics rebased

## Human Evaluation
- Required for: any generative/creative output, safety-critical applications, subjective quality
- Use structured rubrics with 3-5 point scales — free-form feedback is supplementary, not primary
- Minimum 3 evaluators per item; report IAA (Inter-Annotator Agreement)
- Blind evaluation: evaluators should not know which model produced which output
- LLM-as-judge: acceptable for development iteration, but calibrate against human ratings (report agreement ≥80%)

## Reporting Standards
- Always report: metric name, value, confidence interval, sample size, evaluation date
- Format: `metric: value ± CI (n=sample_size)`
- Include both primary metric AND cost/efficiency metrics (latency, token usage, compute cost)
- Negative results are results — document what was tried and why it didn't work
- Evaluation dashboard: automated, always up-to-date, accessible to the full team

## Common Pitfalls
- Overfitting to the eval set: if you look at eval results and iterate, you're implicitly training on it
- Metric gaming: optimizing a proxy metric that diverges from actual user value
- Cherry-picking: showing only the metrics that look good — report all pre-defined metrics
- Ignoring variance: single-run results on small eval sets are unreliable
- Stale eval sets: production data evolves but eval set stays frozen — revisit quarterly
